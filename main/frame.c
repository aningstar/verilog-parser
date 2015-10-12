#include <stdio.h>
#include <gtk/gtk.h>
#include "frame.h"
#include "../parser/lib/verilog_parser.tab.h"

extern FILE *yyin;

static void destroy(GtkWidget *widget,gpointer data) {
    gtk_main_quit ();
}

static void parse_file(GObject *object) {

    yyin = fopen("grammar_examples/bit_selects_grammar.v", "r"); // open given file

    yyparse(); // parse file

    fclose(yyin); // close file

}

void run (int argc, char **argv) {
    GtkBuilder *builder;
    GObject *window;
    GObject *parse_file_button;

    gtk_init (&argc, &argv);

    /* Construct a GtkBuilder instance and load our UI description */
    builder = gtk_builder_new();
    gtk_builder_add_from_file(builder, "interface/build.xml", NULL);

    /* Connect signal handlers to the constructed widgets. */
    window = gtk_builder_get_object (builder, "window");
    g_signal_connect (window, "destroy",
                          G_CALLBACK (destroy), NULL);

    parse_file_button = gtk_builder_get_object (builder, "parse_file_button");

    g_signal_connect (parse_file_button, "clicked",
                          G_CALLBACK (parse_file), NULL);

    gtk_main();
}

