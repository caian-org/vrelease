module main

import os
import json
import time


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
	release    map[string]string
	release_id int
}

fn git_build(pp PrettyPrint, limit int) Git {
	return Git{
		pp:      pp,
		limit:   limit
		remote:  GitRemote{}
		release: map{}
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
		} else {
			segs := uri.split('/')
			if segs.len != 5 {
				panic(mf)
			}

			user = segs[3]
			repo = segs[4]
		}

		if repo.ends_with('.git') {
			repo = repo[0 .. repo.len - 4]
		}

		return user, repo
	}

	user, repo := xtract(g, protocol, uri)
	g.remote = GitRemote{protocol, uri, user, repo}
	g.pp.info('executing on repository ${g.pp.emph(repo)} of user ${g.pp.emph(user)}')
}

fn (mut g Git) gen_changelog(with_description bool) ? {
	nt := g.pp.errmsg('no tags found')

	mut res := os.execute_or_panic('git tag --sort=-creatordate')
	g.pp.debug('git_tags_sorted', '${json.encode(res.output)}')

	mut tags := res.output.split('\n')
	if tags.len <= 1 {
		panic(nt)
	}

	tags.pop()
	if tags[0].trim_space() == '' {
		panic(nt)
	}

	current_ref := tags[0].trim_space()
	g.pp.debug('git_found_tags', '$tags')

	mut last_ref := 'master'
	if tags.len >= 2 {
		last_ref = tags[1].trim_space()
	}

	mut content := ''

	g.pp.info('generating changelog from ${g.pp.emph(last_ref)} to ${g.pp.emph(current_ref)}')
	res = os.execute_or_panic('git log --pretty=oneline ${last_ref}..${current_ref}')

	mut logs := res.output.split('\n')
	if logs.len <= 1 {
		panic('no entries')
	}

	logs.pop()
	g.pp.debug('git_logs', '\n$logs')

	mut release_title := current_ref
	if with_description {
		res = os.execute_or_panic('git log -1 --pretty=%B $current_ref')
		g.pp.debug('git_last_commit', '${json.encode(res.output)}')

		mut lines := res.output.split('\n')
		release_title = lines[0].trim(' ')
		g.pp.debug('git_release_title', release_title)

		lines.delete(0)
		for {
			if lines.len > 0 && lines.last().trim(' ') == '' {
				lines.pop()
				continue
			}

			break
		}

		if lines.len > 0 {
			content = '<h1>Description</h1>' + lines.join('\n')
		}
	}

	mut limit := if logs.len > g.limit { g.limit } else { logs.len }
	limit = if g.limit == -1 { logs.len } else { limit }
	g.pp.debug('git_chosed_commit_limit', '$limit')

	mut items := ''
	for i := 0; i < limit; i++ {
		log := logs[i]
		sha := log[0 .. 40]
		msg := log[41 .. log.len]

		commit_url := 'https://github.com/$g.remote.user/$g.remote.repo/commit'
		items += '<li><a href="$commit_url/$sha"><code>${sha[0 .. 7]}</code></a> $msg</li>'
	}

	mut ommited_commit_msg := ''
	omitted_commits := logs.len - limit
	if omitted_commits > 0 {
		ommited_commit_msg = '<i>$omitted_commits commits were ommited from this list</i><br><br>'
	}

	content += '<h1>Changelog</h1>'
		+ ommited_commit_msg
		+ '<ul>$items</ul>'

	g.pp.debug('generated_changelog', '\n$content')
	g.release = map{
		'content': content,
		'tag': current_ref,
		'title': release_title,
	}
}

fn (mut g Git) gen_checksum(annexes []Annex) {
	mut annex_sec := '<h1>Checksum (SHA256)</h1>'

	mut checksum_items := ''
	for annex in annexes {
		checksum_items += '<li>${annex.filename} (<code>${annex.checksum}</code>)</li>'
	}

	annex_sec += '<ul>$checksum_items</ul>'
	g.pp.debug('generated_checksum', '\n$annex_sec')
	g.release['content'] += annex_sec
}

fn (g Git) get_call(url string, token string, data string) CURLCall {
	mut call := build_curl(g.pp, url, data)
	call.add_header('Accept', 'application/vnd.github.v3+json')
	call.add_header('Authorization', 'token ' + token)

	return call
}

fn (g Git) upload_asset(token string, annex Annex) ?CURLResponse {
	url := 'https://uploads.github.com/repos'
		+ '/$g.remote.user/$g.remote.repo'
		+ '/releases/$g.release_id/assets?name=$annex.filename'

	g.pp.debug('git_upload_asset_url', '$url')

	mut req := g.get_call(url, token, annex.filepath)
	res := req.post_multipart() or {
		panic(g.pp.errmsg('error while making request; got "$err.msg"'))
	}

	g.pp.debug('git_upload_res_status_code', '$res.code')
	g.pp.debug('git_upload_res_text', '\n$res.body')

	return res
}

fn (mut g Git) create_release(token string, is_pre_release bool) ?(CURLResponse, ReleaseResponse) {
	g.pp.info_nl('creating release... ')
	payload := ReleaseBody{
		target_commitish: 'master'
		tag_name:   g.release['tag']
		name:       g.release['title']
		body:       g.release['content']
		prerelease: is_pre_release
		draft:      false
	}

	url  := 'https://api.github.com/repos/$g.remote.user/$g.remote.repo/releases'
	data := json.encode(payload)
	g.pp.debug('git_release_url', '$url')
	g.pp.debug('git_release_req_data', '$data')

	tmp_file := os.join_path(os.getwd(), time.now().unix_time_milli().str())
	os.write_file(tmp_file, data) or {
		panic(g.pp.errmsg('could not write to "$tmp_file"; got "$err.msg"'))
	}

	g.pp.debug('release_payload_tmp_file', tmp_file)

	mut req := g.get_call(url, token, tmp_file)
	res := req.post_json() or {
		panic(g.pp.errmsg('error while making request; got "$err.msg"'))
	}

	os.rm(tmp_file) or {
		panic(g.pp.errmsg('could not remove temp file "$tmp_file"; got "$err.msg"'))
	}

	g.pp.debug('git_release_res_status_code', '$res.code')
	g.pp.debug('git_release_res_text', '\n$res.body')
	res_p := json.decode(ReleaseResponse, res.body) or {
		panic(g.pp.errmsg('could not encode request response; got "$err.msg"'))
	}

	g.release_id = res_p.id

	return res, res_p
}
