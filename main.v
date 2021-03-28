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

fn start_msg(now time.Time, md map[string]string) {
	println('')
	println(term.bold("${md['program_name']} ${md['program_version']} ${md['target_kernel']}/${md['target_arch']}"))
	println(term.gray('program has started @ ${now.str()}'))
	println('')
}

fn get_token() ?string {
	key := 'VRELEASE_GITHUB_TOKEN'
	env := os.environ()

	if key in env { return env[key] }
	panic(errmsg('environment variable $key is undefined'))
}

fn main() {
	meta_d := get_meta_d()

	mut cli := build_cli(meta_d)
	cli.act()

	started_at := time.now()
	start_msg(started_at, meta_d)

	gh_token := get_token() or { panic(err.msg) }
	remote := get_remote_info() or { panic(err.msg) }

	info('executing on repository ${emph(remote.repo)} of user ${emph(remote.user)}')
	changelog := get_repo_changelog(remote.user, remote.repo) or { panic(err.msg) }

	info('creating release')
	release_res := create_release(remote, gh_token, changelog) or { panic(err.msg) }

	if release_res.status_code != 201 {
		panic(errmsg('failed with code $release_res.status_code; << $release_res.text >>'))
	}

	duration := time.now() - started_at
	info('done; took ${emph(duration.milliseconds().str() + "ms")}')
}
