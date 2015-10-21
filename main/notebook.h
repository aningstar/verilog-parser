// get the the the nth opened file in notebook
guint notebook_current_file_number();
// returns the text view of the selected tab of notebook
GtkWidget *notebook_current_view();
// creates a text view with the contents
// of the given file and append it to the
// notebook
void notebook_add_page();
