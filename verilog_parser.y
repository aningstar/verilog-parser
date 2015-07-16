/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

/* Token declarations */

%token IDENTIFIER
%token NUM_INTEGER REALV
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE
%token EQUAL COMMA COLON SEMICOLON HASH
%token OPENPARENTHESES CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS
%token INPUT OUTPUT INOUT
%token SIGNED
%token ADDITION SUBTRACTION MULTIPLICATION MODULUS
%token VECTORED SCALARED
/* Verilog 2001 net type tokens. */
%token WIRE WOR WAND
%token TRI0 TRI1 TRI TRIOR TRIAND TRIREG
/* Verilog 2001 variable type tokens. */
%token REG INTEGER TIME REAL REALTIME
/* Verilog 2001 other type tokens. */
%token PARAMETER LOCALPARAM SPECPARAM
%token GENVAR EVENT
/* Verilog 2001 drive strength tokens. */
%token SUPPLY0 SUPPLY1 STRONG0 STRONG1 PULL0 PULL1 WEAK0 WEAK1
/* Verilog 2001 capacitance strength tokens. */
%token LARGE MEDIUM SMALL

%error-verbose
%locations

%%

description: /* empty */
| description module { }
;

module: MODULE IDENTIFIER OPENPARENTHESES identifier_list CLOSEPARENTHESES
        SEMICOLON block ENDMODULE { printf("Module.\n"); }
;

identifier_list: /* empty */
| nonempty_identifier_list { }
;

nonempty_identifier_list: IDENTIFIER { }
|                         IDENTIFIER COMMA identifier_list
    { printf("nonempty identifier list "); }
;

block: /* empty */
| block statement  { }
;

statement: assignment  SEMICOLON { printf("\n"); }
|          declaration SEMICOLON { printf("\n"); }
|          declaration_with_attributes SEMICOLON { printf("\n"); }
;

declaration_with_attributes: attributes declaration { }
;

/*               TODO                    */
/* An attribute can appear as a prefix to module items, statements, or port */
/* connections. An attribute can appear as a suffix to an operator or a call */
/* to a function. */
attributes: OPENPARENTHESES MULTIPLICATION attribute_list MULTIPLICATION
    CLOSEPARENTHESES { printf("attributes"); }
;

attribute_list: attribute                      { }
|               attribute_list COMMA attribute { }
;

attribute: IDENTIFIER                  { }
|          IDENTIFIER EQUAL IDENTIFIER { }
|          IDENTIFIER EQUAL number     { }
;

declaration: port_declaration     { }
|            net_declaration      { }
|            variable_declaration { }
|            constant_declaration { }
;

port_declaration: port_direction port_type SIGNED range nonempty_identifier_list
    { }
|                 port_direction port_type SIGNED nonempty_identifier_list { }
|                 port_direction port_type range nonempty_identifier_list { }
|                 port_direction port_type nonempty_identifier_list { }
|                 port_direction SIGNED range nonempty_identifier_list { }
|                 port_direction SIGNED nonempty_identifier_list { }
|                 port_direction range nonempty_identifier_list { }
|                 port_direction nonempty_identifier_list { }
;

/* Port direction can be 'input', 'output' or 'inout'. */
port_direction : INPUT  { printf("input "); }
|                OUTPUT { printf("output "); }
|                INOUT  { printf("inout "); }
;

/* All data types except real. */
port_type: REG                       { }
|          INTEGER                   { }
|          TIME                      { }
|          REALTIME                  { }
|          net_type_except_trireg    { printf("port_type "); }
|          TRIREG                    { }
|          other_type                { printf("port_type "); }
;

/* Many data and port declarations use the optional 'signed' keyword. */
optional_signed : /* empty */
| SIGNED { printf("signed "); }
;

/*  Net Declarations     */
/*      TODO             */
/*     strength          */
/* before or after range */
net_declaration: net_type_except_trireg SIGNED range delay net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg SIGNED range net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg SIGNED delay net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg SIGNED net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg range delay net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg range net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg delay net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg net_name
    { printf("net_declaration\n"); }
|                net_type_except_trireg strength SIGNED range net_name { }
|                net_type_except_trireg strength SIGNED net_name { }
|                net_type_except_trireg strength range net_name { }
|                net_type_except_trireg strength net_name { }
|                TRIREG SIGNED range delay net_name
    { printf("net_declaration\n"); }
|                TRIREG SIGNED range net_name
    { printf("net_declaration\n"); }
