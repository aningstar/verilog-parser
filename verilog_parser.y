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
%token EQUAL LESSTHAN GREATERTHAN COMMA COLON SEMICOLON HASH PERIOD
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
/* Verilog 2001 module instance tokens */
%token DEFPARAM
/* Verilog 2001 gate primitive tokens. */
%token AND NAND OR NOR XOR XNOR BUF NOT BUFIF0 NOTIF0 BUFIF1 NOTIF1 PULLUP
%token PULLDOWN
/* Verilog 2001 switch primitive tokens. */
%token PMOS NMOS RPMOS RNMOS CMOS RCMOS TRAN RTRAN TRANIF0 TRANIF1 RTRANIF0
%token RTRANIF1
/* Verilog 2001 generate blocks */
%token GENERATE ENDGENERATE
/* Verilog 2001 procedural block tokens */
%token INITIAL_TOKEN ALWAYS AT POSEDGE NEGEDGE BEGIN_TOKEN END FORK JOIN DISABLE WAIT
%token ASSIGN DEASSIGN FORCE RELEASE IF IFNONE ELSE CASE ENDCASE DEFAULT CASEZ CASEX
%token FOR WHILE REPEAT FOREVER
/* Version 2001 task definitions */
%token TASK ENDTASK AUTOMATIC
/* Version 2001 function definitions */
%token FUNCTION ENDFUNCTION
/* Version 2001 specify blocks */
%token SPECIFY ENDSPECIFY PATHPULSE DOLLAR
%token PULSESTYLE_ONEVENT PULSESTYLE_ONDETECT SHOWCANCELLED NOSHOWCANCELLED
%token SETUP HOLD SETUPHOLD RECOVERY REMOVAL RECREM SKEW TIMESKEW
%token FULLSKEW D_PERIOD WIDTH NOCHANGE
%token EDGE NEGATION 
%token THREE_AND PUNCTUATION_MARK
/* specify blocks: scalar_constant */
%token ONE ZERO ZERO_ONE ONE_ZERO ONE_BIN_ZERO_LOW ONE_BIN_ONE_LOW
%token ONE_BIN_ZERO_UPPER ONE_BIN_ONE_UPPER BIN_ZERO_LOW BIN_ONE_LOW 
%token BIN_ZERO_UPPER BIN_ONE_UPPER
%token X_ZERO_UPPER X_ONE_UPPER X_ZERO_LOW X_ONE_LOW Z_ZERO_UPPER
%token Z_ONE_UPPER Z_ZERO_LOW Z_ONE_LOW ZERO_X_UPPER ONE_X_UPPER 
%token ZERO_X_LOW ONE_X_LOW ZERO_Z_UPPER ONE_Z_UPPER ZERO_Z_LOW
%token ONE_Z_LOW

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
| block statement  { }
| block generate_block { }
| block task_definition { }
| block function_definition { }
| block specify_block { }
;
/*          Generate Blocks             */
/****************************************/
/* Generate blocks provide control over */
/* the creation of many types of module */
/* items. A generate block must be      */
/* defined within a module, and is used */
/* to generate code within that module. */
/*                                      */
/* genvar genvar_name, ... ;            */
/* generate                             */
/*        genvar genvar_name, ... ;     */
/*        generate_items                */
/* endgenerate                          */
/****************************************/
generate_block:
            GENERATE genvar generate_items ENDGENERATE { printf("generate\n"); }
|           GENERATE generate_items ENDGENERATE { printf("generate\n");}
;
/* generate_items are: */
/*  genvar_name = constant_expression; */
/*  net_declaration */
/*  variable_declaration */
/*  module_instance */
/*  primitive_instance */ 
/*  continuous_assignment */
/*  procedural_block */
/*  task_definition */
/*  function_definition */
generate_items:
              statement { }
|             generate_items statement { }
;
/* genvar is an integer variable which must be a positive */
/* value. They may only be used within a generate block. */
/* Genvar variables only have a value during elaboration, */
/* and do not exist during simulation. Genvar variables must */
/* be declared within the module where the genvar is used. */
/* They may be declared either inside or outside of a generate block. */
genvar: 
      GENVAR nonempty_identifier_list SEMICOLON {printf("genvar\n"); }
;

/*            Task Definitions            */
/******************************************/
/* There are two types of task definition */
/******************************************/
/* 1st type: (added in Verilog-2001) */
/* task automatic task_name ( */
/*   port_declaration port_name, port_name, ... ,  */
/*   port_declaration port_name, port_name, ... ); */
/*   local variable declarations */
/*   procedural_statement or statement_group */
/* endtask */
/* 2st type: (old style) */
/* task automatic task_name; */
/*   port_declaration port_name, port_name, ...; */
/*   port_declaration port_name, port_name, ...; */
/*   local variable declarations */
/*   procedural_statement or statement_group */
/* endtask */
/*******************************************/
/* automatic is optional, port_declaration */
/*  can be: port_direction signed range    */
/*          port_direction reg signed range*/
/*          port_direction port_type       */
task_definition:
                /* 1st type: (added in Verilog-2001) */
               TASK AUTOMATIC IDENTIFIER OPENPARENTHESES task_port_list 
               CLOSEPARENTHESES SEMICOLON task_body ENDTASK 
               { printf("task_definition\n"); }

               /* without body */
