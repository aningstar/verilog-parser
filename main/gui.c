#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "gui.h"
#include "../parser/lib/verilog_parser.tab.h"
#include "../parser/lib/structures.h"

extern FILE *yyin;
/* Terminate program when window closed */
void destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit ();
}
/* Use verilog parser to parse the specified verilog file */
void parse_file(GObject *object) {
    // open given file
    yyin = fopen("grammar_examples/bit_selects_grammar.v", "r");
    // parse file
    yyparse();
    // close file
    fclose(yyin);
}
/* When open file button is pressed, the open_file function is called */
/* and user searchs and opens a file. The filename is saved. */
void open_file () {
    GtkWidget *chooser;
    // open a dialog and save the chosen file name
    chooser = gtk_file_chooser_dialog_new ("Open File",
                        GTK_WINDOW (parser.window),
                        GTK_FILE_CHOOSER_ACTION_OPEN,
                        NULL, GTK_RESPONSE_CANCEL,
                        NULL, GTK_RESPONSE_OK, NULL);

    if (gtk_dialog_run (GTK_DIALOG (chooser)) == GTK_RESPONSE_OK) {
        filename = gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (chooser));
    }
    // destroy chooser widget
    gtk_widget_destroy (chooser);

}
/* Parser's Thread function. The thread checks the redirected */
/* standard ouput, for messages from parser and display them */
/* to label */
void *display_parser_output() {

    gint chars_read;
    gchar buf[1024];

    //Redirect fds[1] to be writed with the standard output.
    dup2 (fds[1], 1);

    while(1) {
        // read from pipe
        chars_read = read(fds[0], buf, 1024);
        fprintf(stderr, "%i chars: %s\n", chars_read, buf);
        // display data to the label
        gtk_label_set_text((GtkLabel*)(parser.parser_output_label), buf);
    }
    return 0;
}

/* Initialize gtk. Parse and save objects from UI description */
void init(int argc, char **argv) {

    gtk_init (&argc, &argv);
    /* Construct a GtkBuilder instance and load our UI description */
    parser.builder = gtk_builder_new();
    gtk_builder_add_from_file(parser.builder, "interface/build.xml", NULL);

    /* Connect signal handlers to the constructed widgets. */
    // take window object from the UI description
    parser.window = gtk_builder_get_object (parser.builder, "window");
    // connect window with destroy function.
    g_signal_connect (parser.window, "destroy", G_CALLBACK (destroy), NULL);
    // take parse file button from the UI description
    parser.parse_file_button =
        gtk_builder_get_object (parser.builder, "parse_file_button");
    // connect parse file button with the parse file function
    g_signal_connect (parser.parse_file_button, "clicked",
            G_CALLBACK (parse_file), NULL);
    // take open file button from the UI description
    parser.open_file_button =
        gtk_builder_get_object (parser.builder, "open_file_button");
    // connect open file button with the open file function
    g_signal_connect (parser.open_file_button,
            "clicked", G_CALLBACK (open_file), NULL);
    // take parser output lable from UI description
    parser.parser_output_label =
        gtk_builder_get_object(parser.builder,"parser_output");
}
