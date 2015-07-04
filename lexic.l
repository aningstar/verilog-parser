%{
#include "verilog_parser.tab.h"
#include "string.h"
%}

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
"endmodule"           { printf("ENDMODULE\n"); }
"endprimitive"        { printf("ENDPRIMITIVE\n"); }
"endspecify"          { printf("ENDSPECIFY\n"); }
"endtable"            { printf("ENDTABLE\n"); }
"endtask"             { printf("ENDTASK\n"); }
"event"               { printf("EVENT\n"); }
"for"                 { printf("FOR\n"); }
"force"               { printf("FORCE\n"); }
"forever"             { printf("FOREVER\n"); }
"fork"                { printf("FORK\n"); }
"function"            { printf("FUNCTION\n"); }
"generate"            { printf("GENERATE\n"); }
"genvar"              { printf("GENVAR\n"); }
"highz0"              { printf("HIGHZ0\n"); }
"highz1"              { printf("HIGHZ1\n"); }
"if"                  { printf("IF\n"); }
"ifnone"              { printf("IFNONE\n"); }
"initial"             { printf("INITIAL\n"); }
"instance"            { printf("INSTANCE\n"); }
"inout"               { printf("INOUT\n"); }
"input"               { printf("INPUT\n"); }
"integer"             { printf("INTEGER\n"); }
"join"                { printf("JOIN\n"); }
"large"               { printf("LARGE\n"); }
"liblist"             { printf("LIBLIST\n"); }
"localparam"          { printf("LOCALPARAM\n"); }
"macromodule"         { printf("MACROMODULE\n"); }
"medium"              { printf("MEDIUM\n"); }
"module"              { printf("MODULE\n"); }
"nand"                { printf("NAND\n"); }
"negedge"             { printf("NEGEDGE\n"); }
"nmos"                { printf("NMOS\n"); }
"nor"                 { printf("NOR\n"); }
"not"                 { printf("NOT\n"); }
"noshowcancelled"     { printf("NOSHOWCANCELLED\n"); } 
"notif0"              { printf("NOTIF0\n"); }
"notif1"              { printf("NOTIF1\n"); }
"or"                  { printf("OR\n"); }
"output"              { printf("OUTPUT\n"); }
"parameter"           { printf("PARAMETER\n"); }
"pmos"                { printf("PMOS\n"); }
"posedge"             { printf("POSEDGE\n"); }
"primitive"           { printf("PRIMITIVE\n"); }
"pull0"               { printf("PULL0\n"); }
"pull1"               { printf("PULL1\n"); }
"pulldown"            { printf("PULLDOWN\n"); }
"pullup"              { printf("PULLUP\n"); }
"pulsestyle_onevent"  { printf("PULSESTYLE_ONEVENT\n"); }
"pulsestyle_ondetect" { printf("PULSESTYLE_ONDETECT\n"); }
"rcmos"               { printf("RCMOS\n"); }
"real"                { printf("REAL\n"); }
"realtime"            { printf("REALTIME\n"); }
"reg"                 { printf("REG\n"); }
"release"             { printf("RELEASE\n"); }
"repeat"              { printf("REPEAT\n"); }
"rnmos"               { printf("RNMOS\n"); }
"rpmos"               { printf("RPMOS\n"); }
"rtran"               { printf("RTRAN\n"); }
"rtranif0"            { printf("RTRANIF0\n"); }
"rtranif1"            { printf("RTRANIF1\n"); }
"scalared"            { printf("SCALARED\n"); }
"signed"              { printf("SIGNED\n"); }
"showcancelled"       { printf("SHOWCANCELLED\n"); }
"small"               { printf("SMALL\n"); }
"specify"             { printf("SPECIFY\n"); }
"specparam"           { printf("SPECPARAM\n"); }
"strength"            { printf("STRENGTH\n"); }
"strong0"             { printf("STRONG0\n"); }
"strong1"             { printf("STRONG1\n"); }
"supply0"             { printf("SUPPLY0\n"); }
"supply1"             { printf("SUPPLY1\n"); }
"table"               { printf("TABLE\n"); }
"task"                { printf("TASK\n"); }
"time"                { printf("TIME\n"); }
"tran"                { printf("TRAN\n"); }
"tranif0"             { printf("TRANIF0\n"); }
"tranif1"             { printf("TRANIF1\n"); }
"tri"                 { printf("TRI\n"); }
"tri0"                { printf("TRI0\n"); }
"tri1"                { printf("TRI1\n"); }
"triand"              { printf("TRIAND\n"); }
"trior"               { printf("TRIOR\n"); }
"trireg"              { printf("TRIREG\n"); }
"unsigned"            { printf("UNSIGNED\n"); }
"use"                 { printf("USE\n"); }
"vectored"            { printf("VECTORED\n"); }
"wait"                { printf("WAIT\n"); }
"wand"                { printf("WAND\n"); }
"weak0"               { printf("WEAK0\n"); }
"weak1"               { printf("WEAK1\n"); }
"while"               { printf("WHILE\n"); }
"wire"                { printf("WIRE\n"); }
"wor"                 { printf("WOR\n"); }
"xnor"                { printf("XNOR\n"); }
"xor"                 { printf("XOR\n"); }

    /* Match Verilog 2001 comments. */
