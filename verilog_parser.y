/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

/* Token declarations */

%token IDENTIFIER
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token REAL
%token MODULE ENDMODULE
%token EQUAL COMMA COLON SEMICOLON
%token OPENPARENTHESES CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS
%token INPUT OUTPUT INOUT WIRE

%%

description: /* empty */
 | description module { }
 ;

module: MODULE IDENTIFIER OPENPARENTHESES identifier_list CLOSEPARENTHESES
        SEMICOLON block ENDMODULE { printf("Module.\n"); }
 ;

identifier_list: /* empty */
 | IDENTIFIER { }
 | IDENTIFIER COMMA identifier_list { }
 ;

block: /* empty */
 | block statement  { }
 ;

statement: expression SEMICOLON { printf("Statement.\n"); }
 |         declaration SEMICOLON { printf("Declaration.\n"); }
 ;

declaration: io_declaration { }
 |           wire_declaration { }
 ;

io_declaration: INPUT identifier_list { }
 |              OUTPUT identifier_list { }
 |              INOUT identifier_list { }
 |              INPUT OPENBRACKETS number COLON number CLOSEBRACKETS
                identifier_list { }
 |              OUTPUT OPENBRACKETS number COLON number CLOSEBRACKETS
                identifier_list { }
 |              INOUT OPENBRACKETS number COLON number CLOSEBRACKETS
                identifier_list { }
 |
 ;

wire_declaration: WIRE identifier_list { }
 |                WIRE OPENBRACKETS number COLON number CLOSEBRACKETS
                  identifier_list { }
 ;

expression: IDENTIFIER EQUAL number { printf("Assignment.\n"); }
 |          number { }
 ;

number: UNSIG_BIN { }
 |      UNSIG_OCT { }
 |      UNSIG_DEC { }
 |      UNSIG_HEX { }
 |      SIG_BIN { }
 |      SIG_OCT { }
 |      SIG_DEC { }
 |      SIG_HEX { }
 |      REAL { }
 ;

%%

main (int argc, char *argv[]) {
	yyparse();
}

yyerror(char *error_string) {
	fprintf(stderr, "error: %s\n", error_string);
}