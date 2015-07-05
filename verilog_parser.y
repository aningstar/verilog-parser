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
%token EQUAL SEMICOLON

%type <num> statement number

%%

block: 
   /* empty */
 | block statement { printf("Added statement %d\n", $2); }
 ;

statement: IDENTIFIER EQUAL number SEMICOLON 
				{ $$ = $3;
				  printf("Assigned value %d to identifier %c\n", $3, $1); }
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