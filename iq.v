module main

import flag
import os

pub fn iq_exec(expr string, contents string) ?string {
	ex := expr.split('=')
	k := ex[0].split('.')
	if k.len != 3 || !expr.starts_with('') {
		return error('expr must be of the form .section.key')
	}
	assigning := ex.len == 2
	lines := contents.split_into_lines()
	mut section := ''
	mut out := []string{}
	mut seen_section := false
	mut seen_key := false
	mut empty_lines := 0
	for line in lines {
		line1 := line.trim_space()

		if line1.len > 0 && line1.starts_with('[') {
			sec := line1.find_between('[', ']').trim_space()
			if sec.len > 0 {
				if ex.len > 1 && section == k[1] && !seen_key {
					out << k[2] + '=' + ex[1]
					seen_key = true
				}
				section = sec
				for empty_lines > 0 {
					out << ''
					empty_lines--
				}
				if section == k[1] {
					seen_section = true
				}
			}
		}
		if assigning {
			if line1.len == 0 {
				empty_lines++
				continue
			} else {
				for _ in 0 .. empty_lines {
					out << ''
				}
				empty_lines = 0
			}
			mut lineout := line
			if section == k[1] {
				p := line1.index('=') or { 0 }
				if p > 0 {
					mut q := p
					for i := p; i < line1.len; i++ {
						if line1[i] == `;` || line1[i] == `#` {
							break
						}
						if !line1[i].is_space() {
							q = i + 1
						}
					}
					kl := line1[..p].trim_space()
					if kl == k[2] {
						seen_key = true
						lineout = kl + '=' + ex[1] + line1[q..]
					}
				}
			}
			out << lineout
		} else {
			if section == k[1] {
				p := line1.index('=') or { 0 }
				if p > 0 {
					kl := line1[..p].trim_space()
					vl := line1[p + 1..].before('#').before(';').trim_space()
					if kl == k[2] {
						out << vl
					}
				}
			}
		}
	}
	if ex.len > 1 {
		if !seen_key {
			if !seen_section {
				out << ''
				out << '[' + k[1] + ']'
			}
			out << k[2] + '=' + ex[1]
		}
		for _ in 0 .. empty_lines {
			out << ''
		}
		empty_lines = 0
	}
	return out.join('\n')
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('iq')
	fp.version('v0.0.1')
	fp.limit_free_args(1, 1)? // comment this, if you expect arbitrary texts after the options
	fp.description('iq -i -e .section.key[=value] file.conf')
	fp.skip_executable()
	inplace := fp.bool('inplace', `i`, false, 'modify file in place')
	expr := fp.string('expression', `e`, '', 'expresion. example .section.key=value')
	additional_args := fp.finalize() or {
		eprintln(err)
		println(fp.usage())
		return
	}
	path := additional_args[0]
	contents := os.read_file(path) or {
		eprintln(err.str())
		exit(1)
	}

	out := iq_exec(expr, contents) or {
		eprintln(err.str())
		exit(2)
	}
	// println({'inplace':inplace.str(),'expr':expr,'path':path})
	if inplace {
		os.write_file(path, out) or {
			eprintln(err.str())
			exit(3)
		}
	} else {
		println(out)
	}
}
