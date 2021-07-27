module main

import os
import crypto.sha256


struct Annex {
	filename string [required]
	filepath string [required]
	checksum string [required]
}

fn file_is_valid(p string) bool {
	return os.is_file(p) && os.is_readable(p)
}

fn file_resolve_path(p string) ?string {
	if os.is_abs_path(p) {
		if file_is_valid(p) {
			return p
		}

		panic('file path "$p" does not exists or cannot be read')
	}

	resolved_p := os.real_path(os.join_path(os.getwd(), p))
	if file_is_valid(resolved_p) {
		return resolved_p
	}

	panic('resolved path "$resolved_p" does not exists or cannot be read')
}

fn file_sha256_sum(p string) ?string {
	fileb := os.read_bytes(p) or {
		panic('content of file path "$p" could be read')
	}

	return sha256.sum(fileb).hex()
}
