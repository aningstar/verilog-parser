#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "structures.h"

/* Function: void add_module(char name[]) */
/* Arguments: string with the name of module  */
/* Returns: - */
/* Description: Allocates space for a Module struct in the */
/*     modules hash table, and saves the name of the module to */
/*     the hashes member of the Module struct */
void add_module(char name[]) {
    // checks if modules hash table is empty
    if (modules == NULL) {
        // allocates space for one Module struct
        modules = (Module**) malloc(sizeof(Module*));
        modules[0] = (Module*) malloc(sizeof(Module));
        // allocates space for cell list for this module
        cells = (Instance**) malloc(sizeof(Instance*));
        cells[0] = NULL;
        // increases the number of stored modules
        number_of_modules = 1;
    // reallocates space at the modules hash table for another Module struct
    }else {
        modules = (Module**)
                  realloc(modules, (number_of_modules + 1)*sizeof(Module));
        modules[number_of_modules] = (Module*) malloc(sizeof(Module));

        // allocates space for cell list for this module
        cells = (Instance**) realloc(cells,
                  (number_of_modules + 1)*sizeof(Instance*));
        cells[number_of_modules] = NULL;
        // increases the number of stored modules
        number_of_modules = number_of_modules + 1;
    }

    // copies the name of the module at the hashes member
    // of the Module struct
    strcpy(modules[number_of_modules - 1]->name, name);
}

/* Function: void print_modules(void) */
/* Arguments: -  */
/* Returns: - */
/* Description: Prints the modules and for each module the list */
/*        the list of the submodules */
void print_modules(void) {
    int i;
    Instance *curr = NULL;
    //print the modules names from the modules table
    for (i = 0; i < number_of_modules; i++) {
        printf("<%s : { ", modules[i]->name);
        // print the list of submodules for the current module
        for(curr = cells[i]; curr != NULL; curr = curr->next) {
            printf(" %s %s, ",modules[curr->module_key]->name,
                              curr->instance_name);
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
            cmp_value = strcmp(modules[i]->name,name);
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

/* Function: Instance *addInstance(Instance *head, int module_key) */
/* Arguments: the list's head of cells and the module_key */
/*      for the new cell */
/* Returns: the updated head of list */
/* Description: add to the list of cells a new cell */
Instance *addInstance(Instance *head, char instance_name[], int module_key) {
    // if list is empty
    if (head == NULL) {
        // add a new cell struct to list's head
        head = (Instance*)malloc(sizeof(Instance));
        head->module_key = module_key;
        head->next = NULL;
        strcpy(head->instance_name, instance_name);
    }else {
        // add a new cell struct at the beggining of the list
        Instance *cell = (Instance*)malloc(sizeof(Instance));
        cell->module_key = module_key;
        cell->next = head;
        head = cell;
        strcpy(head->instance_name, instance_name);
    }
    return head;
}

