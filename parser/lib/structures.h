// HASHDEPTH number of hash collisions //
// TODO
//#define HASHDEPTH 18
#define HASHDEPTH 50
// colors for output
#define KGRN  "\x1B[32m"
#define KBLU  "\x1B[34m"
#define KRED  "\x1B[31m"
#define RESET "\033[0m"

#define PRINT_TABLES

typedef enum {N, S, E, W, FN, FS, FE, FW} orientation;
typedef unsigned char  string; // shorthand for unsigned char  //
typedef unsigned long hash; // hash type //
// Placement/Placeable Modules //
typedef struct plmodule Plmodule; // Verilog module //
// list with the module cells that contains each module
typedef struct mcell Mcell;

/* Function prototypes. */
Mcell *addMcell(Mcell *head, int module_key);
int check_for_module(char name[]);
void add_module(char name[]);
void print_modules(void);
void reset_reduction_flags(int *reduction_and_flag, int *reduction_or_flag);
void turn_reduction_flag_on(int *reduction_flag);
void check_reduction_flag(int reduction_flag);
//void yyerror(char *error_string);

/* Flags used to determine if the last expression created was a reduction_and */
/* or a reduction_or (value 1) or not (value 0). */
int reduction_and_flag, reduction_or_flag;

// componenthash - from DEF or VERILOG file //
struct componenthash
{
    // HASHDEPTH number of hash collisions //
    //
    string hashes[HASHDEPTH]; // hash strings //

    int hashpresent[HASHDEPTH]; // hash present //
    // component data //
    double x[HASHDEPTH]; // x coordinate
    double y[HASHDEPTH]; // y coordinate
    // component orientation //
    //orientation o[HASHDEPTH]; // orientation
    // library cell data //
    hash libhash[HASHDEPTH]; // library cell hash
    int libhashdepth[HASHDEPTH]; // library cell hash depth
};

//gatepinhash - from SDF or STA or DEF or VERILOG //
struct gatepinhash
{
    // HASHDEPTH number of hash collisions //
    string hashes[HASHDEPTH]; // hash strings //
    int hashpresent[HASHDEPTH]; // hash present //
    // the use of the gatepincons and net sections is mutually exclusive //
    // gatepin data //
    hash *gatepincons[HASHDEPTH]; // connection hashes - zero terminated //
    int *gatepinconsdepth[HASHDEPTH]; // connection hashes depths //
    double *gatepinconsdelay[HASHDEPTH]; // delay per connection //
    double *gatepinpathdelay[HASHDEPTH]; // delay per path //
    unsigned long gatepinconsnum[HASHDEPTH]; // number of total connection //
                                             // hashes - for fast insertion //
    // special net data //
    hash specialnet[HASHDEPTH]; // special net hash reference - zero if none //
    int specialnetdepth[HASHDEPTH]; // special net hash depth //
    // NOTE: NET is used in NET mode - gatepin data and special net in non NET
    // mode //
    //
    // net, i.e. hierarchical wire, data; stores gatepin connections to other
    // gatepins //
    hash net[HASHDEPTH]; // net hash reference - zero if none //
    int netdepth[HASHDEPTH]; // net hash depth //
};

struct plmodule
{
    char hashes[HASHDEPTH]; // hash strings - module name //
    int hashpresent[HASHDEPTH]; // hash present //
    string globalhierarchyname[HASHDEPTH]; // global hierarchical name for this
                                           // module //
    // all gatepins and components are prefixed by the global hierarchy name //
    // module cell groups //
    //Plcellgroup *cellgroups[HASHDEPTH]; // array of cell groups contained in
                                          // this module - NULL terminated on
                                          // groupname //
    // module coordinates //
    double x[HASHDEPTH], y[HASHDEPTH];
    double w[HASHDEPTH], h[HASHDEPTH]; // BB of floorplan rectangle //
    // module total standard-cell area (um^2) //
    double area[HASHDEPTH];
    // module flat cell (not in modules) standard-cell area (um^2) //
    double cellarea[HASHDEPTH];
    // module utilisation ratio (floating point) //
    double utilisation[HASHDEPTH];
    // floorplan module flag - default = 1 //
    char floorplanmodule[HASHDEPTH];
    // module ports pin data - correspond to relative module port //
    double *moduleportspinx[HASHDEPTH]; // pin x value //
    double *moduleportspiny[HASHDEPTH]; // pin y value //
    int *moduleportsside[HASHDEPTH]; // port side: WESTSIDE, SOUTHSIDE,
                                     // EASTSIDE, NORTHSIDE //
};

struct mcell {
    int module_key;
    struct mcell *next;
};

// Pointer to the modules hash table
Plmodule **modules;
// Pointer to the hash table that contains the lists of cells for each module
// Each entry is a list with keys for the modules hash table
Mcell **cells;
// Pointer to the head of the list that contains the cells for the current
// module
Mcell *current_head;
// Pointer to the instaces hash table
char **instances;
// the number of stored modules to the modules hash table
int number_of_modules;
// the number of stored instance to the instances hash table
int number_of_instances;
// variable used for function's returned values
int returned_value;
