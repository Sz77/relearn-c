# 01 — Hello world and the toolchain

You will be able to take a `.c` file through preprocess → compile → assemble → link by
hand, explain what each stage produces, and tell a compiler error from a linker error.

## Why it matters

Every later topic assumes you know what `gcc` actually does when you type `gcc foo.c`.
When something breaks, the first question is always *which stage failed?* A missing
header, a type error and an "undefined reference" are three different problems with
three different fixes. This repo also builds everything with strict warnings as errors,
so you need to be able to read those diagnostics without panicking.

## Concepts

### 1. The smallest program, and what "running" means

```c
#include <stdio.h>

int main(void)
{
    puts("Hello");
    return 0;
}
```

- `int main(void)` is one of the two signatures the standard guarantees for hosted
  programs (the other takes `argc`/`argv`, topic 16). Write `(void)`, not `()`. In C17
  an empty `()` means "unspecified parameters", an obsolete style the compiler cannot check.
- Your `main` is **not** the first code that runs. The linker adds C runtime startup
  code (`crt1.o`, `crti.o`, ...) that sets up the stack, collects `argc`/`argv`, calls
  `main`, and then passes `main`'s return value to `exit()`.
- `exit()` flushes `stdout` and gives the status to the OS. In the shell, `echo $?`
  shows it. 0 (`EXIT_SUCCESS`) means success; anything else (`EXIT_FAILURE`, usually 1)
  means failure. Tests and scripts rely on this.
- `main` is the only function where falling off the end without `return` is defined
  (it returns 0). For any other non-`void` function, using the value of a function
  that fell off the end is **undefined behavior**.

### 2. The four stages

`gcc` is a *driver*. It runs four separate tools for you:

```
foo.c ──cpp──▶ foo.i ──cc1──▶ foo.s ──as──▶ foo.o ──ld──▶ foo (executable)
      preprocess    compile       assemble       link (+ libc, startup code)
```

| Stage | Command to stop after it | Input → output | What happens |
|-------|--------------------------|----------------|--------------|
| Preprocess | `gcc -E foo.c -o foo.i` | text → text | `#include` pastes files, `#define` macros are substituted, comments removed, `#if` evaluated |
| Compile | `gcc -S foo.i -o foo.s` | C → assembly | parse, type-check, warn, optimize, emit assembly for your CPU |
| Assemble | `gcc -c foo.s -o foo.o` | assembly → object file | machine code plus a **symbol table** and **relocations** (holes to fill in later) |
| Link | `gcc foo.o -o foo` | objects → executable | resolve every symbol, fill in the holes, add libc and startup code |

`gcc -save-temps foo.c` keeps all the intermediate files at once.

The preprocessor knows nothing about C. It works on text and tokens. After `-E`, the
compiler never sees your `#define` names, only what they expanded to. That is why
macro bugs (topic 25) produce confusing error messages.

### 3. Declarations vs definitions (preview)

`#include <stdio.h>` does **not** bring in the code for `printf`. It brings in a
*declaration*:

```c
int printf(const char *restrict format, ...);
```

A declaration tells the compiler the name and type so it can type-check the call and
emit a `call` instruction. The *definition* (the machine code) lives in libc
(`libc.so.6`), and the linker connects the two. Look at an object file with `nm`:

```
$ nm foo.o
0000000000000000 T main      # T: defined here, global
                 U puts      # U: undefined here, someone else must provide it
```

The compiler may also rewrite `printf("Hello\n")` into `puts("Hello")`. Optimizers
are allowed to do this as long as the visible behavior is the same. Do not be surprised
to see `puts` in the assembly.

If the linker finds no definition for a `U` symbol, you get `undefined reference to
'name'`. That is a **link error**: your C was fine, but a piece is missing. Usually a
`.c` file is not on the command line, or a library flag like `-lm` is missing. Topic 2
goes deeper with multiple files.

### 4. Errors vs warnings, and our strict flags

The compiler emits two kinds of diagnostics:

- **Errors**: the code is not valid C (syntax error, wrong type). No output file.
- **Warnings**: the code is valid, but probably wrong. By default you still get a binary.

This repo builds with:

```
-std=c17 -Wall -Wextra -Werror -pedantic -Wshadow -Wconversion -Wstrict-prototypes -g -O0
```

| Flag | Meaning |
|------|---------|
| `-std=c17` | Use ISO C17. Without it gcc uses `gnu17`, which accepts GNU extensions silently. |
| `-Wall -Wextra` | Turn on the common and the extra warnings. Despite the name, `-Wall` is not "all". |
| `-pedantic` | Warn about anything the ISO standard does not allow, including extensions. |
| `-Wshadow` | Warn when an inner variable hides an outer one with the same name. |
| `-Wconversion` | Warn about implicit conversions that can change a value (for example `long` → `int`). |
| `-Wstrict-prototypes` | Reject `f()` style declarations without parameter types. |
| `-Werror` | Treat every warning as an error. Nothing is "just a warning". |
| `-g` | Put debug info into the binary (for gdb, topic 8, and readable sanitizer reports). |
| `-O0` | Don't optimize, so the machine code follows your source closely. |

Read a diagnostic from left to right:

```
foo.c:23:12: error: function declaration isn't a prototype [-Werror=strict-prototypes]
 file  line col                  message                    which flag caught it
```

Always fix the **first** diagnostic first. Later ones are often follow-on noise caused by
the first.

### 5. Undefined behavior: the deal you make with the compiler

The C standard (C17 §3.4.3) defines *undefined behavior* (UB) as behavior "for which this
International Standard imposes no requirements". This does not mean "crashes" or
"does something random but harmless". The compiler is allowed to assume UB never happens
and optimize based on that. So a program with UB may work at `-O0` and break at `-O2`.

