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

fn (p PrettyPrint) debug(key string, txt string) {
	if !p.debug_mode { return }
	if p.no_color {
		println('===> [DEBUG] $key = $txt')
	} else {
		println(
			term.gray('===> ')
			+ term.bold('[DEBUG] ')
			+ key
			+ term.bright_red(' = ')
			+ txt
		)
	}
}
