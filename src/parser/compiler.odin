package parser


import "core:fmt"

Compiler :: struct {
	program: string,
}

compile :: proc(compiler: ^Compiler) {
	fmt.println(compiler.program)
}
