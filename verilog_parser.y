/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

/* Token declarations */

%token IDENTIFIER
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE
%token EQUAL COMMA COLON SEMICOLON HASH
%token OPENPARENTHESES CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS
%token INPUT OUTPUT INOUT
%token SIGNED
%token ADDITION SUBTRACTION MODULUS
/* net types */
%token WIRE WOR WAND SUPPLY0 SUPPLY1 
%token TRI0 TRI1 TRI TRIOR TRIAND TRIREG
/* variable types */
%token REG INTEGER TIME REAL REALTIME
/* other types */
%token PARAMETER LOCALPARAM SPECPARAM
%token GENVAR EVENT

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

statement: assignment  SEMICOLON { printf("\n"); }
 |         declaration SEMICOLON { printf("\n"); }
 ;

declaration: port_declaration { }
|            net_declaration  { }
 ;

/*  Port Declarations  */
port_declaration: port_direction data_type signed range identifier_list { }
|                 port_direction signed range identifier_list { }
;
/*  Net Declarations   */
net_declaration: net_type signed range delay net_list { printf("net_declaration\n");}
;
/* */
net_list: IDENTIFIER                      { printf("identifier "); } 
|         IDENTIFIER COMMA net_list       { printf("identifier "); }
|         IDENTIFIER array                { printf("identifier "); }
|         IDENTIFIER array COMMA net_list { printf("identifier "); }
;
/* n-dimensional array */
array: range       { printf("array "); }
|      range array { printf("array "); }
;
/* delays to transitions */
/* 1 number for all output transitions */
/* 2 numbers for rise, fall output transitions */
/* 3 numbers for rise, fall, turn-off output transitions */
delay:
|     HASH dec_real                                                  { }
|     HASH OPENPARENTHESES dec_real CLOSEPARENTHESES                 { }
|     HASH OPENPARENTHESES dec_real COMMA dec_real CLOSEPARENTHESES  { }
|     HASH OPENPARENTHESES dec_real COMMA dec_real COMMA dec_real CLOSEPARENTHESES { }
;
/* port direction is declared as: */
/* input, output, and inout ports */
port_direction : INPUT  {printf("input "); }
|                OUTPUT {printf("output "); }
|                INOUT  {printf("inout "); }
;
/* range is optional and is from [msb :lsb] */
/* The msb and lsb must be a literal number, a constant, an expression, */
/* or a call to a constant function. */
range :
|      OPENBRACKETS range_value COLON range_value CLOSEBRACKETS {printf("range ");}
;
range_value: UNSIG_DEC                        { }
|            constants                        { }
|            constants ADDITION UNSIG_DEC     { }
|            constants SUBTRACTION UNSIG_DEC  { }
|            constants MODULUS UNSIG_DEC      { }
|            UNSIG_DEC ADDITION constants     { }
|            UNSIG_DEC SUBTRACTION constants  { }
|            UNSIG_DEC MODULUS constants      { }
;

constants: IDENTIFIER      { }
|          function_call   { }
;
/* call to constant function */
function_call: IDENTIFIER OPENPARENTHESES IDENTIFIER CLOSEPARENTHESES { }
|              IDENTIFIER OPENPARENTHESES number CLOSEPARENTHESES { }
;
/* signed is optional */
signed : 
|       SIGNED { printf("signed "); }
;
/* ####################### */
/* Data types */
data_type : net_type      { printf("data_type "); }
|           variable_type { printf("data_type "); }
|           other_type    { printf("data_type "); }
;
net_type: WIRE    { }
|         WOR     { } 
|         WAND    { }
|         SUPPLY0 { }
|         SUPPLY1 { }
|         TRI0    { } 
|         TRI1    { }
|         TRI     { }
|         TRIOR   { }
|         TRIAND  { }
|         TRIREG  { }
;
/* except REAL */
variable_type: REG      { }
|              INTEGER  { }
|              TIME     { }
|              REALTIME { }
;
other_type:    PARAMETER  { }
|              LOCALPARAM { }
|              SPECPARAM  { }
|              GENVAR     { }
|              EVENT      { }
;
/* ######################## */
assignment: IDENTIFIER EQUAL expression       { printf("assignment ");}
;
expression: number                            { }
|           IDENTIFIER                        { }
|           number ADDITION expression        { }
|           number SUBTRACTION expression     { }
|           IDENTIFIER ADDITION expression    { }
|           IDENTIFIER SUBTRACTION expression { }
;

dec_real: UNSIG_DEC { }
|         REAL      { }
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
