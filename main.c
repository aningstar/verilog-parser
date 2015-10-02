#include <stdio.h>
#include <stdlib.h>
#include "verilog_parser.tab.h"
#include "structures.h"

// read from file
extern FILE *yyin;

int main (int argc, char *argv[]) {

    yyin = fopen(argv[1], "r"); // open given file

    // DEBUG
    #ifdef SYNTAX_DEBUG
        printf(KGRN "SYNTAX DEBUG\n*\n"RESET);
    #endif

    yyparse(); // parse file

    // DEBUG
    #ifdef SYNTAX_DEBUG
        printf(KGRN "*\n"RESET);
    #endif

    #ifdef PRINT_TABLES
        print_modules();
    #endif

    fclose(yyin); // close file

    return 0;
}
