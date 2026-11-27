---
description: Generate the next topic (curriculum + exercise agents), open a PR and queue it for auto-merge
argument-hint: "[force]"
---

Generate the next topic of the C curriculum. This exact procedure is also run by
`.github/workflows/next-topic.yml`.

1. **Sync.** `git fetch origin && git switch main && git pull --ff-only`. If the working
   tree is dirty, stop and tell the user.
2. **Gate.** Read `curriculum/ROADMAP.md`. If a row is `🟡 in progress` and `$ARGUMENTS`
   is not `force`, stop and report which topic is still open. Nothing to do.
   If an open PR from a `topic/*` branch already exists (`gh pr list --head` / `gh pr list --search "head:topic/"`),
   stop and report it.
3. **Curriculum.** Use the **curriculum** subagent (Task tool, `subagent_type: curriculum`)
   to choose and create the next topic folder (README + examples + ROADMAP update). If
   subagents are not available, read `.claude/agents/curriculum.md` and follow it yourself.
4. **Exercises.** Use the **exercise** subagent on the new folder (or follow
   `.claude/agents/exercise.md` yourself). It must finish its full verification.
5. **Verify** everything yourself: `make examples`, `make starters`, `make test` (all new
   exercises SKIP), `pre-commit run --all-files`. Fix anything that fails. Confirm that
   `git status` shows no files under `topics/*/solutions/` and no reference solutions anywhere.
6. **Branch, commit, push.** `git switch -c topic/NN-name`. Commit (Conventional Commits,
   the hooks must pass) with something like `feat(topic-NN): add <title>`. Use separate
   commits if natural (`docs(topic-NN): …` for the README/examples, `test(topic-NN): …` for
   exercises and tests, `docs(roadmap): …`). Then `git push -u origin topic/NN-name`.
7. **PR.** `gh pr create --base main --title "feat(topic-NN): <title>" --body <summary>`. The body
   lists the concepts, the exercises with difficulty, the verification results, and
   "Start with: `git switch main && git pull && git switch -c solve/NN-name && make start T=NN`".
8. **Gates.** Mark the PR as not needing a solution review, then queue the merge:
   - `gh api repos/{owner}/{repo}/statuses/$(git rev-parse HEAD) -f state=success -f context=review-verdict -f description="Topic PR: no solutions to review"`
   - If running in GitHub Actions (`GITHUB_ACTIONS=true`), CI does not trigger itself for
     bot-pushed commits, so dispatch it: `gh workflow run ci.yml --ref topic/NN-name`.
   - `gh pr merge --auto --squash` (merges once CI is green).
9. **Report** the PR URL and the "start with" commands. If `$GITHUB_OUTPUT` is set, append
   `pr_url=<url>` to it.
