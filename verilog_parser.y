/* Verilog 2001 parser */

%{
#include <stdio.h>
#include <stdlib.h>

/* Function prototypes. */

void reset_reduction_flags(int *reduction_and_flag, int *reduction_or_flag);
void turn_reduction_flag_on(int *reduction_flag);
void check_reduction_flag(int reduction_flag);

/* Global variable declarations */

/* Flags used to determine if the last expression created was a reduction_and */
/* or a reduction_or (value 1) or not (value 0). */
int reduction_and_flag, reduction_or_flag;
%}

/* Token declarations */

%token IDENTIFIER
%token NUM_INTEGER REALV
/* Verilog 2001 unsigned literals. */
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
/* Verilog 2001 signed literals. */
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE
%token EQUALS COMMA QUESTION_MARK SEMICOLON HASH PERIOD
%token OPENPARENTHESES CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS OPENBRACES
%token CLOSEBRACES
/* Verilog 2001 port diractions. */
%token INPUT OUTPUT INOUT
%token SIGNED
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
/* Verilog 2001 gate primitive tokens. */
%token AND NAND OR NOR XOR XNOR BUF NOT BUFIF0 NOTIF0 BUFIF1 NOTIF1 PULLUP
%token PULLDOWN
/* Verilog 2001 switch primitive tokens. */
%token PMOS NMOS RPMOS RNMOS CMOS RCMOS TRAN RTRAN TRANIF0 TRANIF1 RTRANIF0
%token RTRANIF1
/* Verilog 2001 procedural block tokens. IF and THEN have precedence. */
%token INITIAL_TOKEN ALWAYS AT POSEDGE NEGEDGE BEGIN_TOKEN END FORK JOIN DISABLE
%token WAIT ASSIGN DEASSIGN FORCE RELEASE IF CASE ENDCASE DEFAULT CASEZ CASEX
%token FOR WHILE REPEAT FOREVER TRIGGER_EVENT_OPERATOR
/* Verilog 2001 system function tokens. The "$signed" and "$unsigned" system */
/* functions should not be consfused with the "signed" "unsigned" Verilog */
/* keywords. */
%token SIGNED_SYSTEM_FUNCTION UNSIGNED_SYSTEM_FUNCTION

/* Tokens with precedence. */

/* THEN is a fictitious terminal symbol, given less precedence than the ELSE */
/* token. That way, every 'else' is matched to the closest 'if'. */
%nonassoc THEN
%nonassoc ELSE

/* EXPRESSION_USED is a fictitious terminal symbol, given less precedence than */
/* the expression operator tokens. This ensures depth-first recursion. */
%nonassoc EXPRESSION_USED
/* CONDITIONAL is a fictitious terminal symbol, giving to a conditional */
/* expression the correct precedence. */
%right QUESTION_MARK COLON
/* Logical 'and' and 'or' tokens. */
%left LOGICAL_OR
%left LOGICAL_AND
/* Bitwise operator tokens. The suffix _OPERATOR is added to signify that */
/* they are different from the 'and' and 'or' keywords. */
%left OR_OPERATOR
%left XOR_OPERATOR XNOR_OPERATOR
%left AND_OPERATOR
/* Case identity operator tokens. */
%left IDENTICAL NOT_IDENTICAL
/* Equality operator tokens. */
%left EQUAL NOT_EQUAL
/* Relational operator tokens. */
%left LESSTHAN LESSTHANOREQUAL GREATERTHAN GREATERTHANOREQUAL
/* Shift tokens. */
%left BITWISE_LEFT_SHIFT BITWISE_RIGHT_SHIFT ARITHMETIC_LEFT_SHIFT
    ARITHMETIC_RIGHT_SHIFT
/* Binary arithmetic operation tokens. */
%left PLUS MINUS
%left ASTERISK SLASH MODULO
%left POWER
/* UNARY_PLUS and UNARY_MINUS are fictitious terminal symbols, giving unary */
/* precedence to binary operators PLUS and MINUS. */
%left UNARY_PLUS UNARY_MINUS
/* The reduction tokens are fictitious terminal symbols, giving unary */
/* precedence to binary bitwise operators '&', '|', '^', '~^' and '^~'. */
%left REDUCTION_AND NAND_OPERATOR REDUCTION_OR NOR_OPERATOR REDUCTION_XOR
    REDUCTION_XNOR
/* Logical and bitwise not tokens. */
%left EXCLAMATION_MARK TILDE
/* PARENTHESISED_EXPRESSION is a fictitious terminal symbol, giving higher */
/* precedence to expressions in parenthesis. */
%nonassoc PARENTHESISED_EXPRESSION
/* CONCATENATED_EXPRESSIONS is a fictitious terminal symbol, giving higher */
/* precedence to concatenation in expressions. */
%nonassoc CONCATENATED_EXPRESSIONS
/* BIT_SELECT is a fictitious terminal symbol, giving higher precedence to */
/* bit selects in expressions. */
%left BIT_SELECT

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
    { printf("nonempty_identifier_list "); }
