# relearn-c: notes for Claude

This repo is a self-running C learning environment. The learner writes **only** exercise
solutions in `topics/NN-name/solutions/`. Agents maintain everything else.

- Conventions and layout: `curriculum/AUTHORING.md` (read it before creating or changing a topic).
- Agents: `.claude/agents/curriculum.md`, `exercise.md` and `review.md`.
- Procedures: `/next-topic` (`.claude/commands/next-topic.md`) and `/review-pr <N>` (`.claude/commands/review-pr.md`).
  The GitHub workflows in `.github/workflows/` run these same files.
- **Never give the learner solution code** unless they explicitly ask for it in the
  conversation. Hints, explanations of principles and pointers to docs are fine.
- Commands: `make help`. Run `make check` before pushing. Commits must follow
  Conventional Commits (enforced by commitlint).
- `main` is protected: changes go through PRs with the `ci-ok` and `review-verdict` checks.
