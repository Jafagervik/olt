package parser

import "../utils"

Lexer :: struct {
	filename: string,
	data:     string,
	pos:      int,
	line:     int,
	col:      int,
}


// Tokenize the input of a single file
tokenize :: proc(lexer: ^Lexer) -> (tokens: [dynamic]Token) {
	n := len(lexer.data)

	for lexer.pos < n {
		c := get_curr_char(lexer)

		if c == ' ' || c == '\t' {
			lexer.col += c == ' ' ? 1 : 4
			advance(lexer)
			continue
		}

		if c == '\n' {
			new_line(lexer)
			advance(lexer)
			continue
		}

		// Handle strings (identifiers, keywords) and numbers
		if utils.is_alpha(c) {
			lex_strings(lexer, &tokens)
			advance(lexer)
			continue
		}
		if utils.is_numeric(c) {
			lex_numbers(lexer, &tokens)
			advance(lexer)
			continue
		}

		if c == '/' {
			if peek(lexer) == '/' {
				lex_comment(lexer)
				advance(lexer)
				continue
			} else if peek(lexer) == '*' {
				advance(lexer)
				continue
			}
		}

		// Handle multi-character and single-character tokens
		token_type: TokenType
		lexeme: string
		consumed := 1 // Number of characters consumed (default 1 for single-char tokens)

		switch c {
		case '<':
			if peek(lexer) == '=' {
				token_type = .LEQ
				lexeme = "<="
				consumed = 2
			} else {
				token_type = .LT
				lexeme = "<"
			}
		case '>':
			if peek(lexer) == '=' {
				token_type = .GEQ
				lexeme = ">="
				consumed = 2
			} else {
				token_type = .GT
				lexeme = ">"
			}
		case '!':
			if peek(lexer) == '=' {
				token_type = .NEQ
				lexeme = "!="
				consumed = 2
			} else {
				token_type = .Exclamation
				lexeme = "!"
			}
		case '=':
			if peek(lexer) == '=' {
				token_type = .EQEQ
				lexeme = "=="
				consumed = 2
			} else {
				token_type = .EQ
				lexeme = "="
			}
		case ':':
			if peek(lexer) == ':' {
				token_type = .ColonColon
				lexeme = "::"
				consumed = 2
			} else if peek(lexer) == '=' {
				token_type = .ColonEQ
				lexeme = ":="
				consumed = 2
			} else {
				token_type = .Colon
				lexeme = ":"
			}
		case '+':
			if peek(lexer) == '=' {
				token_type = .PlusEQ
				lexeme = "+="
				consumed = 2
			} else {
				token_type = .Plus
				lexeme = "+"
			}
		case '-':
			if peek(lexer) == '>' {
				token_type = .Arrow
				lexeme = "->"
				consumed = 2
			} else if peek(lexer) == '=' {
				token_type = .MinusEQ
				lexeme = "-="
				consumed = 2
			} else {
				token_type = .Minus
				lexeme = "-"
			}
		case '*':
			if peek(lexer) == '=' {
				token_type = .MultiplyEQ
				lexeme = "*="
				consumed = 2
			} else {
				token_type = .Multiply
				lexeme = "*"
			}
		case '/':
			if peek(lexer) == '=' {
				token_type = .DivideEQ
				lexeme = "/="
				consumed = 2
			} else {
				token_type = .Divide
				lexeme = "/"
			}
		case '|':
			if peek(lexer) == '>' {
				token_type = .Pipe
				lexeme = "|>"
				consumed = 2
			} else {
				token_type = .Bar
				lexeme = "|"
			}
		case '(':
			token_type = .LParen
			lexeme = "("
		case ')':
			token_type = .RParen
			lexeme = ")"
		case '[':
			token_type = .LBrack
			lexeme = "["
		case ']':
			token_type = .RBrack
			lexeme = "]"
		case '{':
			token_type = .LBrace
			lexeme = "{"
		case '}':
			token_type = .RBrace
			lexeme = "}"
		case '.':
			if peek_n(lexer, 2) == ".= " {
				token_type = .DotDotEq
				lexeme = "..="
				consumed = 3
			} else if peek(lexer) == '.' {
				token_type = .DotDot
				lexeme = ".."
				consumed = 2
			} else {
				token_type = .Dot
				lexeme = "."
			}
		case ',':
			token_type = .Comma
			lexeme = ","
		case ';':
			token_type = .SemiColon
			lexeme = ";"
		case '#':
			// TODO: needs extra lexing i suppose
			token_type = .Directive
			lexeme = "#"
		case '\'':
			token_type = .Quote
			lexeme = "'"
		case '"':
			token_type = .DoubleQuote
			lexeme = "\""
		case:
			token_type = .Invalid
			lexeme = utils.char_to_string(c)
		}

		// Append the token and advance the lexer
		append(&tokens, create_token(lexer, token_type, lexeme))
		for _ in 0 ..< consumed {
			advance(lexer)
		}
	}

	return
}
@(private = "file")
lex_comment :: proc(lexer: ^Lexer) {
	for cc := get_curr_char(lexer); cc != '\n'; {
		advance(lexer)
		cc = get_curr_char(lexer)
	}
	regress(lexer)
}

