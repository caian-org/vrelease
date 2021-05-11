import os
import term

fn errmsg(txt string) string {
	return term.bold(term.bright_red('ERROR: ')) + txt
}

fn get_last_tag() ?string {
	res := os.execute_or_panic('git tag --sort=-creatordate')
	tags := res.output.split('\n')

	if tags.len > 0 {
		last_t := tags[0]

		if last_t.trim_space() != '' {
			return last_t
		}
	}

	return 'UNRELEASED'
}

fn get_last_commit_hash() ?string {
	res := os.execute_or_panic('git rev-parse --short HEAD')
	return res.output.trim_space()
}

fn main() {
	src_dir := os.join_path(os.getwd(), '..', 'src')
	meta_f  := os.join_path(src_dir, '_meta')
	meta_t  := os.join_path(src_dir, 'meta.v')

	last_tag := get_last_tag() or {
		panic(errmsg('could not get the last git tag; got "$err.msg"'))
	}

	last_commit_hash := get_last_commit_hash() or {
		panic(errmsg('could not get the last commit hash; got "$err.msg"'))
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
		+ '* commit hash:     $last_commit_hash\n'
		+ '* target_arch:     $arch\n'
		+ '* target_kernel:   $kernel\n\n'
	)

	os.rm(meta_t) or {}
	mut meta_c := os.read_file(meta_f) or { panic(errmsg('could not open meta template')) }

	meta_c = 'module main\n\n'
		+ '/* this file is auto-generated */\n'
		+ meta_c
			.replace(':tag', last_tag)
			.replace(':hash', last_commit_hash)
			.replace(':arch', arch)
			.replace(':kernel', kernel)

	os.write_file(meta_t, meta_c) or { panic(errmsg('could not write meta file')) }
}
