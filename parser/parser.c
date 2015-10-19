#include <stdio.h>
#include "lib/verilog_parser.tab.h"
#include "lib/structures.h"

extern FILE *yyin;

int main (int argc, char **argv) {

    char *filename = argv[0];

    printf("\n*****\n");
    printf("Parsing %s", filename);
    printf("\n*****\n");
    fflush(stdout);
    fprintf(stderr, "%s\n", filename);
    // open given file
    yyin = fopen(filename, "r");
    // parse file
    yyparse();
    // close file
    fclose(yyin);
    printf("\n*****\n");
    printf("Parsing Complete");
    printf("\n*****\n");
    fflush(stdout);

    return 0;
}
