/* Verilog 2001 parser */

%{
#include <stdio.h>
%}

/* Token declarations */

%token IDENTIFIER
%token NUM_INTEGER REALV
/* Verilog 2001 unsigned literals. */
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
/* Verilog 2001 signed literals. */
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE
%token EQUAL COMMA COLON SEMICOLON HASH
%token OPENPARENTHESES CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS
/* Verilog 2001 port diractions. */
%token INPUT OUTPUT INOUT
%token SIGNED
%token ADDITION SUBTRACTION MULTIPLICATION MODULUS
%token VECTORED SCALARED
/* Verilog 2001 net type tokens. */
%token WIRE WOR WAND TRI0 TRI1 TRI TRIOR TRIAND TRIREG
/* Verilog 2001 variable type tokens. */
%token REG INTEGER TIME REAL REALTIME
/* Verilog 2001 other type tokens. */
%token PARAMETER LOCALPARAM SPECPARAM GENVAR EVENT
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
|            net_declaration      { printf("net_declaration"); }
|            variable_declaration { printf("variable_declaration"); }
|            constant_or_event_declaration
    { printf("constant_or_event_declaration"); }
;

/*             Port declarations.          */
/*******************************************/
/* There are 2 types of port declarations. */
/*******************************************/
/* 1st type, combined declarations (added in Verilog-2001): */
/*     port_direction data_type signed range port_name, port_name, ... ; */
/* 2nd type, old style declarations: */
/*     port_direction signed range port_name, port_name, ... ; */
/*     data_type_declarations */
/*******************************************/
/* 2nd type declarations are a subset of 1st type declarations. 'data_type', */
/* 'signed' and 'range' are all optional. */
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
|          net_type_except_trireg    { }
|          TRIREG                    { }
|          other_type                { }
;

other_type: PARAMETER  { }
|           LOCALPARAM { }
|           SPECPARAM  { }
|           GENVAR     { }
|           EVENT      { }
;

/*             Net declarations.          */
/******************************************/
/* There are 3 types of net declarations. */
/******************************************/
/* 1st type: net_type signed [range] #(delay) net_name [array], ... ; */
/* 2nd type: net_type (drive_strength) signed [range] #(delay) net_name = */
/*     continuous_assignment; */
/* 3rd type: trireg (capacitance_strength) signed [range] */
/*     #(delay, decay_time) net_name [array], ... ; */
/******************************************/
/* 'signed', 'range', 'delay' and 'drive_strength' are all optional. 'trireg' */
/* is treated  separately so that 3rd type declarations can also be matched. */
/* The keywords 'vectored' or scalared' may be used immediately following the */
/* net_type keyword. */
net_declaration: /* 1st type net declarations (except trireg). */
                 net_type_except_trireg optional_vectored_or_scalared SIGNED
    range delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared SIGNED
    range net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared SIGNED
    delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared SIGNED
    net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared range
    delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared range
    net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared delay
    net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared
    net_name_list { }
                 /* 1st type net declarations (trireg). */
|                TRIREG optional_vectored_or_scalared SIGNED range delay
    net_name_list { }
|                TRIREG optional_vectored_or_scalared SIGNED range
    net_name_list { }
|                TRIREG optional_vectored_or_scalared SIGNED delay
    net_name_list { }
|                TRIREG optional_vectored_or_scalared SIGNED net_name_list { }
|                TRIREG optional_vectored_or_scalared range delay
    net_name_list { }
|                TRIREG optional_vectored_or_scalared range net_name_list { }
|                TRIREG optional_vectored_or_scalared delay net_name_list { }
|                TRIREG optional_vectored_or_scalared net_name_list { }
                 /* 2nd type net declarations (except trireg). */
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    range delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    range IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    IDENTIFIER EQUAL expression { }
                 /* 2nd type net declarations (trireg). */
|                TRIREG optional_vectored_or_scalared strength SIGNED range
    delay IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED range
    IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED delay
    IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED IDENTIFIER
    EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength range delay
    IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength range IDENTIFIER
    EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength delay IDENTIFIER
    EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength IDENTIFIER EQUAL
    expression { }
                 /* 3rd type net declarations. */
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED range delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED range net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    range delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    range net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    net_name_list { }
;

