# ex03 — Build info from the preprocessor (★★★)

## Goal

Write a small command-line tool that reports how it was **compiled**: which C standard,
whether it was optimized, whether `assert` is active. All of that is known only to the
preprocessor and compiler, so you must get it from predefined macros and `#if` /
`#ifdef`, not by guessing. You also design the command-line behavior from ex01 a step
further: an optional argument, two different error cases and three exit codes.

## Requirements

File: `solutions/ex03-build-info/main.c` (a program, so it defines `main`).
In the examples below the program is called `build-info`.

### The facts

| Key | Value | Where it comes from |
|-----|-------|---------------------|
| `c_standard` | the value of `__STDC_VERSION__` as a decimal number (`201710` under `-std=c17`) | standard predefined macro |
| `stdc` | `1` if `__STDC__` is defined as 1, else `0` | standard predefined macro |
| `hosted` | the value of `__STDC_HOSTED__` (`1` for a normal program with a full libc) | standard predefined macro |
| `optimized` | `yes` if the compiler defines `__OPTIMIZE__`, else `no` | gcc/clang predefined macro, set by `-O1` and higher |
| `asserts` | `off` if `NDEBUG` is defined, else `on` | the macro that switches `assert()` off |

Every value must be decided by the preprocessor or by a macro's value. Hard-coding
`201710` or `no` in a `printf` is wrong even though the test cannot tell. Rebuild with
`-O2` or `-DNDEBUG` by hand and check that the output changes.

### Command-line behavior

1. **No arguments**: print all five facts, one per line as `key=value`, in exactly the
   order of the table, to `stdout`. Exit status `0`. With the test build flags
   (`-std=c17 -O0`, no `NDEBUG`) the output is exactly:
   ```
   c_standard=201710
   stdc=1
   hosted=1
   optimized=no
   asserts=on
   ```
2. **One argument that is a known key** (`build-info optimized`): print only the value
   and a newline (`no`) to `stdout`. Exit status `0`. Keys are case-sensitive and must
   match exactly: `HOSTED`, `host`, `hosted=` and the empty string are not keys.
3. **One argument that is not a key** (`build-info colour`): nothing on `stdout`; on
   `stderr` exactly
   ```
   build-info: unknown key 'colour'
   ```
   Exit status `2`.
4. **Two or more arguments**: nothing on `stdout`; on `stderr` exactly
   ```
   usage: build-info [KEY]
   ```
   Exit status `1`.

In every case, the stream that is not mentioned stays empty.

## Constraints

- You may use `<stdio.h>`, `<stdlib.h>` and `strcmp` from `<string.h>`.
- Add a compile-time guard: if the code is compiled with a C standard older than C17,
  compilation must stop with a clear message of your own. (Look up `#error`. Try it
  with `-std=c11` by hand. The test cannot check this, but the review will.)
- Any helper function must be `static` (see ex02 and `-Wmissing-prototypes`).
- Design so that each key name appears **once** in your source. Listing all facts and
  looking up a single one should use the same data, so they can never disagree.

## Hints

- `printf("%ld\n", __STDC_VERSION__)` works because the macro expands to a `long`
  constant such as `201710L`. Check the type of the other macros the same way: look at
  what `gcc -E` turns them into, or run `gcc -dM -E -x c /dev/null | sort` to list every
  predefined macro.
- `#ifdef` and `#if` choose between pieces of *source text* before the compiler runs.
  A good pattern is to set your own macro (or a `static const` variable) to a string in
  each branch, and use only that afterwards.
- For the "each key once" rule, think of the facts as rows of a little table that your
  code walks through. Which C feature lets you keep several `(name, value)` pairs in one
  place? Plain parallel arrays are fine for now.

## Test

```sh
make test T=01
```

The test is `tests/test_ex03-build-info.sh`. It compares `stdout`, `stderr` and the exit
status exactly for every case above.
