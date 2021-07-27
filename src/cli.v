module main

import os
import cli { Command, Flag }


struct Cli {
	signature string [required]
mut:
	cmd Command [required]
}

fn cli_build(md map[string]string) Cli {
	mut cmd := Command{
		name:            md['program_name']
		description:     md['program_description']
		version:         md['program_version']
		disable_help:    true
		disable_version: true
	}

	cmd.add_flag(Flag{
		flag:        .string_array
		name:        'attach'
		abbrev:      'a'
		description: 'attaches (uploads) a file to the release'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'add-description'
		abbrev:      'i'
		description: 'adds release description from last commit'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'add-checksum'
		abbrev:      'c'
		description: 'adds file integrity data (SHA256 checksum)'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'pre-release'
		abbrev:      'p'
		description: 'identifies the release as non-production ready'
	})

	cmd.add_flag(Flag{
		flag:          .int
		name:          'limit'
		abbrev:        'l'
		default_value: ['-1']
		description:   'sets a limit to the amount of changelog lines'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'debug'
		abbrev:      'd'
		description: 'enables debug mode'
	})

	cmd.add_flag(Flag{
		flag:        .bool
		name:        'no-color'
		abbrev:      'n'
		description: 'disables output with colors'
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

	signature := program_signature(md)
	return Cli{ signature, cmd }
}

fn (c Cli) f() []Flag {
	return c.cmd.flags
}

fn (c Cli) is_set(flag string) bool {
	return c.f().get_bool(flag) or { false }
}

fn (c Cli) get_limit() int {
	v := c.f().get_int('limit') or { 0 }
	if v <= 0 {
		return -1
	}

	return v
}

fn (c Cli) get_annexes() []string {
	return c.f().get_strings('attach') or { []string{} }
}

fn (mut c Cli) act() bool {
	c.cmd.setup()
	c.cmd.parse(os.args)

	if c.is_set('help') {
		c.cmd.execute_help()
		return true
	}

	if c.is_set('version') {
		println(c.signature)
		return true
	}

	return false
}
