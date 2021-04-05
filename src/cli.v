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
import cli { Command, Flag }


struct Cli {
mut:
	cmd Command [required]
}

fn (c Cli) f() []Flag {
	return c.cmd.flags
}

fn (c Cli) is_set(flag string) bool {
	return c.f().get_bool(flag) or { false }
}

fn (c Cli) get_limit() int {
	v := c.f().get_int('limit') or { 0 }

	if v <= 0 { return -1 }
	return v
}

fn (c Cli) get_annexes() []string {
	return c.f().get_strings('attach') or { []string{} }
}

fn (mut c Cli) act() {
	c.cmd.setup()
	c.cmd.parse(os.args)

	if c.is_set('help') {
		c.cmd.execute_help()
		exit(0)
	}

	if c.is_set('version') {
		println(c.cmd.version)
		exit(0)
	}
}

fn build_cli(md map[string]string) Cli {
	mut cmd := Command{
		name:            md['program_name']
		description:     md['program_description']
		version:         md['program_version']
		disable_help:    true
		disable_version: true
	}

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'debug'
		abbrev:      'd'
		description: 'enables the debug mode'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'no-color'
		abbrev:      'n'
		description: 'disables output with colors (useful on non-compliant shells)'
	})

	cmd.add_flag(Flag{
		flag:        .string_array
		name:        'attach'
		abbrev:      'a'
		description: 'attaches (uploads) a file to the release'
	})

	cmd.add_flag(Flag{
		flag:          .int
		name:          'limit'
		abbrev:        'l'
		default_value: ['-1']
		description:   'sets a limit to the amount of commits on the changelog'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'help'
		abbrev:      'h'
		description: 'prints help information'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'version'
		abbrev:      'v'
		description: 'prints version information'
	})

	return Cli{ cmd }
}