|              TASK AUTOMATIC IDENTIFIER OPENPARENTHESES task_port_list 
               CLOSEPARENTHESES SEMICOLON ENDTASK 
               { printf("task_definition\n"); }

|              TASK IDENTIFIER OPENPARENTHESES task_port_list CLOSEPARENTHESES 
               SEMICOLON task_body ENDTASK 
               { printf("task_definition\n"); }

               /* without body */
|              TASK IDENTIFIER OPENPARENTHESES task_port_list CLOSEPARENTHESES 
               SEMICOLON ENDTASK 
               { printf("task_definition\n"); }

                /* 2st type: (old style) */
|              TASK AUTOMATIC IDENTIFIER SEMICOLON task_port_body task_body 
               ENDTASK 
               { printf("task_definition\n"); }

               /* without ports */
|              TASK AUTOMATIC IDENTIFIER SEMICOLON task_body 
               ENDTASK 
               { printf("task_definition\n"); }

               /* without body */
|              TASK AUTOMATIC IDENTIFIER SEMICOLON task_port_body ENDTASK 
               { printf("task_definition\n"); }

               /* without ports and body */
|              TASK AUTOMATIC IDENTIFIER SEMICOLON ENDTASK 
               { printf("task_definition\n"); }

|              TASK IDENTIFIER SEMICOLON task_port_body task_body ENDTASK 
               { printf("task_definition\n"); }

               /* without ports */
|              TASK IDENTIFIER SEMICOLON task_body ENDTASK 
               { printf("task_definition\n"); }

               /* without body */
|              TASK IDENTIFIER SEMICOLON task_port_body ENDTASK 
               { printf("task_definition\n"); }

               /* without ports and body */
|              TASK IDENTIFIER SEMICOLON ENDTASK 
               { printf("task_definition\n"); }
;

/* May have any number of input, output or inout ports, including none. */
task_port_list: 
|                   nonempty_task_port_list { }
;

nonempty_task_port_list: 
                         task_port_declaration 
                         {printf("task_port_declaration "); }
|                        task_port_declaration COMMA task_port_list 
                         { printf("task_port_declaration "); }
;

task_port_body:
              task_port_declaration SEMICOLON
              { printf("task_port_declaration "); }
|             task_port_body task_port_declaration SEMICOLON 
              { printf("task_port_declaration "); }
;

task_port_declaration: 
                     port_direction SIGNED range IDENTIFIER { }
|                    port_direction SIGNED IDENTIFIER { }
|                    port_direction range IDENTIFIER { }
|                    port_direction REG SIGNED range IDENTIFIER { }
|                    port_direction REG SIGNED IDENTIFIER { }
|                    port_direction REG range IDENTIFIER { }
|                    port_direction task_port_type IDENTIFIER { }
;

task_port_type: 
              INTEGER { }
|             TIME { }
|             REAL { }
|             REALTIME { }
;
/*                  TODO                              */
/* procedural statement must be included to task body */
/******************************************************/
/* task body contains : local variable declarations   */ 
/* and procedural_statement or statement_group        */
task_body: 
           variable_declaration SEMICOLON { }
|          statement_group { }
|          variable_declaration SEMICOLON task_body { }
|          statement_group task_body { }
;

/*           Function Definitions            */
/* There are 2 types of function definitions */
/*********************************************/
/* 1st type: */
/* function automatic range_or_type function_name ( */
/*     input range_or_type port_name, port_name, ... , */
/*     input range_or_type port_name, port_name, ... ); */
/*     local variable declarations */
/*     procedural_statement or statement_group */
/* endfunction */
/* 2st type: */
/* function automatic [range_or_type] function_name; */
/*     input range_or_type port_name, port_name, ... ; */
/*     input range_or_type port_name, port_name, ... ; */
/*     local variable declarations */
/*     procedural_statement or statement_group */
/* endfunction */
/*********************************************/

function_definition:
                   /* 1st type of function definition */
                   FUNCTION AUTOMATIC range_or_type IDENTIFIER OPENPARENTHESES 
                   function_parameters CLOSEPARENTHESES SEMICOLON function_body 
                   ENDFUNCTION { printf("function_definition\n"); }

                   /* without body */
|                  FUNCTION AUTOMATIC range_or_type IDENTIFIER OPENPARENTHESES 
                   function_parameters CLOSEPARENTHESES SEMICOLON  
                   ENDFUNCTION { printf("function_definition\n"); }

|                  FUNCTION range_or_type IDENTIFIER OPENPARENTHESES 
                   function_parameters CLOSEPARENTHESES SEMICOLON function_body 
                   ENDFUNCTION { printf("function_definition\n"); }
                   
                   /* without body */
