# Authoring conventions (shared by all agents)

This file is the contract between the curriculum, exercise and review agents and the
tooling in `scripts/`. Follow it exactly. Tooling depends on these paths.

## Learner profile

- Former C programmer who has forgotten almost everything. Treat them as a beginner who learns fast.
- **Little time per week, many weeks.** Keep each topic small: about **1–2 hours** total
  (reading plus exercises). Prefer more, smaller topics over big ones. Use **2–3 exercises**
  per topic, and 4 only when the topic really needs it.
- Toolchain: Linux, gcc and clang, **C17** (`-std=c17`), GNU Make.
- **End goal: Linux kernel and device-driver development** (roadmap topics 53+). Shape the
  earlier topics toward it where it fits naturally, without making them harder. Examples:
  - error handling through negative errno-style return codes and `goto` cleanup ladders
  - intrusive lists and `container_of`-style thinking once structs are known
  - bit flags and masks, fixed-width types (`uint32_t`), explicit about overflow and alignment
  - no hidden allocation; every resource has a clear owner and release path
  - in "Further reading", mention where an idiom shows up in the kernel (for example `include/linux/list.h`)

## Kernel topics (59+): tooling to add when the first one is created

User-space tooling (Make, Unity, sanitizers) does not apply to kernel code. The curriculum
agent that creates topic 59 must also add this tooling, in the same PR, and verify it
both locally and in CI:

- **Reproducible kernel:** `scripts/kernel.sh` downloads a pinned upstream release (one
  version in `curriculum/KERNEL_VERSION`), configures it with `vng --kconfig` plus debug
  options (KASAN, lockdep, KUnit, DEBUG_INFO), and builds it into `build/linux/`. Cache the
  build in CI. Do not use the host kernel; local and CI must be identical.
- **Running:** use virtme-ng (`uv tool install virtme-ng`; needs `qemu-system-x86_64`) to boot that
  kernel with the repo mounted, load the module, and run the tests. GitHub-hosted Linux
  runners provide `/dev/kvm`.
- **Layout:** a kernel exercise's solution is `solutions/exNN-slug/*.c` plus a `Kbuild` file.
  Tests are a `tests/test_exNN-slug.sh` that runs *inside the VM*. It loads the module,
  exercises it from user space (a small C test program and/or `/dev`, sysfs or debugfs) and
  checks `dmesg` for oops, KASAN, lockdep or WARN output (any is a failure). Unload must
  succeed with no leaks (kmemleak). KUnit suites are allowed from topic 70.
