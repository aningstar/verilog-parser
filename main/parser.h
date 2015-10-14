/* Parser's Thread function. The thread checks the redirected */
/* standard ouput, for messages from parser and display them */
/* to label */
void *display_parser_output();
/* Use verilog parser to parse the specified verilog file */
void parse_file(GObject *object);
