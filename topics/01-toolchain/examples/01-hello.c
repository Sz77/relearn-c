/*
 * 01-hello.c: the smallest useful C program, annotated line by line.
 *
 * Build and run by hand:
 *   gcc -std=c17 -Wall -Wextra -Werror -pedantic 01-hello.c -o hello
 *   ./hello
 *   echo $?          # prints the exit status that main returned (0 here)
 */

/*
 * #include is handled by the PREPROCESSOR, before the compiler proper runs.
 * It pastes the text of the header in place of this line. <stdio.h> only
 * DECLARES functions such as puts and printf ("this function exists and has
 * this type"). The actual machine code for them lives in the C library
 * (libc), which the LINKER attaches at the very end.
 */
#include <stdio.h>
#include <stdlib.h> /* for EXIT_SUCCESS / EXIT_FAILURE */

/*
 * main is where your code starts. Before main runs, startup code from the C
 * runtime (crt1.o and friends, added by the linker) sets up the stack and
 * argc/argv. After main returns, that startup code calls exit() with the
 * returned value, which flushes stdout and hands the status to the OS.
 *
 * "int main(void)" is one of the two forms the standard guarantees
 * (C17 5.1.2.2.1). The "(void)" matters: it says "takes no arguments".
 * An empty "()" in C17 means "unspecified arguments", which is an old,
 * non-prototype style; -Wstrict-prototypes rejects it.
 */
int main(void)
{
    /*
     * puts writes the string and then a newline. It returns EOF on error.
     * stdout is usually LINE-BUFFERED on a terminal and FULLY buffered when
     * redirected to a file or pipe, so output may sit in memory until a
     * newline, a flush, or program exit.
     */
    if (puts("Hello, C17!") == EOF) {
        return EXIT_FAILURE; /* non-zero status: tells the shell we failed */
    }

    /*
     * printf takes a FORMAT string. %d means "print an int in decimal".
     * The compiler checks the format against the arguments (-Wformat, part of
     * -Wall). A mismatch, e.g. %d with a double, is undefined behavior.
     */
    int year = 2017;
    printf("C17 was published around %d.\n", year);

    /*
     * Returning from main is the same as calling exit() with that value.
     * For main ONLY, falling off the end returns 0, but being explicit is
     * clearer. EXIT_SUCCESS is 0 on every system you will meet.
     */
    return EXIT_SUCCESS;
}
