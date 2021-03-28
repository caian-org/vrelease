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
import encoding.base64

import net.http { Method, Request }

/* data structures */

enum Protocol {
	http
	https
	ssh
}

struct GitRemote {
	protocol Protocol [required]

	uri  string [required]
	user string [required]
	repo string [required]
}

/* utils */

fn info(txt string) {
	print(term.bright_blue('=> ') + txt + '\n')
}

fn errmsg(txt string) string {
	return term.bold(term.bright_red('ERROR: ')) + txt
}

/* running "phases" */

fn start_msg() {
	now_ts := time.now().str()
	program_version, target_arch, target_kernel := metad()

	println('')
	println(term.bold('vrelease $program_version $target_kernel/$target_arch'))
	println(term.gray('program has started @ ${now_ts}'))
	println('')
}

fn get_token() ?string {
	key := 'VRELEASE_GITHUB_TOKEN'
	env := os.environ()

	if key in env {
		return env[key]
	}

	panic(errmsg('environment variable $key is undefined'))
}

fn get_remote_info() ?GitRemote {
	res := os.execute_or_panic('git remote get-url --all origin')
	uri := res.output.trim_space()

	mut protocol := Protocol.ssh
	if uri.starts_with('http://') {
		protocol = Protocol.http
	}

	if uri.starts_with('https://') {
		protocol = Protocol.https
	}

	xtract := fn (p Protocol, uri string) (string, string) {
		mf := errmsg('malformed remote git URI; got "$uri"')

		if !uri.contains('/') {
			panic(mf)
		}

		mut user := ''
		mut repo := ''

		if p == Protocol.ssh {
			if !uri.contains(':') {
				panic(mf)
			}

			mut segs := uri.split(':')
			if segs.len != 2 {
				panic(mf)
			}

			segs = segs[1].split('/')
			if segs.len != 2 {
				panic(mf)
			}

			user = segs[0]
			repo = segs[1]

		}
		else {
			segs := uri.split('/')
			if segs.len != 5 {
				panic(mf)
			}

			user = segs[3]
			repo = segs[4]
		}

		return user, repo[0 .. repo.len - 4] // removes ".git" from the repo name
	}

	user, repo := xtract(protocol, uri)
	return GitRemote{protocol, uri, user, repo}
}

fn main() {
	emph := fn(m string) string { return term.green(m) }

	start_msg()

	gh_token := get_token() or { panic(err.msg) }
	remote := get_remote_info() or { panic(err.msg) }

	info('executing on project "${emph(remote.repo)}" of account "${emph(remote.user)}"')
	auth_h_v := 'Basic ' + base64.encode_str('$remote.user:$gh_token')

	mut req := Request{
		method: Method.get,
		url: 'https://api.github.com/repos/$remote.user/$remote.repo/releases'
	}

	req.add_header('Accept', 'application/vnd.github.v3+json')
	req.add_header('Authorization', auth_h_v)

	res := req.do() or {
		panic('ooops')
	}

	println(res.status_code)
	println(res.text)
}
