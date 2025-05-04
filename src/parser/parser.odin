package parser

import "core:fmt"

ASTNode :: union {
	LetStmt,
	BinaryExpr,
	NumberLiteral,
	Identifier,
}

Position :: struct {
	line: int,
	col:  int,
}

// s := 1
LetStmt :: struct {
	name:  string, // Identifier name
	value: ^ASTNode, // Expression
	pos:   Position,
}

// s :: 12
ConstStmt :: struct {
	name:  string, // Identifier name
	value: ^ASTNode, // Expression
	pos:   Position,
}

BinaryExpr :: struct {
	left:  ^ASTNode, // Left operand
	op:    TokenType, // e.g., .Plus, .Multiply
	right: ^ASTNode, // Right operand
	pos:   Position,
}

NumberLiteral :: struct {
	value: string, // Raw number string
	pos:   Position,
}

Identifier :: struct {
	name: string, // Variable name
	pos:  Position,
}

Parser :: struct {
	tokens: [dynamic]Token,
	pos:    int,
}

// TOP DOWN RECURSIVE DESCENT PARSING
parse :: proc(parser: ^Parser) -> ^int {
	return nil
}

advance :: proc(parser: ^Parser) -> bool {
	if parser.pos >= len(parser.tokens) {
		fmt.eprintln("End of tokens")
		return false
	}

	parser.pos += 1
	return true
}

get_curr_token :: #force_inline proc(parser: ^Parser) -> Token {
	return parser.tokens[parser.pos]
}

peek :: #force_inline proc(parser: ^Parser) -> Token {
	return parser.tokens[parser.pos + 1]
}

expect :: proc(parser: ^Parser) {

}

parse_expression :: proc() {}
parse_mutable_statement :: proc() {}
parse_if :: proc() {}
parse_for :: proc() {}
parse_switch :: proc() {}
parse_program :: proc() {}
