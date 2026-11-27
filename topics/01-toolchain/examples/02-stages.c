/*
 * 02-stages.c: a tiny program to push through each stage of the toolchain
 * one at a time, so you can look at what each stage produces.

 * Run these from this directory and open each output file:
 *
 *   gcc -std=c17 -E 02-stages.c -o stages.i   # 1. preprocess only
 *   gcc -std=c17 -S stages.i -o stages.s      # 2. compile to assembly
 *   gcc -c stages.s -o stages.o               # 3. assemble to object code
 *   gcc stages.o -o stages                    # 4. link with libc + startup
 *   ./stages
 *
 * Inspect the results:
 *   tail -n 30 stages.i      # your code, macros expanded, headers pasted in
 *   wc -l stages.i           # hundreds of lines came from <stdio.h> alone
 *   less stages.s            # assembly: look for "square:" and "main:"
 *   nm stages.o              # symbols: T = defined here, U = undefined (needed)
 *   nm stages | grep square  # after linking, every symbol has an address
 *
 * Shortcut that keeps every intermediate file:
 *   gcc -std=c17 -save-temps 02-stages.c -o stages
 */
#include <stdio.h>

/*
 * A macro is pure text substitution done by the preprocessor. After -E,
 * the name SIDE no longer exists: every use has become the literal 7.
 */
#define SIDE 7

/*
 * "static" here means this function is only visible inside this file
 * (internal linkage). In stages.o, nm shows it as "t" (lowercase = local).
 * Remove static and it becomes "T" (global): other files could call it.
 * Topic 17 covers linkage properly.
 */
static int square(int x)
{
    /*
     * The compiler turns this into a multiply instruction (imul on x86-64).
     * If x * x does not fit in an int, the behavior is UNDEFINED (signed
     * overflow). With SIDE = 7 we are nowhere near that. Topic 4 digs in.
     */
    return x * x;
}

int main(void)
{
    /*
     * printf is not defined in this file. In stages.o, nm lists it as "U"
     * (undefined): the object file holds a placeholder (a relocation), and
     * the linker fills in the real address from libc in step 4.
     */
    printf("area of a %dx%d square = %d\n", SIDE, SIDE, square(SIDE));
    return 0;
}
