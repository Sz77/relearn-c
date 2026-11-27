#!/usr/bin/env bash
# Copy starter .c files of a topic into its solutions/ folder (never overwrites).
# Usage: scripts/start-topic.sh 01
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
shopt -s nullglob
matches=(topics/"$1"*/)
if [[ ${#matches[@]} -ne 1 ]]; then
  echo "Expected exactly one topic matching '$1', found: ${matches[*]:-none}" >&2
  exit 1
fi
topic_dir="${matches[0]%/}"
for ex_dir in "$topic_dir"/exercises/*/; do
  ex="$(basename "$ex_dir")"
  dest="$topic_dir/solutions/$ex"
  mkdir -p "$dest"
  for f in "$ex_dir"*.c; do
    if [[ -e "$dest/$(basename "$f")" ]]; then
      echo "keep    $dest/$(basename "$f") (already exists)"
    else
      cp "$f" "$dest/"
      echo "created $dest/$(basename "$f")"
    fi
  done
done
cat <<EOF

Next:
  1. Read $topic_dir/README.md, then each exercises/*/README.md
  2. Edit the files in $topic_dir/solutions/
  3. make test T=$1
EOF
