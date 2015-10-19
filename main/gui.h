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

ParserGUI parser;
GList *opened_files;
/* File descriptors for pipe. */
int fds[2];

/* Initialize gtk. Parse and save objects from UI description */
void init(int argc, char **argv);
