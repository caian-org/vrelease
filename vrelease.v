// vi: ft=vlang

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

import term
import time
import net.http { Method, Request }

fn info(txt string) {
	print(term.bright_blue('=> ') + txt + '\n')
}

fn start_msg() {
	program_version, target_arch, target_kernel := metad()
	println('')
	println(term.bold('vrelease $program_version $target_kernel/$target_arch'))
	println(term.gray('program has started @ ${time.now().str()}'))
	println('')
}

fn main() {
	start_msg()
	info('doing stuff')

	req := Request{
		method: Method.get,
		url: 'https://api.github.com/repos/caiertl/tmp/releases'
	}

	res := req.do() or {
		panic('ooops')
	}

	println(res.status_code)
	println(res.text)
}
