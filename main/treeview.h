// enum for the treeview model
enum {
    MODULE_NAME = 0,
    INSTANCE_NAME,
    INSTANCE_ENABLE,
    NUM_COLS
} ;

void clean_tree();
void create_and_fill_tree ();
// Sets columns and store model for the treeview
void init_treeview ();
