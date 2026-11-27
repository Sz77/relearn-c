/* EXPECT_COMPILE_ERROR: with the strict flags, warnings become errors.
 *
 * 03-warnings-are-errors.c: code that a lax compiler accepts silently, but
 * our strict flags reject. Compare the two builds:
 *
 *   gcc -std=c17 03-warnings-are-errors.c -o lax        # builds, no output
 *   gcc -std=c17 -Wall -Wextra -Werror -pedantic -Wstrict-prototypes \
 *       -Wconversion 03-warnings-are-errors.c -o strict  # refuses to build
 *
 * Read the diagnostics. Each line has the form
 *   file:line:column: error: message [-Wflag-that-caught-it]
 * The flag in brackets tells you which warning fired. With -Werror the word
 * says "error", but the root cause is still a warning.
 */
#include <stdio.h>

/*
 * Problem 1 (-Wstrict-prototypes): "()" is NOT the same as "(void)" in C17.
 * It declares a function with UNSPECIFIED parameters, so the compiler cannot
 * check calls to it. Calling it with arguments would compile, and would be
 * undefined behavior.
 */
static int lucky_number()
{
    return 7;
}

/*
 * Problem 2 (-Wunused-parameter, from -Wextra): "verbose" is never used.
 * Often this means a bug: you forgot to use the value you were given.
 */
static void report(int value, int verbose)
{
    printf("value = %d\n", value);
}

int main(void)
{
    report(lucky_number(), 1);
    return 0;
}