Examples you will meet soon: signed integer overflow (topic 4), reading an uninitialized
variable, out-of-bounds array access (topic 9), `printf` with a format that does not
match the argument type. Warnings catch some of these at compile time. The sanitizers
(`-fsanitize=address,undefined`, which this repo's tests use) catch many others at run
time. Neither catches everything. Your understanding has to do the rest.

### 6. How this repo uses the toolchain

- `make examples T=01` compiles every example in this topic with the strict flags.
- `make start T=01` copies exercise starter files into `solutions/`, where you work.
- `make test T=01` builds your solutions with sanitizers and runs the tests.
- Under the hood these are `gcc` commands like the ones above. Run `make test T=01` and
  look at `scripts/run-tests.sh` if you are curious.

## Common mistakes

- **`int main()` instead of `int main(void)`.** It works with lax flags but fails with
  `-Wstrict-prototypes`. Same for every function that takes no parameters.
- **Ignoring warnings because "it still built".** Here `-Werror` means you can't anyway.
  Out in the world, treat a warning as a bug report you have not read yet.
- **Fixing the last error first.** Scroll up. The first diagnostic is the real one.
- **Confusing compile and link errors.** `error: implicit declaration of function 'foo'`
  is the *compiler* saying "I don't know `foo`": include the right header. `undefined
  reference to 'foo'` is the *linker* saying "nobody defined `foo`": add the `.c` file or
  library. The fixes are different.
- **Forgetting `-lm`.** `sqrt` and friends are declared in `<math.h>` but defined in
  `libm`, which gcc does not link by default. Put `-lm` *after* the source/object files.
- **Expecting output that never appears.** `stdout` is buffered. If the program crashes
  before a flush, text printed earlier may be lost. Debug with `fprintf(stderr, ...)`,
  which is unbuffered.
- **Returning garbage from `main`.** The exit status is 8 bits on Linux (`return 256;`
  shows up as 0 in `$?`). Use `EXIT_SUCCESS`/`EXIT_FAILURE` or small numbers.

_(This list will be tailored with your own recurring mistakes as reviews come in.)_

## Examples

| File | Shows |
|------|-------|
| `examples/01-hello.c` | An annotated hello world: includes, `main(void)`, `puts`/`printf`, exit status, buffering |
| `examples/02-stages.c` | A tiny program to run through `-E`, `-S`, `-c` and the link step, with `nm` commands to inspect each result |
| `examples/03-warnings-are-errors.c` | Valid C that a lax build accepts and our strict flags reject. Read the diagnostics. (Fails to build on purpose.) |
| `examples/04-link-error.c` | Compiles fine with `-c`, then fails at the link step with `undefined reference`. (Fails to build on purpose.) |

Build them all with `make examples T=01`. Files 03 and 04 are marked
`EXPECT_COMPILE_ERROR`, so the build script counts their failure as success. Their
diagnostics are in `build/01-toolchain/examples/*.log`.

By hand, from `topics/01-toolchain/examples/`:

```sh
gcc -std=c17 -Wall -Wextra -Werror -pedantic 01-hello.c -o /tmp/hello && /tmp/hello; echo "status=$?"
gcc -std=c17 -save-temps 02-stages.c -o /tmp/stages     # leaves .i .s .o next to the source
nm 02-stages.o                                          # T, t and U symbols
gcc -std=c17 03-warnings-are-errors.c -o /tmp/lax       # builds
gcc -std=c17 -Wall -Wextra -Werror -Wstrict-prototypes 03-warnings-are-errors.c   # does not
gcc -std=c17 -c 04-link-error.c && nm 04-link-error.o   # compiles, shows U missing_helper
gcc 04-link-error.o                                     # link fails
rm -f 02-stages.i 02-stages.s 02-stages.o 04-link-error.o  # keep the repo clean
```

Things to try:

- In `02-stages.i`, find your `main`. How many lines came before it?
- In `02-stages.s`, find `square`. Then rebuild with `-O2 -S` and look again. Where did it go?
- Remove `static` from `square` and check how `nm` shows it now.

## Exercises

| # | Exercise | Difficulty | Practices |
|---|----------|------------|-----------|
| 1 | [`ex01-hello-streams`](exercises/ex01-hello-streams/README.md) | ★ | A complete program: `stdout` vs `stderr`, exit status with `EXIT_SUCCESS`/`EXIT_FAILURE`, silencing an unused parameter under `-Werror` |
| 2 | [`ex02-exitcode`](exercises/ex02-exitcode/README.md) | ★★ | Code without `main` linked against a test program: header declarations vs your definitions, `static` helpers and `-Wmissing-prototypes`, the 8-bit exit status, avoiding signed overflow at `INT_MIN`/`INT_MAX` |
| 3 | [`ex03-build-info`](exercises/ex03-build-info/README.md) | ★★★ | Predefined macros, `#if`/`#ifdef`/`#error`, seeing how flags like `-O2` and `-DNDEBUG` change the program; designing a small CLI with three exit codes |

Start with `make start T=01`, edit files in `solutions/`, test with `make test T=01`.

## Further reading

- `man gcc`: sections "Overall Options" (`-E`, `-S`, `-c`, `-o`, `-save-temps`) and
  "Warning Options"
- `man nm`, `man 3 puts`, `man 3 printf`, `man 3 exit`
- cppreference: [Translation phases](https://en.cppreference.com/w/c/language/translation_phases),
  [main function](https://en.cppreference.com/w/c/language/main_function),
  [Undefined behavior](https://en.cppreference.com/w/c/language/behavior)
- C17 standard: §5.1.1.2 (translation phases), §5.1.2.2.1 (program startup),
  §5.1.2.2.3 (program termination), §3.4.3 (undefined behavior)
- GCC manual: [Warning Options](https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html)