/* The keywords vectored or scalared may be used immediately following */
/* data type keywords. Software tools and/or the Verilog PLI may restrict */
/* access to individual bits within a vector that is declared as */
/* vectored. */
optional_vectored_or_scalared: /* empty */
| VECTORED { printf("vectored "); }
| SCALARED { printf("scalared "); }
;

/* NOTE: trireg can be declared with capacitance strength, so it cannot be */
/* treated like a regular net type. */
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
/* 2 delays (rise and fall transitions) */
/* 3 delays (rise, fall and tri-state turn-off transitions) */
delay: HASH transition                                                   { }
|      HASH OPENPARENTHESES transition CLOSEPARENTHESES                  { }
|      HASH OPENPARENTHESES transition COMMA transition CLOSEPARENTHESES { }
|      HASH OPENPARENTHESES transition COMMA transition COMMA transition
    CLOSEPARENTHESES { }
;

/* Each delay transition can be a single number or a minimum:typical:max */
/* delay range. */
transition: integer_or_real                                             { }
|           integer_or_real COLON integer_or_real COLON integer_or_real { }
;

net_name_list: net_name                     { }
|              net_name_list COMMA net_name { }
;

net_name: IDENTIFIER       { }
|         IDENTIFIER array { }
;

/* n-dimensional array */
array: range       { printf("array "); }
|      array range { printf("array "); }
;

/* range is optional and is from [ msb : lsb ] */
/* The msb and lsb must be a literal number, a constant, an expression, */
/* or a call to a constant function. */
range : OPENBRACKETS range_value COLON range_value CLOSEBRACKETS
    { printf("range "); }
;

/*              TODO           */
/*   Range value expressions   */
range_value: NUM_INTEGER                                            { }
|            constant_or_constant_function                          { }
|            constant_or_constant_function ADDITION NUM_INTEGER     { }
|            constant_or_constant_function SUBTRACTION NUM_INTEGER  { }
|            constant_or_constant_function MODULUS NUM_INTEGER      { }
|            NUM_INTEGER ADDITION constant_or_constant_function     { }
|            NUM_INTEGER SUBTRACTION constant_or_constant_function  { }
|            NUM_INTEGER MODULUS constant_or_constant_function      { }
;

constant_or_constant_function: IDENTIFIER             { }
|                              constant_function_call { }
;

/* Call to constant function. */
constant_function_call: IDENTIFIER OPENPARENTHESES IDENTIFIER CLOSEPARENTHESES
    { }
|                       IDENTIFIER OPENPARENTHESES number CLOSEPARENTHESES
    { }
;

/* Logic values can have 8 strength levels: 4 driving, 3 capacitive, and high */
/* impedance (no strength). */
strength: OPENPARENTHESES strength0 COMMA strength1 CLOSEPARENTHESES
    { printf("strength0, strength1 "); }
|         OPENPARENTHESES strength1 COMMA strength0 CLOSEPARENTHESES
    { printf("strength1, strength0 "); }
;

/* Drive strength 0. */
strength0: SUPPLY0 { }
|          STRONG0 { }
|          PULL0   { }
|          WEAK0   { }
;

/* Drive strength 1. */
strength1: SUPPLY1 { }
|          STRONG1 { }
|          PULL1   { }
|          WEAK1   { }
;

capacitance_strength: OPENPARENTHESES capacitance CLOSEPARENTHESES
    { printf("capacitance_strength "); }
;

/* Capacitance strengths. */
capacitance: LARGE  { }
|            MEDIUM { }
|            SMALL  { }
;

/*            Variable declarations.           */
/***********************************************/
/* There are 3 types of variable declarations. */
/***********************************************/
/* 1st type: variable_type signed [range] variable_name, variable_name, ... ; */
/* 2nd type: variable_type signed [range] variable_name = initial_value, */
/*     ... ; */
/* 3rd type: variable_type signed [range] variable_name [array], ... ; */
/***********************************************/
/* 'signed' and 'range' are both optional and may only be used with reg */
/* variables. The keywords 'vectored' or scalared' may be used immediately */
/* following the reg keyword. To match these cases, 'reg' is treated */
/* separately. 'initial_value' is optional. Any of the 3 types of variable */
/* declarations can be in the same statement (separated by commas). */
variable_declaration: /* 1st, 2nd and 3rd type variable declarations (except
    reg). */
                      variable_type_except_reg variable_name_list { }
                      /* 1st, 2nd and 3rd type variable declarations (reg). */
