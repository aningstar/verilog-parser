#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "gui.h"
#include "treeview.h"
#include "../parser/lib/verilog_parser.tab.h"

void clean_tree() {
    gtk_tree_store_clear(parser.treestore);
}

void create_and_fill_tree () {
    GtkTreeIter toplevel;
    GtkTreeIter child;
    int i = 0;
    Instance *curr;
    // Append module to tree
    for(i = 0; i < number_of_modules; i++) {
        gtk_tree_store_append(parser.treestore, &toplevel, NULL);
        gtk_tree_store_set(parser.treestore, &toplevel,
                        MODULE_NAME, modules[i]->name,
                        INSTANCE_ENABLE, TRUE,
                        -1);
        // Append module's instances to tree
        for(curr = cells[i]; curr != NULL; curr = curr->next) {
            gtk_tree_store_append(parser.treestore, &child, &toplevel);
            gtk_tree_store_set(parser.treestore, &child,
                        MODULE_NAME, modules[curr->module_key]->name,
                        INSTANCE_NAME, curr->instance_name,
                        -1);
        }
    }
}

// Sets columns and store model for the treeview
void init_treeview () {
    GtkCellRenderer *renderer;

    /* --- Column #1 --- */
    renderer = gtk_cell_renderer_text_new ();
    gtk_tree_view_insert_column_with_attributes (GTK_TREE_VIEW (parser.treeview),
                                                 -1,
                                                 "Cell Type",
                                                 renderer,
                                                 "text", MODULE_NAME,
                                                 NULL);
    /* --- Column #2 --- */
    renderer = gtk_cell_renderer_text_new ();
    g_object_set(renderer,
              "cell-background", "CYAN",
              "cell-background-set", TRUE,
              NULL);
    gtk_tree_view_insert_column_with_attributes (GTK_TREE_VIEW (parser.treeview),
                                                 -1,
                                                 "Instance Name",
                                                 renderer,
                                                 "text", INSTANCE_NAME,
                                                 "cell-background-set", INSTANCE_ENABLE,
                                                 NULL);
    // new tree store model with 3 entries
    parser.treestore = gtk_tree_store_new (NUM_COLS, G_TYPE_STRING,
              G_TYPE_STRING, G_TYPE_BOOLEAN);
    // set store model to the treeview
    gtk_tree_view_set_model (GTK_TREE_VIEW (parser.treeview),
              GTK_TREE_MODEL(parser.treestore));

}