|                  FUNCTION range_or_type IDENTIFIER OPENPARENTHESES 
                   function_parameters CLOSEPARENTHESES SEMICOLON ENDFUNCTION 
                   { printf("function_definition\n"); }

                   /* 2st type of function definition */
|                  FUNCTION AUTOMATIC range_or_type IDENTIFIER SEMICOLON 
                   function_input_declarations function_body ENDFUNCTION 
                   { printf("function_definition\n"); }

                   /* without body */
|                  FUNCTION AUTOMATIC range_or_type IDENTIFIER SEMICOLON 
                   function_input_declarations ENDFUNCTION 
                   { printf("function_definition\n"); }

|                  FUNCTION range_or_type IDENTIFIER SEMICOLON 
                   function_input_declarations function_body ENDFUNCTION 
                   { printf("function_definition\n"); }

                   /* without body */
|                  FUNCTION range_or_type IDENTIFIER SEMICOLON 
                   function_input_declarations ENDFUNCTION 
                   { printf("function_definition\n"); }
;
/* Must have at least one input; may not have outputs or inouts. */
function_parameters: 
                   INPUT range_or_type nonempty_identifier_list { }
|                  function_parameters INPUT range_or_type nonempty_identifier_list { }
;

function_input_declarations:
                   INPUT range_or_type nonempty_identifier_list SEMICOLON { }
|                  function_input_declarations INPUT range_or_type nonempty_identifier_list SEMICOLON { }
;

function_body: 
              variable_declaration SEMICOLON{ }
|             assignment SEMICOLON { }
|             function_body variable_declaration SEMICOLON { }
|             function_body assignment SEMICOLON { }
;

range_or_type: 
|            range { }
|            SIGNED range { }
|            REG SIGNED range { }
|            REG range { }
|            INTEGER { }
|            TIME { }
|            REAL { }
|            REALTIME { }
;

statement: assignment  SEMICOLON { printf("\n"); }
|          declaration SEMICOLON { printf("\n"); }
|          declaration_with_attributes SEMICOLON { printf("\n"); }
|          primitive_instance SEMICOLON { printf("primitive_instance\n"); }
|          module_instances SEMICOLON { printf("module_instance\n"); }
|          procedural_block { printf("procedural_block\n"); }
|          continuous_assignment SEMICOLON { }
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
|            net_declaration      
    { printf("net_declaration "); }
|            variable_declaration 
    { printf("variable_declaration "); }
|            constant_or_event_declaration
    { printf("constant_or_event_declaration "); }
|            genvar
    { printf("genvar_declaration "); }
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
    SIGNED range transition_delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED transition_delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    range transition_delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    range IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    transition_delay IDENTIFIER EQUAL expression { }
|                net_type_except_trireg optional_vectored_or_scalared strength
    IDENTIFIER EQUAL expression { }
                 /* 2nd type net declarations (trireg). */
|                TRIREG optional_vectored_or_scalared strength SIGNED range
    transition_delay IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED range
    IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED
    transition_delay IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength SIGNED IDENTIFIER
    EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength range
    transition_delay IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength range IDENTIFIER
    EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength transition_delay
    IDENTIFIER EQUAL expression { }
|                TRIREG optional_vectored_or_scalared strength IDENTIFIER EQUAL
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
range_value: num_integer                                            { }
|            constant_or_constant_function                          { }
|            constant_or_constant_function ADDITION num_integer     { }
|            constant_or_constant_function SUBTRACTION num_integer  { }
|            constant_or_constant_function MODULUS num_integer      { }
|            num_integer ADDITION constant_or_constant_function     { }
|            num_integer SUBTRACTION constant_or_constant_function  { }
|            num_integer MODULUS constant_or_constant_function      { }
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

/*            Continuous Assignments           */
/***********************************************/
/* There are 2 types of continuous assignments */
/* 1st type : assign #(delay) net_name = expression; */
/* 2st type : net_type (strength) [size] #(delay) net_name = expression; */
/***********************************************/
/* 2st type implemented on net declaration */
/* delay , strength and size are optional */
continuous_assignment: /* Explicit Continuous Assignment */
                      ASSIGN transition_delay IDENTIFIER EQUAL expression 
                      { printf("explicit_continuous_assignment\n"); }
|                     ASSIGN IDENTIFIER EQUAL expression
                      { printf("explicit_continuous_assignment\n"); }
;

expression: expression_term {printf("expression "); }
|           expression expression_operation expression_term
    {printf("expression "); }
;

expression_term: number     { }
|                IDENTIFIER { }
|                bit_select { }
;

expression_operation:  ADDITION       { }
|                      SUBTRACTION    { }
|                      MULTIPLICATION { }
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
|           IDENTIFIER OPENBRACKETS bit_number ADDITION COLON part_select_width 
            CLOSEBRACKETS 
    { printf("variable_part_select "); }
            /* Variable Part Select 2 (4th type). */
