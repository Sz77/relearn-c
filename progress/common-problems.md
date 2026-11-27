# Common problems

Recurring mistakes seen across topics. Maintained by the **review agent**.
The curriculum agent uses it to tailor "Common mistakes" sections and review topics.

<!-- Format:
## <short problem name>
- **Seen in:** topic NN (PR #x), topic MM (PR #y)
- **What happens:** one or two sentences
- **Fix / habit to build:** one or two sentences
-->

## Committing build artifacts / editing files outside solutions/
- **Seen in:** topic 01 (PR #5)
- **What happens:** `git add -A` picks up the compiled binary and accidental edits to curriculum files.
- **Fix / habit to build:** build into `build/` or add the output to `.gitignore`; review `git diff --stat` before every commit.