|                TRIREG SIGNED delay net_name
    { printf("net_declaration\n"); }
|                TRIREG SIGNED net_name
    { printf("net_declaration\n"); }
|                TRIREG range delay net_name
    { printf("net_declaration\n"); }
|                TRIREG range net_name
    { printf("net_declaration\n"); }
|                TRIREG delay net_name
    { printf("net_declaration\n"); }
|                TRIREG net_name
    { printf("net_declaration\n"); }
|                TRIREG strength SIGNED range net_name { }
|                TRIREG strength SIGNED net_name { }
|                TRIREG strength range net_name { }
|                TRIREG strength net_name { }
|                TRIREG capacitive_strength SIGNED range delay net_name { }
|                TRIREG capacitive_strength SIGNED range net_name { }
|                TRIREG capacitive_strength SIGNED delay net_name { }
|                TRIREG capacitive_strength SIGNED net_name { }
|                TRIREG capacitive_strength range delay net_name { }
|                TRIREG capacitive_strength range net_name { }
|                TRIREG capacitive_strength delay net_name { }
|                TRIREG capacitive_strength net_name { }
;

/* NOTE: trireg can be declared with capacitance strength, so it cannot be */
/* treated like a regular variable. */
net_type_except_trireg: WIRE    { printf("wire "); }
|                       WOR     { }
|                       WAND    { }
|                       SUPPLY0 { }
|                       SUPPLY1 { }
|                       TRI0    { }
|                       TRI1    { }
|                       TRI     { }
|                       TRIOR   { }
|                       TRIAND  { }
;

/* Delays to transitions. */
/* 1 delay (all transitions) */
/* 2 delays (rise and fall transitions)
/* 3 delays (rise, fall and tri-state turn-off transitions) */
delay: HASH transition                                                   { }
|      HASH OPENPARENTHESES transition CLOSEPARENTHESES                  { }
|      HASH OPENPARENTHESES transition COMMA transition CLOSEPARENTHESES { }
|      HASH OPENPARENTHESES transition COMMA transition COMMA transition
    CLOSEPARENTHESES { }
;

/* Each delay transition can be a single number or a minimum:typical:max */
/* delay range. */
transition: integer_or_real { }
|           integer_or_real COLON integer_or_real COLON integer_or_real { }
;

net_name: array_list { }
|         assignment { }
;

/* ################################################################## */
/* Variable data types declared with 3 ways:                          */
/*  •variable_type signed [range] variable_name, variable_name, ... ; */
/*  •variable_type signed [range] variable_name = initial_value, ... ;*/
/*  •variable_type signed [range] variable_name [array], ... ;        */
/* signed,range values and keywords vectored, scalared may only be    */
/* used with reg variables */
variable_declaration: REG v_o_keywords optional_signed optional_range
    variable_name { }
|                     variable_type variable_name array_list { }
;

/* The keywords vectored or scalared may be used immediately following */
/* the reg keyword. Software tools and/or the Verilog PLI may restrict */
/* access to individual bits within a vector that is declared as       */
/* vectored. */
v_o_keywords:         { }
|            VECTORED { printf("vectored "); }
|            SCALARED { printf("scalared "); }
;

/* The variable names are declared as :       */
/* •variable_name, variable_name, ... ;       */
/* •variable_name = initial_value, ... ;      */
/* •variable_name [array], ... ;              */
variable_name: IDENTIFIER                     { printf("identifier "); }
|              IDENTIFIER COMMA variable_name { printf("identifier "); }
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
/*           TODO multiple initialisations in one line              */
variable_initial: IDENTIFIER EQUAL integer_or_real
    { printf("variable initial "); }
;

variable_type:  INTEGER  { printf("integer "); }
|               TIME     { printf("time "); }
|               REAL     { printf("real "); }
|               REALTIME { printf("realtime "); }
;

/* ################################################################ */ 
/* Constant declarations */
/*    TODO    */
/* genvar ??? */
constant_declaration: PARAMETER optional_signed optional_range constant_variable
    { printf("parameter "); }
|                     PARAMETER constant_type constant_variable
    { printf("parameter "); }
|                     LOCALPARAM optional_signed optional_range
    constant_variable { printf("localparam "); }
|                     LOCALPARAM constant_type constant_variable
    { printf("localparam "); }
|                     SPECPARAM constant_variable { printf("specparam "); }
|                     EVENT event_names { printf("event "); }
;

