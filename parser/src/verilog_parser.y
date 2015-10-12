/* Verilog 2001 parser */

%{
#include <stdio.h>
#include <stdlib.h>
#include "structures.h"

#define SYNTAX_DEBUG 

%}

%union {
    char* name;   
}

/* Token declarations */

%token <name> IDENTIFIER
%token NUM_INTEGER REALV
/* Verilog 2001 unsigned literals. */
%token UNSIG_BIN UNSIG_OCT UNSIG_DEC UNSIG_HEX
/* Verilog 2001 signed literals. */
%token SIG_BIN SIG_OCT SIG_DEC SIG_HEX
%token MODULE ENDMODULE MACROMODULE
%token EQUALS_SIGN QUESTION_MARK SEMICOLON HASH PERIOD
%token CLOSEPARENTHESES OPENBRACKETS CLOSEBRACKETS OPENBRACES
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
%token INITIAL_TOKEN ALWAYS AT POSEDGE NEGEDGE BEGIN_TOKEN END FORK JOIN DISABLE
%token ASSIGN DEASSIGN FORCE RELEASE IF IFNONE ELSE CASE ENDCASE DEFAULT CASEZ 
%token FOR WHILE REPEAT FOREVER TRIGGER_EVENT_OPERATOR WAIT CASEX
/* Version 2001 task definitions */
%token TASK ENDTASK AUTOMATIC
/* Version 2001 function definitions */
%token FUNCTION ENDFUNCTION
/* Version 2001 specify blocks */
%token SPECIFY ENDSPECIFY PATHPULSE 
%token PULSESTYLE_ONEVENT PULSESTYLE_ONDETECT SHOWCANCELLED NOSHOWCANCELLED
%token SETUP HOLD SETUPHOLD RECOVERY REMOVAL RECREM SKEW TIMESKEW
%token FULLSKEW D_PERIOD WIDTH NOCHANGE
%token EDGE 
%token THREE_AND PUNCTUATION_MARK
/* specify blocks: scalar_constant */
%token ONE ZERO ZERO_ONE ONE_ZERO ONE_BIN_ZERO_LOW ONE_BIN_ONE_LOW
%token ONE_BIN_ZERO_UPPER ONE_BIN_ONE_UPPER BIN_ZERO_LOW BIN_ONE_LOW 
%token BIN_ZERO_UPPER BIN_ONE_UPPER
%token X_ZERO_UPPER X_ONE_UPPER X_ZERO_LOW X_ONE_LOW Z_ZERO_UPPER
%token Z_ONE_UPPER Z_ZERO_LOW Z_ONE_LOW ZERO_X_UPPER ONE_X_UPPER 
%token ZERO_X_LOW ONE_X_LOW ZERO_Z_UPPER ONE_Z_UPPER ZERO_Z_LOW
%token ONE_Z_LOW
/* Version 2001 udp declaration */
%token PRIMITIVE ENDPRIMITIVE TABLE ENDTABLE
%token ONE_BIN_X_LOW_LOW ONE_BIN_X_LOW_UPPER ONE_BIN_X_UPPER_LOW  
%token ONE_BIN_X_UPPER_UPPER
/* Common System Tasks and Functions */
%token F_DISPLAY F_DISPLAYB F_DISPLAYO F_DISPLAYH F_WRITE F_WRITEB F_WRITEO   
%token F_WRITEH F_STROBE F_STROBEB F_STROBEO F_STROBEH F_MONITOR F_MONITORB 
%token F_MONITORO F_MONITORH F_FOPEN F_FCLOSE F_FMONITOR F_FDISPLAY F_FWRITE 
%token F_FSTROBE F_FGETC F_UNGETC F_FGETS F_FSCANF F_FREAD F_FTELL F_FSEEK 
%token F_REWIND F_FERROR F_FFLUSH F_FINISH F_STOP F_TIME F_STIME F_REALTIME  
%token F_TIMEFORMAT F_PRINTTIMESCALE F_SIGNED F_UNSIGNED F_SWRITE F_SWRITEB 
%token F_SWRITEO F_SWRITED F_SFORMAT F_SSCANF F_READMEMB F_READMEMH F_REALTOBITS
%token F_BITSTOREAL F_TEST_PLUSARGS F_VALUE_PLUSARGS
%token TEXT

%token <name> X_LOW X_UPPER B_LOW B_UPPER R_LOW R_UPPER F_LOW F_UPPER 
%token <name> P_LOW P_UPPER N_LOW N_UPPER
%type <name> identifier

/* Tokens with precedence. */

/* PORT_DECLARATION_PRECEDENCE is a fictitious terminal symbol, given less */
/* precedence than the PORT_IDENTIFIER_LIST_PRECEDENCE token. That way, each */
/* port direction keyword matches as many ports as possible */
%left PORT_DECLARATION_PRECEDENCE
%left COMMA

/* THEN is a fictitious terminal symbol, given less precedence than the ELSE */
/* token. That way, every 'else' is matched to the closest 'if'. */
%nonassoc THEN
%nonassoc ELSE

/* SYSTEM_TASK_ENABLE_WITHOUT_EXPRESSIONS_PRECEDENCE is a fictitious terminal */
/* symbol, given less precedence than the OPENPARENTHESES token. That way, */
/* system task enables include expressions if possible. */
%nonassoc SYSTEM_TASK_ENABLE_WITHOUT_EXPRESSIONS_PRECEDENCE

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
/* IDENTIFIER_ONLY is a fictitious terminal symbol, giving lower precedence */
/* to identifiers than identifiers followed by an OPENPARENTHESES */
/* (functions). */
%nonassoc IDENTIFIER_ONLY
/* OPENPARENTHESES gives higher precedence to functions than IDENTIFIER_ONLY. */
%right OPENPARENTHESES
/* CONCATENATED_EXPRESSIONS is a fictitious terminal symbol, giving higher */
/* precedence to concatenation in expressions. */
%nonassoc CONCATENATED_EXPRESSIONS
/* BIT_SELECT is a fictitious terminal symbol, giving higher precedence to */
/* bit selects in expressions. */
%left BIT_SELECT

%error-verbose
%locations
%glr-parser
%expect 1

%%

description: /* empty */
| description module_declaration 
| description udp_declaration
;

/*            Module Definition            */
/*******************************************/
/* There are 2 types of module definiyions */
/*******************************************/
/* 1st: (added in Verilog-2001) */
/* module module_name */
/*      #(parameter_declaration, parameter_declaration,... ) */
/*      (port_declaration port_name, port_name,..., */
/*      port_declaration port_name, port_name,...); */
/*      module items */
/* endmodule */
/* 2st: Old Style Port List */
/* module module_name (port_name, port_name, ... ); */
/*      port_declaration port_name, port_name,...; */
/*      port_declaration port_name, port_name,...; */ 
/*      module items 
/* endmodule
/********************************************/
/* The keyword macromodule is a synonym for */
/* module. */

module_declaration: 
    module_keyword identifier module_parameter OPENPARENTHESES
    module_port_list CLOSEPARENTHESES
    SEMICOLON module_items ENDMODULE 
    { 
        add_module($2); // create a plmodule node in modules hash table
                        // and store module name to plmodule struct

        // store the list of submodules for the current module
        cells[number_of_modules - 1] = current_head;
        current_head = NULL;
    }
|   module_keyword identifier OPENPARENTHESES
    module_port_list CLOSEPARENTHESES
    SEMICOLON module_items ENDMODULE 
    { 
        add_module($2); // create a plmodule node in modules hash table
                        // and store module name to plmodule struct

        // store the list of submodules for the current module
        cells[number_of_modules - 1] = current_head;
        current_head = NULL;
    }
|   module_keyword identifier OPENPARENTHESES nonempty_identifier_list 
    CLOSEPARENTHESES SEMICOLON module_port_body
    module_items ENDMODULE
    { 
        add_module($2); // create a plmodule node in modules hash table
                        // and store module name to plmodule struct

        // store the list of submodules for the current module
        cells[number_of_modules - 1] = current_head;
        current_head = NULL;
    }
;

module_keyword:
    MODULE 
|   MACROMODULE 
;

module_parameter:
    HASH OPENPARENTHESES module_parameter_declaration_list CLOSEPARENTHESES 
;

module_parameter_declaration_list:
    PARAMETER identifier EQUALS_SIGN number 
    { }
|   PARAMETER identifier EQUALS_SIGN number COMMA 
    module_parameter_declaration_list 
    { }
;

/* May have any number of input, output or inout ports, including none. */
module_port_list: 
|   nonempty_module_port_list 
    { }
;

nonempty_module_port_list: 
    module_port_declaration 
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_port_declaration "); 
        #endif
    }
|   nonempty_module_port_list COMMA identifier
    {
        #ifdef SYNTAX_DEBUG
            printf("module_port_declaration "); 
        #endif
    }
|   nonempty_module_port_list COMMA module_port_declaration
    { 
     #ifdef SYNTAX_DEBUG
         printf("module_port_declaration "); 
     #endif
    }
;

module_port_body:
    port_declaration SEMICOLON
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_port_declaration "); 
        #endif
    }
|   module_port_body port_declaration SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_port_declaration "); 
        #endif
    }
;

module_items: /* empty */
|   module_items statement  { }
|   module_items generate_block { }
|   module_items task_definition { }
|   module_items function_declaration { }
|   module_items specify_block { }
|   module_items procedural_programming_statement { }
|   module_items system_task { }
;

nonempty_identifier_list: 
    identifier 
    { 
         #ifdef SYNTAX_DEBUG
             printf("identifier ");
         #endif
    }
|   nonempty_identifier_list COMMA identifier
    { 
         #ifdef SYNTAX_DEBUG
             printf("comma identifier ");
         #endif
    }
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
    GENERATE genvar nonempty_generate_item_list ENDGENERATE 
    { 
        #ifdef SYNTAX_DEBUG
            printf("generate\n");
        #endif
    }
|   GENERATE nonempty_generate_item_list ENDGENERATE 
    { 
        #ifdef SYNTAX_DEBUG
            printf("generate\n");
        #endif
    }
;

nonempty_generate_item_list:
    generate_item { }
|   nonempty_generate_item_list generate_item { }
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
/*  generate_programming_statements */
generate_item:
    statement { }
|   function_declaration { }
|   task_definition { }
|   generate_programming_statement { }
;

/*             Generate Programming Statements.           */
/**********************************************************/
/* There are 4 types of generate programming statements.  */
/**********************************************************/
/* 1st type:  if (constant_expression) generate_item or   */
/*            generate_item_group                         */
/* 2st type:  if (constant_expression)                    */
/*                generate_item or generate_item_group    */
/*            else                                        */
/*                generate_item or generate_item_group    */
/* 3st type:  case (constant_expression)
/*                genvar_value : generate_item or generate_item_group */
/*                genvar_value : generate_item or generate_item_group */
/*                ... */
/*                default: generate_item or generate_item_group */
/*            endcase */
/* 4st type:  for (genvar_name = constant_expression; constant_expression; */
/*            genvar_name = constant_expression) */
/*                generate_item or generate_item_group */
/**********************************************************/
generate_programming_statement:
    /* 1st type generate programming statements. Lower precedence than the 
    rule below, so that each 'else' statement group is matched to the closest 
    'if' statement group. */
    IF OPENPARENTHESES expression CLOSEPARENTHESES
    generate_statement_item %prec THEN 
    { 
        #ifdef SYNTAX_DEBUG
             printf("simple_if "); 
        #endif
    } 
    /* 2rd type generate programming statements. Higher precedence than the rule
    above, so that each 'else' statement group is matched to the closest 'if' 
    statement group. */         
|   IF OPENPARENTHESES expression CLOSEPARENTHESES
    generate_statement_item ELSE generate_statement_item %prec ELSE 
    {
        #ifdef SYNTAX_DEBUG
            printf("if_else ");
        #endif
    }
    /* 3rd type generate programming statement
    (the default case is optional). */
|   CASE OPENPARENTHESES expression CLOSEPARENTHESES 
    generate_case_list_with_optional_default_case ENDCASE
    { }
    /* 6th type generate programming statement.A generate for loop permits one 
    or more generate items to be instantiated multiple times. The index loop 
    variable must be a genvar. */