[//].*[\n]            { printf("COMMENTS : %s",yytext); }
[/][*].*[*][/]        { printf("COMMENTS : %s \n",yytext); }

    /* Match Verilog 2001 symbols. */
"@"                   { printf("AT : %s \n",yytext); }
"("                   { printf("OPENPARENTHESES : %s \n",yytext); }
")"                   { printf("CLOSEPARENTHESES : %s \n",yytext); }
"["                   { printf("OPENBRACKETS : %s \n",yytext); }
"]"                   { printf("CLOSEBRACKETS : %s \n",yytext); }
"{"                   { printf("OPENBRACES : %s \n",yytext); }
"}"                   { printf("CLOSEBRACES : %s \n",yytext); }
","                   { printf("COMMA : %s \n",yytext); }
";"                   { return SEMICOLON; }
 /* ";"                   { printf("SEMICOLON : %s \n",yytext); } */
"#"                   { printf("HASH : %s \n",yytext); }
"&"                   { printf("AND : %s \n",yytext); }
"|"                   { printf("OR : %s \n",yytext); }
"+"                   { printf("ADDITION : %s \n",yytext); }
"-"                   { printf("SUBTRACTION : %s \n",yytext); }
"="                   { return EQUAL; }
 /* "="                   { printf("EQUAL : %s \n",yytext); } */
"<"                   { printf("LESSTHAN : %s \n",yytext); }
">"                   { printf("GREATERTHAN : %s \n",yytext); }
":"                   { printf("COLON : %s \n",yytext); }
"?"                   { printf("QUESTION MARK : %s \n",yytext); }
"~"                   { printf("NEGATION : %s \n",yytext); }
"%"                   { printf("MODULUS : %s \n",yytext); }
"."                   { printf("PERIOD : %s \n",yytext); }
"$"                   { printf("DOLLAR : %s \n",yytext); }

    /* Match Verilog 2001 identifiers. */
[a-zA-Z_][a-zA-Z0-9_$]*  { yylval.name = yytext[0]; return IDENTIFIER; }
 /* [a-zA-Z_][a-zA-Z0-9_$]*  { printf("IDENTIFIER : %s \n",yytext); } */
[\\][^\n\t ]+         { printf("IDENTIFIER : %s \n",&yytext[1]); }
 
    /* Match Verilog 2001 real numbers. */
[0-9]+[.][0-9][0-9_]*     { printf("REAL NUMBER : %s \n",yytext); }
[0-9]+[.][0-9][0-9_]*[eE]-?[0-9]+ { printf("REAL NUMBER : %s \n",yytext); }
[0-9]+[0-9_]*[eE]-?[0-9]+ { printf("REAL NUMBER : %s \n",yytext); }

    /* Match Verilog 2001 integers. */
[0-9]+                  { printf("UNSIGNED DECIMAL INTEGER : %s \n",yytext); }

    /* Match Verilog 2001 unsigned numbers. */
[0-9]*['][bB][01xXzZ?][01xXzZ?_]*        { strtok(yytext, "'b"); yylval.num = atoi(strtok(NULL, "'b")); return UNSIG_BIN; }            /* Remove binary prefix XX'b from number. */
 /* [0-9]*['][bB][01xXzZ?][01xXzZ?_]*        { printf("UNSIGNED BINARY : %s \n",yytext); } */
[0-9]*['][oO][0-7xXzZ?][0-7xXzZ?_]*       { printf("UNSIGNED OCTAL : %s \n",yytext); }
[0-9]*['][dD][0-9][0-9_]*            { printf("UNSIGNED DECIMAL : %s \n",yytext); }
[0-9]*['][hH][0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]* { printf("UNSIGNED HEXADECIMAL : %s \n",yytext); }

    /* Match Verilog 2001 signed numbers. */
[0-9]*['][s][bB][01xXzZ?][01xXzZ?_]*        { printf("SIGNED BINARY : %s \n",yytext); }
[0-9]*['][s][oO][0-7xXzZ?][0-7xXzZ?_]*       { printf("SIGNED OCTAL : %s \n",yytext); }
[0-9]*['][s][dD][0-9][0-9_]*            { printf("SIGNED DECIMAL : %s \n",yytext); }
[0-9]*['][s][hH][0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]* { printf("SIGNED HEXADECIMAL : %s \n",yytext); }

    /* Match newlines, carriage returns, spaces and tabs. */
[\n\r]+               { printf("NEWLINE\n"); }
[ ]                   { }
[\t]                  { }

    /* Any single character that doesn't match the above rules. */
.                     { printf("UNIDENTIFIED : %c\n",yytext[0]); }

%%