|           IDENTIFIER OPENBRACKETS bit_number SUBTRACTION COLON 
            part_select_width CLOSEBRACKETS 
    { printf("variable_part_select "); }
;

index: OPENBRACKETS bit_number CLOSEBRACKETS { }
;

/* The bit number must be a literal number or a constant. */
bit_number: num_integer { }
|           IDENTIFIER { }
;

/* The width of the part select must be a literal number, a constant or a */
/* call to a constant function. */
part_select_width: num_integer                   { }
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
array_select: /* 1st and 2nd type array selects. */
              IDENTIFIER array_index_list 
    { printf("array_select_integer "); }
              /* 3rd type array selects. */
|             IDENTIFIER array_index_list OPENBRACKETS bit_number 
              COLON bit_number CLOSEBRACKETS 
    { printf("array_select_3 "); }
|             IDENTIFIER array_index_list OPENBRACKETS bit_number ADDITION COLON
              part_select_width CLOSEBRACKETS 
    { printf("array_select_3 "); }
|             IDENTIFIER array_index_list OPENBRACKETS bit_number SUBTRACTION
              COLON part_select_width CLOSEBRACKETS 
    { printf("array_select_3 "); }
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
|               DEFPARAM IDENTIFIER PERIOD IDENTIFIER EQUAL number { }
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

/*           Procedural Time Control.          */
/***********************************************/
/* There is 3 type of procedural time control. */
/***********************************************/
/* 1st type: #delay */
/* 2nd type: @(edge signal or edge signal or ... ) */
/* 3rd type: @(edge signal, edge signal, ... ) */
/* 4th type: @(*) */
/* 5th type: wait (expression) */
/***********************************************/
/* edge is optional maybe either 'posedge' or 'negedge'. If no edge is */
/* specified, then any logic transition is used. The use of commas was added */
/* in Verilog-2001. signal may be a net type or variable type, and may be any */
/* vector size. An asterisk in place of the list of signals indicates */
/* sensitivity to any edge of all signals that are read in the statement or */
/* statement group that follows. @* was added in Verilog-2001. */
time_control: /* 1st type procedural time control. Each delay unit can be a
    single number or a minimum:typical:max delay range. */
              HASH procedural_delay_type { }
|             HASH OPENPARENTHESES procedural_delay_type CLOSEPARENTHESES { }
|             OPENPARENTHESES procedural_delay_type COLON procedural_delay_type
    COLON procedural_delay_type CLOSEPARENTHESES { }
              /* 2nd type and 3rd type procedural time control. */
|             AT OPENPARENTHESES procedural_time_conrol_signal_list
    CLOSEPARENTHESES { }
              /* Parenthesis are not required when there is only one signal in
    the list and no edge is specified. */
|             AT IDENTIFIER { }
              /* 4th type procedural time control. */
|             AT MULTIPLICATION { }
              /* 5th type procedural time control. */
|             WAIT OPENPARENTHESES expression CLOSEPARENTHESES { }
;

/* The procedural delay may be a literal number, a variable, or an */
/* expression. */
procedural_delay_type: expression { }
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

procedural_statement: procedural_assignment_statement SEMICOLON { }
|                     procedural_programming_statement          { }
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
                                 variable_or_bit_select EQUAL expression { }
                                 /* 2nd type procedural assignment statement
    (non-blocking procedural assignment). */
|                                variable_or_bit_select LESSTHAN EQUAL
    expression { }
                                 /* 5th type procedural assignment statement
    (blocking intra-assignment delay). */
|                                variable_or_bit_select EQUAL time_control
    expression { }
                                 /* 6th type procedural assignment statement
    (non-blocking intra-assignment delay). */
|                                variable_or_bit_select LESSTHAN EQUAL
    time_control expression { }
                                 /* 7th type procedural assignment statement
    (procedural continuous assignment). */
|                                ASSIGN variable_or_bit_select EQUAL
    expression { }
                                 /* 8th type procedural assignment statement
    (de-activates a procedural continuous assignment). */
|                                DEASSIGN variable_or_bit_select { }
                                 /* 9th type procedural assignment statement
    (forces any data type to a value, overriding all other logic). */
|                                FORCE variable_or_bit_select EQUAL
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
procedural_programming_statement: /* 1st and 2nd type procedural programming
    statements. */
                                  if_statement { }
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

if_statement: simple_if_statement                      { }
|             simple_if_statement ELSE statement_group { }
;

simple_if_statement: IF OPENPARENTHESES expression CLOSEPARENTHESES
    statement_group { }
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
case_item_list: expression_term                      { }
|               case_item_list COMMA expression_term { }
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
|                 AT MULTIPLICATION { }
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

/*           Specify Blocks              */
/*****************************************/
/* specify */
/*   specparam_declarations */ 
/*   simple_pin-to-pin_path_delay */
/*   edge-sensitive_pin-to-pin_path_delay */
/*   state-dependent_pin-to-pin_path_delay */
/*   timing_constraint_checks */
/* endspecify */
/*****************************************/

