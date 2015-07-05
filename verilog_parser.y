/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

%union {
	long int num;
	char name;                   /* Currently the identifier's first letter. */
}

/* Token declarations */

%token <name> IDENTIFIER
%token <num> UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
%token MODULE ENDMODULE
%token EQUAL COMMA SEMICOLON OPENPARENTHESES CLOSEPARENTHESES

%type <num> statement expression number

%%

description: /* empty */
 | description module { }
 ;

module: MODULE IDENTIFIER OPENPARENTHESES port_list CLOSEPARENTHESES SEMICOLON
        block ENDMODULE { }
 ;

port_list: /* empty */
 | IDENTIFIER { }
 | IDENTIFIER COMMA port_list { }
 ;

block: /* empty */
 | block statement  { }
 ;

statement: expression SEMICOLON { $$ = $1;
                     printf("Statement %d\n", $1); }
 ;

expression: IDENTIFIER EQUAL number { $$ = $3;
                     printf("Assigned value %d to identifier %c\n", $3, $1); }
 |          number { }
 ;

number: UNSIG_BIN { }
 |      UNSIG_OCT { }
 |      UNSIG_DEC { }
 |      UNSIG_HEX { }
 ;

%%

main (int argc, char *argv[]) {
	yyparse();
}

yyerror(char *error_string) {
	fprintf(stderr, "error: %s\n", error_string);
}