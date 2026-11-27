/* EXPECT_COMPILE_ERROR: this compiles fine but fails at the LINK step.
 *
 * 04-link-error.c: the difference between a compiler error and a linker
 * error. Try both commands:
 *
 *   gcc -std=c17 -Wall -Wextra -Werror -pedantic -c 04-link-error.c
 *       -> succeeds and writes 04-link-error.o (compile + assemble only)
 *   nm 04-link-error.o
 *       -> shows "U missing_helper": needed, but not defined here
 *   gcc 04-link-error.o -o link-error
 *       -> fails: "undefined reference to `missing_helper'"
 *          The message comes from ld (the linker), not from cc1 (the compiler).
 */
#include <stdio.h>

/*
 * A DECLARATION: it promises the compiler "a function with this name and
 * type exists somewhere". That is enough to compile a call: the compiler
 * emits a call instruction with a placeholder address. Nobody ever provides
 * the DEFINITION (the body), so the linker has nothing to fill in.
 */
int missing_helper(int x);

int main(void)
{
    printf("%d\n", missing_helper(41));
    return 0;
}