specify_block: 
             SPECIFY specify_item ENDSPECIFY { printf("specify_block\n");}
;

specify_item:
            specparam_declaration              
            { printf("specparam_declaration "); }
|           simple_path_delay                  
            { printf("simple_path_delay "); }
|           edge_sensitive_path_delay
            { printf("edge_sensitive_path_delay "); }
|           state_dependent_path_delay 
            { printf("state_dependent_path_delay "); }
|           pulse_propagation 
            { printf("pulse_propagation "); }
|           timing_checks
            { printf("timing_constraint_checks "); }

|           specparam_declaration specify_item 
            { printf("specparam_declaration "); }
|           simple_path_delay specify_item
            { printf("simple_path_delay "); }
|           edge_sensitive_path_delay specify_item
            { printf("edge_sensitive_path_delay "); }
|           state_dependent_path_delay specify_item
            { printf("state_dependent_path_delay "); }
|           pulse_propagation specify_item
            { printf("pulse_propagation "); }
|           timing_checks specify_item
            { printf("timing_constraint_checks "); }
;

/* specparam must be declared inside specify */
/* blocks. Cannot use defparam to override values */
specparam_declaration: 
                      SPECPARAM specparam_assignment_list SEMICOLON { }
;

specparam_assignment_list:
                         specparam_assignment { }
|                        specparam_assignment_list COMMA specparam_assignment { }
;

specparam_assignment:
                    IDENTIFIER EQUAL transition_delay_unit { }
|                   pulse_control_specparam { }
;

/* A special specparam constant can be used to control whether the pulse */
/* will propagate to the output (transport delay), not propagate to the */
/* output (inertial delay), or result in a logic X on the output. */
pulse_control_specparam:
                        /* specparam PATHPULSE$ = single_limit; */
                       PATHPULSE EQUAL transition_delay_unit 
                       { printf("pulse_control_specparam "); }

                        /* specparam PATHPULSE$ = (reject_limit, error_limit); */
|                      PATHPULSE EQUAL OPENPARENTHESES 
                       transition_delay_unit COMMA transition_delay_unit 
                       CLOSEPARENTHESES
                       { printf("pulse_control_specparam "); }

;

pulse_propagation:
                  /* pulsestyle_onevent list_of_path_outputs; */
                 PULSESTYLE_ONEVENT SEMICOLON
                 { }
|                PULSESTYLE_ONEVENT IDENTIFIER SEMICOLON
                 { }
|                PULSESTYLE_ONEVENT OPENPARENTHESES nonempty_identifier_list 
                 CLOSEPARENTHESES SEMICOLON
                 { }

                  /* pulsestyle_ondetect list_of_path_outputs; */
|                PULSESTYLE_ONDETECT SEMICOLON
                 { }
|                PULSESTYLE_ONDETECT IDENTIFIER SEMICOLON
                 { }
|                PULSESTYLE_ONDETECT OPENPARENTHESES nonempty_identifier_list 
                 CLOSEPARENTHESES SEMICOLON
                 { }

                  /* showcancelled list_of_path_outputs; */
|                SHOWCANCELLED SEMICOLON
                 { }
|                SHOWCANCELLED IDENTIFIER SEMICOLON
                 { }
|                SHOWCANCELLED OPENPARENTHESES nonempty_identifier_list 
                 CLOSEPARENTHESES SEMICOLON
                 { }

                  /* noshowcancelled list_of_path_outputs; */
|                NOSHOWCANCELLED SEMICOLON
                 { }
|                NOSHOWCANCELLED IDENTIFIER SEMICOLON
                 { }
|                NOSHOWCANCELLED OPENPARENTHESES nonempty_identifier_list 
                 CLOSEPARENTHESES SEMICOLON
                 { }
;

/* (input_port polarity:path_token output_port ) = (delay); */
simple_path_delay: 
                  OPENPARENTHESES nonempty_identifier_list polarity path_token 
                  nonempty_identifier_list CLOSEPARENTHESES EQUAL path_delay 
                  SEMICOLON 
                  { }
;

/* (edge input_port path_token (output_port polarity:source)) = (delay); */
edge_sensitive_path_delay:
                         OPENPARENTHESES edge IDENTIFIER path_token 
                         OPENPARENTHESES IDENTIFIER polarity COLON IDENTIFIER 
                         CLOSEPARENTHESES CLOSEPARENTHESES EQUAL path_delay 
                         SEMICOLON 
                         { }

;

/* if (first_condition) simple_or_edge-sensitive_path_delay */
/* if (next_condition) simple_or_edge-sensitive_path_delay */ 
/* ifnone simple_path_delay */
state_dependent_path_delay:
                          IF OPENPARENTHESES condition CLOSEPARENTHESES 
                          simple_path_delay 
                          { }
|                         IF OPENPARENTHESES condition CLOSEPARENTHESES 
                          edge_sensitive_path_delay 
                          { }
|                         IFNONE simple_path_delay 
                          { } 
;

