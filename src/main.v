/*
	The person who associated a work with this deed has dedicated the work to the
	public domain by waiving all of his or her rights to the work worldwide under
	copyright law, including all related and neighboring rights, to the extent
	allowed by law.

	You can copy, modify, distribute and perform the work, even for commercial
	purposes, all without asking permission.

	AFFIRMER OFFERS THE WORK AS-IS AND MAKES NO REPRESENTATIONS OR WARRANTIES OF
	ANY KIND CONCERNING THE WORK, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,
	INCLUDING WITHOUT LIMITATION WARRANTIES OF TITLE, MERCHANTABILITY, FITNESS
	FOR A PARTICULAR PURPOSE, NON INFRINGEMENT, OR THE ABSENCE OF LATENT OR OTHER
	DEFECTS, ACCURACY, OR THE PRESENT OR ABSENCE OF ERRORS, WHETHER OR NOT
	DISCOVERABLE, ALL TO THE GREATEST EXTENT PERMISSIBLE UNDER APPLICABLE LAW.

	For more information, please see
	<http://creativecommons.org/publicdomain/zero/1.0/>
*/

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
	limit      := cli.get_limit()
	annexes    := cli.get_annexes()

	pp := PrettyPrint{ debug_mode, no_color }
	pp.debug('flag_debug_mode', '$debug_mode')
	pp.debug('flag_no_color', '$no_color')
	pp.debug('flag_limit', '$limit')
	pp.debug('flag_attach', '$annexes')
	start_msg(no_color, started_at, meta_d)

	git_bin_path  := check_dependency('git') or { panic(pp.errmsg(err.msg)) }
	curl_bin_path := check_dependency('curl') or { panic(pp.errmsg(err.msg)) }
	pp.debug('git_binary_path', '$git_bin_path')
	pp.debug('curl_binary_path', '$curl_bin_path')

	mut resolved_annexes := []string{}
	for annex in annexes {
		resolved_annexes << file_resolve_path(annex) or { panic(pp.errmsg(err.msg)) }
	}

	pp.debug('resolved_annexes', '$resolved_annexes')

	gh_token_is_undef, gh_token := get_github_token()
	if gh_token_is_undef {
		panic(pp.errmsg('github token is undefined'))
	}

	mut git := git_build(pp, limit)
	git.get_remote_info() or { panic(err.msg) }
	git.get_repo_changelog() or { panic(err.msg) }

	release_res, release := git.create_release(gh_token) or { panic(err.msg) }
	if release_res.code != 201 {
		println(pp.fail('failed'))
		panic(pp.errmsg('failed with code $release_res.code;\n\n$release_res.body'))
	}

	println(pp.success('succeed'))
	pp.info('release id is ${pp.emph(release.id)}')
	pp.info('available @ ${pp.href(release.html_url)}')

	for annex in resolved_annexes {
		pp.info_nl('uploading asset "${os.base(annex)}"... ')
		git.upload_asset(gh_token, annex) or {
			println(pp.fail('failed'))
			panic(pp.errmsg(err.msg))
		}

		println(pp.success('succeed'))
	}

	duration := time.now() - started_at
	pp.info('done; took ${pp.emph(duration.milliseconds().str() + 'ms')}')
}
