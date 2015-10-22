#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <gtk/gtk.h>
#include "gui.h"
#include "treeview.h"
#include "notebook.h"
#include "../parser/lib/verilog_parser.tab.h"
#include "../tpl/tpl.h"

extern FILE *yyin;

/* Spanws a new process and use verilog parser to parse
 * the specified verilog file. After that serialize the
 * structrures */
void parse_file(GObject *object) {
    gtk_tree_store_clear(parser.treestore);
    gchar *filename;
    // get filename of opened file
    filename = g_list_nth_data(opened_files, notebook_current_file_number());

    // Delete old text in text_view
    GtkTextBuffer *buffer;
    GtkTextIter iter_start, iter_end;
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(parser.parser_output));
    gtk_text_buffer_get_start_iter(buffer, &iter_start);
    gtk_text_buffer_get_end_iter(buffer, &iter_end);
    gtk_text_buffer_delete(buffer, &iter_start, &iter_end);

    if (filename != NULL) {
        // spawn new process for parsing
        if (fork() == 0) {
            Shared *shmem;
            // attach shared memory segment to the address space
            shmem = (Shared *)shmat(shmid, NULL, 0);
            //Redirect fds[1] to be writed with the standard output.
            dup2 (fds[1], 1);
            printf("\n*****\n");
            printf("Parsing %s", filename);
            printf("\n*****\n");
            fflush(stdout);
            fprintf(stderr, "%s\n", filename);
            // open given file
            yyin = fopen(filename, "r");
            // parse file
            yyparse();
            // close file
            fclose(yyin);
            print_modules();
            printf("\n*****\n");
            printf("Parsing Complete");
            printf("\n*****\n");
            fflush(stdout);
            store_structures();
            // copy structures to the shared segment
            shmem->rdy = 1;
            // detache from shared segment
            shmdt(shmem);
            // exit child process
            exit(0);
        }
    }
}
/* Thread function that wait from parser
 * to end , and uses the tlp library to
 * deserialize the structures. After that it
 * paints the structures to the gtk tree. */
void *read_structures() {
    Shared *shmem;
    // create a new shared segment
    shmid = shmget(IPC_PRIVATE, sizeof(Shared), IPC_CREAT|0777);
    // attach shared memory segment to the address space
    shmem = (Shared *)shmat(shmid, NULL, 0);
    // destroy segment after the last process detaches
    shmctl(shmid, IPC_RMID, NULL);

    while(1) {
        // wait for the process to signal
        shmem->rdy = 0;
        while(shmem->rdy == 0) {}
        // deserialize the structures
        load_structures();
        create_and_fill_tree();
        free_memory();
    }
    return 0;
}
/* Uses the tlp library and serialize
 * the structures in binary format */
void store_structures() {
    int i = 0;
    tpl_node *tn_modules, *tn_instances;
    Module tmp_module;
    Instance tmp_instance, *curr;

    // Map an array with structs
    tn_modules = tpl_map("A(S(c#))", &tmp_module, SIZE);
    // Pack the informations of the array
    for (i = 0; i < number_of_modules; i++) {
        tmp_module = *modules[i];
        tpl_pack(tn_modules, 1);
    }
    // Save to tlp file
    tpl_dump(tn_modules, TPL_FILE, "modules.tpl");
    // Free memory
    tpl_free(tn_modules);

    // Map a two dimensional array with lists
    tn_instances = tpl_map("A(A(S(ic#)))", &tmp_instance, SIZE);
    // Pack the informations of the array
    for (i = 0; i < number_of_modules; i++) {
        for(curr = cells[i]; curr != NULL; curr = curr->next) {
            tmp_instance = *curr;
            tpl_pack(tn_instances, 2);
        }
        tpl_pack(tn_instances, 1);
    }
    // Save to tlp file
    tpl_dump(tn_instances, TPL_FILE, "instances.tpl");
    // Free memory
    tpl_free(tn_instances);
}
/* Uses the tlp library and deserialize the binary file
 * with the structures from parsing */
void load_structures() {
    int i = 0;
    tpl_node *tn_modules, *tn_instances;
    Module tmp_module;
    Instance tmp_instance;
    Instance *head = NULL;

    // Map an array structs
    tn_modules = tpl_map("A(S(c#))", &tmp_module, SIZE);
    // Load file with structure
    tpl_load(tn_modules, TPL_FILE, "modules.tpl");
    // Unpack the array and save the structrure
    while(tpl_unpack(tn_modules, 1) > 0) {
        add_module(tmp_module.name);
    }
    // Free the memory
    tpl_free(tn_modules);

    // Map a two dimensional array with lists
    tn_instances = tpl_map("A(A(S(ic#)))", &tmp_instance, SIZE);
    // Load file with structure
    tpl_load(tn_instances, TPL_FILE, "instances.tpl");
    // Unpack the array and save the structure
    while(tpl_unpack(tn_instances, 1) > 0) {
        while(tpl_unpack(tn_instances, 2) > 0) {
            head = addInstance(head, tmp_instance.instance_name, tmp_instance.module_key);
        }
        cells[i] = head;
        i++;
        head = NULL;
    }
    // Free the memory
    tpl_free(tn_instances);
}

/* Parser's Thread function. The thread checks the redirected standard ouput */
/* of child process,for messages from parser and display them to textview */
void *display_parser_output() {
    gint chars_read;
    gchar buf[1024];
    GtkTextBuffer *buffer;
    GtkTextIter iter;

    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(parser.parser_output));

    // TODO
    // Listen for a stop signal from main thread,
    // to stop the loop. After the signal remove the
    // parser log file.
    while(1) {
        // read from pipe
        chars_read = read(fds[0], buf, 1024);
        gtk_text_buffer_get_end_iter(buffer, &iter);
        gtk_text_buffer_insert(buffer, &iter, buf, chars_read);
    }
}

/* Terminate program when window closed */
void destroy(GtkWidget *widget, gpointer data) {
    gtk_main_quit ();
}

void close_file() {
    notebook_close_current_page();
    gtk_tree_store_clear(parser.treestore);
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
    parser.close_file_button =
        gtk_builder_get_object (parser.builder, "close_file_button");
    g_signal_connect (parser.close_file_button, "clicked",
            G_CALLBACK(close_file), NULL);
    // take parser output lable from UI description
    parser.parser_output =
        gtk_builder_get_object(parser.builder,"parser_output");
    // take tree view object from UI description
    parser.treeview = gtk_builder_get_object(parser.builder, "treeview");
    // take notebook object from UI description
    parser.notebook = gtk_builder_get_object(parser.builder, "notebook");
    g_signal_connect(parser.notebook, "select-page", G_CALLBACK(select_page), NULL);
    init_treeview();
}
