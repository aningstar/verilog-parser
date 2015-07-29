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
"automatic"           { printf("AUTOMATIC\n"); }
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
"defparam"            { printf("DEFPARAM\n"); }
"design"              { printf("DESIGN\n"); }
"disable"             { return DISABLE; }
"edge"                { printf("EDGE\n"); }
"else"                { return ELSE; }
"end"                 { return END; }
"endcase"             { return ENDCASE; }
"endconfig"           { printf("ENDCONFIG\n"); }
"endfunction"         { printf("ENDFUNCTION\n"); }
"endgenerate"         { printf("ENDGENERATE\n"); }
"endmodule"           { return ENDMODULE; }
"endprimitive"        { printf("ENDPRIMITIVE\n"); }
"endspecify"          { printf("ENDSPECIFY\n"); }
"endtable"            { printf("ENDTABLE\n"); }
"endtask"             { printf("ENDTASK\n"); }
"event"               { return EVENT; }
"for"                 { return FOR; }
"force"               { return FORCE; }
"forever"             { return FOREVER; }
"fork"                { return FORK; }
"function"            { printf("FUNCTION\n"); }
"generate"            { printf("GENERATE\n"); }
"genvar"              { return GENVAR; }
"highz0"              { printf("HIGHZ0\n"); }
"highz1"              { printf("HIGHZ1\n"); }
"if"                  { return IF; }
"ifnone"              { printf("IFNONE\n"); }
"initial"             { return INITIAL_TOKEN; }
"instance"            { printf("INSTANCE\n"); }
"inout"               { return INOUT; }
"input"               { return INPUT; }
"integer"             { return INTEGER; }
"join"                { return JOIN; }
"large"               { return LARGE; }
"liblist"             { printf("LIBLIST\n"); }
"localparam"          { return LOCALPARAM; }
"macromodule"         { printf("MACROMODULE\n"); }
"medium"              { return MEDIUM;}
"module"              { return MODULE; }
"nand"                { return NAND; }
"negedge"             { return NEGEDGE; }
"nmos"                { return NMOS; }
"nor"                 { return NOR; }
"not"                 { return NOT; }
"noshowcancelled"     { printf("NOSHOWCANCELLED\n"); } 
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
"pulsestyle_onevent"  { printf("PULSESTYLE_ONEVENT\n"); }
"pulsestyle_ondetect" { printf("PULSESTYLE_ONDETECT\n"); }
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
"{"                   { printf("OPENBRACES : %s \n",yytext); }
"}"                   { printf("CLOSEBRACES : %s \n",yytext); }
","                   { return COMMA; }
";"                   { return SEMICOLON; }
"#"                   { return HASH; }
"&"                   { printf("AND : %s \n",yytext); }
"|"                   { printf("OR : %s \n",yytext); }
"+"                   { return ADDITION; }
"-"                   { return SUBTRACTION; }
"*"                   { return MULTIPLICATION; }
"/"                   { printf("DIVISION : %s \n",yytext); }
"%"                   { return MODULUS; }
"="                   { return EQUAL; }
"<"                   { return LESSTHAN; }
">"                   { printf("GREATERTHAN : %s \n",yytext); }
":"                   { return COLON; }
"?"                   { printf("QUESTION MARK : %s \n",yytext); }
"~"                   { printf("NEGATION : %s \n",yytext); }
"."                   { return PERIOD; }
"$"                   { printf("DOLLAR : %s \n",yytext); }

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
