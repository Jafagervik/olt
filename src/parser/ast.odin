#+feature dynamic-literals
package parser


@(private = "file")
PRECEDENCE := map[string]int {
	"="   = 1,
	"or"  = 2,
	"and" = 3,
	"<"   = 7,
	">"   = 7,
	"<="  = 7,
	">="  = 7,
	"=="  = 7,
	"!="  = 7,
	"+"   = 10,
	"-"   = 10,
	"*"   = 20,
	"/"   = 20,
}
