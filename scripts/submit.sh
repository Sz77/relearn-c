#!/usr/bin/env bash
# Push the current solve/NN-name branch and open (or show) its PR.
set -euo pipefail
branch="$(git rev-parse --abbrev-ref HEAD)"
if [[ ! "$branch" =~ ^solve/([0-9]+)-(.+)$ ]]; then
  echo "You are on '$branch'. Solutions live on a branch named solve/NN-name (e.g. solve/01-hello-world)." >&2
  exit 1
fi
nn="${BASH_REMATCH[1]}"; name="${BASH_REMATCH[2]}"
if [[ -n "$(git status --porcelain)" ]]; then
  echo "You have uncommitted changes. Commit them first, e.g.:" >&2
  echo "  git add -A && git commit -m \"feat(topic-$nn): solve exercise 1\"" >&2
  exit 1
fi
git push -u origin "$branch"
if gh pr view "$branch" >/dev/null 2>&1; then
  echo "PR already open; the push re-triggers the review:"
  gh pr view "$branch" --json url --jq .url
else
  gh pr create --base main --head "$branch" \
    --title "feat(topic-$nn): solve ${name//-/ }" \
    --body "Solutions for topic $nn ($name). Please review."
fi
