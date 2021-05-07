module main

import os
import term
import time


fn start_msg(no_color bool, now time.Time, md map[string]string) {
	p_name    := md['program_name']
	p_version := md['program_version']
	t_kernel  := md['target_kernel']
	t_arch    := md['target_arch']
	vr_hi     := '$p_name $p_version $t_kernel/$t_arch'
	vr_at     := 'program has started @ ${now.str()}'

	mut m := []string{}
	if no_color {
		m << vr_hi
		m << vr_at
	} else {
		m << term.bold(vr_hi)
		m << term.gray(vr_at)
	}
	println('\n${m.join('\n')}\n')
}

fn get_github_token() (bool, string) {
	env := os.environ()
	mut gh_token := ''
	mut gh_token_is_undef := true
	gh_token_var := 'VRELEASE_GITHUB_TOKEN'

	if gh_token_var in env {
		gh_token = env[gh_token_var].trim_space()
		if gh_token != '' { gh_token_is_undef = false }
	}

	return gh_token_is_undef, gh_token
}

fn check_dependency(binary string) ?string {
	r := os.execute('which $binary')
	if r.exit_code != 0 {
		return error('could not find required dependency "$binary"')
	}

	return r.output.trim_space()
}

fn main() {
	started_at := time.now()
	meta_d     := get_meta_d()

	mut cli   := cli_build(meta_d)
	must_exit := cli.act()
	if must_exit { exit(0) }

	debug_mode := cli.is_set('debug')
	no_color   := cli.is_set('no-color')
	add_sum    := cli.is_set('add-checksum')
	add_descr  := cli.is_set('add-description')
	pre_rel    := cli.is_set('pre-release')
	limit      := cli.get_limit()
	annexes    := cli.get_annexes()

	pp := PrettyPrint{ debug_mode, no_color }
	pp.debug('flag_debug_mode', '$debug_mode')
	pp.debug('flag_no_color', '$no_color')
	pp.debug('flag_add_checksum', '$add_sum')
	pp.debug('flag_add_description', '$add_descr')
	pp.debug('flag_pre_release', '$pre_rel')
	pp.debug('flag_limit', '$limit')
	pp.debug('flag_attach', '$annexes')
	start_msg(no_color, started_at, meta_d)

	git_bin_path  := check_dependency('git') or { panic(pp.errmsg(err.msg)) }
	curl_bin_path := check_dependency('curl') or { panic(pp.errmsg(err.msg)) }
	pp.debug('git_binary_path', '$git_bin_path')
	pp.debug('curl_binary_path', '$curl_bin_path')

	mut resolved_annexes := []Annex{}
	for annex in annexes {
		resolved_p := file_resolve_path(annex) or { panic(pp.errmsg(err.msg)) }

		mut sum := ''
		if add_sum {
			sum = file_sha256_sum(resolved_p) or { panic(pp.errmsg(err.msg)) }
		}

		resolved_annexes << Annex{
			filename: os.base(resolved_p)
			filepath: resolved_p,
			checksum: sum,
		}
	}

	pp.debug('resolved_annexes', '$resolved_annexes')

	gh_token_is_undef, gh_token := get_github_token()
	if gh_token_is_undef {
		panic(pp.errmsg('github token is undefined'))
	}

	mut git := git_build(pp, limit)
	git.get_remote_info() or { panic(err.msg) }
	git.gen_changelog(add_descr) or { panic(err.msg) }
	if add_sum { git.gen_checksum(resolved_annexes) }

	release_res, release := git.create_release(gh_token, pre_rel) or { panic(err.msg) }
	if release_res.code != 201 {
		println(pp.fail('failed'))
		panic(pp.errmsg('failed with code $release_res.code;\n\n$release_res.body'))
	}

	println(pp.success('succeeded'))
	pp.info('release id is ${pp.emph(release.id.str())}')
	pp.info('available @ ${pp.href(release.html_url)}')

	if add_sum {
		pp.info('checksums calculated')
	}

	for annex in resolved_annexes {
		pp.info_nl('uploading asset "$annex.filename"... ')
		git.upload_asset(gh_token, annex) or {
			println(pp.fail('failed'))
			panic(pp.errmsg(err.msg))
		}

		println(pp.success('succeeded'))
	}

	duration := time.now() - started_at
	pp.info('done; took ${pp.emph(duration.milliseconds().str() + 'ms')}\n')
}