/* TODO */
/* check for illegal expressions */
condition: 
         expression { }
;

/* Polarity (optional) is either + or –. A – indicates the input will */
/* be inverted. Polarity is ignored by most simulators, but may be */
/* used by timing analyzers. */
polarity: 
|       ADDITION    { }
|       SUBTRACTION { }
;

/* Path_token is either *> for full connection or => for parallel connection. */
/* Parallel connection indicates each input bit of a vector is connected to */
/* its corresponding output bit (bit 0 to bit 0, bit 1 to bit 1, ...) */
/* Full connection indicates an input bit may propagate to any output bit. */
path_token: 
            MULTIPLICATION GREATERTHAN { }
|           EQUAL GREATERTHAN          { }
;

/* Separate delay sets for 1, 2, 3, 6 or 12 transitions may be specified. */
/* Each delay set may have a single delay or a min:typ:max delay range. */
path_delay:      /* all output transitions */
                 transition_delay_unit
                 { }
|                OPENPARENTHESES transition_delay_unit CLOSEPARENTHESES
                 { }
|                IDENTIFIER 
                 { }
|                OPENPARENTHESES IDENTIFIER CLOSEPARENTHESES

                 /* rise, fall output transitions */
|                OPENPARENTHESES transition_delay_unit COMMA 
                 transition_delay_unit CLOSEPARENTHESES 
                 { }
|                OPENPARENTHESES IDENTIFIER COMMA IDENTIFIER CLOSEPARENTHESES 
                 { }

                 /* rise, fall, turn-off output transitions */
|                OPENPARENTHESES transition_delay_unit COMMA 
                 transition_delay_unit COMMA transition_delay_unit 
                 CLOSEPARENTHESES 
                 { }
|                OPENPARENTHESES IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER 
                 CLOSEPARENTHESES 
                 { }
                 
                 /* rise, fall, 0–>Z, Z–>1, 1–>Z, Z–>0 */
|                OPENPARENTHESES transition_delay_unit COMMA 
                 transition_delay_unit COMMA transition_delay_unit 
                 COMMA transition_delay_unit COMMA transition_delay_unit COMMA 
                 transition_delay_unit CLOSEPARENTHESES 
                 { }
|                OPENPARENTHESES IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER 
                 COMMA IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER 
                 CLOSEPARENTHESES 
                 { }
                    
                 /* rise, fall, 0->Z, Z->1, 1->Z, Z->0, */
                 /* 0->X, X->1, 1->X, X->0, X->Z, Z->X  */
|                OPENPARENTHESES transition_delay_unit COMMA 
                 transition_delay_unit COMMA transition_delay_unit 
                 COMMA transition_delay_unit COMMA transition_delay_unit
                 COMMA transition_delay_unit COMMA transition_delay_unit
                 COMMA transition_delay_unit COMMA transition_delay_unit
                 COMMA transition_delay_unit COMMA transition_delay_unit
                 COMMA transition_delay_unit
                 { }
|                OPENPARENTHESES IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER 
                 COMMA IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER 
                 COMMA IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER
                 COMMA IDENTIFIER COMMA IDENTIFIER COMMA IDENTIFIER
                 { }

;

/* Timing constraint checks are special tasks that model restrictions */
/* on input changes, such as setup times and hold times. */
timing_checks:
               /* $setup(data_event, reference_event, limit, notifier); */
              SETUP OPENPARENTHESES data_event COMMA reference_event 
              COMMA limit COMMA notifier CLOSEPARENTHESES SEMICOLON
              { printf("$setup "); }
               /* $setup(data_event, reference_event, limit); */
|             SETUP OPENPARENTHESES data_event COMMA reference_event 
              COMMA limit CLOSEPARENTHESES SEMICOLON
              { printf("$setup "); }

               /* $hold(reference_event, data_event, limit, notifier); */
|             HOLD OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit COMMA notifier CLOSEPARENTHESES SEMICOLON
              { printf("$hold "); }
               /* $hold(reference_event, data_event, limit); */
|             HOLD OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit CLOSEPARENTHESES SEMICOLON
              { printf("$hold "); }

               /* $setuphold(reference_event, data_event, setup_limit, */
               /* hold_limit, notifier, stamptime_condition, */
               /* checktime_condition, delayed_ref, delayed_data); */
|             SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
              COMMA setup_limit COMMA hold_limit COMMA notifier COMMA 
              stamptime_condition COMMA checktime_condition COMMA delayed_ref 
              COMMA delayed_data CLOSEPARENTHESES SEMICOLON
              { printf("$setuphold "); }

               /* $recovery(reference_event, data_event, limit, notifier); */
|             RECOVERY OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit COMMA notifier CLOSEPARENTHESES SEMICOLON 
              { printf("$recovery "); }
               /* $recovery(reference_event, data_event, limit); */
|             RECOVERY OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit CLOSEPARENTHESES SEMICOLON 
              { printf("$recovery "); }

               /* $removal(reference_event, data_event, limit, notifier); */
