package utils

is_alphanumeric :: #force_inline proc(c: u8) -> bool {
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_'
}


is_alpha :: #force_inline proc(c: u8) -> bool {
	return (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || c == '_'
}

is_numeric :: #force_inline proc(c: u8) -> bool {
	return c >= '0' && c <= '9'
}

char_to_string :: #force_inline proc(c: u8) -> string {
	return string([]u8{c})
}
