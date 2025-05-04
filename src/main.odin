package main

import "cli"
import "core:fmt"
import "core:os"

main :: proc() {
	args := os.args[1:]

	when ODIN_DEBUG {
		fmt.println("DEBUG MODE")
	} else {
		fmt.println("FAST MODE")
	}

	if argc := len(args); argc > 1 {
		fmt.println("Too many arguments for now:", argc)
		return
	}

	cli.run_file(args[0])
}
