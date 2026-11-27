# relearn-c

A self-running environment for relearning C from zero to advanced. **You write only the
exercise solutions.** Agents generate topics, exercises and tests, review your code, track
your progress and pick what comes next.

```
 ┌───────────────────────── next-topic workflow (Claude) ─────────────────────────┐
 │ curriculum agent → topic README + examples   exercise agent → exercises + tests │
 │                 → PR topic/NN-name → CI green → auto-merged to main             │
 └──────────────────────────────────────┬─────────────────────────────────────────┘
                                        ▼
            you: branch solve/NN-name → make start → solve → make test → make submit
                                        ▼
 ┌────────────────────────────── review workflow (Claude) ───────────────────────┐
 │ review agent: tests + sanitizers + lint + line-by-line review                  │
 │ → PR comment with APPROVE / REDO, progress/ updated, ROADMAP marked ✅ if done  │
 └──────────────────────────────────────┬─────────────────────────────────────────┘
                 REDO: fix and push again│APPROVE: you merge the PR
                                        ▼
                     merge triggers the next topic (loop)
```

## Setup (once, after cloning)

```bash
git clone git@github.com:Sz77/relearn-c.git && cd relearn-c
./setup.sh
```

`setup.sh` installs gcc, clang, sanitizer runtimes, cppcheck, node and pre-commit. It
installs the git hooks and runs a self-check. Run `make help` for every command.

## Your loop for each topic

```bash
git switch main && git pull                   # get the newest topic
# find the 🟡 topic in curriculum/ROADMAP.md, e.g. 01-hello-world
git switch -c solve/01-hello-world
make start T=01                               # copies starter files into topics/01-*/solutions/
$EDITOR topics/01-*/README.md                 # learn the concept, then read exercises/*/README.md
make test T=01                                # build + run tests (ASan + UBSan on)
git add -A && git commit -m "feat(topic-01): solve ex01"
make submit                                   # push + open PR → review agent runs
```

- **REDO**: the PR comment lists exact required fixes. The review bot also pushed a
  progress commit to your branch, so run `git pull` first, then fix,
  `git commit -m "fix(topic-01): ..."` and `git push`. The review reruns on every push.
- **APPROVE**: merge the PR (`gh pr merge --squash --delete-branch` or the button). This
  triggers the next topic. It appears as an auto-merged PR a few minutes later, so
  `git switch main && git pull` and continue.

## Rules enforced on every commit and PR

| What | How |
|------|-----|
| Strict compile | `-std=c17 -Wall -Wextra -Werror -pedantic -Wshadow -Wconversion …` |
| Memory and UB errors | tests run with AddressSanitizer + LeakSanitizer + UBSan |
| Formatting | clang-format (`.clang-format`), run `make format` |
| Lint | clang-tidy (`.clang-tidy`), cppcheck |
| Commit messages | commitlint, [Conventional Commits](https://www.conventionalcommits.org): `feat:` `fix:` `docs:` `test:` `refactor:` `chore:` |
| `main` | protected: merge only by PR with `ci-ok` (build, tests on gcc and clang, lint, commitlint) and `review-verdict` green |

## Repo layout

```
curriculum/ROADMAP.md        ordered topics with status (⬜ todo · 🟡 in progress · ✅ done · 🔁 review)
curriculum/AUTHORING.md      conventions the agents follow
topics/NN-name/
  README.md                  the concept
  examples/                  small commented programs (make examples)
  exercises/exMM-slug/       task description, header, starter file
  tests/                     Unity tests / program tests your solution must pass
  solutions/                 YOUR code (the only place you write)
progress/                    common-problems, weak-spots, strengths, topic-log (kept by the review agent)
.claude/agents/              curriculum, exercise, review agent definitions
.claude/commands/            /next-topic, /review-pr
.github/workflows/           ci.yml, review.yml, next-topic.yml
third_party/unity/           Unity test framework (vendored)
```

## Manual controls (if automation is unavailable)

In Claude Code, inside this repo:

- `/next-topic` generates the next topic locally and opens its PR (`/next-topic force` skips the in-progress check)
- `/review-pr 12` runs the review agent on PR #12 locally

Or on GitHub: **Actions → Next topic → Run workflow**, or **Actions → Review → Run workflow** with a PR number.

The workflows need a `CLAUDE_CODE_OAUTH_TOKEN` repository secret. Create it with
`claude setup-token`, then `gh secret set CLAUDE_CODE_OAUTH_TOKEN`.
