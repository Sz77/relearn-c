# ex01 — Hello, streams and exit status (★)

## Goal

Write a complete program that sends text to the right stream (`stdout` or `stderr`) and
reports success or failure through its exit status. Scripts, `make` and every test in
this repo use exactly these three channels to decide whether a program worked.

## Requirements

File: `solutions/ex01-hello-streams/main.c` (a program, so it defines `main`).

1. **Run with no arguments** (`./hello`):
   - `stdout` gets exactly this line, followed by a newline:
     ```
     Hello, toolchain!
     ```
   - `stderr` gets exactly this line, followed by a newline:
     ```
     hello: done
     ```
   - The exit status is `0`. Use `EXIT_SUCCESS` from `<stdlib.h>`.
2. **Run with one or more arguments** (`./hello x`, `./hello a b c`, even `./hello ""`):
   - `stdout` stays **empty**.
   - `stderr` gets exactly this line, followed by a newline:
     ```
     usage: hello
     ```
   - The exit status is `1`. Use `EXIT_FAILURE`.

Nothing else may be printed on either stream.

## Constraints

- Use the `int main(int argc, char *argv[])` form. `argc` counts the program name too,
  so "no arguments" means `argc == 1`.
- You do not need `argv`. The strict flags (`-Wextra` turns on `-Wunused-parameter`)
  reject an unused parameter, so you have to tell the compiler that you are ignoring it
  on purpose. The starter shows the usual way.
- The build uses `-Werror`. Your file must compile with no warnings at all.

## Hints

- `puts` writes to `stdout` and adds the newline for you. For `stderr` you need a
  function that takes the stream as an argument. Look at `man 3 fputs` and `man 3 fprintf`.
- Test it by hand, one stream at a time: `./hello 2>/dev/null` hides `stderr`,
  `./hello >/dev/null` hides `stdout`, and `echo $?` right after shows the exit status.

## Test

```sh
make start T=01      # once: copies the starter into solutions/
make test T=01
```

The test is `tests/test_ex01-hello-streams.sh`. It runs your binary and compares
`stdout`, `stderr` and the exit status exactly.
