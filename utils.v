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

struct PrettyPrint {
	debug_mode bool [required]
	no_color   bool [required]
}

fn (p PrettyPrint) errmsg(txt string) string {
	if p.no_color {
		return 'ERROR: ' + txt
	}

	return term.bold(term.bright_red('ERROR: ')) + txt
}

fn (p PrettyPrint) emph(txt string) string {
	if p.no_color {
		return txt
	}

	return term.green(txt)
}

fn (p PrettyPrint) href(txt string) string {
	if p.no_color {
		return txt
	}

	return term.underline(txt)
}

fn (p PrettyPrint) info(txt string) {
	if p.no_color {
		println('=> ${txt}')
	}
	else {
		println(term.bright_blue('=> ') + txt)
	}
}

fn (p PrettyPrint) debug(txt string) {
	if p.debug_mode {
		if p.no_color {
			println('==> [DEBUG] $txt')
		}
		else {
			println(term.yellow('==> ') + term.bold('[DEBUG] ') + txt)
		}
	}
}