|             REMOVAL OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit COMMA notifier CLOSEPARENTHESES SEMICOLON
              { }

               /* $recrem(reference_event, data_event, recovery_limit, */
               /* removal_limit, notifier, stamptime_cond, checktime_cond, */
               /* delayed_ref, delayed_data); */
|             RECREM OPENPARENTHESES reference_event COMMA data_event 
              COMMA recovery_limit COMMA removal_limit COMMA notifier COMMA 
              stamptime_condition COMMA checktime_condition COMMA delayed_ref 
              COMMA delayed_data CLOSEPARENTHESES SEMICOLON
              { }

               /* $skew(reference_event, data_event, limit, notifier); */
|             SKEW OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit COMMA notifier CLOSEPARENTHESES SEMICOLON
              { printf("$skew "); }
               /* $skew(reference_event, data_event, limit); */
|             SKEW OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit CLOSEPARENTHESES SEMICOLON
              { printf("$skew "); }

               /* $timeskew(reference_event, data_event, limit, notifier, */
               /* event_based_flag, remain_active_flag); */
|             TIMESKEW OPENPARENTHESES reference_event COMMA data_event 
              COMMA limit COMMA notifier COMMA events_based_flag COMMA 
              remain_active_flag CLOSEPARENTHESES SEMICOLON
              { }

               /* $fullskew(reference_event, data_event, data_skew_limit, */
               /* ref_skew_limit, notifier, event_based_flag, */
               /* remain_active_flag); */
|             FULLSKEW OPENPARENTHESES reference_event COMMA data_event 
              COMMA data_skew_limit COMMA ref_skew_limit COMMA notifier COMMA 
              events_based_flag COMMA remain_active_flag CLOSEPARENTHESES 
              SEMICOLON
              { }

               /* $period(reference_event, limit, notifier); */
|             D_PERIOD OPENPARENTHESES reference_event COMMA limit COMMA 
              notifier CLOSEPARENTHESES SEMICOLON
              { }

               /* $width(reference_event, limit, width_threshold, notifier); */
|             WIDTH OPENPARENTHESES reference_event COMMA limit COMMA 
              width_threshold COMMA notifier CLOSEPARENTHESES SEMICOLON 
              { }

               /* $nochange(reference_event, data_event, start_edge_offset, */
               /* end_edge_offset, notifier); */
|             NOCHANGE OPENPARENTHESES reference_event COMMA data_event 
              COMMA start_edge_offset COMMA end_edge_offset COMMA notifier 
              CLOSEPARENTHESES SEMICOLON
              { }
;

/* The transition at a control signal that establishes the reference time for */
/* tracking timing violations on the data_event. The type is module input or */
/* inout that is scalar or vector net. */
reference_event:
          timing_check_event_control IDENTIFIER THREE_AND timing_check_condition
          { }
|         timing_check_event_control IDENTIFIER 
          { }
|         IDENTIFIER THREE_AND timing_check_condition
          { }
|         IDENTIFIER
          { }
;

/* The signal change that initiates the timing check and is monitored for */
/* violations. The type is module input or inout that is scalar or vector net */
data_event:
          timing_check_event_control IDENTIFIER THREE_AND timing_check_condition
          { }
|         timing_check_event_control IDENTIFIER 
          { }
|         IDENTIFIER THREE_AND timing_check_condition
          { }
|         IDENTIFIER
          { }
;

timing_check_event_control:
                          POSEDGE { }
|                         NEGEDGE { }
|                         edge_control_specifier { }
;

edge_control_specifier:
                      EDGE edge_desciptor COMMA edge_desciptor { }
|                     EDGE edge_desciptor { }
|                     EDGE { }
;

/* Edge descriptor can be 01,10,(x|X|z|Z) (0|1),(0|1) (x|X|z|Z) */
edge_desciptor:
              ZERO_ONE { }
|             ONE_ZERO { }
|             zx_zero_one { }
;
/*                TODO                      */
/* zx_zero_one must included to identifiers */
/* z 0r x and zero or one */
/* X0 X1 x0 x1 Z0 Z1 z0 z1 */
/* 0X 1X 0x 1x 0Z 1Z 0z 1z */
zx_zero_one:
           X_ZERO_UPPER
|          X_ONE_UPPER 
|          X_ZERO_LOW
|          X_ONE_LOW
|          Z_ZERO_UPPER
|          Z_ONE_UPPER
|          Z_ZERO_LOW
|          Z_ONE_LOW
|          ZERO_X_UPPER
|          ONE_X_UPPER 
|          ZERO_X_LOW
|          ONE_X_LOW
|          ZERO_Z_UPPER
|          ONE_Z_UPPER 
|          ZERO_Z_LOW
|          ONE_Z_LOW
;

timing_check_condition:
                      scalar_timing_check_condition { }
|                     OPENPARENTHESES scalar_timing_check_condition 
                      CLOSEPARENTHESES { }
;