|                     REG optional_vectored_or_scalared SIGNED
    range variable_name_list { }
|                     REG optional_vectored_or_scalared SIGNED
    variable_name_list { }
|                     REG optional_vectored_or_scalared
    range variable_name_list { }
|                     REG optional_vectored_or_scalared variable_name_list { }
;

/* NOTE: reg can be declared with 'signed', 'range', 'vectored' and */
/* 'scalared' optional keywords so it cannot be  treated like a regular */
/* variable type. */
variable_type_except_reg: INTEGER  { printf("integer "); }
|                         TIME     { printf("time "); }
|                         REAL     { printf("real "); }
|                         REALTIME { printf("realtime "); }
;

variable_name_list: variable_name_or_assignment                          { }
|                   variable_name_list COMMA variable_name_or_assignment { }
;

variable_name_or_assignment: IDENTIFIER                       { }
|                            IDENTIFIER EQUAL integer_or_real { }
|                            IDENTIFIER array                 { }
;

/*            Constant and event declarations.           */
/*********************************************************/
/* There are 6 types of constant and event declarations. */
/*********************************************************/
/* 1st type: parameter signed [range] constant_name = value, ... ; */
/* 2nd type: parameter constant_type constant_name = value, ... ; */
/* 3rd type: localparam signed [range] constant_name = value,...; */
/* 4th type: localparam constant_type constant_name = value, ... ; */
/* 5th type: specparam constant_name = value, ... ; */
/* 6th type: event event_name, ... ; */
/*********************************************************/
/* 'signed', 'range' and 'constant_type' are all optional. constant_type can */
/* be 'integer', 'time', 'real' or 'realtime'. There is also the 'genvar' */
/* type that can only used within a generate loop. */
constant_or_event_declaration: /* 1st type constant declarations. */
                               PARAMETER SIGNED range constant_assignment_list
    { printf("parameter "); }
|                              PARAMETER SIGNED constant_assignment_list
    { printf("parameter "); }
|                              PARAMETER range constant_assignment_list
    { printf("parameter "); }
|                              PARAMETER constant_assignment_list
    { printf("parameter "); }
                               /* 2nd type constant declarations. */
|                              PARAMETER constant_type constant_assignment_list
    { printf("parameter "); }
                               /* 3rd type constant declarations. */
|                              LOCALPARAM SIGNED range constant_assignment_list
    { printf("localparam "); }
|                              LOCALPARAM SIGNED constant_assignment_list
    { printf("localparam "); }
|                              LOCALPARAM range constant_assignment_list
    { printf("localparam "); }
|                              LOCALPARAM constant_assignment_list
    { printf("localparam "); }
                               /* 4th type constant declarations. */
|                              LOCALPARAM constant_type constant_assignment_list
    { printf("localparam "); }
                               /* 5th type constant declarations. */
|                              SPECPARAM constant_assignment_list
    { printf("specparam "); }
                               /* 6th type event declarations. */
|                              EVENT nonempty_identifier_list
    { printf("event "); }
;

constant_assignment_list: constant_assignment                                { }
|                         constant_assignment_list COMMA constant_assignment { }
;

/* Constants may contain integers, real numbers, time, delays, or ASCII */
/* strings. */
constant_assignment: IDENTIFIER EQUAL number { printf("constant "); }
|                    IDENTIFIER EQUAL IDENTIFIER    { printf("constant "); }
;

constant_type: INTEGER    { printf("integer "); }
|              REAL       { printf("real "); }
|              TIME       { printf("time "); }
|              REALTIME   { printf("realtime "); }
;

assignment: IDENTIFIER EQUAL expression { printf("assignment "); }
|           IDENTIFIER EQUAL array_select
    { printf("array_select_assignment "); }
;

expression: expression_term {printf("expression "); }
|           expression expression_operation expression_term
    {printf("expression "); }
;

expression_term: number     { }
|                IDENTIFIER { }
|                bit_select { }
;

expression_operation:  ADDITION    { }
|                      SUBTRACTION { }
;

