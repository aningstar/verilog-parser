%{
#include "verilog_parser.tab.h"
#include <string.h>
#include <stdlib.h>

/* Lexer function prototypes.
long int convert_str_to_bin(char *binary_string);
long int convert_str_to_oct(char *octal_string);
long int convert_str_to_dec(char *decimal_string);
long int convert_str_to_hex(char *hexadecimal_string);
*/
%}

%{
/* Exlusive start conditions used to match comments. Patterns aren't recognised
inside them. */
%}
%x multi_line_comment
%x single_line_comment

%%

    /* Match Verilog 2001 keywords. */
"always"              { printf("ALWAYS : %s \n",yytext); }
"and"                 { printf("AND : %s \n",yytext); }
"assign"              { printf("ASSIGN\n"); }
"automatic"           { printf("AUTOMATIC\n"); }
"begin"               { printf("BEGIN\n"); }
"buf"                 { printf("BUF\n"); }
"bufif0"              { printf("BUFIF0\n"); }
"bufif1"              { printf("BUFIF1\n"); }
"case"                { printf("CASE\n"); }
"casex"               { printf("CASEX\n"); }
"casez"               { printf("CASEZ\n"); }
"cell"                { printf("CELL\n"); }
"cmos"                { printf("CMOS\n"); }
"config"              { printf("CONFIG\n"); }
"deassign"            { printf("DEASSIGN\n"); }
"default"             { printf("DEFAULT\n"); }
"defparam"            { printf("DEFPARAM\n"); }
"design"              { printf("DESIGN\n"); }
"disable"             { printf("DISABLE\n"); }
"edge"                { printf("EDGE\n"); }
"else"                { printf("ELSE\n"); }
"end"                 { printf("END\n"); }
"endcase"             { printf("ENDCASE\n"); }
"endconfig"           { printf("ENDCONFIG\n"); }
"endfunction"         { printf("ENDFUNCTION\n"); }
"endgenerate"         { printf("ENDGENERATE\n"); }
"endmodule"           { return ENDMODULE; }
"endprimitive"        { printf("ENDPRIMITIVE\n"); }
"endspecify"          { printf("ENDSPECIFY\n"); }
"endtable"            { printf("ENDTABLE\n"); }
"endtask"             { printf("ENDTASK\n"); }
"event"               { return EVENT; }
"for"                 { printf("FOR\n"); }
"force"               { printf("FORCE\n"); }
"forever"             { printf("FOREVER\n"); }
"fork"                { printf("FORK\n"); }
"function"            { printf("FUNCTION\n"); }
"generate"            { printf("GENERATE\n"); }
"genvar"              { return GENVAR; }
"highz0"              { printf("HIGHZ0\n"); }
"highz1"              { printf("HIGHZ1\n"); }
"if"                  { printf("IF\n"); }
"ifnone"              { printf("IFNONE\n"); }
"initial"             { printf("INITIAL\n"); }
"instance"            { printf("INSTANCE\n"); }
"inout"               { return INOUT; }
"input"               { return INPUT; }
"integer"             { return INTEGER; }
"join"                { printf("JOIN\n"); }
"large"               { return LARGE; }
"liblist"             { printf("LIBLIST\n"); }
"localparam"          { return LOCALPARAM; }
"macromodule"         { printf("MACROMODULE\n"); }
"medium"              { return MEDIUM;}
"module"              { return MODULE; }
"nand"                { printf("NAND\n"); }
"negedge"             { printf("NEGEDGE\n"); }
"nmos"                { printf("NMOS\n"); }
"nor"                 { printf("NOR\n"); }
"not"                 { printf("NOT\n"); }
"noshowcancelled"     { printf("NOSHOWCANCELLED\n"); } 
"notif0"              { printf("NOTIF0\n"); }
"notif1"              { printf("NOTIF1\n"); }
"or"                  { printf("OR\n"); }
"output"              { return OUTPUT; }
"parameter"           { return PARAMETER;}
"pmos"                { printf("PMOS\n"); }
"posedge"             { printf("POSEDGE\n"); }
"primitive"           { printf("PRIMITIVE\n"); }
"pull0"               { return PULL0; }
"pull1"               { return PULL1; }
"pulldown"            { printf("PULLDOWN\n"); }
"pullup"              { printf("PULLUP\n"); }
"pulsestyle_onevent"  { printf("PULSESTYLE_ONEVENT\n"); }
"pulsestyle_ondetect" { printf("PULSESTYLE_ONDETECT\n"); }
"rcmos"               { printf("RCMOS\n"); }
"real"                { return REAL; }
"realtime"            { return REALTIME; }
"reg"                 { return REG; }
"release"             { printf("RELEASE\n"); }
"repeat"              { printf("REPEAT\n"); }
"rnmos"               { printf("RNMOS\n"); }
"rpmos"               { printf("RPMOS\n"); }
"rtran"               { printf("RTRAN\n"); }
"rtranif0"            { printf("RTRANIF0\n"); }
"rtranif1"            { printf("RTRANIF1\n"); }
"scalared"            { return SCALARED; }
"signed"              { return SIGNED; }
"showcancelled"       { printf("SHOWCANCELLED\n"); }
"small"               { return SMALL; }
"specify"             { printf("SPECIFY\n"); }
"specparam"           { return SPECPARAM; }
"strength"            { printf("STRENGTH\n"); }
"strong0"             { return STRONG0; }
"strong1"             { return STRONG1; }
"supply0"             { return SUPPLY0; }
"supply1"             { return SUPPLY1; }
"table"               { printf("TABLE\n"); }
"task"                { printf("TASK\n"); }
"time"                { return TIME;}
"tran"                { printf("TRAN\n"); }
"tranif0"             { printf("TRANIF0\n"); }
"tranif1"             { printf("TRANIF1\n"); }
"tri"                 { return TRI; }
"tri0"                { return TRI0; }
"tri1"                { return TRI1; }
"triand"              { return TRIAND; }
"trior"               { return TRIOR; }
"trireg"              { return TRIREG; }
"unsigned"            { printf("UNSIGNED\n"); }
"use"                 { printf("USE\n"); }
"vectored"            { return VECTORED; }
"wait"                { printf("WAIT\n"); }
"wand"                { return WAND; }
"weak0"               { return WEAK0; }
"weak1"               { return WEAK1; }
"while"               { printf("WHILE\n"); }
"wire"                { return WIRE; }
"wor"                 { return WOR; }
"xnor"                { printf("XNOR\n"); }
"xor"                 { printf("XOR\n"); }

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
"@"                   { printf("AT : %s \n",yytext); }
"("                   { return OPENPARENTHESES; }
")"                   { return CLOSEPARENTHESES; }
"["                   { return OPENBRACKETS; }
"]"                   { return CLOSEBRACKETS; }
"{"                   { printf("OPENBRACES : %s \n",yytext); }
"}"                   { printf("CLOSEBRACES : %s \n",yytext); }
","                   { return COMMA; }
";"                   { return SEMICOLON; }
"#"                   { return HASH; }
"&"                   { printf("AND : %s \n",yytext); }
"|"                   { printf("OR : %s \n",yytext); }
"+"                   { return ADDITION; }
"-"                   { return SUBTRACTION; }
"*"                   { printf("MULTIPLICATION : %s \n",yytext); }
"/"                   { printf("DIVISION : %s \n",yytext); }
"%"                   { return MODULUS; }
"="                   { return EQUAL; }
"<"                   { printf("LESSTHAN : %s \n",yytext); }
">"                   { printf("GREATERTHAN : %s \n",yytext); }
":"                   { return COLON; }
"?"                   { printf("QUESTION MARK : %s \n",yytext); }
"~"                   { printf("NEGATION : %s \n",yytext); }
"."                   { printf("PERIOD : %s \n",yytext); }
"$"                   { printf("DOLLAR : %s \n",yytext); }

    /* Match Verilog 2001 identifiers. */
[a-zA-Z_][a-zA-Z0-9_$]*                            { return IDENTIFIER; }
[\\][^\n\t ]+                                      { return IDENTIFIER; }
 
    /* Match Verilog 2001 real numbers. */
[0-9]+[.][0-9][0-9_]*                              { return REALV; }
[0-9]+[.][0-9][0-9_]*[eE]-?[0-9]+                  { return REALV; }
[0-9]+[0-9_]*[eE]-?[0-9]+                          { return REALV; }

    /* Match Verilog 2001 integers. */
     /* TODO */
    /* Change UNSIG_DEC tokken for this pattern to integer */
[0-9]+                                             { return UNSIG_DEC; }

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
