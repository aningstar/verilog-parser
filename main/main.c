#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <gtk/gtk.h>
#include "gui.h"
#include "parser.h"

extern int fds[2];

int main (int argc, char **argv) {

    pthread_t thread_1;
    int return_code;
    // initialize gui
    init(argc, argv);
    // Create a pipe. File descriptors for the two ends of
    // the pipe are placed in fds.
    pipe (fds);
    // spawn a thread to check and display parser messages from redirectd
    // standard output
    return_code = pthread_create(&thread_1, NULL, display_parser_output, NULL);
    if (return_code) {
        perror("error: pthread_create");
        return 1;
    }
    // start gui
    gtk_main();
    return 0;
}
