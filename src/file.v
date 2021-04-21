module main

import os


fn file_is_valid(filepath string) bool {
	return os.is_file(filepath) && os.is_readable(filepath)
}

fn file_resolve_path(p string) ?string {
	if os.is_abs_path(p) {
		if file_is_valid(p) { return p }
		panic('file path "$p" does not exists or cannot be read')
	}

	resolved_p := os.real_path(os.join_path(os.getwd(), p))
	if file_is_valid(resolved_p) { return resolved_p }
	panic('resolved path "$resolved_p" does not exists or cannot be read')
}
