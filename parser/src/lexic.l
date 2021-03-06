%{
#include "verilog_parser.tab.h"
#include <string.h>
#include <stdlib.h>

#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno;

/* Lexer function prototypes.
long int convert_str_to_bin(char *binary_string);
long int convert_str_to_oct(char *octal_string);
long int convert_str_to_dec(char *decimal_string);
long int convert_str_to_hex(char *hexadecimal_string);
*/
%}

%option yylineno

%{
/* Exlusive start conditions used to match comments. Patterns aren't recognised
inside them. */
%}
%x multi_line_comment
%x single_line_comment
%x text_with_format

%%

    /* Match Verilog 2001 keywords. */
"-incdir"             { return INCDIR; }
"always"              { return ALWAYS; }
"and"                 { return AND; }
"assign"              { return ASSIGN; }
"automatic"           { return AUTOMATIC; }
"begin"               { return BEGIN_TOKEN; }
"buf"                 { return BUF; }
"bufif0"              { return BUFIF0; }
"bufif1"              { return BUFIF1; }
"case"                { return CASE; }
"casex"               { return CASEX; }
"casez"               { return CASEZ; }
"cell"                { return CELL; }
"cmos"                { return CMOS; }
"config"              { return CONFIG; }
"deassign"            { return DEASSIGN; }
"default"             { return DEFAULT; }
"defparam"            { return DEFPARAM; }
"design"              { return DESIGN; }
"disable"             { return DISABLE; }
"edge"                { return EDGE; }
"else"                { return ELSE; }
"end"                 { return END; }
"endcase"             { return ENDCASE; }
"endconfig"           { return ENDCONFIG; }
"endfunction"         { return ENDFUNCTION; }
"endgenerate"         { return ENDGENERATE; }
"endmodule"           { return ENDMODULE; }
"endprimitive"        { return ENDPRIMITIVE; }
"endspecify"          { return ENDSPECIFY; }
"endtable"            { return ENDTABLE; }
"endtask"             { return ENDTASK; }
"event"               { return EVENT; }
"for"                 { return FOR; }
"force"               { return FORCE; }
"forever"             { return FOREVER; }
"fork"                { return FORK; }
"function"            { return FUNCTION; }
"generate"            { return GENERATE; }
"genvar"              { return GENVAR; }
"highz0"              { printf("HIGHZ0\n"); }
"highz1"              { printf("HIGHZ1\n"); }
"if"                  { return IF; }
"ifnone"              { return IFNONE; }
"include"             { return INCLUDE; }
"initial"             { return INITIAL_TOKEN; }
"instance"            { return INSTANCE; }
"inout"               { return INOUT; }
"input"               { return INPUT; }
"integer"             { return INTEGER; }
"join"                { return JOIN; }
"large"               { return LARGE; }
"liblist"             { return LIBLIST; }
"library"             { return LIBRARY; }
"localparam"          { return LOCALPARAM; }
"macromodule"         { return MACROMODULE; }
"medium"              { return MEDIUM;}
"module"              { return MODULE; }
"nand"                { return NAND; }
"negedge"             { return NEGEDGE; }
"nmos"                { return NMOS; }
"nor"                 { return NOR; }
"not"                 { return NOT; }
"noshowcancelled"     { return NOSHOWCANCELLED; } 
"notif0"              { return NOTIF0; }
"notif1"              { return NOTIF1; }
"or"                  { return OR; }
"output"              { return OUTPUT; }
"parameter"           { return PARAMETER;}
"pmos"                { return PMOS; }
"posedge"             { return POSEDGE; }
"primitive"           { return PRIMITIVE; }
"pull0"               { return PULL0; }
"pull1"               { return PULL1; }
"pulldown"            { return PULLDOWN; }
"pullup"              { return PULLUP; }
"pulsestyle_onevent"  { return PULSESTYLE_ONEVENT; }
"pulsestyle_ondetect" { return PULSESTYLE_ONDETECT; }
"rcmos"               { return RCMOS; }
"real"                { return REAL; }
"realtime"            { return REALTIME; }
"reg"                 { return REG; }
"release"             { return RELEASE; }
"repeat"              { return REPEAT; }
"rnmos"               { return RNMOS; }
"rpmos"               { return RPMOS; }
"rtran"               { return RTRAN; }
"rtranif0"            { return RTRANIF0; }
"rtranif1"            { return RTRANIF1; }
"scalared"            { return SCALARED; }
"signed"              { return SIGNED; }
"showcancelled"       { return SHOWCANCELLED; }
"small"               { return SMALL; }
"specify"             { return SPECIFY; }
"specparam"           { return SPECPARAM; }
"strength"            { printf("STRENGTH\n"); }
"strong0"             { return STRONG0; }
"strong1"             { return STRONG1; }
"supply0"             { return SUPPLY0; }
"supply1"             { return SUPPLY1; }
"table"               { return TABLE; }
"task"                { return TASK; }
"time"                { return TIME;}
"tran"                { return TRAN; }
"tranif0"             { return TRANIF0; }
"tranif1"             { return TRANIF1; }
"tri"                 { return TRI; }
"tri0"                { return TRI0; }
"tri1"                { return TRI1; }
"triand"              { return TRIAND; }
"trior"               { return TRIOR; }
"trireg"              { return TRIREG; }
"unsigned"            { printf("UNSIGNED\n"); }
"use"                 { return USE; }
"vectored"            { return VECTORED; }
"wait"                { return WAIT; }
"wand"                { return WAND; }
"weak0"               { return WEAK0; }
"weak1"               { return WEAK1; }
"while"               { return WHILE; }
"wire"                { return WIRE; }
"wor"                 { return WOR; }
"xnor"                { return XNOR; }
"xor"                 { return XOR; }

