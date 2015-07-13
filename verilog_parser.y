/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

/* Token declarations */

%token IDENTIFIER
%token REALV
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE
%token EQUAL COMMA COLON SEMICOLON HASH
%token OPENPARENTHESES CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS
%token INPUT OUTPUT INOUT
%token SIGNED
%token ADDITION SUBTRACTION MODULUS
%token VECTORED SCALARED
/* net types */
%token WIRE WOR WAND 
%token TRI0 TRI1 TRI TRIOR TRIAND TRIREG
/* variable types */
%token REG INTEGER TIME REAL REALTIME
/* other types */
%token PARAMETER LOCALPARAM SPECPARAM
%token GENVAR EVENT
/* drive strength */
%token SUPPLY0 SUPPLY1 STRONG0 STRONG1 PULL0 PULL1 WEAK0 WEAK1
/* capacitive strength */
%token LARGE MEDIUM SMALL

%error-verbose

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

declaration: port_declaration     { }
|            net_declaration      { }
|            variable_declaration { }
|            constant_declaration { }
;

/*  Port Declarations   */
port_declaration: port_direction port_type signed range identifier_list { }
|                 port_direction signed range identifier_list { }
;
/* port direction is declared as: */
/* input, output, and inout ports */
port_direction : INPUT  {printf("input "); }
|                OUTPUT {printf("output "); }
|                INOUT  {printf("inout "); }
;
/* all data types except real */
port_type : REG         { }
|           INTEGER     { }
|           TIME        { }
|           REALTIME    { }
|           net_type    { printf("port_type "); }
|           other_type  { printf("port_type "); }
;
;
/*  Net Declarations     */
/*      TODO             */
/*     strength          */
/* before or after range */
net_declaration: net_type signed range delay net_name { printf("net_declaration\n");}
|                net_type strength signed range delay net_name { }
|                TRIREG capacitive_strength signed range decay_time net_name { } 
;
/* */
net_name: array_list   { }
|         assignment { }
;
/* ################################################################## */
/* Variable data types declared with 3 ways:                          */
/*  •variable_type signed [range] variable_name, variable_name, ... ; */
/*  •variable_type signed [range] variable_name = initial_value, ... ;*/
/*  •variable_type signed [range] variable_name [array], ... ;        */
/* signed,range values and keywords vectored, scalared may only be    */
/* used with reg variables */
variable_declaration: REG v_o_keywords signed range variable_name { } 
|                     variable_type variable_name                 { }
;
/* The keywords vectored or scalared may be used immediately following */
/* the reg keyword. Software tools and/or the Verilog PLI may restrict */
/* access to individual bits within a vector that is declared as       */
/* vectored. */
v_o_keywords:         { }
|            VECTORED { printf("vectored ");}
|            SCALARED { printf("scalared ");}
;
/* The variable names are declared as :       */
/* •variable_name, variable_name, ... ;       */
/* •variable_name = initial_value, ... ;      */
/* •variable_name [array], ... ;              */
variable_name: IDENTIFIER                     { printf("identifier ");}
|              IDENTIFIER COMMA variable_name { printf("identifier ");}
|              array_list                     { }
|              variable_initial               { }
;
/* initial_value (optional) sets the initial value of the variable. */
/* • The value is set in simulation time 0,                         */
/*   the same as if the variable had been                           */
/*   assigned a value in an initial procedure.                      */
/* • If not initialized, the default value for                      */
/*   reg, integer and time variables is X,                          */
/*   and the initial value for real and                             */ 
/*   realtime variables is 0.0.                                     */
variable_initial: IDENTIFIER EQUAL dec_real                        { printf("variable initial ");}
|                 IDENTIFIER EQUAL dec_real COMMA variable_initial { printf("variable initial ");}
;
variable_type:  INTEGER  { printf("integer ");}
|               TIME     { printf("time ");}
|               REAL     { printf("real ");}
|               REALTIME { printf("realtime ");}
;
/* ################################################################ */ 
/* Constant declarations */
/*    TODO    */
/* genvar ??? */
constant_declaration: PARAMETER signed range constant_variable     {printf("parameter "); }
|                     PARAMETER constant_type constant_variable    {printf("parameter ");}
|                     LOCALPARAM signed range constant_variable    {printf("localparam ");}
|                     LOCALPARAM constant_type constant_variable   {printf("localparam ");}
|                     SPECPARAM constant_variable                  {printf("specparam "); }
|                     EVENT event_names                            {printf("event "); }
;
/* A constant declared with a type will have the same properties as */
/* a variable of that type. If no type is specified, the constant   */
/* will default to the data type of the last value assigned to it,  */
/* after any parameter redefinitions. */ 
constant_type:           { }
|             INTEGER    { printf("integer "); }
|             TIME       { printf("time ");    }
|             REAL       { printf("real ");    }
|             REALTIME   { printf("realtime ");}
;
constant_variable: IDENTIFIER EQUAL number                         {printf("constant "); }
|                  IDENTIFIER EQUAL number COMMA constant_variable {printf("constant "); }
;
/* a momentary flag with no logic value or data storage.Can be      */
/* used for synchronizing concurrent activities within a module.    */
event_names: IDENTIFIER                   {printf("identifier "); }
|            IDENTIFIER COMMA event_names {printf("identifier "); }
;
/* */
array_list: IDENTIFIER                        { printf("identifier "); } 
|           IDENTIFIER COMMA array_list       { printf("identifier "); }
|           IDENTIFIER array                  { printf("identifier "); }
|           IDENTIFIER array COMMA array_list { printf("identifier "); }
;
/* Logic values can have 8 strength levels: */
/* 4 driving, 3 capacitive, and high        */
/* impedance (no strength).                 */
strength: 
|         OPENPARENTHESES strength0 COMMA strength1 CLOSEPARENTHESES { printf("strength0,strength1 ");}
|         OPENPARENTHESES strength1 COMMA strength0 CLOSEPARENTHESES { printf("strength1,strength0 ");}
;
capacitive_strength :
|         OPENPARENTHESES capacitive CLOSEPARENTHESES       { printf("capacitive_strength ");}
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
decay_time:
          |       HASH OPENPARENTHESES dec_real COMMA dec_real COMMA dec_real CLOSEPARENTHESES { }
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
net_type: WIRE    { printf("wire ");}
|         WOR     { } 
|         WAND    { }
|         SUPPLY0 { }
|         SUPPLY1 { }
|         TRI0    { } 
|         TRI1    { }
|         TRI     { }
|         TRIOR   { }
|         TRIAND  { }
|         TRIREG  { printf("trireg "); }
;
other_type:    PARAMETER  { }
|              LOCALPARAM { }
|              SPECPARAM  { }
|              GENVAR     { }
|              EVENT      { }
;
/* ######################## */
/* Drive strength           */
strength0: SUPPLY0 { }
|          STRONG0 { }
|          PULL0   { }
|          WEAK0   { }
;
strength1: SUPPLY1 { }
|          STRONG1 { }
|          PULL1   { }
|          WEAK1   { }
;
/* Capacitive strengths     */
capacitive: LARGE  { }
|           MEDIUM { }
|           SMALL  { }
;
/* ######################## */
assignment: IDENTIFIER EQUAL expression       { printf("assignment ");}
;
expression: expression_term                                                                      {printf("expression "); }
|           expression_term expression_operation expression_term                                 {printf("expression "); }
|           expression_term expression_operation expression_term expression_operation expression {printf("expression "); }
;
expression_term: number
|                IDENTIFIER
|                bit_select
;
expression_operation:  ADDITION    { }
|                      SUBTRACTION { }
;
/* Vector Bit Selects and Part Selects */
bit_select: IDENTIFIER OPENBRACKETS bit_number CLOSEBRACKETS                  {printf("bit_select "); }
|           IDENTIFIER OPENBRACKETS bit_number COLON bit_number CLOSEBRACKETS {printf("bit_select "); }
;
bit_number: UNSIG_DEC                         { }
|           IDENTIFIER                        { }
|           IDENTIFIER ADDITION bit_number    { }
|           IDENTIFIER SUBTRACTION bit_number { }
|           UNSIG_DEC ADDITION bit_number     { }
|           UNSIG_DEC SUBTRACTION bit_number  { }
;
dec_real: UNSIG_DEC { }
|         REALV
;

number: UNSIG_BIN { }
 |      UNSIG_OCT { }
 |      UNSIG_DEC { }
 |      UNSIG_HEX { }
 |      SIG_BIN { }
 |      SIG_OCT { }
 |      SIG_DEC { }
 |      SIG_HEX { }
 |      REALV{ }
 ;

%%

main (int argc, char *argv[]) {
	yyparse();
}

yyerror(char *error_string) {
	fprintf(stderr, "error: %s\n", error_string);
}