|   FOR OPENPARENTHESES assignment SEMICOLON expression SEMICOLON
    assignment CLOSEPARENTHESES generate_statement_item 
    { }
;

/* case_item: generate_item or generate_item_group */
/* case_item, case_item: generate_item or generate_item_group */
/* default: generate_item or generate_item_group */
generate_case_list_with_optional_default_case: 
    generate_case_list  
    { }
|   generate_case_list generate_default_case 
    { }
;

generate_case_list: 
    generate_case
    { }
|   generate_case_list generate_case 
    { }
;

generate_case: 
    generate_case_item_list COLON generate_statement_item 
    { }
;

/* The generate_case expression can be a literal, a constant expression or a */
/* bit select. */
generate_case_item_list: 
    expression
    { }
|   generate_case_item_list COMMA expression 
    { }
;

generate_default_case: 
    DEFAULT COLON generate_statement_item 
    { }
;

generate_statement_item:
    generate_item 
    { }
|   generate_item_group 
    { }
;

generate_item_group:
    BEGIN_TOKEN COLON identifier nonempty_generate_item_list END 
    { }
|   BEGIN_TOKEN nonempty_generate_item_list END 
    { }
;

/* genvar is an integer variable which must be a positive */
/* value. They may only be used within a generate block. */
/* Genvar variables only have a value during elaboration, */
/* and do not exist during simulation. Genvar variables must */
/* be declared within the module where the genvar is used. */
/* They may be declared either inside or outside of a generate block. */
genvar: 
    GENVAR nonempty_identifier_list SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("genvar\n"); 
        #endif
    }
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
    TASK AUTOMATIC identifier OPENPARENTHESES task_port_list 
    CLOSEPARENTHESES SEMICOLON task_body ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without body */
|   TASK AUTOMATIC identifier OPENPARENTHESES task_port_list 
    CLOSEPARENTHESES SEMICOLON ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
|   TASK identifier OPENPARENTHESES task_port_list CLOSEPARENTHESES 
    SEMICOLON task_body ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without body */
|   TASK identifier OPENPARENTHESES task_port_list CLOSEPARENTHESES 
    SEMICOLON ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
     /* 2st type: (old style) */
|   TASK AUTOMATIC identifier SEMICOLON task_port_body task_body 
    ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without ports */
|   TASK AUTOMATIC identifier SEMICOLON task_body 
    ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without body */
|   TASK AUTOMATIC identifier SEMICOLON task_port_body ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without ports and body */
|   TASK AUTOMATIC identifier SEMICOLON ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
|   TASK identifier SEMICOLON task_port_body task_body ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without ports */
|   TASK identifier SEMICOLON task_body ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without body */
|   TASK identifier SEMICOLON task_port_body ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
    /* without ports and body */
|   TASK identifier SEMICOLON ENDTASK 
    { 
        #ifdef SYNTAX_DEBUG
            printf("task_definition\n"); 
        #endif
    }
;

/* May have any number of input, output or inout ports, including none. */
task_port_list: 
|   nonempty_task_port_list 
    { }
;

nonempty_task_port_list: 
    task_port_declaration 
    {
        #ifdef SYNTAX_DEBUG
            printf("task_port_declaration ");
        #endif
    }
|   task_port_declaration COMMA task_port_list 
    {
        #ifdef SYNTAX_DEBUG
            printf("task_port_declaration ");
        #endif
    }
;

task_port_body:
    task_port_declaration SEMICOLON
    {
        #ifdef SYNTAX_DEBUG
            printf("task_port_declaration ");
        #endif
    }
|   task_port_body task_port_declaration SEMICOLON 
    {
        #ifdef SYNTAX_DEBUG
            printf("task_port_declaration ");
        #endif
    }
;

task_port_declaration: 
    port_direction SIGNED range identifier 
    { }
|   port_direction SIGNED identifier 
    { }
|   port_direction range identifier 
    { }
|   port_direction REG SIGNED range identifier 
    { }
|   port_direction REG SIGNED identifier 
    { }
|   port_direction REG range identifier 
    { }
|   port_direction task_port_type identifier 
    { }
;

task_port_type: 
    INTEGER 
    { }
|   TIME 
    { }
|   REAL 
    { }
|   REALTIME 
    { }
;

/* task body contains : local variable declarations   */ 
/* and procedural_statement or statement_group        */
task_body: 
    variable_declaration SEMICOLON 
    { }
|   statement_group 
    { }
|   variable_declaration SEMICOLON task_body 
    { }
|   statement_group task_body 
    { }
;

/*             Function Declaration            */
/* There are 2 types of function declarations. */
/***********************************************/
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
/***********************************************/
/* 'automatic', 'signed' and 'range_or_type' are all optional. */
function_declaration: 
    /* 1st type function declarations. */
    FUNCTION AUTOMATIC SIGNED range_or_type identifier OPENPARENTHESES 
    nonempty_function_port_list CLOSEPARENTHESES SEMICOLON
    block_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION AUTOMATIC SIGNED identifier OPENPARENTHESES 
    nonempty_function_port_list CLOSEPARENTHESES SEMICOLON 
    block_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION AUTOMATIC range_or_type identifier OPENPARENTHESES 
    nonempty_function_port_list CLOSEPARENTHESES SEMICOLON
    block_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION AUTOMATIC identifier OPENPARENTHESES nonempty_function_port_list 
    CLOSEPARENTHESES SEMICOLON block_item_declaration_list function_statement 
    ENDFUNCTION 
    { }
|   FUNCTION SIGNED range_or_type identifier OPENPARENTHESES 
    nonempty_function_port_list CLOSEPARENTHESES SEMICOLON 
    block_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION SIGNED identifier OPENPARENTHESES nonempty_function_port_list 
    CLOSEPARENTHESES SEMICOLON block_item_declaration_list function_statement 
    ENDFUNCTION 
    { }
|   FUNCTION range_or_type identifier OPENPARENTHESES 
    nonempty_function_port_list CLOSEPARENTHESES SEMICOLON 
    block_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION identifier OPENPARENTHESES nonempty_function_port_list 
    CLOSEPARENTHESES SEMICOLON block_item_declaration_list function_statement 
    ENDFUNCTION 
    { }
    /* 2nd type function declarations. */
|   FUNCTION AUTOMATIC SIGNED range_or_type identifier SEMICOLON 
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION AUTOMATIC SIGNED identifier SEMICOLON 
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION AUTOMATIC range_or_type identifier SEMICOLON 
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION AUTOMATIC identifier SEMICOLON  
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION SIGNED range_or_type identifier SEMICOLON 
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION SIGNED identifier SEMICOLON 
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION range_or_type identifier SEMICOLON 
    nonempty_function_item_declaration_list function_statement ENDFUNCTION 
    { }
|   FUNCTION identifier SEMICOLON nonempty_function_item_declaration_list 
    function_statement ENDFUNCTION 
    { }
;

nonempty_function_item_declaration_list: 
    function_item_declaration 
    { }
|   nonempty_function_item_declaration_list function_item_declaration 
    { }
;

function_item_declaration: 
    block_item_declaration         
    { }
|   nonempty_tf_input_declaration_list SEMICOLON 
    { }
;

nonempty_tf_input_declaration_list: 
    tf_input_declaration 
    { }
|   nonempty_tf_input_declaration_list COMMA tf_input_declaration 
    { }
|   nonempty_tf_input_declaration_list COMMA identifier 
    { }
;

nonempty_function_port_list: 
    tf_input_declaration 
    { }
|   nonempty_function_port_list COMMA tf_input_declaration 
    { }
|   nonempty_function_port_list COMMA identifier 
    { }
;

tf_input_declaration: 
    INPUT REG SIGNED range identifier 
    { }
|   INPUT REG SIGNED identifier 
    { }
|   INPUT REG range identifier 
    { }
|   INPUT REG identifier 
    { }
|   INPUT SIGNED range identifier 
    { }
|   INPUT SIGNED identifier 
    { }
|   INPUT range identifier 
    { }
|   INPUT identifier 
    { }
|   INPUT task_port_type identifier 
    { }
;

function_statement_or_null: 
    function_statement 
    { }
|   SEMICOLON
    { }
;

/* function_statement ::= */
/*   { attribute_instance } function_blocking_assignment ; */
/* | { attribute_instance } function_case_statement */
/* | { attribute_instance } function_conditional_statement */
/* | { attribute_instance } function_loop_statement */
/* | { attribute_instance } function_seq_block */
/* | { attribute_instance } disable_statement */
/* | { attribute_instance } system_task_enable */
function_statement: 
    function_blocking_assignment   
    { }
|   function_case_statement        
    { }
|   function_conditional_statement 
    { }
|   function_loop_statement        
    { }
|   function_seq_block             
    { }
|   disable_statement              
    { }
|   system_task_enable             
    { }
;

function_blocking_assignment: 
    variable_or_bit_select EQUALS_SIGN expression SEMICOLON 
    { }
;

function_case_statement: 
    CASE OPENPARENTHESES expression CLOSEPARENTHESES 
    nonempty_function_case_item_list ENDCASE 
    { }
|   CASEZ OPENPARENTHESES expression CLOSEPARENTHESES 
    nonempty_function_case_item_list ENDCASE 
    { }
|   CASEX OPENPARENTHESES expression CLOSEPARENTHESES
    nonempty_function_case_item_list ENDCASE 
    { }
;

nonempty_function_case_item_list: 
    function_case_item 
    { }
|   nonempty_function_case_item_list function_case_item 
    { }
;

function_case_item: 
    nonempty_expression_list SEMICOLON function_statement_or_null 
    { }
|   DEFAULT COLON function_statement_or_null 
    { }
|   DEFAULT function_statement_or_null 
    { }
;

nonempty_expression_list: 
    expression %prec EXPRESSION_USED    
    { }
|   nonempty_expression_list expression %prec EXPRESSION_USED 
    { }
;

function_conditional_statement: 
    IF OPENPARENTHESES expression CLOSEPARENTHESES function_statement_or_null 
    %prec THEN 
    { }
|   IF OPENPARENTHESES expression CLOSEPARENTHESES function_statement_or_null 
    ELSE function_statement_or_null 
    { }
;

function_loop_statement: 
    FOREVER function_statement 
    { }
|   REPEAT OPENPARENTHESES expression CLOSEPARENTHESES function_statement 
    { }
|   WHILE OPENPARENTHESES expression CLOSEPARENTHESES function_statement 
    { }
|   FOR OPENPARENTHESES variable_assignment SEMICOLON expression SEMICOLON 
    variable_assignment CLOSEPARENTHESES function_statement 
    { }
;

variable_assignment: 
    variable_lvalue EQUALS_SIGN expression
    { }
;

/* variable_1value ::= */
/* hierarchical_variable_identifier */
/* | hierarchical_variable_identifier [ expression ] { [ expression ] } */
/* | hierarchical_variable_identifier [ expression ] { [ expression ] } [ */
/* range_expression ] */
/* | hierarchical_variable_identifier [ range_expression ] */ 
/* | variable_concatenation */
variable_lvalue: 
    identifier                                             
    { }
|   identifier nonempty_expression_in_brackets_list        
    { }
|   variable_concatenation                                 
    { }
;

nonempty_expression_in_brackets_list: 
    OPENBRACKETS range_expression CLOSEBRACKETS 
    { }
|   OPENBRACKETS expression CLOSEBRACKETS
    { }
|   OPENBRACKETS expression CLOSEBRACKETS nonempty_expression_in_brackets_list 
    { }
;

/* 'range_expression' can also be an 'expression' but this is already covered */
/* in 'variable_lvalue'. */
/* TODO */
/* The correct first rule is: */
/*    constant_expression COLON constant_expression */
/* but at this level all expressions are accepted. */
range_expression: 
    expression COLON expression 
    { }
|   expression PLUS COLON constant_expression     
    { }
|   expression MINUS COLON constant_expression    
    { }
;

variable_concatenation: 
    OPENBRACES nonempty_variable_concatenation_value_list CLOSEBRACES 
    { }
;

nonempty_variable_concatenation_value_list: 
    variable_lvalue        
    { }
|   nonempty_variable_concatenation_value_list COMMA variable_lvalue 
    { }
;

function_seq_block: 
    BEGIN_TOKEN COLON identifier block_item_declaration_list 
    function_statement_list END 
    { }
