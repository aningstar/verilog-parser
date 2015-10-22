// HASHDEPTH number of hash collisions //
// TODO
//#define SIZE 18
#define SIZE 50
// colors for output
#define KGRN  "\x1B[32m"
#define KBLU  "\x1B[34m"
#define KRED  "\x1B[31m"
#define RESET "\033[0m"

#define PRINT_TABLES

typedef struct module Module; // Verilog module //
// list with the module cells that contains each module
typedef struct instance Instance;

/* Function prototypes. */
Instance *addInstance(Instance *head, char instance_name[], int module_key);
int check_for_module(char name[]);
void add_module(char name[]);
void print_modules(void);
/* Free allocated memory and initialize
 * global variables */
void free_memory();
void reset_reduction_flags(int *reduction_and_flag, int *reduction_or_flag);
void turn_reduction_flag_on(int *reduction_flag);
void check_reduction_flag(int reduction_flag);
//void yyerror(char *error_string);

/* Flags used to determine if the last expression created was a reduction_and */
/* or a reduction_or (value 1) or not (value 0). */
int reduction_and_flag, reduction_or_flag;

struct module {
    char name[SIZE]; // hash strings - module name //
};

struct instance {
    int module_key;
    char instance_name[SIZE];
    struct instance *next;
};

// Pointer to the modules hash table
Module **modules;
// Pointer to the hash table that contains the lists of cells for each module
// Each entry is a list with keys for the modules hash table
Instance **cells;
// Pointer to the head of the list that contains the cells for the current
// module
Instance *current_head;
// the number of stored modules to the modules hash table
int number_of_modules;
// variable used for function's returned values
int returned_value;
