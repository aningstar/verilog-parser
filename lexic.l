%{
#include "verilog_parser.tab.h"
#include <string.h>
#include <stdlib.h>

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;

/* Lexer function prototypes.
long int convert_str_to_bin(char *binary_string);
long int convert_str_to_oct(char *octal_string);
long int convert_str_to_dec(char *decimal_string);
long int convert_str_to_hex(char *hexadecimal_string);
*/
%}

%option yylineno

%{
/* Exlusive start conditions used to match comments. Patterns aren't recognised
inside them. */
%}
%x multi_line_comment
%x single_line_comment

%%

    /* Match Verilog 2001 keywords. */
"always"              { return ALWAYS; }
"and"                 { return AND; }
"assign"              { return ASSIGN; }
"automatic"           { return AUTOMATIC; }
"begin"               { return BEGIN_TOKEN; }
"buf"                 { return BUF; }
"bufif0"              { return BUFIF0; }
"bufif1"              { return BUFIF1; }
"case"                { return CASE; }
"casex"               { return CASEX; }
"casez"               { return CASEZ; }
"cell"                { printf("CELL\n"); }
"cmos"                { return CMOS; }
"config"              { printf("CONFIG\n"); }
"deassign"            { return DEASSIGN; }
"default"             { return DEFAULT; }
"defparam"            { return DEFPARAM; }
"design"              { printf("DESIGN\n"); }
"disable"             { return DISABLE; }
"edge"                { return EDGE; }
"else"                { return ELSE; }
"end"                 { return END; }
"endcase"             { return ENDCASE; }
"endconfig"           { printf("ENDCONFIG\n"); }
"endfunction"         { return ENDFUNCTION; }
"endgenerate"         { return ENDGENERATE; }
"endmodule"           { return ENDMODULE; }
"endprimitive"        { printf("ENDPRIMITIVE\n"); }
"endspecify"          { return ENDSPECIFY; }
"endtable"            { printf("ENDTABLE\n"); }
"endtask"             { return ENDTASK; }
"event"               { return EVENT; }
"for"                 { return FOR; }
"force"               { return FORCE; }
"forever"             { return FOREVER; }
"fork"                { return FORK; }
"function"            { return FUNCTION; }
"generate"            { return GENERATE; }
"genvar"              { return GENVAR; }
"highz0"              { printf("HIGHZ0\n"); }
"highz1"              { printf("HIGHZ1\n"); }
"if"                  { return IF; }
"ifnone"              { return IFNONE; }
"initial"             { return INITIAL_TOKEN; }
"instance"            { printf("INSTANCE\n"); }
"inout"               { return INOUT; }
"input"               { return INPUT; }
"integer"             { return INTEGER; }
"join"                { return JOIN; }
"large"               { return LARGE; }
"liblist"             { printf("LIBLIST\n"); }
"localparam"          { return LOCALPARAM; }
"macromodule"         { return MACROMODULE; }
"medium"              { return MEDIUM;}
"module"              { return MODULE; }
"nand"                { return NAND; }
"negedge"             { return NEGEDGE; }
"nmos"                { return NMOS; }
"nor"                 { return NOR; }
"not"                 { return NOT; }
"noshowcancelled"     { return NOSHOWCANCELLED; } 
"notif0"              { return NOTIF0; }
"notif1"              { return NOTIF1; }
"or"                  { return OR; }
"output"              { return OUTPUT; }
"parameter"           { return PARAMETER;}
"pmos"                { return PMOS; }
"posedge"             { return POSEDGE; }
"primitive"           { printf("PRIMITIVE\n"); }
"pull0"               { return PULL0; }
"pull1"               { return PULL1; }
"pulldown"            { return PULLDOWN; }
"pullup"              { return PULLUP; }
"pulsestyle_onevent"  { return PULSESTYLE_ONEVENT; }
"pulsestyle_ondetect" { return PULSESTYLE_ONDETECT; }
"rcmos"               { return RCMOS; }
"real"                { return REAL; }
"realtime"            { return REALTIME; }
"reg"                 { return REG; }
"release"             { return RELEASE; }
"repeat"              { return REPEAT; }
"rnmos"               { return RNMOS; }
"rpmos"               { return RPMOS; }
"rtran"               { return RTRAN; }
"rtranif0"            { return RTRANIF0; }
"rtranif1"            { return RTRANIF1; }
"scalared"            { return SCALARED; }
"signed"              { return SIGNED; }
"showcancelled"       { return SHOWCANCELLED; }
"small"               { return SMALL; }
"specify"             { return SPECIFY; }
"specparam"           { return SPECPARAM; }
"strength"            { printf("STRENGTH\n"); }
"strong0"             { return STRONG0; }
"strong1"             { return STRONG1; }
"supply0"             { return SUPPLY0; }
"supply1"             { return SUPPLY1; }
"table"               { printf("TABLE\n"); }
"task"                { return TASK; }
"time"                { return TIME;}
"tran"                { return TRAN; }
"tranif0"             { return TRANIF0; }
"tranif1"             { return TRANIF1; }
"tri"                 { return TRI; }
"tri0"                { return TRI0; }
"tri1"                { return TRI1; }
"triand"              { return TRIAND; }
"trior"               { return TRIOR; }
"trireg"              { return TRIREG; }
"unsigned"            { printf("UNSIGNED\n"); }
"use"                 { printf("USE\n"); }
"vectored"            { return VECTORED; }
"wait"                { return WAIT; }
"wand"                { return WAND; }
"weak0"               { return WEAK0; }
"weak1"               { return WEAK1; }
"while"               { return WHILE; }
"wire"                { return WIRE; }
"wor"                 { return WOR; }
"xnor"                { return XNOR; }
"xor"                 { return XOR; }