/*            Vector Bit Selects and Part Selects                      */
/***********************************************************************/
/* There are 2 types of vector and part selects                        */
/***********************************************************************/
/* 1st type: vector_name[bit_number]                                   */
/* 2st type: vector_name[bit_number : bit_number]                      */
/* 3st type: vector_name[starting_bit_number +: part_select_width]     */
/* 4st type: vector_name[starting_bit_number -: part_select_width]     */
/***********************************************************************/
/* Bit select: bit number can be an integer, a constant, a net,        */
/* a variable or an expression.                                        */
/* Constant part select : The bit numbers must be a literal number     */
/* or a constant.                                                      */
/* Variable part selects: Starting bit number must be a literal number */
/* or a constant, and the width of the part select must be a literal   */
/* number, a constant or a call to a constant function.                */
/* +: indicates the part select increases from the starting point.     */
/* -: indicates the part select decreases from the starting point.     */
/***********************************************************************/
bit_select: /* Bit Select ('array_index' is a number in brackets). */
            IDENTIFIER array_index
    { printf("bit_select "); }
|           IDENTIFIER OPENBRACKETS IDENTIFIER CLOSEBRACKETS
    { printf("bit_select "); }
            /* Constant Part Select */
|           IDENTIFIER OPENBRACKETS bit_number COLON bit_number CLOSEBRACKETS
    { printf("constant_part_select "); }
            /* Variable Part Select 1 */
|           IDENTIFIER OPENBRACKETS bit_number ADDITION COLON part_select_width 
            CLOSEBRACKETS 
    { printf("variable_part_select_1 "); }
            /* Variable Part Select 2 */
|           IDENTIFIER OPENBRACKETS bit_number SUBTRACTION COLON 
            part_select_width CLOSEBRACKETS 
    { printf("variable_part_select_2 "); }
;

/* The bit number must be a literal number or a constant. */
bit_number: NUM_INTEGER { }
|           IDENTIFIER { }
;

/* The width of the part select must be a literal number, a constant or a */
/* call to a constant function. */
part_select_width: NUM_INTEGER                   { }
|                  constant_or_constant_function { }
;

/*             Array Selects           */
/***************************************/
/* There are 3 types of array selects. */
/***************************************/
/* 1st type: array_name[index][index]... */
/* 2nd type: array_name[index][index]...[bit_number] */
/* 3rd type: array_name[index][index]...[part_select] */
/***************************************/
/* Multiple indices, bit selects and part selects from an array were added in */
/* Verilog-2001. An array select can be an integer, a net, a variable, or an */
/* expression. */
array_select: /* 1st type (and 2nd type with integers) array selects. */
              IDENTIFIER array_index_list { printf("array_select_integer"); }
              /* 2nd type (without integers) array selects. */
|             IDENTIFIER array_index_list OPENBRACKETS IDENTIFIER CLOSEBRACKETS
    { printf("array_select_constant "); }
              /* 3rd type array selects. */
|             IDENTIFIER array_index_list OPENBRACKETS bit_number
    COLON bit_number CLOSEBRACKETS { printf("array_select_3 "); }
|             IDENTIFIER array_index_list OPENBRACKETS bit_number ADDITION COLON
    part_select_width CLOSEBRACKETS { printf("array_select_3 "); }
|             IDENTIFIER array_index_list OPENBRACKETS bit_number SUBTRACTION
    COLON part_select_width CLOSEBRACKETS { printf("array_select_3 "); }
;

array_index_list: array_index array_index { }
|                 array_index_list array_index { }
;

array_index: OPENBRACKETS NUM_INTEGER CLOSEBRACKETS  { }
;

integer_or_real: NUM_INTEGER { }
|                REALV       { }
;

number: NUM_INTEGER { }
|       UNSIG_BIN   { }
|       UNSIG_OCT   { }
|       UNSIG_DEC   { }
|       UNSIG_HEX   { }
|       SIG_BIN     { }
|       SIG_OCT     { }
|       SIG_DEC     { }
|       SIG_HEX     { }
|       REALV       { }
;

%%

main (int argc, char *argv[]) {
    yyparse();
}

yyerror(char *error_string) {
    fprintf(stderr, "ERROR in line %d: %s\n", yylloc.first_line, error_string);
}