;

block: /* empty */
| block statement { }
;

statement: assignment  SEMICOLON { printf("\n"); }
|          declaration SEMICOLON { printf("\n"); }
|          declaration_with_attributes SEMICOLON { printf("\n"); }
|          primitive_instance SEMICOLON { printf("primitive_instance\n"); }
|          module_instances SEMICOLON { printf("module_instance\n"); }
|          procedural_block { printf("procedural_block\n"); }
;

declaration_with_attributes: attributes declaration { }
;

/*               TODO                    */
/* An attribute can appear as a prefix to module items, statements, or port */
/* connections. An attribute can appear as a suffix to an operator or a call */
/* to a function. */
attributes: OPENPARENTHESES ASTERISK attribute_list ASTERISK CLOSEPARENTHESES
    { printf("attributes"); }
;

attribute_list: attribute                      { }
|               attribute_list COMMA attribute { }
;

attribute: IDENTIFIER                  { }
|          IDENTIFIER EQUALS IDENTIFIER { }
|          IDENTIFIER EQUALS number     { }
;

declaration: port_declaration { }
|            net_declaration { printf("net_declaration"); }
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
    range transition_delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared SIGNED
    range net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared SIGNED
    transition_delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared SIGNED
    net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared range
    transition_delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared range
    net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared
    transition_delay net_name_list { }
|                net_type_except_trireg optional_vectored_or_scalared
    net_name_list { }
                 /* 1st type net declarations (trireg). */
|                TRIREG optional_vectored_or_scalared SIGNED range
    transition_delay net_name_list { }
|                TRIREG optional_vectored_or_scalared SIGNED range
    net_name_list { }
|                TRIREG optional_vectored_or_scalared SIGNED transition_delay
    net_name_list { }
|                TRIREG optional_vectored_or_scalared SIGNED net_name_list { }
|                TRIREG optional_vectored_or_scalared range transition_delay
    net_name_list { }
|                TRIREG optional_vectored_or_scalared range net_name_list { }
|                TRIREG optional_vectored_or_scalared transition_delay
    net_name_list { }
|                TRIREG optional_vectored_or_scalared net_name_list { }
                 /* 2nd type net declarations (except trireg). */
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range transition_delay IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED transition_delay IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    range transition_delay IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    range IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    transition_delay IDENTIFIER EQUALS expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    IDENTIFIER EQUALS expression { }
                 /* 2nd type net declarations (trireg). */
|                TRIREG optional_vectored_or_scalared strength SIGNED range
    transition_delay IDENTIFIER EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED range
    IDENTIFIER EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED
    transition_delay IDENTIFIER EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED IDENTIFIER
    EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength range
    transition_delay IDENTIFIER EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength range IDENTIFIER
    EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength transition_delay
    IDENTIFIER EQUALS expression { }
|                TRIREG optional_vectored_or_scalared strength IDENTIFIER EQUALS
    expression { }
                 /* 3rd type net declarations. */
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED range transition_delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED range net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED transition_delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    range transition_delay net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    range net_name_list { }
|                TRIREG optional_vectored_or_scalared capacitance_strength
    transition_delay net_name_list { }
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

/* Delays to transitions. Each delay is actually a delay unit. */
/* 1 delay (all transitions). */
/* 2 delays (rise and fall transitions). */
/* 3 delays (rise, fall and tri-state turn-off transitions). */
transition_delay: HASH transition_delay_unit { }
|                 HASH OPENPARENTHESES transition_delay_unit CLOSEPARENTHESES
    { }
|                 HASH OPENPARENTHESES transition_delay_unit COMMA
    transition_delay_unit CLOSEPARENTHESES { }
|                 HASH OPENPARENTHESES transition_delay_unit COMMA
    transition_delay_unit COMMA transition_delay_unit CLOSEPARENTHESES { }
;

/* Each delay unit can be a single number or a minimum:typical:max delay */
/* range. */
transition_delay_unit: integer_or_real                                  { }
|                      integer_or_real COLON integer_or_real COLON
    integer_or_real { }
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
range_value: NUM_INTEGER                                      { }
|            constant_or_constant_function                    { }
|            constant_or_constant_function PLUS NUM_INTEGER   { }
|            constant_or_constant_function MINUS NUM_INTEGER  { }
|            constant_or_constant_function MODULO NUM_INTEGER { }
|            NUM_INTEGER PLUS constant_or_constant_function   { }
|            NUM_INTEGER MINUS constant_or_constant_function  { }
|            NUM_INTEGER MODULO constant_or_constant_function { }
;

