#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "structures.h"

/* Function: void add_module(char name[]) */
/* Arguments: string with the name of module  */
/* Returns: - */
/* Description: Allocates space for a Plmodule struct in the */
/*     modules hash table, and saves the name of the module to */
/*     the hashes member of the Plmodule struct */
void add_module(char name[]) {
    // checks if modules hash table is empty
    if (modules == NULL) {
        // allocates space for one Plmodule struct
        modules = (Plmodule**) malloc(sizeof(Plmodule*));
        modules[0] = (Plmodule*) malloc(sizeof(Plmodule));
        // allocates space for cell list for this module
        cells = (Mcell**) malloc(sizeof(Mcell*));
        cells[0] = NULL;
        // increases the number of stored modules
        number_of_modules = 1;
    // reallocates space at the modules hash table for another Plmodule struct
    }else {
        modules = (Plmodule**)
                  realloc(modules, (number_of_modules + 1)*sizeof(Plmodule));
        modules[number_of_modules] = (Plmodule*) malloc(sizeof(Plmodule));

        // allocates space for cell list for this module
        cells = (Mcell**) realloc(cells,
                  (number_of_modules + 1)*sizeof(Mcell*));
        cells[number_of_modules] = NULL;
        // increases the number of stored modules
        number_of_modules = number_of_modules + 1;
    }

    // copies the name of the module at the hashes member
    // of the Plmodule struct
    strcpy(modules[number_of_modules - 1]->hashes, name);
}

/* Function: void print_modules(void) */
/* Arguments: -  */
/* Returns: - */
/* Description: Prints the modules and for each module the list */
/*        the list of the submodules */
void print_modules(void) {
    int i;
    Mcell *curr = NULL;
    //print the modules names from the modules table
    for (i = 0; i < number_of_modules; i++) {
        printf("<%s : { ", modules[i]->hashes);
        // print the list of submodules for the current module
        for(curr = cells[i]; curr != NULL; curr = curr->next) {
            printf(" %s, ",modules[curr->module_key]->hashes);
        }
        printf(" }>\n");
    }
    fflush(stdout);
}
/* Function: void check_for_module(char name[]) */
/* Arguments: string with the name of instance module */
/* Returns: 1 module exists, 0 module does not exist */
/* Description: Checks the instance module if exists to */
/*      the modules hash table. If does not exist the */
/*      main thread terminated with error message */
int check_for_module(char name[]) {
    int i = 0;
    int cmp_value = 1;
    if (modules != NULL) {
        // checks all stored modules
        for (i = 0; i < number_of_modules; i++) {
            // compares the current module with the instance module
            cmp_value = strcmp(modules[i]->hashes,name);
            // if module exists breaks the loop
            if (cmp_value == 0) {
                return i;
            }
        }
    }
    // if module does not exist, return 0
    if (cmp_value != 0) {
        return -1;
    }
    return -1;
}

/* Function: Mcell *addMcell(Mcell *head, int module_key) */
/* Arguments: the list's head of cells and the module_key */
/*      for the new cell */
/* Returns: the updated head of list */
/* Description: add to the list of cells a new cell */
Mcell *addMcell(Mcell *head, int module_key) {
    // if list is empty
    if (head == NULL) {
        // add a new cell struct to list's head
        head = (Mcell*)malloc(sizeof(Mcell));
        head->module_key = module_key;
        head->next = NULL;
    }else {
        // add a new cell struct at the beggining of the list
        Mcell *cell = (Mcell*)malloc(sizeof(Mcell));
        cell->module_key = module_key;
        cell->next = head;
        head = cell;
    }
    return head;
}

