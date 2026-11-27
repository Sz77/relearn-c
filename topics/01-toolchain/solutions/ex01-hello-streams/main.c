#include <stdio.h>
#include <stdlib.h>

#define SUCCESS_STR "Hello, toolchain!"
#define SUCCESS_ERR "hello: done\n"

#define UNUSED_ERR "usage: hello\n"

int main(int argc, char *argv[])
{
    /* Casting to void marks a parameter as "unused on purpose". */
    (void)argv;

    int return_code = EXIT_SUCCESS;
    if (1 == argc) {

        if (puts(SUCCESS_STR) == EOF) {
            return_code = EXIT_FAILURE; /* non-zero status: tells the shell we failed */
        }

        if (fputs(SUCCESS_ERR, stderr) == EOF) {
            return_code = EXIT_FAILURE;
        }

    } else {
        return_code = EXIT_FAILURE;
        (void)fputs(UNUSED_ERR, stderr);
    }

    return return_code;
}
