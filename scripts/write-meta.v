import os
import term

fn errmsg(txt string) string {
	return term.bold(term.bright_red('ERROR: ')) + txt
}

fn get_last_tag() ?string {
	res := os.execute_or_panic('git tag --sort=committerdate')
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
	here   := os.getwd()
	meta_f := os.join_path(here, '_meta')
	meta_t := os.join_path(here, 'meta.v')

	last_tag := get_last_tag() or {
		panic(errmsg('could not get the last git tag; got "$err.msg"'))
	}

	uname  := os.uname()
	arch   := uname.machine
	kernel := uname.sysname

	print(
		'\n'
		+ '* reading from: $meta_f\n'
		+ '* writing to:   $meta_t\n'
		+ '\n'
		+ '* program version: $last_tag\n'
		+ '* target_arch:     $arch\n'
		+ '* target_kernel:   $kernel\n\n'
	)

	os.rm(meta_t) or {}
	mut meta_c := os.read_file(meta_f) or { panic(errmsg('could not open meta template')) }

	meta_c = 'module main\n\n'
		+ '/* this file is auto-generated */\n'
		+ meta_c
			.replace(':tag', last_tag)
			.replace(':arch', arch)
			.replace(':kernel', kernel)

	os.write_file(meta_t, meta_c) or { panic(errmsg('could not write meta file')) }
}
