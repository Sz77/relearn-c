# Weak spots

Concepts the learner is still shaky on. Maintained by the **review agent**.
Read by the curriculum agent to decide whether to insert a review topic.

A topic can be marked `✅ done` in the roadmap only when no **open** item lists it in `Topic:`.

<!-- Format:
## <concept>
- **Status:** open | resolved (topic NN, PR #x)
- **Topic:** NN (where it showed up)
- **Evidence:** what went wrong, with file:line from the PR
- **What would close it:** the concrete thing the learner must show
-->

## Open

_None._

## Resolved

## Repository hygiene: build artifacts and files outside solutions/
- **Status:** resolved (topic 01, PR #5)
- **Topic:** 01
- **Evidence:** `hello` (12 KB ELF binary) committed at the repo root in 37f0049; `topics/01-toolchain/examples/02-stages.c:4` lost its leading ` *` inside a block comment.
- **What would close it:** a PR that touches only `solutions/` and progress files, with no binaries (check `git status` / `git diff --stat` before committing).
