#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <pthread.h>
#include "frame.h"
#include "../parser/lib/verilog_parser.tab.h"
#include "../parser/lib/structures.h"

extern FILE *yyin;

GtkTextBuffer *buffer;
GtkBuilder *builder;
GObject *window;
GObject *parse_file_button;
GObject *open_file_button;
GObject *parser_output;
GtkTextIter iter;
gchar *filename;

/* File descriptors for pipe. */
int fds[2];

static void destroy(GtkWidget *widget,gpointer data) {
    gtk_main_quit ();
}

static void parse_file(GObject *object) {

    yyin = fopen("grammar_examples/bit_selects_grammar.v", "r"); // open given file

    yyparse(); // parse file

    fclose(yyin); // close file
}

void open_file () {
    GtkWidget *chooser;
    chooser = gtk_file_chooser_dialog_new ("Open File",
                        GTK_WINDOW (window),
                        GTK_FILE_CHOOSER_ACTION_OPEN,
                        NULL, GTK_RESPONSE_CANCEL,
                        NULL, GTK_RESPONSE_OK, NULL);

    if (gtk_dialog_run (GTK_DIALOG (chooser)) == GTK_RESPONSE_OK)
    {
        filename = gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (chooser));
    }

    gtk_widget_destroy (chooser);

}

static void *display_parser_output() {

    gint chars_read;
    gchar buf[20];

    //Redirect fds[1] to be writed with the standard output.
    dup2 (fds[1], 1);

    while(1) {
        // read from pipe
        chars_read = read(fds[0], buf, 20);
        fprintf(stderr, "%i chars: %s\n", chars_read, buf);
        gtk_text_buffer_insert(buffer, &iter, buf, chars_read);
        gtk_text_buffer_get_end_iter(buffer, &iter);
    }
    return 0;
}

void run (int argc, char **argv) {

    pthread_t thread_1;
    int return_code;

    // Create a pipe. File descriptors for the two ends of the pipe are placed in fds.
    pipe (fds);

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

    open_file_button = gtk_builder_get_object (builder, "open_file_button");

    g_signal_connect (open_file_button, "clicked",
                          G_CALLBACK (open_file), NULL);

    parser_output = gtk_builder_get_object(builder,"parser_output");
    buffer = gtk_text_view_get_buffer (GTK_TEXT_VIEW (parser_output));
    gtk_text_buffer_get_end_iter(buffer, &iter);

    /* This is the singnal connection to call input_callback when we have data in standard output read end pipe. */
    //gdk_input_add(fds[0], GDK_INPUT_READ, write_parser_output, NULL);

    return_code = pthread_create(&thread_1, NULL, display_parser_output, NULL);
    if (return_code) {
        perror("error: pthread_create");
        return;
    }

    gtk_main();

}

