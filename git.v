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
import json
import encoding.base64

import net.http { Method, Request, Response }

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

struct ReleaseBody {
	target_commitish string [required]
	tag_name         string [required]
	name             string [required]
	body             string [required]
	draft            bool   [required]
	prerelease       bool   [required]
}

pub fn get_remote_info() ?GitRemote {
	res := os.execute_or_panic('git remote get-url --all origin')
	out := res.output.trim_space().split('\n')
	uri := out[0]

	mut protocol := Protocol.ssh
	if uri.starts_with('http://') { protocol = Protocol.http }
	if uri.starts_with('https://') { protocol = Protocol.https }

	xtract := fn (p Protocol, uri string) (string, string) {
		mf := errmsg('malformed remote git URI; got "$uri"')

		if !uri.contains('/') { panic(mf) }

		mut user := ''
		mut repo := ''

		if p == Protocol.ssh {
			if !uri.contains(':') { panic(mf) }

			mut segs := uri.split(':')
			if segs.len != 2 { panic(mf) }

			segs = segs[1].split('/')
			if segs.len != 2 { panic(mf) }

			user = segs[0]
			repo = segs[1]

		}
		else {
			segs := uri.split('/')
			if segs.len != 5 { panic(mf) }

			user = segs[3]
			repo = segs[4]
		}

		return user, repo[0 .. repo.len - 4] // removes ".git" from the repo name
	}

	user, repo := xtract(protocol, uri)
	return GitRemote{protocol, uri, user, repo}
}

pub fn get_repo_changelog(user string, repo string) ?map[string]string {
	nt := errmsg('no tags found')

	mut res := os.execute_or_panic('git tag --sort=committerdate')
	mut tags := res.output.split('\n')

	if tags.len <= 1 { panic(nt) }
	tags.pop()

	if tags[0].trim_space() == '' { panic(nt) }
	last_ref := tags[tags.len - 1].trim_space()

	mut sec_last_ref := 'master'
	if tags.len >= 2 {
		sec_last_ref = tags[tags.len - 2].trim_space()
	}

	info('generating changelog from ${emph(sec_last_ref)} to ${emph(last_ref)}')
	res = os.execute_or_panic('git log --pretty=oneline ${sec_last_ref}..${last_ref}')

	mut logs := res.output.split('\n')
	if logs.len <= 1 { panic('no entries') }
	logs.pop()

	mut changelog := ''
	for i := 0; i < logs.len; i++ {
		log := logs[i]

		sha := log[0 .. 40]
		msg := log[41 .. log.len]

		commit_url := 'https://github.com/$user/$repo/commit'
		changelog += '<li><a href="$commit_url/$sha"><code>${sha[0 .. 7]}</code></a> $msg</li>'
	}

	changelog = '<h1>Changelog</h1><ul>$changelog</ul>'
	return map{ 'content': changelog, 'tag': last_ref }
}

pub fn create_release(remote GitRemote, token string, changelog map[string]string) ?Response {
	payload := ReleaseBody{
        target_commitish: 'master'
        tag_name:         changelog['tag']
        name:             changelog['tag']
        body:             changelog['content']
        draft:            false
        prerelease:       false
	}

	mut req := Request{
		method: Method.post,
		url:    'https://api.github.com/repos/$remote.user/$remote.repo/releases',
		data:   json.encode(payload)
	}

	auth_h_v := 'Basic ' + base64.encode_str('$remote.user:$token')
	req.add_header('Accept', 'application/vnd.github.v3+json')
	req.add_header('Authorization', auth_h_v)

	res := req.do() or { panic(errmsg('error while making request; got "$err.msg"')) }
	return res
}
