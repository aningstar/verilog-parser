#include <stdio.h>
#include <stdlib.h>
#include <gtk/gtk.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include "gui.h"
#include "treeview.h"

void create_and_fill_model () {
  GtkTreeIter toplevel;
  GtkTreeIter child;

  /* append another row and fill in some data */
  gtk_tree_store_append (parser.treestore, &toplevel, NULL);
  gtk_tree_store_set (parser.treestore, &toplevel,
                      MODULE_NAME, "ADDER",
                      INSTANCE_ENABLE, TRUE,
                      -1);

  int i = 0;
  for (i = 0; i < 50; i++) {
      /* ... and a third row */
      gtk_tree_store_append (parser.treestore, &child, &toplevel);
      gtk_tree_store_set (parser.treestore, &child,
                          MODULE_NAME, "MUX",
                          INSTANCE_NAME, "mux1",
                          -1);
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
              "cell-background", "GREY",
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
