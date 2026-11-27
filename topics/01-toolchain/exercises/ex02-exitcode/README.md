# ex02 — What the shell sees (★★)

## Goal

Write three small functions in a file **without `main`**, and let the linker connect
them to a test program that someone else wrote. Along the way, find out what really
happens to the value `main` returns: only 8 bits of it reach the shell.

This is the first exercise where your code is *not* a whole program. The test file
`tests/test_ex02-exitcode.c` has the `main`. It includes `exitcode.h` (the
**declarations**) and calls your functions. Your `exitcode.c` provides the
**definitions**. The build compiles both into object files and links them together.

## Requirements

File: `solutions/ex02-exitcode/exitcode.c`. Implement every function declared in
`exercises/ex02-exitcode/exitcode.h`. The header is the contract; read its comments
carefully. In short:

| Function | Returns |
|----------|---------|
| `int exitcode_wrap(int main_return)` | `main_return` reduced into `0..255` the way `$?` shows it: `256 → 0`, `300 → 44`, `-1 → 255` |
| `bool exitcode_is_success(int main_return)` | `true` exactly when the wrapped status is 0 |
| `const char *exitcode_name(int main_return)` | `"EXIT_SUCCESS"`, `"EXIT_FAILURE"` or `"other"`, based on the **wrapped** status |

- **Every** `int` is valid input, including `INT_MIN` and `INT_MAX`. There is no error
  case, and nothing may overflow.
- `exitcode_name` returns a pointer to a string literal. Nothing is allocated, and the
  caller never frees it.
- Compare with the `EXIT_SUCCESS` / `EXIT_FAILURE` macros from `<stdlib.h>`, not with
  hard-coded `0` / `1`.

## Constraints

- Do **not** define `main` in `exitcode.c`. If you do, the link fails with
  `multiple definition of 'main'`. That is a linker error, not a compiler error. Try it
  once on purpose and read the message.
- Do not change `exitcode.h`.
- The build uses `-Wmissing-prototypes`. If you write a helper function, either declare
  it `static` (visible only inside this file, which is what you want) or the build fails.
  After `gcc -c`, run `nm` on your object file and compare how a `static` helper and the
  public functions show up.
- The tests run with UndefinedBehaviorSanitizer. Signed overflow stops the test.

## Hints

- In C, `%` with a negative left operand gives a result that is zero or negative
  (`-1 % 256 == -1`). That is not the answer you want, so you need one more step.
  Check that step with `INT_MAX` in mind: `INT_MAX + 1` is undefined behavior.
- `abs(INT_MIN)` and `-INT_MIN` are undefined behavior too. You don't need either.
- Once `exitcode_wrap` works, the other two functions should each take a line or two.
  Reuse it.

## Test

```sh
make test T=01
```

The test is `tests/test_ex02-exitcode.c` (Unity). It is compiled and linked together
with your `exitcode.c`, so a compile error, a link error, a failed assertion and a
sanitizer report all show up as `FAIL`. Read the log below the `FAIL` line to see which
stage failed.
