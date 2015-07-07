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
%token INPUT OUTPUT INOUT WIRE REG
%token SIGNED

%%

description: /* empty */
 | description module { }
 ;

module: MODULE IDENTIFIER OPENPARENTHESES identifier_list CLOSEPARENTHESES
        SEMICOLON block ENDMODULE { printf("Module.\n"); }
 ;

identifier_list: /* empty */
 | IDENTIFIER { printf("identifier ");}
 | IDENTIFIER COMMA identifier_list { }
 ;

block: /* empty */
 | block statement  { }
 ;

statement: expression SEMICOLON { printf("\n"); }
 |         declaration SEMICOLON { printf("\n"); }
 ;

declaration: port_declaration { }
 ;
            /* Port Declarations */
port_declaration: port_direction data_type signed range identifier_list { }
|                 port_direction signed range identifier_list { }
;

port_direction : INPUT  {printf("input "); }
|                OUTPUT {printf("output "); }
|                INOUT  {printf("inout "); }
;

data_type :  { }
;

range :
|      OPENBRACKETS range_value COLON range_value CLOSEBRACKETS {printf("range ");}
;

range_value: number
;

signed : 
|       SIGNED { printf("signed "); }
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