- **Lint:** kernel code follows kernel style (`scripts/checkpatch.pl --no-tree -f`). Use a
  separate `.clang-format` in `topics/` for kernel topics (copy the kernel's), and add the
  checkpatch hook to pre-commit for those paths only.
- Extend `scripts/run-tests.sh`, `setup.sh` (dnf/apt: qemu, flex, bison, bc, elfutils-libelf-devel,
  openssl-devel; uv tool: virtme-ng) and `.github/workflows/ci.yml` accordingly.
- Never touch the host kernel: no `insmod` on the learner's real machine. Everything runs in the VM.

## Topic layout

```
topics/NN-kebab-name/
  README.md                       concept explanation (see below)
  examples/
    01-something.c                standalone, compilable, heavily commented example
    02-multi-file/                a folder = one program built from all its .c files
      main.c  util.c  util.h
  exercises/
    ex01-slug/
      README.md                   the task: goal, requirements, constraints, hints, how to test
      slug.h                      (unit-tested exercises) the interface the tests call. Learner must not change it.
      slug.c                      starter file with TODOs. It must compile cleanly and the tests must FAIL.
    ex02-slug/
      main.c                      (program exercises) starter main.c
  tests/
    test_ex01-slug.c              Unity test → the solution must NOT define main()
    test_ex02-slug.sh             program test → gets the compiled binary path as $1
  solutions/                      learner's code only: solutions/exNN-slug/*.c (+ optional .h)
```

- `NN` is a two-digit, zero-padded number in **creation order** (01, 02, …). Review topics
  get the next free number too, for example `07-review-pointers`.
- `make start T=NN` copies the starter `.c` files from `exercises/exNN-slug/` into
  `solutions/exNN-slug/`. The learner edits only `solutions/`.
- Exercise headers stay in `exercises/exNN-slug/`, which is on the include path for both
  tests and solutions (`#include "slug.h"`).
- An exercise may also have `solutions/exNN-slug/*.h` written by the learner. That folder is on the include path too.

## Build rules (enforced by scripts)

- Flags: `-std=c17 -Wall -Wextra -Werror -pedantic -Wshadow -Wconversion -Wstrict-prototypes -Wmissing-prototypes -g -O0`
- Tests are built with `-fsanitize=address,undefined -fno-sanitize-recover=all`, with leak detection on.
  Any leak or UB fails the test.
- `make test` runs only exercises that have a solution; the rest are SKIP. This keeps CI green on `main`.
- `make starters` checks that every starter compiles against its test.
- `make examples` compiles every example. If an example is meant to fail compilation, put
  `EXPECT_COMPILE_ERROR` in a comment on one of its first 3 lines.
- `make lint` = clang-format + clang-tidy + cppcheck (+ actionlint, YAML checks).
  All code you write must pass `make lint`. Run `make format` before linting.

## Writing tests

Unity tests (`tests/test_exNN-slug.c`):

```c
#include "slug.h"
#include "unity.h"

void setUp(void)
{
}

void tearDown(void)
{
}

static void test_handles_empty_input(void)
{
    TEST_ASSERT_EQUAL_size_t(0, slug_count(""));
}

int main(void)
{
    UNITY_BEGIN();
    RUN_TEST(test_handles_empty_input);
    return UNITY_END();
}
```

- Test functions are `static` and named `test_<behavior>`. Each tests one behavior.
- Cover the normal case, boundaries (0, 1, max, `INT_MIN`/`INT_MAX`, empty string, `NULL` if
  the contract allows it), and error paths. Exercise all heap paths so ASan/LSan can catch
  leaks, double frees and out-of-bounds access.
- If a function's contract says the caller frees, the test frees. Then a missing or extra
  free in the solution shows up as a sanitizer error.
- Program tests (`tests/test_exNN-slug.sh`) start with `#!/usr/bin/env bash`, use
  `set -euo pipefail`, run `"$1"` with fixed stdin/args, and compare stdout and exit code
  exactly. Print a clear `expected … got …` message on mismatch. Make them executable (`chmod +x`).
- Before committing, validate the tests against a throwaway reference solution **outside
  the repo**:
  `scripts/run-tests.sh --solutions-root /tmp/ref-NN NN` (where `/tmp/ref-NN/exNN-slug/*.c`).
  Every test must pass with the reference, and every unit test must fail with the starter.
  Delete the reference afterwards. **Never commit solutions.**

## Topic README.md structure

1. `# NN — Title`, then a one-line "you will be able to…" goal
2. **Why it matters** (2–4 sentences)
3. **Concepts**: short sections, each with a small code snippet. Explain what the compiler
   and the machine actually do. Point out undefined behavior.
4. **Common mistakes**: a list. Tailor it using `progress/common-problems.md`.
5. **Examples**: a list of the `examples/` files and what each shows, plus how to build and run them by hand
6. **Exercises**: a table of exercises, difficulty (★ to ★★★★), and what each practices
7. **Further reading**: man pages, a cppreference.com section, or a C17 standard clause

## Commits and PRs

- Conventional Commits only: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:` (+ `style`,
  `perf`, `ci`, `build`, `revert`). Use the topic as scope, for example `feat(topic-03): add exercises`.
- Branch names: `topic/NN-name` for new topics (agents) and `solve/NN-name` for solutions (learner).
- Agents never commit to `topics/*/solutions/` and never write solution code into any file,
  comment or PR text. Hints are fine. The answer is not.
