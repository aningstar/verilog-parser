#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "gui.h"


void notebook_close_current_page() {
    gint page_number = 0;
    page_number = gtk_notebook_get_current_page(GTK_NOTEBOOK(parser.notebook));
    gtk_notebook_remove_page(GTK_NOTEBOOK(parser.notebook), page_number);
}
// returns the nth opened file in notebook
guint notebook_current_file_number() {
    // get the number of current page
    return gtk_notebook_get_current_page(GTK_NOTEBOOK(parser.notebook));
}
// returns the text view of the selected tab of notebook
GtkWidget *notebook_current_view() {
    GtkWidget *current_widget;
    gint current_page;
    GList *list;

    // get the number of current page
    current_page = gtk_notebook_get_current_page(GTK_NOTEBOOK(parser.notebook));
    // get the widget of the nth page
    current_widget = gtk_notebook_get_nth_page(GTK_NOTEBOOK(parser.notebook),
            current_page);
    // get the children of scroll window
    list = gtk_container_get_children(GTK_CONTAINER(current_widget));
    // get the first children of list
    list = g_list_first(list);
    // return the current text view
    return list->data;
}
// creates a text view with the contents
// of the given file and append it to the
// notebook
void notebook_add_page(gchar *filename) {
    GtkWidget *scrolled, *view, *label;
    gchar *contents;
    gsize length;
    // open file with the given filename
    GFile *file = g_file_new_for_path(filename);
    // new scrolled window
    scrolled = gtk_scrolled_window_new(NULL, NULL);
    gtk_widget_show (scrolled);
    // new text view for the file
    view = gtk_text_view_new();
    // label for the tab name of notebook with the given filename
    label = gtk_label_new(g_file_get_basename(file));
    // set options for the textview
    gtk_text_view_set_editable (GTK_TEXT_VIEW (view), TRUE);
    gtk_text_view_set_cursor_visible (GTK_TEXT_VIEW (view), TRUE);
    // add text view to scrolled window
    gtk_container_add (GTK_CONTAINER (scrolled), view);
    gtk_widget_show (view);
    // set the given file name to the notebook tab with label
    gtk_label_set_text(GTK_LABEL(label), g_file_get_basename(file));
    // load file's contents
    if( g_file_load_contents(file, NULL, &contents, &length, NULL, NULL) ) {
        // use GtkTextBuffer to load file's contents to the notebook page
        GtkTextBuffer *buffer;
        buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW (view));
        gtk_text_buffer_set_text(buffer, contents, length);
        g_free(contents);
    }
    // append above objects to the notebook
    gtk_notebook_append_page(GTK_NOTEBOOK(parser.notebook), scrolled, label);
    opened_files = g_list_append(opened_files, filename);
}
