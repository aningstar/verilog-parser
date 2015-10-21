#include "../parser/lib/structures.h"

typedef struct gtk_parser ParserGUI;

struct gtk_parser {
    GtkBuilder *builder;
    GObject *window;
    // tool buttons
    GObject *open_file_button;
    GObject *save_file_button;
    GObject *parse_file_button;
    GObject *close_file_button;
    // parser output
    GObject *parser_output;
    // tree
    GObject *treeview;
    GtkTreeStore *treestore;
    // code view
    GObject *notebook;
};

// Shared struct for the main process and the
// child process which will execute the parser
typedef struct shared Shared;

struct shared {
    int rdy;
};

ParserGUI parser;
GList *opened_files;
/* File descriptors for pipe. */
int fds[2];
// id of shared memory
int shmid;

/* Initialize gtk. Parse and save objects from UI description */
void init(int argc, char **argv);
/* Parser's Thread function. The thread checks the redirected */
/* standard ouput, for messages from parser and display them */
/* to textview */
void *display_parser_output();
/* Thread function that wait from parser
 * to end , and uses the tlp library to
 * deserialize the structures. After that it
 * paints the structures to the gtk tree. */
void *read_structures();
/* Uses the tlp library and serialize
 * the structures in binary format */
void store_structures();
/* Uses the tlp library and deserialize the binary file
 * with the structures from parsing */
void load_structures();
