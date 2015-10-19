#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "parser.h"
#include "gui.h"
#include "treeview.h"
#include "notebook.h"

/* Terminate program when window closed */
void destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit ();
}

void select_page() {
    // free old filename
    //g_free(filename);
    // copy the new filename to global filename pointer
    //strcpy(filename, notebook_current_file());
}
/* When open file button is pressed, the open_file function is called */
/* and user searchs and opens a file. The filename is saved. */
void open_file () {
    GtkWidget *chooser;
    gchar *filename;
    // open a dialog and save the chosen file name
    chooser = gtk_file_chooser_dialog_new ("Open File",
                        GTK_WINDOW (parser.window),
                        GTK_FILE_CHOOSER_ACTION_OPEN,
                        ("_Cancel"), GTK_RESPONSE_CANCEL,
                        ("_Open"), GTK_RESPONSE_OK, NULL);

    if (gtk_dialog_run (GTK_DIALOG (chooser)) == GTK_RESPONSE_OK) {
        filename = gtk_file_chooser_get_filename (GTK_FILE_CHOOSER (chooser));
        // add a page to the notebook with the given file
        notebook_add_page(filename);
    }
    // destroy chooser widget
    gtk_widget_destroy (chooser);

}
// saves the selected file from notebook
void save_file() {
    GError *error = NULL;
    GtkWidget *view;
    GtkTextBuffer *buffer;
    GtkTextIter start, end;
    gchar *text;
    gboolean return_value;
    gchar *filename;

    filename = g_list_nth_data(opened_files, notebook_current_file_number());

    // get current text view from notebook
    view = notebook_current_view();
    // disable text view
    gtk_widget_set_sensitive(view, FALSE);
    // get buffer of text view
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(view));
    // get start and end iter
    gtk_text_buffer_get_start_iter(buffer, &start);
    gtk_text_buffer_get_end_iter(buffer, &end);
    // get text from buffer
    text = gtk_text_buffer_get_text(buffer, &start, &end, FALSE);
    gtk_text_buffer_set_modified(buffer, FALSE);

    // write text to file
    return_value = g_file_set_contents(filename, text, -1, &error);
    if (return_value == FALSE) {
        g_error_free(error);
    }
    // enable text view
    gtk_widget_set_sensitive(view, TRUE);
    // free text's memory
    g_free(text);
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
    g_signal_connect (parser.open_file_button, "clicked",
            G_CALLBACK (open_file), NULL);
    //take save file button from the UI description
    parser.save_file_button =
        gtk_builder_get_object (parser.builder, "save_file_button");
    // connect save file button with the save file function
    g_signal_connect (parser.save_file_button, "clicked",
            G_CALLBACK(save_file), NULL);
    // take parser output lable from UI description
    parser.parser_output_label =
        gtk_builder_get_object(parser.builder,"parser_output");
    // take tree view object from UI description
    parser.treeview = gtk_builder_get_object(parser.builder, "treeview");
    // take notebook object from UI description
    parser.notebook = gtk_builder_get_object(parser.builder, "notebook");
    g_signal_connect(parser.notebook, "select-page", G_CALLBACK(select_page), NULL);
    init_treeview();
}