|   BEGIN_TOKEN function_statement_list END 
    { }
;

block_item_declaration_list: 
    /* empty */
|   block_item_declaration_list block_item_declaration { }
;

block_item_declaration: 
    block_reg_declaration       
    { }
|   event_declaration           
    { }
|   integer_declaration         
    { }
|   local_parameter_declaration 
    { }
|   parameter_declaration       
    { }
|   real_declaration            
    { }
|   realtime_declaration        
    { }
|   time_declaration            
    { }
;

block_reg_declaration: 
    REG SIGNED range list_of_block_variable_identifiers SEMICOLON 
    { }
|   REG SIGNED list_of_block_variable_identifiers SEMICOLON
    { }
|   REG range list_of_block_variable_identifiers SEMICOLON
    { }
|   REG list_of_block_variable_identifiers SEMICOLON 
    { }
;

list_of_block_variable_identifiers: 
    block_variable_type 
    { }
|   list_of_block_variable_identifiers COMMA block_variable_type 
    { }
;

block_variable_type: 
    identifier 
    { }
|   identifier nonempty_dimension_list 
    { }
;

nonempty_dimension_list: 
    dimension                         
    { }
|   nonempty_dimension_list dimension 
    { }
;

dimension: 
    OPENBRACKETS constant_expression COLON constant_expression CLOSEBRACKETS 
    { }
;

event_declaration: 
    EVENT nonempty_list_of_event_identifiers SEMICOLON
    { }
;

nonempty_list_of_event_identifiers: 
    identifier nonempty_dimension_list 
    { }
|   identifier                         
    { }
|                                   
    nonempty_list_of_event_identifiers COMMA identifier nonempty_dimension_list 
    { }
|   nonempty_list_of_event_identifiers COMMA identifier 
    { }
;

integer_declaration: 
    INTEGER nonempty_list_of_variable_identifiers SEMICOLON
    { }
;

nonempty_list_of_variable_identifiers: 
    variable_type 
    { }
|   nonempty_list_of_variable_identifiers COMMA variable_type 
    { }
;

variable_type: 
    identifier                            
    { }
|   identifier EQUALS_SIGN constant_expression 
    { }
|   identifier nonempty_dimension_list    
    { }
;

local_parameter_declaration: 
    LOCALPARAM SIGNED range nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM SIGNED nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM range nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM INTEGER nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM REAL nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM REALTIME nonempty_list_of_param_assignments SEMICOLON 
    { }
|   LOCALPARAM TIME nonempty_list_of_param_assignments SEMICOLON 
    { }
;

nonempty_list_of_param_assignments: 
    param_assignment 
    { }
|   nonempty_list_of_param_assignments COMMA param_assignment 
    { }
;

param_assignment: 
    identifier EQUALS_SIGN constant_expression 
    { }
;

parameter_declaration: 
    PARAMETER SIGNED range nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER SIGNED nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER range nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER INTEGER nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER REAL nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER REALTIME nonempty_list_of_param_assignments SEMICOLON 
    { }
|   PARAMETER TIME nonempty_list_of_param_assignments SEMICOLON 
    { }
;

real_declaration: 
    REAL nonempty_list_of_real_identifiers SEMICOLON
    { }
;

nonempty_list_of_real_identifiers: 
    real_type 
    { }
|   nonempty_list_of_real_identifiers COMMA real_type 
    { }
;

real_type: 
    identifier                            
    { }
|   identifier EQUALS_SIGN constant_expression 
    { }
|   identifier nonempty_dimension_list    
    { }
;

realtime_declaration: 
    REALTIME nonempty_list_of_real_identifiers SEMICOLON
    { }
;

time_declaration: 
    TIME nonempty_list_of_variable_identifiers SEMICOLON
    { }
;

function_statement_list: 
    /* empty */
|   function_statement_list function_statement 
    { }
;

disable_statement: 
    DISABLE identifier SEMICOLON
    { } 
;

system_task_enable: 
    system_identifier OPENPARENTHESES nonempty_expression_list_with_commas 
    CLOSEPARENTHESES 
    { }
|   system_identifier %prec SYSTEM_TASK_ENABLE_WITHOUT_EXPRESSIONS_PRECEDENCE 
    { }
;

nonempty_expression_list_with_commas: 
    expression 
    { }
|                                     
    nonempty_expression_list_with_commas COMMA expression 
    { }
;

range_or_type: 
    range 
|   INTEGER 
|   TIME 
|   REAL 
|   REALTIME 
;

statement: 
    assignment  SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("\n"); 
        #endif
    }
|   declaration SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("\n"); 
        #endif
    }
|   declaration_with_attributes SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("\n"); 
        #endif
    }
|   primitive_instance SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("primitive_instance\n");
        #endif
    }
|   module_instances SEMICOLON 
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_instance\n");
        #endif
    }
|   procedural_block 
    { 
        #ifdef SYNTAX_DEBUG
            printf("procedural_block\n");
        #endif
    }
|   continuous_assignment SEMICOLON 
    { }
;

declaration_with_attributes: 
    attributes declaration 
    { }
;

/*               TODO                    */
/* An attribute can appear as a prefix to module items, statements, or port */
/* connections. An attribute can appear as a suffix to an operator or a call */
/* to a function. */
attributes: 
    OPENPARENTHESES ASTERISK attribute_list ASTERISK CLOSEPARENTHESES
    {
        #ifdef SYNTAX_DEBUG
            printf("attributes"); 
        #endif
    }
;

attribute_list: 
    attribute                      
    { }
|   attribute_list COMMA attribute 
    { }
;

attribute: 
    identifier                  
    { }
|   identifier EQUALS_SIGN identifier
    { }
|   identifier EQUALS_SIGN number
    { }
;

declaration: 
    net_declaration      
    {
        #ifdef SYNTAX_DEBUG
            printf("net_declaration "); 
        #endif
    }
|   variable_declaration 
    {
        #ifdef SYNTAX_DEBUG
            printf("variable_declaration ");
        #endif
    }
|   constant_or_event_declaration
    {
        #ifdef SYNTAX_DEBUG
            printf("constant_or_event_declaration ");
        #endif
    }
|   genvar
    {
        #ifdef SYNTAX_DEBUG
            printf("genvar_declaration ");
        #endif
    }
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
port_declaration: 
    port_direction port_type SIGNED range port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_type SIGNED port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_type range port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_type port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction SIGNED range port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction SIGNED port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction range port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_identifier_list 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
;

module_port_declaration: 
    port_direction port_type SIGNED range identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_type SIGNED identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_type range identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction port_type identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction SIGNED range identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction SIGNED identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction range identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
|   port_direction identifier 
    %prec PORT_DECLARATION_PRECEDENCE 
    { }
;

port_identifier_list:
    identifier 
    { }
|   port_identifier_list COMMA identifier 
    { }
;

/* Port direction can be 'input', 'output' or 'inout'. */
port_direction : 
    INPUT  
    { 
        #ifdef SYNTAX_DEBUG
            printf("input "); 
        #endif
    }
|   OUTPUT 
    { 
        #ifdef SYNTAX_DEBUG
            printf("output "); 
        #endif
    }
|   INOUT 
    { 
        #ifdef SYNTAX_DEBUG
            printf("inout "); 
        #endif
    }
;

/* All data types except real. */
port_type: 
    REG                       
    { }
|   INTEGER                   
    { }
|   TIME                      
    { }
|   REALTIME                  
    { }
|   net_type_except_trireg    
    { }
|   TRIREG                    
    { }
|   other_type                
    { }
;

other_type: 
    PARAMETER 
    { }
|   LOCALPARAM 
    { }
|   GENVAR     
    { }
|   EVENT      
    { }
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
net_declaration: 
    /* 1st type net declarations (except trireg). */
    net_type_except_trireg optional_vectored_or_scalared SIGNED
    range transition_delay net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared SIGNED
    range net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared SIGNED
    transition_delay net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared SIGNED
    net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared range
    transition_delay net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared range
    net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared
    transition_delay net_name_list 
    { }
|   net_type_except_trireg optional_vectored_or_scalared
    net_name_list 
    { }
    /* 1st type net declarations (trireg). */
|   TRIREG optional_vectored_or_scalared SIGNED range
    transition_delay net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared SIGNED range
    net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared SIGNED transition_delay
    net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared SIGNED net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared range transition_delay
    net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared range net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared transition_delay
    net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared net_name_list 
    { }
    /* 2nd type net declarations (except trireg). */
|   net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range transition_delay identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED range identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED transition_delay identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    SIGNED identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    range transition_delay identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    range identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    transition_delay identifier EQUALS_SIGN expression 
    { }
|   net_type_except_trireg optional_vectored_or_scalared strength
    identifier EQUALS_SIGN expression 
    { }
    /* 2nd type net declarations (trireg). */
|   TRIREG optional_vectored_or_scalared strength SIGNED range
    transition_delay identifier EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength SIGNED range
    identifier EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength SIGNED
    transition_delay identifier EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength SIGNED identifier
    EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength range
    transition_delay identifier EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength range identifier
    EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength transition_delay
    identifier EQUALS_SIGN expression 
    { }
|   TRIREG optional_vectored_or_scalared strength identifier EQUALS_SIGN
    expression 
    { }
    /* 3rd type net declarations. */
|   TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED range transition_delay net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED range net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED transition_delay net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    SIGNED net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    range transition_delay net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    range net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    transition_delay net_name_list 
    { }
|   TRIREG optional_vectored_or_scalared capacitance_strength
    net_name_list 
    { }
;

/* The keywords vectored or scalared may be used immediately following */
/* data type keywords. Software tools and/or the Verilog PLI may restrict */
/* access to individual bits within a vector that is declared as */
/* vectored. */
optional_vectored_or_scalared: /* empty */
|   VECTORED 
    { 
        #ifdef SYNTAX_DEBUG
            printf("vectored "); 
        #endif
    }
|   SCALARED 
    {
        #ifdef SYNTAX_DEBUG
            printf("scalared "); 
        #endif
    }
;

/* NOTE: trireg can be declared with capacitance strength, so it cannot be */
/* treated like a regular net type. */
net_type_except_trireg: 
    WIRE    
    { 
        #ifdef SYNTAX_DEBUG
            printf("wire "); 
        #endif
    }
|   WOR     
    { }
|   WAND    
    { }
|   SUPPLY0 
    { }
|   SUPPLY1 
    { }
|   TRI0    
    { }
|   TRI1    
    { }
|   TRI     
    { }
|   TRIOR   
    { }
|   TRIAND  
    { }
;

/* Delays to transitions. Each delay is actually a delay unit. */
/* 1 delay (all transitions). */
/* 2 delays (rise and fall transitions). */
/* 3 delays (rise, fall and tri-state turn-off transitions). */
transition_delay: 
    HASH transition_delay_unit 
    { }
|   HASH OPENPARENTHESES transition_delay_unit CLOSEPARENTHESES
    { }
|   HASH OPENPARENTHESES transition_delay_unit COMMA transition_delay_unit 
    CLOSEPARENTHESES 
    { }
|   HASH OPENPARENTHESES transition_delay_unit COMMA transition_delay_unit COMMA
    transition_delay_unit CLOSEPARENTHESES 
    { }
;

/* Each delay unit can be a single number or a minimum:typical:max delay */
/* range. */
transition_delay_unit: 
    integer_or_real
    { }
|   integer_or_real COLON integer_or_real COLON integer_or_real 
    { }
;

net_name_list: 
    net_name
    { }
|   net_name_list COMMA net_name
    { }
;

net_name: 
    identifier      
    { }
|   identifier array
    { }
;

/* n-dimensional array */
array:
    range       
    {
        #ifdef SYNTAX_DEBUG
            printf("array ");
        #endif
    }
|   array range 
    {
        #ifdef SYNTAX_DEBUG
            printf("array ");
        #endif
    }
;

/* range is optional and is from [ msb : lsb ] */
/* The msb and lsb must be a literal number, a constant, an expression, */
/* or a call to a constant function. */
range: 
    OPENBRACKETS constant_expression COLON constant_expression CLOSEBRACKETS
    { 
        #ifdef SYNTAX_DEBUG
            printf("range ");
        #endif
    }