"PATHPULSE$"[a-zA-Z0-9_$]* { return PATHPULSE; }
    /* Match Verilog 2001 system function keywords. */
"$signed"             { return SIGNED_SYSTEM_FUNCTION; }
"$unsigned"           { return UNSIGNED_SYSTEM_FUNCTION; }

"$setup"              { return SETUP; }
"$hold"               { return HOLD; }
"$setuphold"          { return SETUPHOLD; }
"$recovery"           { return RECOVERY; }
"$removal"            { return REMOVAL; }
"$recrem"             { return RECREM; }
"$skew"               { return SKEW; }
"$timeskew"           { return TIMESKEW; }
"$fullskew"           { return FULLSKEW; }
"$period"             { return D_PERIOD; }
"$width"              { return WIDTH; }
"$nochange"           { return NOCHANGE; }

    /* Match Verilog 2001 comments. Tokens are not returned for comments (so
that comments are invisible to the parser). */
<INITIAL>{
[/][*]                BEGIN(multi_line_comment);
}
<multi_line_comment>{
[*][/]                BEGIN(INITIAL);
[^*]+                 // eat comment in chunks
[*]
}
[/][/].*[\n]

    /* Match Verilog 2001 symbols. */
"@"                   { return AT; }
"("                   { return OPENPARENTHESES; }
")"                   { return CLOSEPARENTHESES; }
"["                   { return OPENBRACKETS; }
"]"                   { return CLOSEBRACKETS; }
"{"                   { return OPENBRACES; }
"}"                   { return CLOSEBRACES; }
","                   { return COMMA; }
";"                   { return SEMICOLON; }
"#"                   { return HASH; }
"&"                   { return AND_OPERATOR; }
"~""&"                { return NAND_OPERATOR; }
"&"{2}                { return LOGICAL_AND; }
"|"                   { return OR_OPERATOR; }
"~""|"                { return NOR_OPERATOR; }
"|"{2}                { return LOGICAL_OR; }
"^"                   { return XOR_OPERATOR; }
"~""^"                { return XNOR_OPERATOR; }
"^""~"                { return XNOR_OPERATOR; }
"+"                   { return PLUS; }
"-"                   { return MINUS; }
"*"                   { return ASTERISK; }
"*"{2}                { return POWER; }
"/"                   { return SLASH; }
"%"                   { return MODULO; }
"="                   { return EQUALS_SIGN; }
"="{2}                { return EQUAL; }
"!""="                { return NOT_EQUAL; }
"="{3}                { return IDENTICAL; }
"!""="{2}             { return NOT_IDENTICAL; }
"<"                   { return LESSTHAN; }
"<""="                { return LESSTHANOREQUAL; }
">"                   { return GREATERTHAN; }
">""="                { return GREATERTHANOREQUAL; }
":"                   { return COLON; }
"?"                   { return QUESTION_MARK; }
"~"                   { return TILDE; }
"!"                   { return EXCLAMATION_MARK; }
"."                   { return PERIOD; }
"<"{2}                { return BITWISE_LEFT_SHIFT; }
">"{2}                { return BITWISE_RIGHT_SHIFT; }
"<"{3}                { return ARITHMETIC_LEFT_SHIFT; }
">"{3}                { return ARITHMETIC_RIGHT_SHIFT; }
"-"">"                { return TRIGGER_EVENT_OPERATOR; }
"&"{3}                { return THREE_AND; }