constant_or_constant_function: IDENTIFIER             { }
|                              constant_function_call { }
;

/* Call to constant function. */
constant_function_call: IDENTIFIER OPENPARENTHESES IDENTIFIER CLOSEPARENTHESES
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
|                            IDENTIFIER EQUALS integer_or_real { }
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
constant_assignment: IDENTIFIER EQUALS number { printf("constant "); }
|                    IDENTIFIER EQUALS IDENTIFIER    { printf("constant "); }
;

constant_type: INTEGER    { printf("integer "); }
|              REAL       { printf("real "); }
|              TIME       { printf("time "); }
|              REALTIME   { printf("realtime "); }
;

assignment: IDENTIFIER EQUALS expression { printf("assignment "); }
|           IDENTIFIER EQUALS array_select
    { printf("array_select_assignment "); }
;

/*           TODO           */
/* Single operands (function). Reduction limitations. */
expression: number                              { 
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           IDENTIFIER                          {
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           bit_select %prec BIT_SELECT         {
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           EXCLAMATION_MARK expression         {
        printf("logical_not ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           TILDE expression                    {
        printf("bitwise_not ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           PLUS expression %prec UNARY_PLUS    {
        printf("unary_plus ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           MINUS expression %prec UNARY_MINUS  {
        printf("unary_minus ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression PLUS expression          {
        printf("addition ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression MINUS expression         {
        printf("subtraction ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression ASTERISK expression      {
        printf("multiplication ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression SLASH expression         {
        printf("division ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression MODULO expression        {
        printf("modulus ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression POWER expression         {
        printf("exponentation ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           OPENPARENTHESES expression CLOSEPARENTHESES %prec
    PARENTHESISED_EXPRESSION                    {
        printf("parenthesised_expression ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression BITWISE_LEFT_SHIFT expression {
        printf("bitwise_left_shift ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression BITWISE_RIGHT_SHIFT expression {
        printf("bitwise_right_shift ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression ARITHMETIC_LEFT_SHIFT expression {
        printf("arithmetic_left_shift ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression ARITHMETIC_RIGHT_SHIFT expression {
        printf("arithmetic_right_shift ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression LESSTHAN expression      {
        printf("less_than ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression LESSTHANOREQUAL expression {
        printf("less_than_or_equal ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression GREATERTHAN expression   {
        printf("greater_than ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression GREATERTHANOREQUAL expression {
        printf("greater_than_or_equal ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression EQUAL expression         {
        printf("equal ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression NOT_EQUAL expression     {
        printf("not_equal ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression IDENTICAL expression     {
        printf("identical ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression NOT_IDENTICAL expression {
        printf("not_intetical ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           AND_OPERATOR expression %prec REDUCTION_AND {
        printf("reduction_and ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
        turn_reduction_flag_on(&reduction_and_flag);
    }
|           NAND_OPERATOR expression            {
        printf("reduction_nand ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           OR_OPERATOR expression %prec REDUCTION_OR {
        printf("reduction_or ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
        turn_reduction_flag_on(&reduction_or_flag);
    }
|           NOR_OPERATOR expression             {
        printf("reduction_nor ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           XOR_OPERATOR expression %prec REDUCTION_XOR {
        printf("reduction_xor ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           XNOR_OPERATOR expression %prec REDUCTION_XNOR {
        printf("reduction_xnor ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression AND_OPERATOR expression  {
        printf("bitwise_and ");
        check_reduction_flag(reduction_and_flag);
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression XOR_OPERATOR expression  {
        printf("bitwise_xor ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression XNOR_OPERATOR expression {
        printf("bitwise_xnor ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression OR_OPERATOR expression   {
        printf("bitwise_or ");
        check_reduction_flag(reduction_or_flag);
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression LOGICAL_AND expression   {
        printf("logical_and ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression LOGICAL_OR expression    {
        printf("logical_or ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           expression QUESTION_MARK expression COLON expression {
        printf("conditional ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           OPENBRACES concatenation_list CLOSEBRACES %prec
    CONCATENATED_EXPRESSIONS {
        printf("concatenation ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           SIGNED_SYSTEM_FUNCTION OPENPARENTHESES expression CLOSEPARENTHESES
    {
        printf("cast_to_signed_system_function ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|           UNSIGNED_SYSTEM_FUNCTION OPENPARENTHESES expression CLOSEPARENTHESES
    {
        printf("cast_to_unsigned_system_function ");
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
;

/*      Vector Bit Selects and Part Selects.     */
/*************************************************/
/* There are 4 types of vector and part selects. */
/*************************************************/
/* 1st type: vector_name[bit_number]                                   */
/* 2nd type: vector_name[bit_number : bit_number]                      */
/* 3rd type: vector_name[starting_bit_number +: part_select_width]     */
/* 4th type: vector_name[starting_bit_number -: part_select_width]     */
/*************************************************/
/* bit_number must be a literal number or a constant. part_select_width must */
/* be a literal number, a constant or a call to a constant function. */
bit_select: /* Bit Select (1st type). */
            IDENTIFIER index { printf("bit_select "); }
            /* Constant Part Select (2nd type). */
|           IDENTIFIER OPENBRACKETS bit_number COLON bit_number CLOSEBRACKETS
    { printf("constant_part_select "); }
            /* Variable Part Select 1 (3rd type). */
|           IDENTIFIER OPENBRACKETS bit_number PLUS COLON part_select_width 
    CLOSEBRACKETS { printf("variable_part_select "); }
            /* Variable Part Select 2 (4th type). */
|           IDENTIFIER OPENBRACKETS bit_number MINUS COLON part_select_width
    CLOSEBRACKETS { printf("variable_part_select "); }
;

index: OPENBRACKETS bit_number CLOSEBRACKETS { }
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

concatenation_list: concatenation_item                          { }
|                   concatenation_list COMMA concatenation_item { }
;

concatenation_item: number                                    { }
|                   IDENTIFIER                                { }
|                   replication                               { }
                    /* Nested concatenations are possible. */
|                   OPENBRACES concatenation_list CLOSEBRACES { }
;

replication: number OPENBRACES concatenation_list CLOSEBRACES { }
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
array_select: /* 1st and 2nd type array selects. */
              IDENTIFIER array_index_list { printf("array_select_integer "); }
              /* 3rd type array selects. */
|             IDENTIFIER array_index_list OPENBRACKETS bit_number COLON
    bit_number CLOSEBRACKETS { printf("array_select_3 "); }
|             IDENTIFIER array_index_list OPENBRACKETS bit_number PLUS COLON
    part_select_width CLOSEBRACKETS { printf("array_select_3 "); }
|             IDENTIFIER array_index_list OPENBRACKETS bit_number MINUS COLON
    part_select_width CLOSEBRACKETS { printf("array_select_3 "); }
;

array_index_list: index index { }
|                 array_index_list index { }
;

/*              Module Instances             */
/*********************************************/
/* There are 5 types of module instances     */
/*********************************************/
/* 1st type: module_name instance_name          */
/*  instance_array_range(signal, signal, ... ); */
/* 2st type: module_name instance_name instance_array_range */
/*  ( .port_name(signal), .port_name(signal), ... ); */
/* 3st type: defparam heirarchy_path.parameter_name = value; */
/* 4st type: module_name #(value,value, ...) instance_name (signal, ... ); */
/* 5st type: module_name #(.parameter_name(value),
/*  .parameter_name(value), ...) instance_name (signal, ... ); */
/*********************************************/
/* instance_array_range is optional */
/* On parameter redefinision Only parameter declarations may */
/* be redefined. localparam and specparam constants cannot be redefined. */

module_instances:
                /* 1st and 2st type module instances */
                IDENTIFIER IDENTIFIER range OPENPARENTHESES connections CLOSEPARENTHESES { }
|               IDENTIFIER IDENTIFIER OPENPARENTHESES connections CLOSEPARENTHESES { }
                /* 3st type module instances (explicit parameter redefinition) */
/* |               DEFPARAM IDENTIFIER PERIOD IDENTIFIER EQUAL number { } */
                /* 4st and 5st type module instances(implicit and explicit) */
|               IDENTIFIER HASH OPENPARENTHESES redefinition_list CLOSEPARENTHESES 
                IDENTIFIER OPENPARENTHESES connections CLOSEPARENTHESES { }
;
/* Parameter values are redefined in the same order in which */
/* they are declared within the module.                      */
redefinition_list: 
                  redefinition_value { printf("redefinition ");}
|                 redefinition_list COMMA redefinition_value {printf("redefinition ");}
;
redefinition_value: 
                  number { }
|                 PERIOD IDENTIFIER OPENPARENTHESES number CLOSEPARENTHESES { }
;
/* Signal can be an identifier, a port name */
/* connection or nothing */
connections: 
             signal                          { }
|            connections COMMA signal        { }
;
signal:                                   { printf("no_signal "); }
|           IDENTIFIER                    { printf("identifier "); }
|           IDENTIFIER index              { printf("identifier(index) ");}
|           port_name_connection          { printf("port_name_connection ");}
;

/* Port name connections list both the port name */ 
/* and signal connected to it, in any order. */
port_name_connection:                      
                    PERIOD IDENTIFIER OPENPARENTHESES IDENTIFIER
                    CLOSEPARENTHESES       { }
|                   PERIOD IDENTIFIER OPENPARENTHESES IDENTIFIER index  
                    CLOSEPARENTHESES { }
;

/*             Primitive Instances           */
/*********************************************/
/* There are 2 types of primitive instances. */
/*********************************************/
/* 1st type: gate_type (drive_strength) #(delay) instance_name */
/*     [instance_array_range] (terminal, terminal, ... ); */
/* 2nd type: switch_type #(delay) instance_name[instance_array_range] */
/*     (terminal, terminal, ... ); */
/*********************************************/
/* 'delay', 'drive_strength', 'instance_name'and 'instance_array_range' are */
/* all optional. Only gate primitives may have the output drive strength */
/* specified. */
primitive_instance: /* 1st type primitive instances. */
                    gate_type strength transition_delay IDENTIFIER range
    OPENPARENTHESES nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength transition_delay IDENTIFIER
    OPENPARENTHESES nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength transition_delay range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength transition_delay OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength IDENTIFIER range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength IDENTIFIER OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type strength OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES { }
|                   gate_type transition_delay IDENTIFIER range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type transition_delay IDENTIFIER OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type transition_delay range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type transition_delay OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type IDENTIFIER range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type IDENTIFIER OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   gate_type range OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES { }
|                   gate_type OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES { }
                    /* 2nd type primitive instances. */
|                   switch_type transition_delay IDENTIFIER range
    OPENPARENTHESES nonempty_identifier_list CLOSEPARENTHESES { }
|                   switch_type transition_delay IDENTIFIER OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   switch_type transition_delay range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   switch_type transition_delay OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   switch_type IDENTIFIER range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   switch_type IDENTIFIER OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES { }
|                   switch_type range OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES { }
|                   switch_type OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES { }
;

/*                      Gate Primitive Types.                     */
/******************************************************************/
/* There are 14 gate primitive types (not counting user-defined). */
/******************************************************************/
/* (1–output, 1-or-more–inputs): and nand or nor xor xnor */
/* (1-or-more–outputs, 1–input): buf not */
/* (1–output, 1–input, 1–control): bufif0 notif0 bufif1 notif1 */
/* (1–output): pullup pulldown */
/* (1–output, 1-or-more–inputs): user_defined_primitive */
/******************************************************************/
/* Primitives can be user-defined. */
gate_type: AND      { }
|          NAND     { }
|          OR       { }
|          NOR      { }
|          XOR      { }
|          XNOR     { }
|          BUF      { }
|          NOT      { }
|          BUFIF0   { }
|          NOTIF0   { }
|          BUFIF1   { }
|          NOTIF1   { }
|          PULLUP   { }
|          PULLDOWN { }
;

/*        Switch Primitive Types.       */
/****************************************/
/* There are 12 switch primitive types. */
/****************************************/
/* (1–output, 1–input, 1–control): pmos nmos rpmos rnmos */
/* (1–output, 1–input, n-control, p-control): cmos rcmos */
/* (2–bidirectional-inouts): tran rtran */
/* (2–bidirectional-inouts, 1–control): tranif0 tranif1 rtranif0 rtranif1 */
/****************************************/
switch_type: PMOS     { }
|            NMOS     { }
|            RPMOS    { }
|            RNMOS    { }
|            CMOS     { }
|            RCMOS    { }
|            TRAN     { }
|            RTRAN    { }
|            TRANIF0  { }
|            TRANIF1  { }
|            RTRANIF0 { }
|            RTRANIF1 { }
;

/*           Procedural Blocks.          */
/*****************************************/
/* There is 1 type of procedural blocks. */
/*****************************************/
/* procedural_block: type_of_block @(sensitivity_list) statement_group */
/* :group_name local_variable_declarations time_control procedural_statements */
/* end_of_statement_group */
/*****************************************/
/* 'sensitivity_list', 'group_name', and 'local_variable_declarations' are */
/* all optional. type_of_block is either 'initial' or 'always'. The */
/* sensitivity list is used at the beginning of an always procedure to infer */
/* combinational logic or sequential logic behavior in simulation. NOTE: */
/* INITIAL is a keyword reserved for start conditions in flex. INITIAL_TOKEN */
/* is used as the Verilog token instead. */
procedural_block: INITIAL_TOKEN statement_group           { }
|                 ALWAYS sensitivity_list statement_group { }
;

/* begin—end groups two or more statements together sequentially. fork—join */
/* groups two or more statements together in parallel. A statement group is */
/* not required if there is only one procedural statement. Named groups may */
/* have local variables, and may be aborted with a disable statement. */
/* 'time_control' is optional at the start of a statement group. */
statement_group: time_control named_begin_group    { }
|                named_begin_group                 { }
|                time_control unnamed_begin_group  { }
|                unnamed_begin_group               { }
|                time_control named_fork_group     { }
|                named_fork_group                  { }
|                time_control unnamed_fork_group   { }
|                unnamed_fork_group                { }
|                time_control procedural_statement { }
|                procedural_statement              { }
;

/* NOTE: BEGIN is a keyword reserved for start conditions in flex. */
/* BEGIN_TOKEN is used as the Verilog token instead. */
named_begin_group: BEGIN_TOKEN COLON IDENTIFIER
    named_group_procedural_statements END { }
;

unnamed_begin_group: BEGIN_TOKEN unnamed_group_procedural_statements END { }
;

named_fork_group: FORK COLON IDENTIFIER named_group_procedural_statements JOIN
    { }
;

unnamed_fork_group: FORK unnamed_group_procedural_statements JOIN { }
;

named_group_procedural_statements: named_group_procedural_statement { }
|                                  named_group_procedural_statements
    named_group_procedural_statement { }
;

/* "disable group_name;" discontinues execution of a named group of */
/* statements. time_control before procedural statements is optional. */
named_group_procedural_statement: /* Local variable declaration. */
                                   variable_declaration SEMICOLON    { }
|                                  DISABLE IDENTIFIER SEMICOLON      { }
|                                  time_control procedural_statement { }
|                                  procedural_statement              { }
;

unnamed_group_procedural_statements: unnamed_group_procedural_statement { }
|                                    unnamed_group_procedural_statements
    unnamed_group_procedural_statement { }
;

/* time_control before procedural statements is optional. */
unnamed_group_procedural_statement: time_control procedural_statement { }
|                                   procedural_statement              { }
;

/*            Procedural Time Control.           */
/*************************************************/
/* There are 5 types of procedural time control. */
/*************************************************/
/* 1st type: #delay */
/* 2nd type: @(edge signal or edge signal or ... ) */
/* 3rd type: @(edge signal, edge signal, ... ) */
/* 4th type: @(*) */
/* 5th type: wait (expression) */
/*************************************************/
/* edge is optional maybe either 'posedge' or 'negedge'. If no edge is */
/* specified, then any logic transition is used. The use of commas was added */
/* in Verilog-2001. signal may be a net type or variable type, and may be any */
/* vector size. An asterisk in place of the list of signals indicates */
/* sensitivity to any edge of all signals that are read in the statement or */
/* statement group that follows. @* was added in Verilog-2001. The procedural */
/* delay may be a literal number, a variable, or an expression. */
time_control: /* 1st type procedural time control. Each delay unit can be a
    single number or a minimum:typical:max delay range. */
              HASH expression %prec EXPRESSION_USED { }
|             OPENPARENTHESES expression COLON expression COLON expression
    CLOSEPARENTHESES %prec EXPRESSION_USED { }
              /* 2nd type and 3rd type procedural time control. */
|             AT OPENPARENTHESES procedural_time_conrol_signal_list
    CLOSEPARENTHESES { }
              /* Parenthesis are not required when there is only one signal in
    the list and no edge is specified. */
|             AT IDENTIFIER { }
              /* 4th type procedural time control. */
|             AT ASTERISK { }
              /* 5th type procedural time control. */
|             WAIT OPENPARENTHESES expression CLOSEPARENTHESES { }
;

/* Either a comma or the keyword 'or' may be used to specify events on any */
/* of several signals. The use of commas was added in Verilog-2001. */
procedural_time_conrol_signal_list: procedural_time_conrol_signal { }
                                    /* 2nd type procedural time control. */
|                                   procedural_time_conrol_signal_list COMMA
    procedural_time_conrol_signal { }
                                    /* 3rd type procedural time control. */
|                                   procedural_time_conrol_signal_list OR
    procedural_time_conrol_signal { }
;

/* edge is optional maybe either 'posedge' or 'negedge'. If no edge is */
/* specified, then any logic transition is used. */
procedural_time_conrol_signal: edge IDENTIFIER { }
|                              IDENTIFIER      { }
;

procedural_statement: procedural_assignment_statement SEMICOLON          { }
|                     procedural_programming_statement                   { }
|                     TRIGGER_EVENT_OPERATOR IDENTIFIER SEMICOLON        { }
;

/*            Procedural Assignment Statements.            */
/***********************************************************/
/* There are 10 types of procedural assignment statements. */
/***********************************************************/
/* 1st type: variable = expression; */
/* 2nd type: variable <= expression; */
/* 3rd type: timing_control variable = expression; */
/* 4th type: timing_control variable <= expression; */
/* 5th type: variable = timing_control expression; */
/* 6th type: variable <= timing_control expression; */
/* 7th type: assign variable = expression; */
/* 8th type: deassign variable; */
/* 9th type: force net_or_variable = expression; */
/* 10th type: release net_or_variable; */
/***********************************************************/
/* NOTE: 3rd type and 4th type procedural assignment statements have been */
/* covered already (time_control can precede any procedural_statement). */
/* variable can be a bit select. */
procedural_assignment_statement: /* 1st type procedural assignment statement
    (blocking procedural assignment). */
                                 variable_or_bit_select EQUALS expression { }
                                 /* 2nd type procedural assignment statement
    (non-blocking procedural assignment). */
|                                variable_or_bit_select LESSTHANOREQUAL
    expression %prec EXPRESSION_USED { }
                                 /* 5th type procedural assignment statement
    (blocking intra-assignment delay). */
|                                variable_or_bit_select EQUALS time_control
    expression { }
                                 /* 6th type procedural assignment statement
    (non-blocking intra-assignment delay). */
|                                variable_or_bit_select LESSTHANOREQUAL
    time_control expression %prec EXPRESSION_USED { }
                                 /* 7th type procedural assignment statement
    (procedural continuous assignment). */
|                                ASSIGN variable_or_bit_select EQUALS
    expression { }
                                 /* 8th type procedural assignment statement
    (de-activates a procedural continuous assignment). */
|                                DEASSIGN variable_or_bit_select { }
                                 /* 9th type procedural assignment statement
    (forces any data type to a value, overriding all other logic). */
|                                FORCE variable_or_bit_select EQUALS
    expression { }
                                 /* 10th type procedural assignment statement
    (removes the effect of a force). */
|                                RELEASE variable_or_bit_select { }
;

variable_or_bit_select: IDENTIFIER { }
|                       bit_select { }
;

/*             Procedural Programming Statements.           */
/************************************************************/
/* There are 10 types of procedural programming statements. */
/************************************************************/
/* 1st type: if ( expression ) statement_or_statement_group */
/* 2nd type: if ( expression ) statement_or_statement_group else */
/*     statement_or_statement_group */
/* 3rd type: case ( expression ) */
/*               case_item: statement_or_statement_group */
/*               case_item, case_item: statement_or_statement_group */
/*               default: statement_or_statement_group */
/*           endcase */
/* 4th type: casez ( expression ) */
/*               case_item: statement_or_statement_group */
/*               case_item, case_item: statement_or_statement_group */
/*               default: statement_or_statement_group */
/*           endcase */
/* 5th type: casex ( expression ) */
/*               case_item: statement_or_statement_group */
/*               case_item, case_item: statement_or_statement_group */
/*               default: statement_or_statement_group */
/*           endcase */
/* 6th type: for ( initial_assignment; expression; step_assignment ) */
/*     statement_or_statement_group */
/* 7th type: while ( expression ) statement_or_statement_group */
/* 8th type: repeat ( number ) statement_or_statement_group */
/* 9th type: forever statement_or_statement_group */
/* 10th type: disable group_name; */
/***********************************************************/
/* NOTE: The default case is optional in 3rd, 4th and 5th type procedural */
/* programming statements. 10th type procedural programming statements are */
/* included in named group statements only and as such aren't declared here. */
procedural_programming_statement: /* 1st type procedural programming
    statements. Lower precedence than the rule below, so that each 'else'
    statement group is matched to the closest 'if' statement group. */
                                  IF OPENPARENTHESES expression CLOSEPARENTHESES
    statement_group %prec THEN { printf("simple_if "); }
                                  /* 2nd type procedural programming
    statements. Higher precedence than the rule above, so that each 'else'
    statement group is matched to the closest 'if' statement group. */                
|                                 IF OPENPARENTHESES expression CLOSEPARENTHESES
    statement_group ELSE statement_group %prec ELSE { printf("if_else ");}
                                  /* 3rd type procedural programming statement
    (the default case is optional). */
|                                 CASE OPENPARENTHESES expression
    CLOSEPARENTHESES case_list_with_optional_default_case ENDCASE { }
                                  /* 4th type procedural programming statement
    (special version of the case statement which uses a Z logic value to
    represent don't-care bits in either the case expression or a case item). */
|                                 CASEZ OPENPARENTHESES expression
    CLOSEPARENTHESES case_list_with_optional_default_case ENDCASE { }
                                  /* 5th type procedural programming statement
    (special version of the case statement which uses Z or X logic values to
    represent don't-care bits in either the case expression or a case item). */
|                                 CASEX OPENPARENTHESES expression
    CLOSEPARENTHESES case_list_with_optional_default_case ENDCASE { }
                                  /* 6th type procedural programming statement.
    */
|                                 FOR OPENPARENTHESES
    procedural_assignment_statement SEMICOLON expression SEMICOLON
    procedural_assignment_statement CLOSEPARENTHESES statement_group { }
                                  /* 7th type procedural programming statement.
    */
|                                 WHILE OPENPARENTHESES expression
    CLOSEPARENTHESES statement_group { }
                                  /* 8th type procedural programming statement
    (the number may be an expression). */
|                                 REPEAT OPENPARENTHESES expression
    CLOSEPARENTHESES statement_group { }
                                  /* 9th type procedural programming statement.
    */
|                                 FOREVER statement_group { }
                                  /* NOTE: 10th type procedural programming
    statement is declared in named_group_procedural_statement. */
;

/* case_item: statement_or_statement_group */
/* case_item, case_item: statement_or_statement_group */
/* default: statement_or_statement_group */
case_list_with_optional_default_case: case_list              { }
|                                     case_list default_case { }
;

case_list: case           { }
|          case_list case { }
;

case: case_item_list COLON statement_group { }
;

/* The case expression can be a literal, a constant expression or a bit */
/* select. */
case_item_list: expression                      { }
|               case_item_list COMMA expression { }
;

default_case: DEFAULT COLON statement_group { }
;

/*            Sensitivity Lists.           */
/*******************************************/
/* There are 3 types of sensitivity lists. */
/*******************************************/
/* 1st type: always @(signal, signal, ... ) */
/* 2nd type: always @* */
/* 3rd type: always @(posedge signal, negedge signal, ... ) */
/*******************************************/
/* @* was added in Verilog-2001. */
sensitivity_list: /* 1st type sensitivity lists. */
                  AT OPENPARENTHESES nonempty_identifier_list CLOSEPARENTHESES
    { }
                  /* 2nd type sensitivity lists. */
|                 AT ASTERISK { }
                  /* 3rd type sensitivity lists. A specific edge should be
    specified for each signal in the list. */
|                 AT OPENPARENTHESES signal_list_with_edge CLOSEPARENTHESES { }
;

signal_list_with_edge: signal_with_edge                             { }
|                      signal_list_with_edge COMMA signal_with_edge { }
;

signal_with_edge: edge IDENTIFIER { }
;

edge: POSEDGE { }
|     NEGEDGE { }
;

integer_or_real: NUM_INTEGER { }
|                REALV       { }
;

number: number_except_real { }
|       REALV              { }
;

number_except_real: NUM_INTEGER { }
|                   UNSIG_BIN   { }
|                   UNSIG_OCT   { }
|                   UNSIG_DEC   { }
|                   UNSIG_HEX   { }
|                   SIG_BIN     { }
|                   SIG_OCT     { }
|                   SIG_DEC     { }
|                   SIG_HEX     { }
;

%%

main (int argc, char *argv[]) {
    yyparse();
}

yyerror(char *error_string) {
    fprintf(stderr, "ERROR in line %d: %s\n", yylloc.first_line, error_string);
}

/* Function: void reset_reduction_flags(int *reduction_and_flag, int */
/*     *reduction_or_flag) */
/* Arguments: pointer to the reduction_and_flag to be reset, pointer to the */
/*     reduction_or_flag to be reset */
/* Returns: - */
/* Description: Used after every expression reduction to return the flags */
/*     signifying that the last expression was a reduction_and or a */
/*     reduction_or to 0. */
void reset_reduction_flags(int *reduction_and_flag, int *reduction_or_flag) {
    *reduction_and_flag = 0;
    *reduction_or_flag = 0;
}

/* Function: void turn_reduction_flag_on(int *reduction_flag) */
/* Arguments: pointer to the reduction flag to change to 1 */
/* Returns: - */
/* Description: Changes a reduction flag to 1. Used after a reduction_and */
/*     with the reduction_and_flag and after a reduction_or with the */
/*     reduction_or_flag. */
void turn_reduction_flag_on(int *reduction_flag) {
    *reduction_flag = 1;
}

/* Function: void check_reduction_flag(int reduction_flag) */
/* Arguments: the reduction flag to check */
/* Returns: - */
/* Description: Checks if a reduction_flag is 1. If it is, it prints a */
/*     relevant error message and terminates the parser. Used to check for a */
/*     reduction_and when making a binary_and and to check for a reduction_or */
/*     when making a binary_or. */
void check_reduction_flag(int reduction_flag) {
    if (reduction_flag == 1) {
        yyerror("\"a & &b\" and \"a | |b\" is invalid Verilog syntax");
        exit(EXIT_FAILURE);
    }
}