@(private = "file")
lex_multi_comment :: proc(lexer: ^Lexer) {
	// TODO: Implement
}

@(private = "file")
// Lex string values
lex_strings :: proc(lexer: ^Lexer, tokens: ^[dynamic]Token) {
	start_pos := lexer.pos
	start_col := lexer.col
	start_line := lexer.line

	for lexer.pos < len(lexer.data) && utils.is_alphanumeric(get_curr_char(lexer)) {
		advance(lexer)
	}

	if start_pos < lexer.pos {
		identifier := lexer.data[start_pos:lexer.pos]
		// TODO: What to do about strings? Let parser handle DoubleQuote Identifier DoubleQuote as string?
		token_type := identifier in KEYWORDS ? KEYWORDS[identifier] : .Identifier

		append(
			tokens,
			Token {
				type = token_type,
				literal = identifier,
				line = start_line,
				col = start_col,
			},
		)
	}

	regress(lexer) // Adjust position back since advance will be called in the main loop
}

@(private = "file")
// Lex numerical values
lex_numbers :: proc(lexer: ^Lexer, tokens: ^[dynamic]Token) {
	start_pos := lexer.pos
	start_line := lexer.line
	start_col := lexer.col
	has_dot := false
	has_exp := false
	is_hex := false
	is_binary := false
	is_octal := false

	// Check for hex, binary or octal prefix
	if get_curr_char(lexer) == '0' && lexer.pos + 1 < len(lexer.data) {
		next_char := peek(lexer)
		if next_char == 'x' || next_char == 'X' {
			is_hex = true
			advance(lexer) // Skip '0'
			advance(lexer) // Skip 'x'
			start_pos = lexer.pos
		} else if next_char == 'b' || next_char == 'B' {
			is_binary = true
			advance(lexer) // Skip '0'
			advance(lexer) // Skip 'b'
			start_pos = lexer.pos
		} else if next_char == 'o' || next_char == 'O' {
			is_octal = true
			advance(lexer) // Skip '0'
			advance(lexer) // Skip 'o'
			start_pos = lexer.pos
		}
	}

	// Continue reading as long as we have valid number characters
	for lexer.pos < len(lexer.data) {
		c := get_curr_char(lexer)

		if is_hex {
			if !((c >= '0' && c <= '9') ||
				   (c >= 'a' && c <= 'f') ||
				   (c >= 'A' && c <= 'F') ||
				   c == '_') {
				break
			}
		} else if is_binary {
			if !(c == '0' || c == '1' || c == '_') {
				break
			}
		} else if is_octal {
			if !((c >= '0' && c <= '7') || c == '_') {
				break
			}
		} else {
			// Decimal number
			if c == '.' && !has_dot && !has_exp {
				has_dot = true
			} else if (c == 'e' || c == 'E') && !has_exp {
				has_exp = true
				if lexer.pos + 1 < len(lexer.data) {
					next := peek(lexer)
					if next == '+' || next == '-' {
						advance(lexer) // Skip 'e'/'E'
					}
				}
			} else if !(utils.is_numeric(c) || c == '_') {
				break
			}
		}

		advance(lexer)
	}

	if start_pos < lexer.pos {
		number := lexer.data[start_pos:lexer.pos]
		append(
			tokens,
			Token {
				type = .Number,
				literal = number,
				col = start_col,
				line = start_line,
			},
		)
	}

	regress(lexer) // Adjust position back since advance will be called in the main loop
}

// ========================
// Helpers
// ========================

@(private = "file")
create_token :: proc(lexer: ^Lexer, type: TokenType, lexeme: string) -> Token {
	return Token{type = type, literal = lexeme, line = lexer.line, col = lexer.col}
}

@(private = "file")
get_curr_char :: proc(lexer: ^Lexer) -> u8 {
	return lexer.data[lexer.pos]
}

@(private = "file")
advance :: proc(lexer: ^Lexer) {
	lexer.pos += 1
	lexer.col += 1
}

@(private = "file")
regress :: proc(lexer: ^Lexer) {
	lexer.pos -= 1
	lexer.col -= 1
}

@(private = "file")
new_line :: proc(lexer: ^Lexer) {
	lexer.line += 1
	lexer.col = 1
}

@(private = "file")
peek :: proc(lexer: ^Lexer) -> u8 {
	return lexer.data[lexer.pos + 1]
}

@(private = "file")
peek_n :: proc(lexer: ^Lexer, n: int) -> string {
	return lexer.data[lexer.pos:lexer.pos + n]
}
