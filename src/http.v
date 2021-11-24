module main

import net.http


struct HTTPCaller {
	pp      PrettyPrint [required]
	url     string      [required]
mut:
	headers http.Header
}

struct HTTPCallerResponse {
	code int
	body string
}

fn build_http_caller(pp PrettyPrint, url string) HTTPCaller {
	return HTTPCaller{ pp, url, http.new_header() }
}

fn (mut h HTTPCaller) add_header(key string, value string) {
	h.headers.add_custom(key, value) or {
		panic(h.pp.errmsg('got invalid header key "$key"'))
	}
}

fn (mut h HTTPCaller) post_json(data string) ?HTTPCallerResponse {
	h.add_header('Content-Type', 'application/json')

	req := http.Request{
		url:    h.url,
		header: h.headers,
		method: http.Method.post,
		data:   data,
	}

	res := req.do() or { panic(err) }
	return HTTPCallerResponse{ res.status_code, res.text }
}

fn (mut h HTTPCaller) post_file(a Annex) ?HTTPCallerResponse {
	data := a.read_data() or { panic(err) }

	c := http.PostMultipartFormConfig{
		header: h.headers,
		files: {
			'asset': [
				http.FileData{
					filename: a.filename,
					content_type: 'application/octet-stream',
					data: data.bytestr()
				}
			]
		}
	}

	res := http.post_multipart_form(h.url, c) or { panic(err) }
	return HTTPCallerResponse{ res.status_code, res.text }
}