"PATHPULSE$"[a-zA-Z0-9_$]* { return PATHPULSE; }

    /* Match Verilog 2001 system function keywords. */
"$setup"              { return SETUP; }
"$hold"               { return HOLD; }
"$setuphold"          { return SETUPHOLD; }
"$recovery"           { return RECOVERY; }
"$removal"            { return REMOVAL; }
"$recrem"             { return RECREM; }
"$skew"               { return SKEW; }
"$timeskew"           { return TIMESKEW; }
"$fullskew"           { return FULLSKEW; }
"$period"             { return D_PERIOD; }
"$width"              { return WIDTH; }
"$nochange"           { return NOCHANGE; }

    /* Text Output System Tasks */
"$display"            { return F_DISPLAY;  }
"$displayb"           { return F_DISPLAYB; }
"$displayo"           { return F_DISPLAYO; }
"$displayh"           { return F_DISPLAYH; }
                                       
"$write"              { return F_WRITE;    }
"$writeb"             { return F_WRITEB;   }
"$writeo"             { return F_WRITEO;   }
"$writeh"             { return F_WRITEH;   }
                                       
"$strobe"             { return F_STROBE;   }
"$strobeb"            { return F_STROBEB;  }
"$strobeo"            { return F_STROBEO;  }
"$strobeh"            { return F_STROBEH;  }
                                       
"$monitor"            { return F_MONITOR;  }
"$monitorb"           { return F_MONITORB; }
"$monitoro"           { return F_MONITORO; }
"$monitorh"           { return F_MONITORH; }

    /* File I/O System Tasks and Functions */
"$fopen"              { return F_FOPEN;    }
"$fclose"             { return F_FCLOSE;   }
"$fmonitor"           { return F_FMONITOR; }
"$fdisplay"           { return F_FDISPLAY; }
"$fwrite"             { return F_FWRITE;   }
"$fstrobe"            { return F_FSTROBE;  }
"$fgetc"              { return F_FGETC;    }
"$ungetc"             { return F_UNGETC;   }
"$fgets"              { return F_FGETS;    }
"$fscanf"             { return F_FSCANF;   }
"$fread"              { return F_FREAD;    }
"$ftell"              { return F_FTELL;    }
"$fseek"              { return F_FSEEK;    }
"$rewind"             { return F_REWIND;   }
"$ferror"             { return F_FERROR;   }
"$fflush"             { return F_FFLUSH;   }

    /* Other Common System Tasks and Functions */
