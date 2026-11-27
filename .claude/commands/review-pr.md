---
description: Run the review agent on a solutions PR (normally automatic in CI)
argument-hint: "<pr-number>"
---

Review learner PR #$ARGUMENTS. This exact procedure is also run by `.github/workflows/review.yml`.

1. `gh pr checkout $ARGUMENTS && git fetch origin main`.
2. Use the **review** subagent (Task tool, `subagent_type: review`) with the PR number. If
   subagents are not available, read `.claude/agents/review.md` and follow it yourself, completely.
3. Make sure the progress/roadmap commit was pushed to the PR branch and the review comment was posted.
4. Set the merge gate on the PR's new head commit. Use `success` for APPROVE and `failure` for REDO:
   `gh api repos/{owner}/{repo}/statuses/$(git rev-parse HEAD) -f state=<state> -f context=review-verdict -f description="Review: <VERDICT>"`
5. If not running in GitHub Actions, switch back to the branch you started on. Report the
   verdict and the PR URL.
