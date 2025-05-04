package cli

import "core:fmt"
import "core:os"
import "core:time"

import "../parser"


// Runs and compiles a single file
// Inputs:
// - fpath (string): filepath
run_file :: proc(fpath: string) {
	data, ok := os.read_entire_file(fpath, context.allocator)

	if !ok {
		fmt.eprintln("Could not read file from %s", fpath)
		return
	}

	defer delete(data, context.allocator)

	inputs := string(data)

	lexer := parser.Lexer {
		filename = fpath,
		data     = inputs,
		pos      = 0,
		line     = 1,
		col      = 0,
	}

	when ODIN_DEBUG {
		start := time.Time{}
		tokens := parser.tokenize(&lexer)
		end := time.Time{}
		fmt.println("Tokenize time:", time.diff(start, end))
	} else {
		tokens := parser.tokenize(&lexer)
	}

	when ODIN_DEBUG {
		for token in tokens {
			parser.print_token(token)
		}
	}

	par := parser.Parser {
		tokens = tokens,
		pos    = 0,
	}

	_ = parser.parse(&par)
}