"$finish"             { return F_FINISH;         }
"$stop"               { return F_STOP;           }
"$time"               { return F_TIME;           }
"$stime"              { return F_STIME;          }
"$realtime"           { return F_REALTIME;       }
"$timeformat"         { return F_TIMEFORMAT;     }
"$printtimescale"     { return F_PRINTTIMESCALE; }
"$signed"             { return F_SIGNED;         }
"$unsigned"           { return F_UNSIGNED;       }
"$swrite"             { return F_SWRITE;         }
"$swriteb"            { return F_SWRITEB;        }
"$swriteo"            { return F_SWRITEO;        }
"$swrited"            { return F_SWRITED;        }
"$sformat"            { return F_SFORMAT;        }
"$sscanf"             { return F_SSCANF;         }
"$readmemb"           { return F_READMEMB;       }
"$readmemh"           { return F_READMEMH;       }
"$realtobits"         { return F_REALTOBITS;     }
"$bitstoreal"         { return F_BITSTOREAL;     }
"$test$plusargs"      { return F_TEST_PLUSARGS;  }
"$value$plusargs"     { return F_VALUE_PLUSARGS; }

    /* Open types. */
"\"r\""               { return OPEN_READ;                        }
"\"rb"\"              { return OPEN_READ;                        }
"\"w"\"               { return TRUNCATE_CREATE_FOR_WRITE;        }
"\"wb"\"              { return TRUNCATE_CREATE_FOR_WRITE;        }
"\"a"\"               { return OPEN_APPEND;                      }
"\"ab"\"              { return OPEN_APPEND;                      }
"\"r+"\"              { return OPEN_UPDATE;                      }
"\"r+b"\"             { return OPEN_UPDATE;                      }
"\"rb+"\"             { return OPEN_UPDATE;                      }
"\"w+"\"              { return TRUNCATE_CREATE_FOR_UPDATE;       }
"\"w+b"\"             { return TRUNCATE_CREATE_FOR_UPDATE;       }
"\"wb+"\"             { return TRUNCATE_CREATE_FOR_UPDATE;       }
"\"a+"\"              { return OPEN_APPEND_OR_CREATE_FOR_UPDATE; }
"\"a+b"\"             { return OPEN_APPEND_OR_CREATE_FOR_UPDATE; }
"\"ab+"\"             { return OPEN_APPEND_OR_CREATE_FOR_UPDATE; }

    /* Verilog compiler directives. */
"`resetall"           { return COMPILER_RESETALL;             }
"`timescale"          { return COMPILER_TIMESCALE;            }
"`define"             { return COMPILER_DEFINE;               }
"`undef"              { return COMPILER_UNDEF;                }
"`ifdef"              { return COMPILER_IFDEF;                }
"`ifndef"             { return COMPILER_IFNDEF;               }
"`else"               { return COMPILER_ELSE;                 }
"`elsif"              { return COMPILER_ELSEIF;               }
"`endif"              { return COMPILER_ENDIF;                }
"`include"            { return COMPILER_INCLUDE;              }
"`celldefine"         { return COMPILER_CELLDEFINE;           }
"`endcelldefine"      { return COMPILER_ENDCELLDEFINE;        }
"`default_nettype"    { return COMPILER_DEFAULT_NETTYPE;      }
"`unconnected_drive"  { return COMPILER_UNCONNECTED_DRIVE;    }
"`nounconnected_drive" { return COMPILER_NOUNCONNECTED_DRIVE; }
"`uselib"             { return COMPILER_USELIB;               }