/* A constant declared with a type will have the same properties as */
/* a variable of that type. If no type is specified, the constant   */
/* will default to the data type of the last value assigned to it,  */
/* after any parameter redefinitions. The case where no type is     */
/* handled in constant_declaration. */
constant_type: INTEGER    { printf("integer "); }
|              TIME       { printf("time ");    }
|              REAL       { printf("real ");    }
|              REALTIME   { printf("realtime "); }
;

constant_variable: IDENTIFIER EQUAL number {printf("constant "); }
|                  IDENTIFIER EQUAL number COMMA constant_variable
    {printf("constant "); }
;

/* a momentary flag with no logic value or data storage. Can be      */
/* used for synchronizing concurrent activities within a module.    */
event_names: IDENTIFIER                   { printf("identifier "); }
|            IDENTIFIER COMMA event_names { printf("identifier "); }
;

array_list: IDENTIFIER COMMA array_list       { printf("identifier "); }
|           IDENTIFIER array                  { printf("identifier "); }
|           IDENTIFIER array COMMA array_list { printf("identifier "); }
;

/* Logic values can have 8 strength levels: */
/* 4 driving, 3 capacitive, and high        */
/* impedance (no strength).                 */
strength: OPENPARENTHESES strength0 COMMA strength1 CLOSEPARENTHESES
    { printf("strength0, strength1 "); }
|         OPENPARENTHESES strength1 COMMA strength0 CLOSEPARENTHESES
    { printf("strength1, strength0 "); }
;

capacitive_strength: OPENPARENTHESES capacitive CLOSEPARENTHESES
    { printf("capacitive_strength "); }
;

/* n-dimensional array */
array: range       { printf("array "); }
|      range array { printf("array "); }
;

optional_range: /* empty */
| range { }
;

/* range is optional and is from [msb :lsb] */
/* The msb and lsb must be a literal number, a constant, an expression, */
/* or a call to a constant function. */
range : OPENBRACKETS range_value COLON range_value CLOSEBRACKETS
    { printf("range "); }
;

/*              TODO           */
/*   Range value expressions   */
range_value: NUM_INTEGER                        { }
|            constants                          { }
|            constants ADDITION NUM_INTEGER     { }
|            constants SUBTRACTION NUM_INTEGER  { }
|            constants MODULUS NUM_INTEGER      { }
|            NUM_INTEGER ADDITION constants     { }
|            NUM_INTEGER SUBTRACTION constants  { }
|            NUM_INTEGER MODULUS constants      { }
;

constants: IDENTIFIER      { }
|          function_call   { }
;

/* call to constant function */
function_call: IDENTIFIER OPENPARENTHESES IDENTIFIER CLOSEPARENTHESES { }
|              IDENTIFIER OPENPARENTHESES number CLOSEPARENTHESES { }
;

other_type: PARAMETER  { }
|           LOCALPARAM { }
|           SPECPARAM  { }
|           GENVAR     { }
|           EVENT      { }
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
assignment: IDENTIFIER EQUAL expression { printf("assignment "); }
;

expression: expression_term {printf("expression "); }
|           expression_term expression_operation expression_term
    {printf("expression "); }
|           expression_term expression_operation expression_term
    expression_operation expression {printf("expression "); }
;

expression_term: number
|                IDENTIFIER
|                bit_select
;

expression_operation:  ADDITION    { }
|                      SUBTRACTION { }
;

/* Vector Bit Selects and Part Selects */
bit_select: IDENTIFIER OPENBRACKETS bit_number CLOSEBRACKETS
    { printf("bit_select "); }
|           IDENTIFIER OPENBRACKETS bit_number COLON bit_number CLOSEBRACKETS
    { printf("bit_select "); }
;

bit_number: NUM_INTEGER                         { }
|           IDENTIFIER                          { }
|           IDENTIFIER ADDITION bit_number      { }
|           IDENTIFIER SUBTRACTION bit_number   { }
|           NUM_INTEGER ADDITION bit_number     { }
|           NUM_INTEGER SUBTRACTION bit_number  { }
;

integer_or_real: NUM_INTEGER { }
|                REALV       { }
;

number: UNSIG_BIN { }
|       UNSIG_OCT { }
|       UNSIG_DEC { }
|       UNSIG_HEX { }
|       SIG_BIN   { }
|       SIG_OCT   { }
|       SIG_DEC   { }
|       SIG_HEX   { }
|       REALV     { }
;

%%

main (int argc, char *argv[]) {
    yyparse();
}

yyerror(char *error_string) {
    fprintf(stderr, "ERROR in line %d: %s\n", yylloc.first_line, error_string);
}