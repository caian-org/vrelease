// vi: ft=vlang

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

fn is_valid_file(filepath string) bool {
	return os.is_file(filepath) && os.is_readable(filepath)
}

fn resolve_path(p string) ?string {
	if os.is_abs_path(p) {
		if is_valid_file(p) {
			return p
		}

		panic('file path "$p" does not exists or cannot be read')
	}

	resolved_p := os.real_path(os.join_path(os.getwd(), p))
	if is_valid_file(resolved_p) {
		return resolved_p
	}

	panic('resolved path "$resolved_p" does not exists or cannot be read')
}

fn start_msg(no_color bool, now time.Time, md map[string]string) {
	vr_hi := "${md['program_name']} ${md['program_version']} ${md['target_kernel']}/${md['target_arch']}"
	vr_at := 'program has started @ ${now.str()}'

	println('')
	if no_color {
		println(vr_hi)
		println(vr_at)
	}
	else {
		println(term.bold(vr_hi))
		println(term.gray(vr_at))
	}
	println('')
}

fn main() {
	meta_d     := get_meta_d()
	started_at := time.now()
	mut cli    := build_cli(meta_d)
	cli.act()

	debug_mode := cli.is_set('debug')
	no_color   := cli.is_set('no-color')
	limit      := cli.get_limit()
	annexes    := cli.get_annexes()

	pp := PrettyPrint{ debug_mode, no_color }
	start_msg(no_color, started_at, meta_d)

	pp.debug('flag_debug_mode = $debug_mode')
	pp.debug('flag_no_color = $no_color')
	pp.debug('flag_limit = $limit')
	pp.debug('flag_attach = $annexes')

	mut resolved_annexes := []string{}
	if annexes.len > 0 {
		for i := 0; i < annexes.len; i++ {
			p := resolve_path(annexes[i]) or { panic(pp.errmsg(err.msg)) }
			resolved_annexes << p
		}
	}

	pp.debug('resolved_annexes = $resolved_annexes')

	env := os.environ()
	mut gh_token := ''
	mut gh_token_is_undef := true
	gh_token_var := 'VRELEASE_GITHUB_TOKEN'

	if gh_token_var in env {
		gh_token = env[gh_token_var].trim_space()
		if gh_token != '' { gh_token_is_undef = false }
	}

	if gh_token_is_undef {
		panic(pp.errmsg('environment variable $gh_token_var is undefined'))
	}

	mut git := build_git(pp, debug_mode, limit)
	git.get_remote_info() or { panic(err.msg) }
	git.get_repo_changelog() or { panic(err.msg) }

	release_res := git.create_release(gh_token) or { panic(err.msg) }
	if release_res.status_code != 201 {
		panic(pp.errmsg('failed with code $release_res.status_code; << $release_res.text >>'))
	}

	pp.info('available @ ${pp.href(git.get_release_page_url())}')

	duration := time.now() - started_at
	pp.info('done; took ${pp.emph(duration.milliseconds().str() + "ms")}')
}
