/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

/* Token declarations */

%token IDENTIFIER
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE
%token EQUAL COMMA SEMICOLON OPENPARENTHESES CLOSEPARENTHESES

%%

description: /* empty */
 | description module { }
 ;

module: MODULE IDENTIFIER OPENPARENTHESES port_list CLOSEPARENTHESES SEMICOLON
        block ENDMODULE { printf("Module.\n"); }
 ;

port_list: /* empty */
 | IDENTIFIER { }
 | IDENTIFIER COMMA port_list { }
 ;

block: /* empty */
 | block statement  { }
 ;

statement: expression SEMICOLON { printf("Statement.\n"); }
 ;

expression: IDENTIFIER EQUAL number { printf("Assignment.\n"); }
 |          number { }
 ;

number: UNSIG_BIN { }
 |      UNSIG_OCT { }
 |      UNSIG_DEC { }
 |      UNSIG_HEX { }
 |      SIG_BIN { printf("Sbin.\n"); }
 |      SIG_OCT { printf("Soct.\n"); }
 |      SIG_DEC { printf("Sdec.\n"); }
 |      SIG_HEX { printf("Shex.\n"); }
 ;

%%

main (int argc, char *argv[]) {
	yyparse();
}

yyerror(char *error_string) {
	fprintf(stderr, "error: %s\n", error_string);
}