;

constant_expression: 
    constant_primary                                      
    { }
|   EXCLAMATION_MARK constant_primary
    {
        #ifdef SYNTAX_DEBUG
            printf("logical_not ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   TILDE constant_primary                                
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_not ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|                    
    PLUS constant_primary %prec UNARY_PLUS                
    {
        #ifdef SYNTAX_DEBUG
            printf("unary_plus ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   MINUS constant_primary %prec UNARY_MINUS              
    {
        #ifdef SYNTAX_DEBUG
            printf("unary_minus ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression PLUS constant_expression
    {
        #ifdef SYNTAX_DEBUG
            printf("addition ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression MINUS constant_expression           
    {
        #ifdef SYNTAX_DEBUG
            printf("subtraction ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression ASTERISK constant_expression      
    {
        #ifdef SYNTAX_DEBUG
            printf("multiplication ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression SLASH constant_expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("division ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression MODULO constant_expression        
    {
        #ifdef SYNTAX_DEBUG
            printf("modulus ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression POWER constant_expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("exponentation ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   OPENPARENTHESES constant_expression CLOSEPARENTHESES %prec
    PARENTHESISED_EXPRESSION 
    {
        #ifdef SYNTAX_DEBUG
            printf("parenthesised_expression ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression BITWISE_LEFT_SHIFT constant_expression
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_left_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression BITWISE_RIGHT_SHIFT constant_expression
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_right_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression ARITHMETIC_LEFT_SHIFT
    constant_expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("arithmetic_left_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression ARITHMETIC_RIGHT_SHIFT
    constant_expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("arithmetic_right_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression LESSTHAN constant_expression      
    {
        #ifdef SYNTAX_DEBUG
            printf("less_than ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression LESSTHANOREQUAL constant_expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("less_than_or_equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression GREATERTHAN constant_expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("greater_than ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression GREATERTHANOREQUAL constant_expression
    {
        #ifdef SYNTAX_DEBUG
            printf("greater_than_or_equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression EQUAL constant_expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression NOT_EQUAL constant_expression     
    {
        #ifdef SYNTAX_DEBUG
            printf("not_equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression IDENTICAL constant_expression     
    {
        #ifdef SYNTAX_DEBUG
            printf("identical ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression NOT_IDENTICAL constant_expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("not_intetical ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   AND_OPERATOR constant_primary %prec REDUCTION_AND     
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_and ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
        turn_reduction_flag_on(&reduction_and_flag);
    }
|   NAND_OPERATOR constant_primary                        
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_nand ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   OR_OPERATOR constant_primary %prec REDUCTION_OR       
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_or ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
        turn_reduction_flag_on(&reduction_or_flag);
    }
|   NOR_OPERATOR constant_primary                         
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_nor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   XOR_OPERATOR constant_primary %prec REDUCTION_XOR     
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_xor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   XNOR_OPERATOR constant_primary %prec REDUCTION_XNOR   
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_xnor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression AND_OPERATOR constant_expression  
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_and ");
        #endif
        check_reduction_flag(reduction_and_flag);
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression XOR_OPERATOR constant_expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_xor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression XNOR_OPERATOR constant_expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_xnor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression OR_OPERATOR constant_expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_or ");
        #endif
        check_reduction_flag(reduction_or_flag);
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression LOGICAL_AND constant_expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("logical_and ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression LOGICAL_OR constant_expression    
    {
        #ifdef SYNTAX_DEBUG
            printf("logical_or ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   constant_expression QUESTION_MARK constant_expression COLON
    constant_expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("conditional ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   F_SIGNED OPENPARENTHESES constant_primary
    CLOSEPARENTHESES 
    {
        #ifdef SYNTAX_DEBUG
            printf("cast_to_signed_system_function ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   F_UNSIGNED OPENPARENTHESES constant_primary
    CLOSEPARENTHESES 
    {
        #ifdef SYNTAX_DEBUG
            printf("cast_to_unsigned_system_function ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
;

constant_primary: 
    constant_function_argument 
    { }
|   constant_function_call {
        #ifdef SYNTAX_DEBUG
            printf("constant_function ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   OPENBRACES constant_concatenation_list CLOSEBRACES %prec 
    CONCATENATED_EXPRESSIONS 
    {
        #ifdef SYNTAX_DEBUG
            printf("constant_concatenation ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
;

constant_concatenation_list: 
    constant_concatenation_item 
    { }
|   constant_concatenation_list COMMA constant_concatenation_item 
    { }
;

constant_concatenation_item: 
    /* Nested concatenations are possible with constant
    expressions. */
    constant_expression  
    { }
|   constant_replication 
    { }
;

constant_replication: number OPENBRACES constant_concatenation_list CLOSEBRACES
    { }
;

constant_function_call: identifier OPENPARENTHESES
    constant_function_call_argument_list CLOSEPARENTHESES { }
;

constant_function_call_argument_list: constant_function_argument { }
|                                     constant_function_call_argument_list COMMA
    constant_function_argument { }
;

constant_function_argument: number { 
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|                           identifier %prec IDENTIFIER_ONLY {
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
;

function_call: identifier OPENPARENTHESES function_call_argument_list
    CLOSEPARENTHESES { }
;

function_call_argument_list: expression                                   { }
|                            function_call_argument_list COMMA expression { }
;

/* Logic values can have 8 strength levels: 4 driving, 3 capacitive, and high */
/* impedance (no strength). */
strength: 
    OPENPARENTHESES strength0 COMMA strength1 CLOSEPARENTHESES
    { 
        #ifdef SYNTAX_DEBUG
            printf("strength0, strength1 "); 
        #endif
    }
|   OPENPARENTHESES strength1 COMMA strength0 CLOSEPARENTHESES
    { 
        #ifdef SYNTAX_DEBUG
            printf("strength1, strength0 "); 
        #endif
    }
;

/* Drive strength 0. */
strength0: 
    SUPPLY0 
    { }
|   STRONG0 
    { }
|   PULL0   
    { }
|   WEAK0   
    { }
;

/* Drive strength 1. */
strength1: 
    SUPPLY1 
    { }
|   STRONG1 
    { }
|   PULL1   
    { }
|   WEAK1   
    { }
;

capacitance_strength: 
    OPENPARENTHESES capacitance CLOSEPARENTHESES
    { 
        #ifdef SYNTAX_DEBUG
            printf("capacitance_strength ");
        #endif
    }
;

/* Capacitance strengths. */
capacitance: 
    LARGE  
    { }
|   MEDIUM 
    { }
|   SMALL  
    { }
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
variable_declaration: 
    /* 1st, 2nd and 3rd type variable declarations (except
    reg). */
    variable_type_except_reg variable_name_list 
    { }
    /* 1st, 2nd and 3rd type variable declarations (reg). */
|   REG optional_vectored_or_scalared SIGNED range variable_name_list 
    { }
|   REG optional_vectored_or_scalared SIGNED variable_name_list 
    { }
|   REG optional_vectored_or_scalared range variable_name_list 
    { }
|   REG optional_vectored_or_scalared variable_name_list 
    { }
;

/* NOTE: reg can be declared with 'signed', 'range', 'vectored' and */
/* 'scalared' optional keywords so it cannot be  treated like a regular */
/* variable type. */
variable_type_except_reg: 
    INTEGER  
    { 
        #ifdef SYNTAX_DEBUG
            printf("integer "); 
        #endif
    }
|   TIME     
    { 
        #ifdef SYNTAX_DEBUG
            printf("time "); 
        #endif
    }
|   REAL     
    { 
        #ifdef SYNTAX_DEBUG
            printf("real "); 
        #endif
    }
|   REALTIME 
    { 
        #ifdef SYNTAX_DEBUG
            printf("realtime "); 
        #endif
    }
;

variable_name_list: 
    variable_name_or_assignment                          
    { }
|   variable_name_list COMMA variable_name_or_assignment 
    { }
;

variable_name_or_assignment: 
    identifier                       
    { }
|   identifier EQUALS_SIGN integer_or_real 
    { }
|   identifier array                 
    { }
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
constant_or_event_declaration: 
    /* 1st type constant declarations. */
    PARAMETER SIGNED range constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("parameter "); 
        #endif
    }
|   PARAMETER SIGNED constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("parameter "); 
        #endif
    }
|   PARAMETER range constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("parameter "); 
        #endif
    }
|   PARAMETER constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("parameter "); 
        #endif
    }
    /* 2nd type constant declarations. */
|   PARAMETER constant_type constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("parameter "); 
        #endif
    }
    /* 3rd type constant declarations. */
|   LOCALPARAM SIGNED range constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("localparam "); 
        #endif
    }
|   LOCALPARAM SIGNED constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("localparam "); 
        #endif
    }
|   LOCALPARAM range constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("localparam "); 
        #endif
    }
|   LOCALPARAM constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("localparam "); 
        #endif
    }
    /* 4th type constant declarations. */
|   LOCALPARAM constant_type constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("localparam "); 
        #endif
    }
    /* 5th type constant declarations. */
|   SPECPARAM constant_assignment_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("specparam "); 
        #endif
    }
    /* 6th type event declarations. */
|   EVENT nonempty_identifier_list
    { 
        #ifdef SYNTAX_DEBUG
            printf("event "); 
        #endif
    }
;

constant_assignment_list: 
    constant_assignment                                
    { }
|   constant_assignment_list COMMA constant_assignment 
    { }
;

/* Constants may contain integers, real numbers, time, delays, or ASCII */
/* strings. */
constant_assignment: 
    identifier EQUALS_SIGN number 
    { 
        #ifdef SYNTAX_DEBUG
            printf("constant "); 
        #endif
    }
|   identifier EQUALS_SIGN identifier    
    { 
        #ifdef SYNTAX_DEBUG
            printf("constant "); 
        #endif
    }
;

constant_type: 
    INTEGER    
    { 
        #ifdef SYNTAX_DEBUG
            printf("integer "); 
        #endif
    }
|   REAL       
    { 
        #ifdef SYNTAX_DEBUG
            printf("real "); 
        #endif
    }
|   TIME       
    { 
        #ifdef SYNTAX_DEBUG
            printf("time "); 
        #endif
    }
|   REALTIME   
    { 
        #ifdef SYNTAX_DEBUG
            printf("realtime "); 
        #endif
    }
;

assignment: 
    identifier EQUALS_SIGN expression 
    { 
        #ifdef SYNTAX_DEBUG
            printf("assignment "); 
        #endif
    }
|   identifier EQUALS_SIGN array_select
    { 
        #ifdef SYNTAX_DEBUG
            printf("array_select_assignment "); 
        #endif
    }
;

/*            Continuous Assignments           */
/***********************************************/
/* There are 2 types of continuous assignments */
/* 1st type : assign #(delay) net_name = expression; */
/* 2st type : net_type (strength) [size] #(delay) net_name = expression; */
/***********************************************/
/* 2st type implemented on net declaration */
/* delay , strength and size are optional */
continuous_assignment: 
    /* Explicit Continuous Assignment */
    ASSIGN transition_delay identifier EQUALS_SIGN expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("explicit_continuous_assignment\n"); 
        #endif
    }
|   ASSIGN identifier EQUALS_SIGN expression
    {
        #ifdef SYNTAX_DEBUG
            printf("explicit_continuous_assignment\n"); 
        #endif
    }
|   ASSIGN array_select EQUALS_SIGN expression
    {
        #ifdef SYNTAX_DEBUG
            printf("explicit_continuous_assignment\n"); 
        #endif
    }
    /* TODO bit select is needed? */
|   ASSIGN bit_select EQUALS_SIGN expression
    {
        #ifdef SYNTAX_DEBUG
            printf("explicit_continuous_assignment\n"); 
        #endif
    }
;

expression: 
    primary                             
    { }
|   EXCLAMATION_MARK primary            
    {
        #ifdef SYNTAX_DEBUG
            printf("logical_not ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   TILDE primary                       
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_not ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   PLUS primary %prec UNARY_PLUS       
    {
        #ifdef SYNTAX_DEBUG
            printf("unary_plus ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   MINUS primary %prec UNARY_MINUS     
    {
        #ifdef SYNTAX_DEBUG
            printf("unary_minus ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression PLUS expression          
    {
        #ifdef SYNTAX_DEBUG
            printf("addition ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression MINUS expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("subtraction ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression ASTERISK expression      
    {
        #ifdef SYNTAX_DEBUG
            printf("multiplication ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression SLASH expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("division ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression MODULO expression        
    {
        #ifdef SYNTAX_DEBUG
            printf("modulus ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression POWER expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("exponentation ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   OPENPARENTHESES expression CLOSEPARENTHESES %prec
    PARENTHESISED_EXPRESSION                    
    {
        #ifdef SYNTAX_DEBUG
            printf("parenthesised_expression ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression BITWISE_LEFT_SHIFT expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_left_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression BITWISE_RIGHT_SHIFT expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_right_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression ARITHMETIC_LEFT_SHIFT expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("arithmetic_left_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression ARITHMETIC_RIGHT_SHIFT expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("arithmetic_right_shift ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression LESSTHAN expression      
    {
        #ifdef SYNTAX_DEBUG
            printf("less_than ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression LESSTHANOREQUAL expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("less_than_or_equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression GREATERTHAN expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("greater_than ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression GREATERTHANOREQUAL expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("greater_than_or_equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression EQUAL expression         
    {
        #ifdef SYNTAX_DEBUG
            printf("equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression NOT_EQUAL expression     
    {
        #ifdef SYNTAX_DEBUG
            printf("not_equal ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression IDENTICAL expression     
    {
        #ifdef SYNTAX_DEBUG
            printf("identical ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression NOT_IDENTICAL expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("not_intetical ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   AND_OPERATOR primary %prec REDUCTION_AND 
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_and ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
        turn_reduction_flag_on(&reduction_and_flag);
    }
|   NAND_OPERATOR primary               
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_nand ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   OR_OPERATOR primary %prec REDUCTION_OR 
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_or ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
        turn_reduction_flag_on(&reduction_or_flag);
    }
|   NOR_OPERATOR primary                
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_nor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   XOR_OPERATOR primary %prec REDUCTION_XOR 
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_xor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   XNOR_OPERATOR primary %prec REDUCTION_XNOR 
    {
        #ifdef SYNTAX_DEBUG
            printf("reduction_xnor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression AND_OPERATOR expression  
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_and ");
        #endif
        check_reduction_flag(reduction_and_flag);
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression XOR_OPERATOR expression  
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_xor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression XNOR_OPERATOR expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_xnor ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression OR_OPERATOR expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("bitwise_or ");
        #endif
        check_reduction_flag(reduction_or_flag);
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression LOGICAL_AND expression   
    {
        #ifdef SYNTAX_DEBUG
            printf("logical_and ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression LOGICAL_OR expression    
    {
        #ifdef SYNTAX_DEBUG
            printf("logical_or ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   expression QUESTION_MARK expression COLON expression 
    {
        #ifdef SYNTAX_DEBUG
            printf("conditional ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   F_SIGNED OPENPARENTHESES expression CLOSEPARENTHESES
    {
        #ifdef SYNTAX_DEBUG
            printf("cast_to_signed_system_function ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   F_UNSIGNED OPENPARENTHESES expression CLOSEPARENTHESES
    {
        #ifdef SYNTAX_DEBUG
            printf("cast_to_unsigned_system_function ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
;

primary: constant_function_argument { }
|        bit_select %prec BIT_SELECT {
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   function_call 
    {
        #ifdef SYNTAX_DEBUG
            printf("function ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
|   OPENBRACES concatenation_list CLOSEBRACES %prec CONCATENATED_EXPRESSIONS 
    {
        #ifdef SYNTAX_DEBUG
            printf("concatenation ");
        #endif
        reset_reduction_flags(&reduction_and_flag, &reduction_or_flag);
    }
;

concatenation_list: 
    concatenation_item                          
    { }
|   concatenation_list COMMA concatenation_item 
    { }
;

concatenation_item: 
    /* Nested concatenations are possible with expressions. */
    expression                                
    { }
|   replication                               
    { }
;

replication: 
    number OPENBRACES concatenation_list CLOSEBRACES 
    { }
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
bit_select: 
    /* Bit Select (1st type). */
    identifier index 
    { 
        #ifdef SYNTAX_DEBUG
            printf("bit_select ");
        #endif
    }
    /* Constant Part Select (2nd type). */
|   identifier OPENBRACKETS bit_number COLON bit_number CLOSEBRACKETS
    { 
        #ifdef SYNTAX_DEBUG
            printf("constant_part_select ");
        #endif
    }
    /* Variable Part Select 1 (3rd type). */
|   identifier OPENBRACKETS bit_number PLUS COLON part_select_width 
    CLOSEBRACKETS 
    { 
        #ifdef SYNTAX_DEBUG
            printf("variable_part_select ");
        #endif
    }
    /* Variable Part Select 2 (4th type). */
|   identifier OPENBRACKETS bit_number MINUS COLON part_select_width 
    CLOSEBRACKETS 
    { 
        #ifdef SYNTAX_DEBUG
            printf("variable_part_select ");
        #endif
    }
;

index: OPENBRACKETS bit_number CLOSEBRACKETS { }
;

/* The bit number must be a literal number or a constant. */
bit_number: 
    num_integer
|   identifier 
;

/* The width of the part select must be a literal number, a constant or a */
/* call to a constant function. */
part_select_width: 
    num_integer                   
|   identifier                    
|   constant_function_call        
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
array_select: 
    /* 1st and 2nd type array selects. */
    identifier array_index_list 
    { }
    /* 3rd type array selects. */
|   identifier array_index_list OPENBRACKETS bit_number COLON bit_number 
    CLOSEBRACKETS 
    { }
|   identifier array_index_list OPENBRACKETS bit_number PLUS COLON
    part_select_width CLOSEBRACKETS 
    { }
|   identifier array_index_list OPENBRACKETS bit_number MINUS COLON
    part_select_width CLOSEBRACKETS 
    { }
;

array_index_list: 
    index index { }
|   array_index_list index { }
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
    identifier identifier range OPENPARENTHESES connections CLOSEPARENTHESES 
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_instance ");
        #endif
        // if modules table does not contain the instance module
        // add it to table
        returned_value = check_for_module($1);
        if (returned_value == -1) {
            add_module($1);   
            // add the cell to the list
            current_head = addMcell(current_head, number_of_modules - 1);
        }else {
            // add the cell to the list
            current_head = addMcell(current_head, returned_value);        
        }
    }
|   identifier identifier OPENPARENTHESES connections CLOSEPARENTHESES 
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_instance ");
        #endif
        // if modules table does not contain the instance module
        // add it to table
        returned_value = check_for_module($1);
        if (returned_value == -1) {
            add_module($1);   
            // add the cell to the list
            current_head = addMcell(current_head, number_of_modules - 1);
        }else {
            // add the cell to the list
            current_head = addMcell(current_head, returned_value);        
        }
    }
    /* 3st type module instances (explicit parameter redefinition) */
|   DEFPARAM identifier PERIOD identifier EQUALS_SIGN number 
    { }
    /* 4st and 5st type module instances(implicit and explicit) */
|   identifier HASH OPENPARENTHESES redefinition_list CLOSEPARENTHESES 
    identifier OPENPARENTHESES connections CLOSEPARENTHESES 
    { 
        #ifdef SYNTAX_DEBUG
            printf("module_instance ");
        #endif
        //add_instance($6);
    }
;
/* Parameter values are redefined in the same order in which */
/* they are declared within the module.                      */
redefinition_list: 
    redefinition_value 
    { }
|   redefinition_list COMMA redefinition_value 
    { }
;
redefinition_value: 
    number 
    { }
|   PERIOD identifier OPENPARENTHESES number CLOSEPARENTHESES 
    { }
;

connections: 
    signal                          
    { }
|   connections COMMA signal        
    { }
;
signal:                                   
    signal_values                 
    {
        #ifdef SYNTAX_DEBUG
            printf("simple_signal "); 
        #endif
    }
|   port_name_connection          
    { 
        #ifdef SYNTAX_DEBUG
            printf("port_name_connection ");
        #endif
    }
;

/* Port name connections list both the port name */ 
/* and signal connected to it, in any order. */
port_name_connection:                      
    /* No signal to port (.port_name()) */
    PERIOD identifier OPENPARENTHESES signal_values CLOSEPARENTHESES 
    { }
;

/*             TODO */
/* What values are illegal ? */
/* Signal can be an identifier, a port name */
/* connection or nothing */
signal_values:
|   scalar_constant               
|   identifier                    
|   bit_select           
|   array_select         
|   vector_signal                 
;

signal_values_list:
    signal_values 
    { }
|   signal_values_list COMMA signal_values 
    { }
;

vector_signal: 
    OPENBRACES signal_values_list CLOSEBRACES 
    { }
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
primitive_instance: 
    /* 1st type primitive instances. */
    gate_type strength transition_delay identifier range OPENPARENTHESES 
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength transition_delay identifier OPENPARENTHESES 
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength transition_delay range OPENPARENTHESES 
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength transition_delay OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength identifier range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength identifier OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type strength OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES 
    { }
|   gate_type transition_delay identifier range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type transition_delay identifier OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type transition_delay range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type transition_delay OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type identifier range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type identifier OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   gate_type range OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES 
    { }
|   gate_type OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES 
    { }
    /* 2nd type primitive instances. */
|   switch_type transition_delay identifier range OPENPARENTHESES 
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   switch_type transition_delay identifier OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   switch_type transition_delay range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   switch_type transition_delay OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   switch_type identifier range OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   switch_type identifier OPENPARENTHESES
    nonempty_identifier_list CLOSEPARENTHESES 
    { }
|   switch_type range OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES 
    { }
|   switch_type OPENPARENTHESES nonempty_identifier_list
    CLOSEPARENTHESES 
    { }
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
gate_type: 
    AND      
|   NAND     
|   OR       
|   NOR      
|   XOR      
|   XNOR     
|   BUF      
|   NOT      
|   BUFIF0   
|   NOTIF0   
|   BUFIF1   
|   NOTIF1   
|   PULLUP   
|   PULLDOWN 
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
switch_type: 
    PMOS     
|   NMOS     
|   RPMOS    
|   RNMOS    
|   CMOS     
|   RCMOS    
|   TRAN     
|   RTRAN    
|   TRANIF0  
|   TRANIF1  
|   RTRANIF0 
|   RTRANIF1 
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
procedural_block: 
    INITIAL_TOKEN statement_group           
    { }
|   ALWAYS sensitivity_list statement_group 
    { }
;

/* begin—end groups two or more statements together sequentially. fork—join */
/* groups two or more statements together in parallel. A statement group is */
/* not required if there is only one procedural statement. Named groups may */
/* have local variables, and may be aborted with a disable statement. */
/* 'time_control' is optional at the start of a statement group. */
statement_group: 
    time_control named_begin_group    
    { }
|   named_begin_group                 
    { }
|   time_control unnamed_begin_group  
    { }
|   unnamed_begin_group               
    { }
|   time_control named_fork_group     
    { }
|   named_fork_group                  
    { }
|   time_control unnamed_fork_group   
    { }
|   unnamed_fork_group                
    { }
|   time_control procedural_statement 
    { }
|   procedural_statement              
    { }
;

/* NOTE: BEGIN is a keyword reserved for start conditions in flex. */
/* BEGIN_TOKEN is used as the Verilog token instead. */
named_begin_group: 
    BEGIN_TOKEN COLON identifier named_group_procedural_statements END 
    { }
;

unnamed_begin_group: 
    BEGIN_TOKEN unnamed_group_procedural_statements END 
    { }
;

named_fork_group: 
    FORK COLON identifier named_group_procedural_statements JOIN
    { }
;

unnamed_fork_group: 
    FORK unnamed_group_procedural_statements JOIN 
    { }
;

named_group_procedural_statements: 
    named_group_procedural_statement 
    { }
|   named_group_procedural_statements named_group_procedural_statement 
    { }
;

/* "disable group_name;" discontinues execution of a named group of */
/* statements. time_control before procedural statements is optional. */
named_group_procedural_statement: 
    /* Local variable declaration. */
    variable_declaration SEMICOLON    
    { }
|   DISABLE identifier SEMICOLON      
    { }
|   time_control procedural_statement 
    { }
|   procedural_statement              
    { }
;

unnamed_group_procedural_statements: 
    unnamed_group_procedural_statement 
    { }
|   unnamed_group_procedural_statements unnamed_group_procedural_statement 
    { }
;

/* time_control before procedural statements is optional. */
unnamed_group_procedural_statement: 
    time_control procedural_statement 
    { }
|   procedural_statement              
    { }
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
time_control: 
    /* 1st type procedural time control. Each delay unit can be a
    single number or a minimum:typical:max delay range. */
    HASH expression %prec EXPRESSION_USED 
    { }
|   OPENPARENTHESES expression COLON expression COLON expression
    CLOSEPARENTHESES %prec EXPRESSION_USED 
    { }
    /* 2nd type and 3rd type procedural time control. */
|   AT OPENPARENTHESES procedural_time_conrol_signal_list
    CLOSEPARENTHESES 
    { }
    /* Parenthesis are not required when there is only one signal in
    the list and no edge is specified. */
|   AT identifier 
    { }
    /* 4th type procedural time control. */
|   AT ASTERISK 
    { }
    /* 5th type procedural time control. */
|   WAIT OPENPARENTHESES expression CLOSEPARENTHESES 
    { }
;

/* Either a comma or the keyword 'or' may be used to specify events on any */
/* of several signals. The use of commas was added in Verilog-2001. */
procedural_time_conrol_signal_list: 
    procedural_time_conrol_signal 
    { }
    /* 2nd type procedural time control. */
|   procedural_time_conrol_signal_list COMMA procedural_time_conrol_signal 
    { }
    /* 3rd type procedural time control. */
|   procedural_time_conrol_signal_list OR procedural_time_conrol_signal 
    { }
;

/* edge is optional maybe either 'posedge' or 'negedge'. If no edge is */
/* specified, then any logic transition is used. */
procedural_time_conrol_signal: 
    edge identifier 
|   identifier      
;

procedural_statement: 
    procedural_assignment_statement SEMICOLON          
    { }
|   procedural_programming_statement                   
    { }
|   TRIGGER_EVENT_OPERATOR identifier SEMICOLON        
    { }
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
procedural_assignment_statement: 
    /* 1st type procedural assignment statement 
    (blocking procedural assignment). */
    variable_or_bit_select EQUALS_SIGN expression 
    { }
    /* 2nd type procedural assignment statement 
    (non-blocking procedural assignment). */
|   variable_or_bit_select LESSTHANOREQUAL expression %prec EXPRESSION_USED 
    { }
    /* 5th type procedural assignment statement
    (blocking intra-assignment delay). */
|   variable_or_bit_select EQUALS_SIGN time_control expression 
    { }
    /* 6th type procedural assignment statement
    (non-blocking intra-assignment delay). */
|   variable_or_bit_select LESSTHANOREQUAL time_control expression %prec 
    EXPRESSION_USED 
    { }
    /* 7th type procedural assignment statement
    (procedural continuous assignment). */
|   ASSIGN variable_or_bit_select EQUALS_SIGN expression 
    { }
    /* 8th type procedural assignment statement
    (de-activates a procedural continuous assignment). */
|   DEASSIGN variable_or_bit_select 
    { }
    /* 9th type procedural assignment statement
    (forces any data type to a value, overriding all other logic). */
|   FORCE variable_or_bit_select EQUALS_SIGN expression 
    { }
    /* 10th type procedural assignment statement
    (removes the effect of a force). */
|   RELEASE variable_or_bit_select 
    { }
;

variable_or_bit_select: 
    identifier 
|   bit_select 
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
procedural_programming_statement: 
    /* 1st type procedural programming statements. Lower precedence than the 
    rule below, so that each 'else' statement group is matched to the closest 
    'if' statement group. */
    IF OPENPARENTHESES expression CLOSEPARENTHESES statement_group %prec THEN 
    { 
        #ifdef SYNTAX_DEBUG
            printf("simple_if "); 
        #endif
    }
    /* 2nd type procedural programming statements. Higher precedence than the 
    rule above, so that each 'else' statement group is matched to the closest 
    'if' statement group. */         
|   IF OPENPARENTHESES expression CLOSEPARENTHESES statement_group ELSE 
    statement_group %prec ELSE 
    { 
        #ifdef SYNTAX_DEBUG
            printf("if_else ");
        #endif
    }
    /* 3rd type procedural programming statement(the default case is optional.*/
|   CASE OPENPARENTHESES expression CLOSEPARENTHESES 
    case_list_with_optional_default_case ENDCASE 
    { }
    /* 4th type procedural programming statement (special version of the case 
    statement which uses a Z logic value to represent don't-care bits in either 
    the case expression or a case item). */
|   CASEZ OPENPARENTHESES expression CLOSEPARENTHESES 
    case_list_with_optional_default_case ENDCASE 
    { }
    /* 5th type procedural programming statement (special version of the case 
    statement which uses Z or X logic values to represent don't-care bits in 
    either the case expression or a case item). */
|   CASEX OPENPARENTHESES expression CLOSEPARENTHESES 
    case_list_with_optional_default_case ENDCASE 
    { }
    /* 6th type procedural programming statement. */
|   FOR OPENPARENTHESES procedural_assignment_statement SEMICOLON expression 
    SEMICOLON procedural_assignment_statement CLOSEPARENTHESES statement_group 
    { }
    /* 7th type procedural programming statement. */
|   WHILE OPENPARENTHESES expression CLOSEPARENTHESES statement_group 
    { }
    /* 8th type procedural programming statement (the number may be an 
    expression). */
|   REPEAT OPENPARENTHESES expression CLOSEPARENTHESES statement_group 
    { }
    /* 9th type procedural programming statement. */
|   FOREVER statement_group 
    { }
    /* NOTE: 10th type procedural programming
    statement is declared in named_group_procedural_statement. */
;

/* case_item: statement_or_statement_group */
/* case_item, case_item: statement_or_statement_group */
/* default: statement_or_statement_group */
case_list_with_optional_default_case: 
    case_list              
    { }
|   case_list default_case 
    { }
;

case_list:
    case           
    { }
|   case_list case 
    { }
;

case:
    case_item_list COLON statement_group 
    { }
;

/* The case expression can be a literal, a constant expression or a bit */
/* select. */
case_item_list: 
    expression                      
    { }
|   case_item_list COMMA expression 
    { }
;

default_case: 
    DEFAULT COLON statement_group 
    { }
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
sensitivity_list: 
    /* 1st type sensitivity lists. */
    AT OPENPARENTHESES nonempty_identifier_list CLOSEPARENTHESES
    { }
    /* 2nd type sensitivity lists. */
|   AT ASTERISK 
    { }
|   AT OPENPARENTHESES ASTERISK CLOSEPARENTHESES 
    { }
    /* 3rd type sensitivity lists. A specific edge should be
    specified for each signal in the list. */
|   AT OPENPARENTHESES signal_list_with_edge CLOSEPARENTHESES 
    { }
;

signal_list_with_edge: 
    signal_with_edge                             
    { }
|   signal_list_with_edge COMMA signal_with_edge 
    { }
;

signal_with_edge:
    edge identifier 
    { }
;

edge: 
    POSEDGE 
|   NEGEDGE 
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
    SPECIFY specify_item ENDSPECIFY 
    { 
        #ifdef SYNTAX_DEBUG
            printf("specify_block\n");
        #endif
    }
;

specify_item:
    specparam_declaration              
    { }
|   simple_path_delay                  
    { }
|   edge_sensitive_path_delay
    { }
|   state_dependent_path_delay 
    { }
|   pulse_propagation 
    { }
|   timing_checks
    { }
|   specparam_declaration specify_item 
    { }
|   simple_path_delay specify_item
    { }
|   edge_sensitive_path_delay specify_item
    { }
|   state_dependent_path_delay specify_item
    { }
|   pulse_propagation specify_item
    { }
|   timing_checks specify_item
    { }
;

/* specparam must be declared inside specify */
/* blocks. Cannot use defparam to override values */
specparam_declaration: 
    SPECPARAM specparam_assignment_list SEMICOLON 
    { }
;

specparam_assignment_list:
    specparam_assignment 
    { }
|   specparam_assignment_list COMMA specparam_assignment 
    { }
;

specparam_assignment:
    identifier EQUALS_SIGN transition_delay_unit 
    { }
|   pulse_control_specparam 
    { }
;

/* A special specparam constant can be used to control whether the pulse */
/* will propagate to the output (transport delay), not propagate to the */
/* output (inertial delay), or result in a logic X on the output. */
pulse_control_specparam:
    /* specparam PATHPULSE$ = single_limit; */
    PATHPULSE EQUALS_SIGN transition_delay_unit 
    { }

    /* specparam PATHPULSE$ = (reject_limit, error_limit); */
|   PATHPULSE EQUALS_SIGN OPENPARENTHESES 
    transition_delay_unit COMMA transition_delay_unit 
    CLOSEPARENTHESES
    { }

;

pulse_propagation:
    /* pulsestyle_onevent list_of_path_outputs; */
    PULSESTYLE_ONEVENT SEMICOLON
    { }
|   PULSESTYLE_ONEVENT identifier SEMICOLON
    { }
|   PULSESTYLE_ONEVENT OPENPARENTHESES nonempty_identifier_list 
    CLOSEPARENTHESES SEMICOLON
    { }

    /* pulsestyle_ondetect list_of_path_outputs; */
|   PULSESTYLE_ONDETECT SEMICOLON
    { }
|   PULSESTYLE_ONDETECT identifier SEMICOLON
    { }
|   PULSESTYLE_ONDETECT OPENPARENTHESES nonempty_identifier_list 
    CLOSEPARENTHESES SEMICOLON
    { }

    /* showcancelled list_of_path_outputs; */
|   SHOWCANCELLED SEMICOLON
    { }
|   SHOWCANCELLED identifier SEMICOLON
    { }
|   SHOWCANCELLED OPENPARENTHESES nonempty_identifier_list 
    CLOSEPARENTHESES SEMICOLON
    { }

    /* noshowcancelled list_of_path_outputs; */
|   NOSHOWCANCELLED SEMICOLON
    { }
|   NOSHOWCANCELLED identifier SEMICOLON
    { }
|   NOSHOWCANCELLED OPENPARENTHESES nonempty_identifier_list 
    CLOSEPARENTHESES SEMICOLON
    { }
;

/* (input_port polarity:path_token output_port ) = (delay); */
simple_path_delay: 
    OPENPARENTHESES nonempty_identifier_list polarity path_token 
    nonempty_identifier_list CLOSEPARENTHESES EQUALS_SIGN path_delay 
    SEMICOLON 
    { }
;

/* (edge input_port path_token (output_port polarity:source)) = (delay); */
edge_sensitive_path_delay:
    OPENPARENTHESES edge identifier path_token 
    OPENPARENTHESES identifier polarity COLON identifier 
    CLOSEPARENTHESES CLOSEPARENTHESES EQUALS_SIGN path_delay 
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
|   IF OPENPARENTHESES condition CLOSEPARENTHESES 
    edge_sensitive_path_delay 
    { }
|   IFNONE simple_path_delay 
    { } 
;

/* TODO */
/* check for illegal expressions */
condition: 
    expression 
;

/* Polarity (optional) is either + or –. A – indicates the input will */
/* be inverted. Polarity is ignored by most simulators, but may be */
/* used by timing analyzers. */
polarity: 
|   PLUS
|   MINUS
;

/* Path_token is either *> for full connection or => for parallel connection. */
/* Parallel connection indicates each input bit of a vector is connected to */
/* its corresponding output bit (bit 0 to bit 0, bit 1 to bit 1, ...) */
/* Full connection indicates an input bit may propagate to any output bit. */
path_token: 
    ASTERISK GREATERTHAN 
|   EQUALS_SIGN GREATERTHAN 
;

/* Separate delay sets for 1, 2, 3, 6 or 12 transitions may be specified. */
/* Each delay set may have a single delay or a min:typ:max delay range. */
path_delay:      
    /* all output transitions */
    transition_delay_unit
    { }
|   OPENPARENTHESES transition_delay_unit CLOSEPARENTHESES
    { }
|   identifier 
    { }
|   OPENPARENTHESES identifier CLOSEPARENTHESES

    /* rise, fall output transitions */
|   OPENPARENTHESES transition_delay_unit COMMA 
    transition_delay_unit CLOSEPARENTHESES 
    { }
|   OPENPARENTHESES identifier COMMA identifier CLOSEPARENTHESES 
    { }

    /* rise, fall, turn-off output transitions */
|   OPENPARENTHESES transition_delay_unit COMMA 
    transition_delay_unit COMMA transition_delay_unit 
    CLOSEPARENTHESES 
    { }
|   OPENPARENTHESES identifier COMMA identifier COMMA identifier 
    CLOSEPARENTHESES 
    { }
    
    /* rise, fall, 0–>Z, Z–>1, 1–>Z, Z–>0 */
|   OPENPARENTHESES transition_delay_unit COMMA 
    transition_delay_unit COMMA transition_delay_unit 
    COMMA transition_delay_unit COMMA transition_delay_unit COMMA 
    transition_delay_unit CLOSEPARENTHESES 
    { }
|   OPENPARENTHESES identifier COMMA identifier COMMA identifier 
    COMMA identifier COMMA identifier COMMA identifier 
    CLOSEPARENTHESES 
    { }
       
    /* rise, fall, 0->Z, Z->1, 1->Z, Z->0, */
    /* 0->X, X->1, 1->X, X->0, X->Z, Z->X  */
|   OPENPARENTHESES transition_delay_unit COMMA 
    transition_delay_unit COMMA transition_delay_unit 
    COMMA transition_delay_unit COMMA transition_delay_unit
    COMMA transition_delay_unit COMMA transition_delay_unit
    COMMA transition_delay_unit COMMA transition_delay_unit
    COMMA transition_delay_unit COMMA transition_delay_unit
    COMMA transition_delay_unit
    { }
|   OPENPARENTHESES identifier COMMA identifier COMMA identifier 
    COMMA identifier COMMA identifier COMMA identifier 
    COMMA identifier COMMA identifier COMMA identifier
    COMMA identifier COMMA identifier COMMA identifier
    { }

;

/* Timing constraint checks are special tasks that model restrictions */
/* on input changes, such as setup times and hold times. */
timing_checks:
    /* $setup(data_event, reference_event, limit); */
    SETUP OPENPARENTHESES data_event COMMA reference_event 
    COMMA timing_check_limit CLOSEPARENTHESES SEMICOLON
    { }
    /* $setup(data_event, reference_event, limit, notifier); */
|   SETUP OPENPARENTHESES data_event COMMA reference_event 
    COMMA timing_check_limit COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }

    /* $hold(reference_event, data_event, limit); */
|   HOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit CLOSEPARENTHESES SEMICOLON
    { }
    /* $hold(reference_event, data_event, limit, notifier); */
|   HOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }

    /* $setuphold(reference_event, data_event, setup_limit, */
    /* hold_limit); */
|   SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit CLOSEPARENTHESES
    SEMICOLON 
    { }
    /* $setuphold(reference_event, data_event, setup_limit, */
    /* hold_limit, notifier); */
|   SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    CLOSEPARENTHESES SEMICOLON 
    { }
    /* $setuphold(reference_event, data_event, setup_limit, */
    /* hold_limit, notifier, stamptime_condition ); */
|   SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier
    COMMA stamptime_condition CLOSEPARENTHESES SEMICOLON
    { }
    /* $setuphold(reference_event, data_event, setup_limit, */
    /* hold_limit, notifier, stamptime_condition, */
    /* checktime_condition); */
|   SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA stamptime_condition COMMA checktime_condition 
    CLOSEPARENTHESES SEMICOLON
    { }
    /* $setuphold(reference_event, data_event, setup_limit, */
    /* hold_limit, notifier, stamptime_condition, */
    /* checktime_condition, delayed_ref); */
|   SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier
    COMMA stamptime_condition COMMA checktime_condition COMMA 
    delayed_ref CLOSEPARENTHESES SEMICOLON
    { }
    /* $setuphold(reference_event, data_event, setup_limit, */
    /* hold_limit, notifier, stamptime_condition, */
    /* checktime_condition, delayed_ref, delayed_data); */
|   SETUPHOLD OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier
    COMMA stamptime_condition COMMA checktime_condition COMMA 
    delayed_ref COMMA delayed_data CLOSEPARENTHESES SEMICOLON 
    { }

    /* $recovery(reference_event, data_event, limit); */
|   RECOVERY OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit CLOSEPARENTHESES SEMICOLON 
    { }
    /* $recovery(reference_event, data_event, limit, notifier); */
|   RECOVERY OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }

    /* $removal(reference_event, data_event, limit); */
|   REMOVAL OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit CLOSEPARENTHESES SEMICOLON
    { }
    /* $removal(reference_event, data_event, limit, notifier); */
|   REMOVAL OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }

    /* $recrem(reference_event, data_event, recovery_limit, */
    /* removal_limit); */
|   RECREM OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit 
    CLOSEPARENTHESES SEMICOLON 
    { }
    /* $recrem(reference_event, data_event, recovery_limit, */
    /* removal_limit, notifier); */
|   RECREM OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    CLOSEPARENTHESES SEMICOLON 
    { }
    /* $recrem(reference_event, data_event, recovery_limit, */
    /* removal_limit, notifier, stamptime_cond); */
|   RECREM OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA stamptime_condition CLOSEPARENTHESES SEMICOLON 
    { }
    /* $recrem(reference_event, data_event, recovery_limit, */
    /* removal_limit, notifier, stamptime_cond, checktime_cond ); */
|   RECREM OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA stamptime_condition COMMA checktime_condition 
    CLOSEPARENTHESES SEMICOLON 
    { }
    /* $recrem(reference_event, data_event, recovery_limit, */
    /* removal_limit, notifier, stamptime_cond, checktime_cond, */
    /* delayed_ref); */
|   RECREM OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA stamptime_condition COMMA checktime_condition COMMA 
    delayed_ref CLOSEPARENTHESES SEMICOLON 
    { }
    /* $recrem(reference_event, data_event, recovery_limit, */
    /* removal_limit, notifier, stamptime_cond, checktime_cond, */
    /* delayed_ref, delayed_data); */
|   RECREM OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA stamptime_condition COMMA checktime_condition COMMA 
    delayed_ref COMMA delayed_data CLOSEPARENTHESES SEMICOLON 
    { }

    /* $skew(reference_event, data_event, limit); */
|   SKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit CLOSEPARENTHESES SEMICOLON
    { }
    /* $skew(reference_event, data_event, limit, notifier); */
|   SKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }

    /* $timeskew(reference_event, data_event, limit)*/
|   TIMESKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit CLOSEPARENTHESES SEMICOLON
    { }
    /* $timeskew(reference_event, data_event, limit, notifier) */
|   TIMESKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }
    /* $timeskew(reference_event, data_event, limit, notifier, */
    /* event_based_flag); */
|   TIMESKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier COMMA events_based_flag 
    CLOSEPARENTHESES SEMICOLON
    { }
    /* $timeskew(reference_event, data_event, limit, notifier, */
    /* event_based_flag, remain_active_flag); */
|   TIMESKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA notifier COMMA events_based_flag 
    COMMA remain_active_flag CLOSEPARENTHESES SEMICOLON
    { }

    /* $fullskew(reference_event, data_event, data_skew_limit, */
    /* ref_skew_limit); */
|   FULLSKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit 
    CLOSEPARENTHESES SEMICOLON
    { }
    /* $fullskew(reference_event, data_event, data_skew_limit, */
    /* ref_skew_limit, notifier); */
|   FULLSKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    CLOSEPARENTHESES SEMICOLON
    { }
    /* $fullskew(reference_event, data_event, data_skew_limit, */
    /* ref_skew_limit, notifier, events_based_flag); */
|   FULLSKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA events_based_flag CLOSEPARENTHESES SEMICOLON
    { }
    /* $fullskew(reference_event, data_event, data_skew_limit, */
    /* ref_skew_limit, notifier, events_based_flag */
    /* remain_active_flag); */
|   FULLSKEW OPENPARENTHESES reference_event COMMA data_event 
    COMMA timing_check_limit COMMA timing_check_limit COMMA notifier 
    COMMA events_based_flag COMMA remain_active_flag 
    CLOSEPARENTHESES SEMICOLON
    { }

    /* $period(reference_event, limit); */
|   D_PERIOD OPENPARENTHESES reference_event COMMA timing_check_limit 
    CLOSEPARENTHESES SEMICOLON
    { }
    /* $period(reference_event, limit, notifier); */
|   D_PERIOD OPENPARENTHESES reference_event COMMA timing_check_limit 
    COMMA notifier CLOSEPARENTHESES SEMICOLON
    { }

    /* $width(reference_event, limit, width_threshold); */
|   WIDTH OPENPARENTHESES reference_event COMMA timing_check_limit 
    COMMA width_threshold CLOSEPARENTHESES SEMICOLON 
    { }
    /* $width(reference_event, limit, width_threshold, notifier); */
|   WIDTH OPENPARENTHESES reference_event COMMA timing_check_limit 
    COMMA width_threshold COMMA notifier CLOSEPARENTHESES SEMICOLON 
    { }

    /* $nochange(reference_event, data_event, start_edge_offset, */
    /* end_edge_offset); */
|   NOCHANGE OPENPARENTHESES reference_event COMMA data_event 
    COMMA start_edge_offset COMMA end_edge_offset 
    CLOSEPARENTHESES SEMICOLON
    { }
    /* $nochange(reference_event, data_event, start_edge_offset, */
    /* end_edge_offset, notifier); */
|   NOCHANGE OPENPARENTHESES reference_event COMMA data_event 
    COMMA start_edge_offset COMMA end_edge_offset COMMA notifier 
    CLOSEPARENTHESES SEMICOLON
    { }
;

/* The transition at a control signal that establishes the reference time for */
/* tracking timing violations on the data_event. The type is module input or */
/* inout that is scalar or vector net. */
reference_event:
    timing_check_event_control identifier THREE_AND 
    scalar_timing_check_condition
    { }
|   timing_check_event_control identifier 
    { }
|   identifier THREE_AND scalar_timing_check_condition
    { }
|   identifier
    { }
;

/* The signal change that initiates the timing check and is monitored for */
/* violations. The type is module input or inout that is scalar or vector net */
data_event:
    timing_check_event_control identifier THREE_AND 
    scalar_timing_check_condition
    { }
|   timing_check_event_control identifier 
    { }
|   identifier THREE_AND scalar_timing_check_condition
    { }
|   identifier
    { }
;

timing_check_event_control:
    POSEDGE 
|   NEGEDGE 
|   edge_control_specifier 
;

edge_control_specifier:
    EDGE edge_desciptor COMMA edge_desciptor 
|   EDGE edge_desciptor 
|   EDGE 
;

/* Edge descriptor can be 01,10,(x|X|z|Z) (0|1),(0|1) (x|X|z|Z) */
edge_desciptor:
    ZERO_ONE
|   ONE_ZERO
|   zx_zero_one
;
/*                TODO                      */
/* zx_zero_one must included to identifiers */
/* z 0r x and zero or one */
/* X0 X1 x0 x1 Z0 Z1 z0 z1 */
/* 0X 1X 0x 1x 0Z 1Z 0z 1z */
zx_zero_one:
    X_ZERO_UPPER
|   X_ONE_UPPER 
|   X_ZERO_LOW
|   X_ONE_LOW
|   Z_ZERO_UPPER
|   Z_ONE_UPPER
|   Z_ZERO_LOW
|   Z_ONE_LOW
|   ZERO_X_UPPER
|   ONE_X_UPPER 
|   ZERO_X_LOW
|   ONE_X_LOW
|   ZERO_Z_UPPER
|   ONE_Z_UPPER 
|   ZERO_Z_LOW
|   ONE_Z_LOW
;

/*               TODO                  */
/* The cases in comments work with     */
/* conflicts. With the current grammar */
/* any value on scalar_constant is allowed */
 
scalar_timing_check_condition:
    expression 
    { }
/*|   expression EQUAL 
    scalar_constant 
    { }
|   expression IDENTICAL 
    scalar_constant 
    { }
|   expression NOT_EQUAL 
    scalar_constant 
    { }
|   expression NOT_IDENTICAL 
    scalar_constant 
    { }
*/
;

/* scalar_constant: 1'b0 |1'b1 |1'B0 |1'B1 |'b0 | 'bl |'B0 |'B1|1 |0 */
scalar_constant:
    ONE_BIN_ZERO_LOW 
|   ONE_BIN_ONE_LOW 
|   ONE_BIN_ZERO_UPPER 
|   ONE_BIN_ONE_UPPER 
|   BIN_ZERO_LOW 
|   BIN_ONE_LOW 
|   BIN_ZERO_UPPER 
|   BIN_ONE_UPPER 
|   ONE 
|   ZERO 
;

/* A time limit used to detect timing violations on the data_event. Limit */
/* is a constant expression. The expression can be a min:typ:max delay set. */
timing_check_limit:
    expression 
|   integer_or_real COLON integer_or_real COLON integer_or_real 
;

/* notifier (optional) is a 1-bit reg variable that is automatically */
/* toggled whenever the timing check detects a violation. */
notifier:
    identifier 
;

/* stamptime_condition (optional) is condition for enabling or disabling */
/* negative timing checks. This argument was added in Verilog-2001. */
stamptime_condition:
    mintypemax_expression 
;

/* checktime_condition (optional) is condition for enabling or disabling */
/* negative timing checks. This argument was added in Verilog-2001. */
checktime_condition:
    mintypemax_expression 
;

/* delayed_ref (optional) is delayed signal for negative timing checks. */
/* This argument was added in Verilog-2001. */
delayed_ref: 
    identifier 
|   identifier mintypemax_expression 
;

/* delayed_data (optional) is delayed signal for negative timing checks. */
/* This argument was added in Verilog-2001. */
delayed_data:
    identifier 
|   identifier mintypemax_expression 
;

/* event_based_flag (optional) when set, causes the timing check to be event */
/* based instead of timer based. This argument was added in Verilog-2001. */
events_based_flag:
    expression 
;

/* remain_active_flag (optional) wen set, causes the timing check to not */
/* become inactive after the first violation is reported. This argument was */
/* added in Verilog-2001. */
remain_active_flag:
    mintypemax_expression 
;

/* start_edge_offset is delay value (either positive or negative) which /* 
/* expand or reduce the time in which no change can occur. */
start_edge_offset:
    mintypemax_expression 
;

/* end_edge_offset is delay value (either positive or negative) */ 
/* which expand or reduce the time in which no change can occur. */
end_edge_offset:
    mintypemax_expression 
;

/* The largest pulse width that is ignored by the timing check $width */
width_threshold:
    expression 
;

/*                TODO                  */
/* This maybe is included to expression */
mintypemax_expression:
    expression 
|   expression COLON expression COLON expression 
;

/*           Udp declaration             */
/*****************************************/
/* There are 2 types of udp declarations */
/*****************************************/
/* 1st type: (added in Verilog 2001) */
/*    primitive primitive_name */
/*    ( output reg = logic_value terminal_declaration, */
/*     input terminal_declarations ); */
/*      table */
/*          table_entry; */
/*          table_entry; */
/*      endtable */
/*    endprimitive */
/* 2nd type: (old style port list) */
/*    primitive primitive_name (output, input, input, ... ); */
/*      output terminal_declaration; */
/*      input terminal_declarations; */
/*      reg output_terminal; */
/*      initial output_terminal = logic_value; */
/*      table */
/*          table_entry; */
/*          table_entry; */
/*      endtable */
/*    endprimitive */
/*****************************************/
/* Only one output is allowed, which must be the first terminal. */
/* The maximum number of inputs is at least 9 inputs for a sequential */
/* UDP and 10 inputs for a combinational UDP. */

udp_declaration: 
    /* 1st type: (added in Verilog 2001) */
    PRIMITIVE identifier OPENPARENTHESES udp_port_list CLOSEPARENTHESES 
    SEMICOLON udp_port_declaration_body udp_body ENDPRIMITIVE
    { 
        #ifdef SYNTAX_DEBUG
            printf("udp_declaration\n");
        #endif
    }
    /* 2nd type: (old style port list) */
|   PRIMITIVE identifier OPENPARENTHESES udp_declaration_port_list 
    CLOSEPARENTHESES SEMICOLON udp_body ENDPRIMITIVE
    { 
        #ifdef SYNTAX_DEBUG
            printf("udp_declaration\n");
        #endif
    }
;

/* output_port_identifier, input_port_identifier {,input_port_identifier } */
udp_port_list:
    nonempty_identifier_list
    { }
;

udp_port_declaration_body:
    udp_port_declaration
    { }
|   udp_port_declaration_body udp_port_declaration
    { }
;

udp_port_declaration:
    udp_output_declaration SEMICOLON
    { }
|   udp_input_declaration SEMICOLON
    { }
|   udp_reg_declaration SEMICOLON
    { }
;

udp_output_declaration:
    OUTPUT identifier
    { 
        #ifdef SYNTAX_DEBUG
            printf("output identifier ");
        #endif
    }
|   OUTPUT REG identifier
    {
        #ifdef SYNTAX_DEBUG
            printf("output reg identifier ");
        #endif
    }
|   OUTPUT REG identifier EQUALS_SIGN expression
    { 
        #ifdef SYNTAX_DEBUG
            printf("output reg identifier equal expression ");
        #endif
    }
;

udp_input_declaration:
    INPUT nonempty_identifier_list
    { }
;

udp_input_single_declaration:
    INPUT identifier
    { 
        #ifdef SYNTAX_DEBUG
            printf("input identifier ");
        #endif
    }
;

udp_reg_declaration:
    REG identifier
    { 
        #ifdef SYNTAX_DEBUG
            printf("reg identifier ");
        #endif
    }
;

udp_declaration_port_list:
    udp_output_declaration COMMA udp_input_declaration_list
    { }
;

udp_input_declaration_list:
    COMMA identifier
    { 
        #ifdef SYNTAX_DEBUG
            printf("comma identifier ");
        #endif
    }
|   udp_input_single_declaration
    { }
|   udp_input_declaration_list COMMA udp_input_single_declaration
    {
    }
|   udp_input_declaration_list COMMA identifier
    { 
        #ifdef SYNTAX_DEBUG
            printf("comma identifier ");
        #endif
    }
;

udp_body:
    combinational_body
    { }
|   sequential_body
    { }
;

combinational_body:
    TABLE combinational_entry_list ENDTABLE
    { }
;

sequential_body:
    udp_initial_statement TABLE sequential_entry_list ENDTABLE
    { }
|   TABLE sequential_entry_list ENDTABLE
    { }
;

combinational_entry_list:
    combinational_entry
    { }
|   combinational_entry_list combinational_entry
    { }
;

sequential_entry_list:
    sequential_entry
    { }
|   sequential_entry_list sequential_entry
    { }
;

combinational_entry:
    level_input_list COLON output_symbol SEMICOLON
    { }
;

sequential_entry:
    seq_input_list COLON current_state COLON next_state SEMICOLON
    { }
;

seq_input_list:
    level_input_list
    { }
|   edge_input_list
    { } 
; 

level_input_list:
    level_symbol
    { }
|   level_input_list level_symbol
    { }
;

edge_input_list:
    level_input_list edge_indicator level_input_list
    { }
|   level_input_list edge_indicator
    { }
|   edge_indicator level_input_list
    { }
;

edge_indicator:
    OPENPARENTHESES spesial_symbols CLOSEPARENTHESES
    { }
|   edge_symbol
    { }
;

current_state:
    level_symbol
;

next_state:
    output_symbol
|   MINUS
;

output_symbol:
    ZERO
|   ONE
|   X_LOW
|   X_UPPER
;

level_symbol:
    ZERO
|   ONE
|   X_LOW
|   X_UPPER
|   QUESTION_MARK
|   B_LOW
|   B_UPPER
;

edge_symbol:
    R_LOW
|   R_UPPER
|   F_LOW
|   F_UPPER
|   P_LOW
|   P_UPPER
|   N_LOW
|   N_UPPER
|   ASTERISK
;

spesial_symbols:
    ZERO_ONE
|   ONE_ZERO
|   ZERO_X_UPPER
|   ONE_X_UPPER
|   X_ZERO_UPPER
|   X_ONE_UPPER
;

/* initial = output_port_identifier = init_val; */
udp_initial_statement:
    INITIAL_TOKEN identifier EQUALS_SIGN init_val 
;

init_val:
    ONE_BIN_ZERO_LOW
|   ONE_BIN_ONE_LOW
|   ONE_BIN_ZERO_UPPER
|   ONE_BIN_ONE_UPPER
|   ONE_BIN_X_LOW_LOW
|   ONE_BIN_X_LOW_UPPER 
|   ONE_BIN_X_UPPER_LOW
|   ONE_BIN_X_UPPER_UPPER
|   ONE
|   ZERO
;

integer_or_real: 
    num_integer 
|   REALV       
;

number: 
    UNSIG_BIN          
|   UNSIG_OCT          
|   UNSIG_DEC          
|   UNSIG_HEX          
|   SIG_BIN            
|   SIG_OCT            
|   SIG_DEC            
|   SIG_HEX            
|   REALV              
|   scalar_constant    
|   NUM_INTEGER        
|   ZERO_ONE           
|   ONE_ZERO           
|   ONE_BIN_X_LOW_LOW
|   ONE_BIN_X_LOW_UPPER
|   ONE_BIN_X_UPPER_LOW
|   ONE_BIN_X_UPPER_UPPER
;

num_integer:
    NUM_INTEGER 
|   ONE 
|   ZERO 
|   ZERO_ONE 
|   ONE_ZERO 
;

/* Common System Tasks and Functions */
system_task:
    system_task_identifier OPENPARENTHESES TEXT COMMA
    list_of_arguments CLOSEPARENTHESES SEMICOLON
    {
        #ifdef SYNTAX_DEBUG
            printf("system_task ");
        #endif
    }
|   system_task_identifier OPENPARENTHESES TEXT CLOSEPARENTHESES SEMICOLON
    {
        #ifdef SYNTAX_DEBUG
            printf("system_task ");
        #endif
    }

;

list_of_arguments:
    identifier { }
|   list_of_arguments COMMA identifier { }
;

system_task_identifier:
    F_DISPLAY 
|   F_DISPLAYB 
|   F_DISPLAYO 
|   F_DISPLAYH 
|   F_WRITE 
|   F_WRITEB 
|   F_WRITEO   
|   F_WRITEH 
|   F_STROBE 
|   F_STROBEB 
|   F_STROBEO 
|   F_STROBEH 
|   F_MONITOR 
|   F_MONITORB 
|   F_MONITORO 
|   F_MONITORH 
;

system_identifier:
    system_task_identifier    
|   F_FOPEN 
|   F_FCLOSE 
|   F_FMONITOR 
|   F_FDISPLAY 
|   F_FWRITE 
|   F_FSTROBE 
|   F_FGETC 
|   F_UNGETC 
|   F_FGETS 
|   F_FSCANF 
|   F_FREAD 
|   F_FTELL 
|   F_FSEEK 
|   F_REWIND 
|   F_FERROR 
|   F_FFLUSH 
|   F_FINISH 
|   F_STOP 
|   F_TIME 
|   F_STIME 
|   F_REALTIME  
|   F_TIMEFORMAT 
|   F_PRINTTIMESCALE 
|   F_SIGNED
|   F_UNSIGNED
|   F_SWRITE 
|   F_SWRITEB 
|   F_SWRITEO 
|   F_SWRITED 
|   F_SFORMAT 
|   F_SSCANF 
|   F_READMEMB 
|   F_READMEMH 
|   F_REALTOBITS 
|   F_BITSTOREAL 
|   F_TEST_PLUSARGS 
|   F_VALUE_PLUSARGS
;

identifier:
    IDENTIFIER
|   X_LOW
|   X_UPPER
|   B_LOW
|   B_UPPER
|   R_LOW
|   R_UPPER
|   F_LOW
|   F_UPPER
|   P_LOW
|   P_UPPER
|   N_LOW
|   N_UPPER
;

%%

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
        yyerror(" 'a & &b' and 'a | |b' is invalid Verilog syntax");
        exit(EXIT_FAILURE);
    }
}