"1"           { return ONE; }
"0"           { return ZERO; }
"01"          { return ZERO_ONE; }
"10"          { return ONE_ZERO; }
"1'b0"        { return ONE_BIN_ZERO_LOW; }
"1'b1"        { return ONE_BIN_ONE_LOW; }
"1'B0"        { return ONE_BIN_ZERO_UPPER; }
"1'B1"        { return ONE_BIN_ONE_UPPER; }
"'b0"         { return BIN_ZERO_LOW; }
"'b1"         { return BIN_ONE_LOW; }
"'B0"         { return BIN_ZERO_UPPER; }
"'B1"         { return BIN_ONE_UPPER; }

"X0"          { return X_ZERO_UPPER; } 
"X1"          { return X_ONE_UPPER; }
"x0"          { return X_ZERO_LOW; }
"x1"          { return X_ONE_LOW; }
"Z0"          { return Z_ZERO_UPPER; }
"Z1"          { return Z_ONE_UPPER; }
"z0"          { return Z_ZERO_LOW; }
"z1"          { return Z_ONE_LOW; }
"0X"          { return ZERO_X_UPPER; }
"1X"          { return ONE_X_UPPER; }
"0x"          { return ZERO_X_LOW; }
"1x"          { return ONE_X_LOW; }
"0Z"          { return ZERO_Z_UPPER; }
"1Z"          { return ONE_Z_UPPER; }
"0z"          { return ZERO_Z_LOW; }
"1z"          { return ONE_Z_LOW; }

    /* Match Verilog 2001 identifiers. */
[a-zA-Z_][a-zA-Z0-9_$]*                            { return IDENTIFIER; }
[\\][^\n\t ]+                                      { return IDENTIFIER; }
 
    /* Match Verilog 2001 real numbers. */
[0-9]+[.][0-9][0-9_]*                              { return REALV; }
[0-9]+[.][0-9][0-9_]*[eE]-?[0-9]+                  { return REALV; }
[0-9]+[0-9_]*[eE]-?[0-9]+                          { return REALV; }

    /* Match Verilog 2001 integers. Note that INTEGER is a keyword token. */
[0-9]+                                             { return NUM_INTEGER; }

    /* Match Verilog 2001 unsigned numbers. */
[0-9]*['][bB][01xXzZ?][01xXzZ?_]*                  { return UNSIG_BIN; }
[0-9]*['][oO][0-7xXzZ?][0-7xXzZ?_]*                { return UNSIG_OCT; }
[0-9]*['][dD][0-9][0-9_]*                          { return UNSIG_DEC; }
[0-9]*['][hH][0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]*    { return UNSIG_HEX; }

    /* Match Verilog 2001 signed numbers. */
[0-9]*['][sS][bB][01xXzZ?][01xXzZ?_]*               { return SIG_BIN; }
[0-9]*['][sS][oO][0-7xXzZ?][0-7xXzZ?_]*             { return SIG_OCT; }
[0-9]*['][sS][dD][0-9][0-9_]*                       { return SIG_DEC; }
[0-9]*['][sS][hH][0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]* { return SIG_HEX; }

    /* Match newlines, carriage returns, spaces and tabs. */
[\n\r]+               { }
[ ]                   { }
[\t]                  { }

    /* Any single character that doesn't match the above rules. */
.                     { printf("UNIDENTIFIED : %c\n",yytext[0]); }

%%

/*
long int convert_str_to_bin(char *binary_string) {
	long int result;
	char *number_start;
	
	/* Remove binary prefix XX'b or XX'B from number. *
	strtok(binary_string, "'");
	number_start = strtok(NULL, "'");
	number_start++;
	
	/* Convert to base 2. *
	result = strtol(number_start, NULL, 2);
	
	return(result);
}

long int convert_str_to_oct(char *octal_string) {
	long int result;
	char *number_start;
	
	/* Remove octal prefix XX'o or XX'O from number. *
	strtok(octal_string, "'");
	number_start = strtok(NULL, "'");
	number_start++;
	
	/* Convert to base 8. *
	result = strtol(number_start, NULL, 8);
	
	return(result);
}

long int convert_str_to_dec(char *decimal_string) {
	long int result;
	char *number_start;
	
	/* Remove decimal prefix XX'd or XX'D from number. *
	strtok(decimal_string, "'");
	number_start = strtok(NULL, "'");
	number_start++;
	
	/* Convert to base 10. *
	result = strtol(number_start, NULL, 10);
	
	return(result);
}

long int convert_str_to_hex(char *hexadecimal_string) {
	long int result;
	char *number_start;
	
	/* Remove hexadecimal prefix XX'o or XX'O from number. *
	strtok(hexadecimal_string, "'");
	number_start = strtok(NULL, "'");
	number_start++;
	
	/* Convert to base 16. *
	result = strtol(number_start, NULL, 16);
	
	return(result);
}
*/
