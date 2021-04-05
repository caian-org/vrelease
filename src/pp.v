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
	if p.no_color { return 'ERROR: ' + txt }
	return term.bold(term.bright_red('ERROR: ')) + txt
}

fn (p PrettyPrint) emph(txt string) string {
	if p.no_color { return txt }
	return term.bright_cyan(txt)
}

fn (p PrettyPrint) href(txt string) string {
	if p.no_color { return txt }
	return term.underline(txt)
}

fn (p PrettyPrint) success(txt string) string {
	if p.no_color { return txt }
	return term.green(txt)
}

fn (p PrettyPrint) fail(txt string) string {
	if p.no_color { return txt }
	return term.red(txt)
}

fn (p PrettyPrint) puts(txt string, nl bool, c fn (t string) string) {
	a := '=> '
	f := if p.debug_mode || !nl { println } else { print }
	if p.no_color {
		f(a + txt)
	} else {
		f(c(a) + txt)
	}
}

fn (p PrettyPrint) info(txt string) {
	p.puts(txt, false, fn (t string) string { return term.bright_blue(t) })
}

fn (p PrettyPrint) info_nl(txt string) {
	p.puts(txt, true, fn (t string) string { return term.bright_blue(t) })
}

fn (p PrettyPrint) warn(txt string) {
	p.puts(txt, false, fn (t string) string { return term.yellow(t) })
}

fn (p PrettyPrint) debug(txt string) {
	if !p.debug_mode { return }
	if p.no_color {
		println('==> [DEBUG] $txt')
	} else {
		println(term.yellow('==> ') + term.bold('[DEBUG] ') + txt)
	}
}
