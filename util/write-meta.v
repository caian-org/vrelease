// vi: ft=vlang

import os
import term

fn errmsg(txt string) string {
	return term.bold(term.bright_red('ERROR: ')) + txt
}

fn get_last_tag() string {
	res := os.execute('git tag --sort=committerdate')
	tags := res.output.split('\n')

	if tags.len > 0 {
		last_t := tags[0]

		if last_t.trim_space() != '' {
			return last_t
		}
	}

	return 'UNRELEASED'
}

fn main() {
	dest_f := './meta.v'
	os.rm(dest_f) or {}

	mut meta_c := os.read_file('./_meta.t') or {
		panic(errmsg('could not open meta template'))
	}

	uname := os.uname()

	meta_c = meta_c
		.replace(':tag', get_last_tag())
		.replace(':arch', uname.machine)
		.replace(':kernel', uname.sysname)

	meta_c = 'module main\n\n'
		+ '/* this file is auto-generated */\n'
		+ meta_c

	os.write_file(dest_f, meta_c) or {
		panic(errmsg('could not write meta file'))
	}
}
