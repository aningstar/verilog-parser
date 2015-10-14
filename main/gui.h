typedef struct gtk_parser ParserGUI;

struct gtk_parser {
    GtkBuilder *builder;
    GObject *window;
    GObject *parse_file_button;
    GObject *open_file_button;
    GObject *parser_output_label;
};

ParserGUI parser;
gchar *filename;
/* File descriptors for pipe. */
int fds[2];

/* Initialize gtk. Parse and save objects from UI description */
void init(int argc, char **argv);
