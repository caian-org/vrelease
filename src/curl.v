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


struct CURLCall {
	pp    PrettyPrint [required]
	url   string      [required]
	filep string      [required]
mut:
	headers map[string]string
}

struct CURLResponse {
	code int
	body string
}

fn build_curl(pp PrettyPrint, url string, filep string) CURLCall {
	return { pp: pp, url: url, filep: filep, headers: map{} }
}

fn (mut c CURLCall) add_header(key string, value string) {
	c.headers[key] = value
}

fn (c CURLCall) build_cmd() string {
	mut header_flags := []string{}
	for header_name, header_value in c.headers {
		header_flags << '-H "$header_name: $header_value"'
	}

	return 'curl -s -w "%{http_code}" -X POST '
		+ header_flags.join(' ')
		+ ' $c.url --data-binary @"$c.filep"'
}

fn (c CURLCall) run(cmd string) ?CURLResponse {
	res  := os.execute_or_panic(cmd)
	segs := res.output.trim_space().split('\n')

	return CURLResponse{
		code: segs.pop().int()
		body: segs.join('\n')
	}
}

fn (mut c CURLCall) post_json() ?CURLResponse {
	c.headers['Content-Type'] = 'application/json'
	return c.run(c.build_cmd())
}

fn (mut c CURLCall) post_multipart() ?CURLResponse {
	c.headers['Content-Type'] = 'application/octet-stream'
	return c.run(c.build_cmd())
}