/*           TODO                */
/* Check for negation expression */
scalar_timing_check_condition:
                             expression 
                             { }
|                            NEGATION expression 
                             { }
|                            expression EQUAL EQUAL 
                             scalar_constant 
                             { }
|                            expression EQUAL EQUAL EQUAL 
                             scalar_constant 
                             { }
|                            expression PUNCTUATION_MARK EQUAL 
                             scalar_constant 
                             { }
|                            expression PUNCTUATION_MARK EQUAL EQUAL 
                             scalar_constant 
                             { }
;

/* scalar_constant: 1'b0 |1'b1 |1'B0 |1'B1 |'b0 | 'bl |'B0 |'B1|1 |0 */
scalar_constant:
               ONE_BIN_ZERO_LOW { }
|              ONE_BIN_ONE_LOW { }
|              ONE_BIN_ZERO_UPPER { }
|              ONE_BIN_ONE_UPPER { }
|              BIN_ZERO_LOW { }
|              BIN_ONE_LOW { }
|              BIN_ZERO_UPPER { }
|              BIN_ONE_UPPER { }
|              ONE { }
|              ZERO { }
;

/* A time limit used to detect timing violations on the data_event. Limit */
/* is a constant expression. The expression can be a min:typ:max delay set. */
limit:
     expression { }
|    integer_or_real COLON integer_or_real COLON
     integer_or_real { }
;

/* notifier (optional) is a 1-bit reg variable that is automatically */
/* toggled whenever the timing check detects a violation. */
notifier:
        IDENTIFIER { }
;

/* stamptime_condition (optional) is condition for enabling or disabling */
/* negative timing checks. This argument was added in Verilog-2001. */
stamptime_condition:
                   expression { }
;

/* checktime_condition (optional) is condition for enabling or disabling */
/* negative timing checks. This argument was added in Verilog-2001. */
checktime_condition:
                   expression { }
;

/* delayed_ref (optional) is delayed signal for negative timing checks. */
/* This argument was added in Verilog-2001. */
delayed_ref: 
           IDENTIFIER { }
;

/* delayed_data (optional) is delayed signal for negative timing checks. */
/* This argument was added in Verilog-2001. */
delayed_data:
            IDENTIFIER { }
;

/* event_based_flag (optional) when set, causes the timing check to be event */
/* based instead of timer based. This argument was added in Verilog-2001. */
events_based_flag:
                 IDENTIFIER { }
;

/* remain_active_flag (optional) wen set, causes the timing check to not */
/* become inactive after the first violation is reported. This argument was */
/* added in Verilog-2001. */
remain_active_flag:
                  IDENTIFIER { }
;

/* start_edge_offset is delay value (either positive or negative) which /* 
/* expand or reduce the time in which no change can occur. */
start_edge_offset:
                 transition_delay_unit { }
;

/* end_edge_offset is delay value (either positive or negative) */ 
/* which expand or reduce the time in which no change can occur. */
end_edge_offset:
               transition_delay_unit { }
;

/* The largest pulse width that is ignored by the timing check $width */
width_threshold:
                expression { }
|               integer_or_real COLON integer_or_real COLON
                integer_or_real { }
;

recovery_limit:
              expression { }
|             integer_or_real COLON integer_or_real COLON
              integer_or_real { }
;

removal_limit:
             expression { }
|            integer_or_real COLON integer_or_real COLON
             integer_or_real { }
;

setup_limit:
           expression { }
|          integer_or_real COLON integer_or_real COLON
           integer_or_real { }
;

hold_limit:
          expression { }
|         integer_or_real COLON integer_or_real COLON
          integer_or_real { }
;

data_skew_limit:
               expression { }
|              integer_or_real COLON integer_or_real COLON
               integer_or_real { }
;

ref_skew_limit:
              expression { }
|             integer_or_real COLON integer_or_real COLON
              integer_or_real { }
;

integer_or_real: num_integer { }
|                REALV       { }
;

number: num_integer        { }
|       UNSIG_BIN          { }
|       UNSIG_OCT          { }
|       UNSIG_DEC          { }
|       UNSIG_HEX          { }
|       SIG_BIN            { }
|       SIG_OCT            { }
|       SIG_DEC            { }
|       SIG_HEX            { }
|       REALV              { }
|       ONE_BIN_ZERO_LOW   { }
|       ONE_BIN_ONE_LOW    { }
|       ONE_BIN_ZERO_UPPER { }
|       ONE_BIN_ONE_UPPER  { }
|       BIN_ZERO_LOW       { }
|       BIN_ONE_LOW        { }
|       BIN_ZERO_UPPER     { }
|       BIN_ONE_UPPER      { }
;

num_integer:
           NUM_INTEGER { }
|          ONE { }
|          ZERO { }
|          ZERO_ONE { }
|          ONE_ZERO { }
;

%%

main (int argc, char *argv[]) {
    yyparse();
}

yyerror(char *error_string) {
    fprintf(stderr, "ERROR in line %d: %s\n", yylloc.first_line, error_string);
}
