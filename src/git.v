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


enum Protocol {
	http
	https
	ssh
}

struct GitRemote {
	protocol Protocol = Protocol.ssh
	uri      string
	user     string
	repo     string
}

struct ReleaseBody {
	target_commitish string [required]
	tag_name         string [required]
	name             string [required]
	body             string [required]
	draft            bool   [required]
	prerelease       bool   [required]
}

struct ReleaseResponse {
	// there are more fields, but these are the ones that matters for now
	html_url string
	id       int
}

struct Git {
	pp    PrettyPrint [required]
	limit int         [required]
mut:
	remote     GitRemote
	changelog  map[string]string
	release_id int
}

fn git_build(pp PrettyPrint, limit int) Git {
	return {
		pp:        pp,
		limit:     limit
		remote:    GitRemote{}
		changelog: map{}
	}
}

fn (mut g Git) get_remote_info() ? {
	res := os.execute_or_panic('git remote get-url --all origin')
	g.pp.debug('git_remote_info', '${json.encode(res.output)}')

	out := res.output.trim_space().split('\n')
	uri := out[0]
	g.pp.debug('git_chosed_uri', '$uri')

	mut protocol := Protocol.ssh
	if uri.starts_with('http://') { protocol = Protocol.http }
	if uri.starts_with('https://') { protocol = Protocol.https }
	g.pp.debug('git_detected_protocol', '$protocol')

	xtract := fn (g Git, p Protocol, uri string) (string, string) {
		mf := g.pp.errmsg('malformed remote git URI; got "$uri"')
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
		} else {
			segs := uri.split('/')
			if segs.len != 5 { panic(mf) }

			user = segs[3]
			repo = segs[4]
		}

		return user, repo[0 .. repo.len - 4] // removes ".git" from the repo name
	}

	user, repo := xtract(g, protocol, uri)
	g.remote = GitRemote{protocol, uri, user, repo}
	g.pp.info('executing on repository ${g.pp.emph(repo)} of user ${g.pp.emph(user)}')
}

fn (mut g Git) get_repo_changelog() ? {
	nt := g.pp.errmsg('no tags found')

	mut res := os.execute_or_panic('git tag --sort=committerdate')
	g.pp.debug('git_tags_sorted', '${json.encode(res.output)}')

	mut tags := res.output.split('\n')
	if tags.len <= 1 { panic(nt) }
	tags.pop()

	if tags[0].trim_space() == '' { panic(nt) }
	last_ref := tags[tags.len - 1].trim_space()
	g.pp.debug('git_found_tags', '$tags')

	mut sec_last_ref := 'master'
	if tags.len >= 2 {
		sec_last_ref = tags[tags.len - 2].trim_space()
	}

	g.pp.info('generating changelog from ${g.pp.emph(sec_last_ref)} to ${g.pp.emph(last_ref)}')
	res = os.execute_or_panic('git log --pretty=oneline ${sec_last_ref}..${last_ref}')

	mut logs := res.output.split('\n')
	if logs.len <= 1 { panic('no entries') }
	logs.pop()
	g.pp.debug('git_logs', '\n$logs')

	mut limit := if logs.len > g.limit { g.limit } else { logs.len }
	limit = if g.limit == -1 { logs.len } else { limit }
	g.pp.debug('git_chosed_commit_limit', '$limit')

	mut changelog := ''
	for i := 0; i < limit; i++ {
		log := logs[i]
		sha := log[0 .. 40]
		msg := log[41 .. log.len]

		commit_url := 'https://github.com/$g.remote.user/$g.remote.repo/commit'
		changelog += '<li><a href="$commit_url/$sha"><code>${sha[0 .. 7]}</code></a> $msg</li>'
	}

	mut ommited_commit_msg := ''
	omitted_commits := logs.len - limit
	if omitted_commits > 0 {
		ommited_commit_msg = '<i>$omitted_commits commits were ommited from this list</i><br><br>'
	}

	changelog = '<h1>Changelog</h1>'
		+ ommited_commit_msg
		+ '<ul>$changelog</ul>'

	g.pp.debug('generated_changelog', '\n$changelog')
	g.changelog = map{ 'content': changelog, 'tag': last_ref }
}

fn (g Git) get_call(url string, token string, data string) CURLCall {
	mut call := build_curl(g.pp, url, data)
	call.add_header('Accept', 'application/vnd.github.v3+json')
	call.add_header('Authorization', 'token ' + token)
	return call
}

fn (g Git) upload_asset(token string, filepath string) ?CURLResponse {
	url := 'https://uploads.github.com/repos'
		+ '/$g.remote.user/$g.remote.repo'
		+ '/releases/$g.release_id/assets?name=${os.base(filepath)}'

	g.pp.debug('git_upload_asset_url', '$url')

	mut req := g.get_call(url, token, filepath)
	res := req.post_multipart() or {
		panic(g.pp.errmsg('error while making request; got "$err.msg"'))
	}

	g.pp.debug('git_upload_res_status_code', '$res.code')
	g.pp.debug('git_upload_res_text', '\n$res.body')
	return res
}

fn (mut g Git) create_release(token string) ?(CURLResponse, ReleaseResponse) {
	g.pp.info_nl('creating release... ')
	payload := ReleaseBody{
		target_commitish: 'master'
		tag_name:   g.changelog['tag']
		name:       g.changelog['tag']
		body:       g.changelog['content']
		draft:      false
		prerelease: false
	}

	url  := 'https://api.github.com/repos/$g.remote.user/$g.remote.repo/releases'
	data := json.encode(payload)
	g.pp.debug('git_release_url', '$url')
	g.pp.debug('git_release_req_data', '$data')

	// should I escape each special character so the shell doesn´t complain
	// or write to a file and pass to CURL via STDIN?
	escaped_data := data.split('')
		.map(fn (s string) string {
			return match s {
				'/'  { '\/' }
				'>'  { '\>' }
				'<'  { '\<' }
				'['  { '\[' }
				']'  { '\]' }
				'('  { '\(' }
				')'  { '\)' }
				';'  { '\;' }
				'|'  { '\|' }
				'^'  { '\^' }
				'~'  { '\~' }
				'!'  { '\!' }
				'?'  { '\?' }
				'#'  { '\#' }
				'$'  { '\$' }
				'%'  { '\%' }
				'&'  { '\&' }
				'*'  { '\*' }
				'.'  { '\.' }
				'`'  { '\`' }
				'"'  { '\\"' }
				'\\' { '\\\\' }
				else { s }
			}
		})
		.join('')

	mut req := g.get_call(url, token, escaped_data)
	res := req.post_json() or {
		panic(g.pp.errmsg('error while making request; got "$err.msg"'))
	}

	g.pp.debug('git_release_res_status_code', '$res.code')
	g.pp.debug('git_release_res_text', '\n$res.body')
	res_p := json.decode(ReleaseResponse, res.body) or {
		panic(g.pp.errmsg('could not encode request response; got "$err.msg"'))
	}

	g.release_id = res_p.id
	return res, res_p
}
