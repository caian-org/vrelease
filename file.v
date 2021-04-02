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
import encoding.base64


fn is_valid_file(filepath string) bool {
	return os.is_file(filepath) && os.is_readable(filepath)
}

fn resolve_path(p string) ?string {
	if os.is_abs_path(p) {
		if is_valid_file(p) {
			return p
		}

		panic('file path "$p" does not exists or cannot be read')
	}

	resolved_p := os.real_path(os.join_path(os.getwd(), p))
	if is_valid_file(resolved_p) {
		return resolved_p
	}

	panic('resolved path "$resolved_p" does not exists or cannot be read')
}

fn read_bytes_f(filepath string) ?string {
	b := os.read_bytes(filepath) or { panic('could not read file "$filepath"') }
	return base64.encode(b)
}