<INITIAL>
{
[/][*]              { BEGIN(multi_line_comment); }
["]                 { BEGIN(text_with_format); }
}

    /* Match Verilog 2001 comments. Tokens are not returned for comments (so
that comments are invisible to the parser). */
<multi_line_comment>
{
[*][/]              { BEGIN(INITIAL); }
[^*]+               // eat comment in chunks
[*]
}
    /* Match text */
<text_with_format>
{ 
["]                 { BEGIN(INITIAL); return TEXT;}
[^"\\]+
"\\""t"
"\\""n"
"\\"["]
"\\""\\"
} 

[/][/].*[\n]

    /* Match Verilog 2001 symbols. */
"@"                   { return AT; }
"("                   { return OPENPARENTHESES; }
")"                   { return CLOSEPARENTHESES; }
"["                   { return OPENBRACKETS; }
"]"                   { return CLOSEBRACKETS; }
"{"                   { return OPENBRACES; }
"}"                   { return CLOSEBRACES; }
","                   { return COMMA; }
";"                   { return SEMICOLON; }
"#"                   { return HASH; }
"&"                   { return AND_OPERATOR; }
"~""&"                { return NAND_OPERATOR; }
"&"{2}                { return LOGICAL_AND; }
"|"                   { return OR_OPERATOR; }
"~""|"                { return NOR_OPERATOR; }
"|"{2}                { return LOGICAL_OR; }
"^"                   { return XOR_OPERATOR; }
"~""^"                { return XNOR_OPERATOR; }
"^""~"                { return XNOR_OPERATOR; }
"+"                   { return PLUS; }
"-"                   { return MINUS; }
"*"                   { return ASTERISK; }
"*"{2}                { return POWER; }
"/"                   { return SLASH; }
"%"                   { return MODULO; }
"="                   { return EQUALS_SIGN; }
"="{2}                { return EQUAL; }
"!""="                { return NOT_EQUAL; }
"="{3}                { return IDENTICAL; }
"!""=""="             { return NOT_IDENTICAL; }
"<"                   { return LESSTHAN; }
"<""="                { return LESSTHANOREQUAL; }
">"                   { return GREATERTHAN; }
">""="                { return GREATERTHANOREQUAL; }
":"                   { return COLON; }
"?"                   { return QUESTION_MARK; }
"~"                   { return TILDE; }
"!"                   { return EXCLAMATION_MARK; }
"."                   { return PERIOD; }
"<"{2}                { return BITWISE_LEFT_SHIFT; }
">"{2}                { return BITWISE_RIGHT_SHIFT; }
"<"{3}                { return ARITHMETIC_LEFT_SHIFT; }
">"{3}                { return ARITHMETIC_RIGHT_SHIFT; }
"-"">"                { return TRIGGER_EVENT_OPERATOR; }
"&"{3}                { return THREE_AND; }


"1"           { return ONE; }
"0"           { return ZERO; }
"01"          { return ZERO_ONE; }
"10"          { return ONE_ZERO; }
"1'b0"        { return ONE_BIN_ZERO_LOW; }
"1'b1"        { return ONE_BIN_ONE_LOW; }
"1'B0"        { return ONE_BIN_ZERO_UPPER; }
"1'B1"        { return ONE_BIN_ONE_UPPER; }
"'b0"         { return BIN_ZERO_LOW; }
"'b1"         { return BIN_ONE_LOW; }
"'B0"         { return BIN_ZERO_UPPER; }
"'B1"         { return BIN_ONE_UPPER; }

"1'bx"        { return ONE_BIN_X_LOW_LOW; }
"1'bX"        { return ONE_BIN_X_LOW_UPPER; }
"1'Bx"        { return ONE_BIN_X_UPPER_LOW; }
"1'BX"        { return ONE_BIN_X_UPPER_UPPER; }

"x"           { return X_LOW; }
"X"           { return X_UPPER; }
"b"           { return B_LOW; }
"B"           { return B_UPPER; }
"r"           { return R_LOW; }
"R"           { return R_UPPER; }
"f"           { return F_LOW; }
"F"           { return F_UPPER; }
"p"           { return P_LOW; }
"P"           { return P_UPPER; }
"n"           { return N_LOW; }
"N"           { return N_UPPER; }

"X0"          { return X_ZERO_UPPER; } 
"X1"          { return X_ONE_UPPER; }
"x0"          { return X_ZERO_LOW; }
"x1"          { return X_ONE_LOW; }
"Z0"          { return Z_ZERO_UPPER; }
"Z1"          { return Z_ONE_UPPER; }
"z0"          { return Z_ZERO_LOW; }
"z1"          { return Z_ONE_LOW; }
"0X"          { return ZERO_X_UPPER; }
"1X"          { return ONE_X_UPPER; }
"0x"          { return ZERO_X_LOW; }
"1x"          { return ONE_X_LOW; }
"0Z"          { return ZERO_Z_UPPER; }
"1Z"          { return ONE_Z_UPPER; }
"0z"          { return ZERO_Z_LOW; }
"1z"          { return ONE_Z_LOW; }

    /* Match Verilog 2001 identifiers. */
[a-zA-Z_][a-zA-Z0-9_$]*                            { yylval.name = strdup(yytext);
                                                     return IDENTIFIER; 
                                                   }

"\\"[^\n\t ]+                                      { yylval.name = strdup(yytext); 
                                                    return IDENTIFIER; }
 
    /* Match Verilog 2001 real numbers. */
[0-9]+[.][0-9][0-9_]*                              { return REALV; }
[0-9]+[.][0-9][0-9_]*[eE]-?[0-9]+                  { return REALV; }
[0-9]+[0-9_]*[eE]-?[0-9]+                          { return REALV; }

    /* Match Verilog 2001 integers. Note that INTEGER is a keyword token. */
[0-9]+                                             { return NUM_INTEGER; }

    /* Match Verilog 2001 unsigned numbers. */
[0-9]*['][bB][01xXzZ?][01xXzZ?_]*                  { return UNSIG_BIN; }
[0-9]*['][oO][0-7xXzZ?][0-7xXzZ?_]*                { return UNSIG_OCT; }
[0-9]*['][dD][0-9][0-9_]*                          { return UNSIG_DEC; }
[0-9]*['][hH][0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]*    { return UNSIG_HEX; }

    /* Match Verilog 2001 signed numbers. */
[0-9]*['][sS][bB][01xXzZ?][01xXzZ?_]*               { return SIG_BIN; }
[0-9]*['][sS][oO][0-7xXzZ?][0-7xXzZ?_]*             { return SIG_OCT; }
[0-9]*['][sS][dD][0-9][0-9_]*                       { return SIG_DEC; }
[0-9]*['][sS][hH][0-9a-fA-FxXzZ?][0-9a-fA-FxXzZ?_]* { return SIG_HEX; }

    /* Match newlines, carriage returns, spaces and tabs. */
[\n\r]+               { }
[ ]                   { }
[\t]                  { }

    /* Any single character that doesn't match the above rules. */
.                     { printf("UNIDENTIFIED : %c\n",yytext[0]); }

%%


//long int convert_str_to_bin(char *binary_string) {
//	long int result;
//	char *number_start;
//	
//	/* Remove binary prefix XX'b or XX'B from number. */
//	strtok(binary_string, "'");
//	number_start = strtok(NULL, "'");
//	number_start++;
//	
//	/* Convert to base 2. */
//	result = strtol(number_start, NULL, 2);
//	
//	return(result);
//}
//
//long int convert_str_to_oct(char *octal_string) {
//	long int result;
//	char *number_start;
//	
//	/* Remove octal prefix XX'o or XX'O from number. */
//	strtok(octal_string, "'");
//	number_start = strtok(NULL, "'");
//	number_start++;
//	
//	/* Convert to base 8. */
//	result = strtol(number_start, NULL, 8);
//	
//	return(result);
//}
//
//long int convert_str_to_dec(char *decimal_string) {
//	long int result;
//	char *number_start;
//	
//	/* Remove decimal prefix XX'd or XX'D from number. */
//	strtok(decimal_string, "'");
//	number_start = strtok(NULL, "'");
//	number_start++;
//	
//	/* Convert to base 10. */
//	result = strtol(number_start, NULL, 10);
//	
//	return(result);
//}
//
//long int convert_str_to_hex(char *hexadecimal_string) {
//	long int result;
//	char *number_start;
//	
//	/* Remove hexadecimal prefix XX'o or XX'O from number. */
//	strtok(hexadecimal_string, "'");
//	number_start = strtok(NULL, "'");
//	number_start++;
//	
//	/* Convert to base 16. */
//	result = strtol(number_start, NULL, 16);
//	
//	return(result);
//}
