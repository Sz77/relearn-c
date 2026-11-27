#!/usr/bin/env bash
# Static analysis for C files: clang-tidy (config in .clang-tidy) and cppcheck.
# Usage: scripts/lint.sh tidy|cppcheck FILE...
# Include paths are derived from each file's topic so exercise headers resolve.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
tool="$1"; shift
status=0
shopt -s nullglob

includes_for() {
  local f="$1" incs=(-Ithird_party/unity)
  if [[ "$f" =~ ^(topics/[^/]+)/ ]]; then
    local t="${BASH_REMATCH[1]}"
    for d in "$t"/exercises/*/; do incs+=(-I"${d%/}"); done
    incs+=(-I"$(dirname "$f")")
  fi
  printf '%s\n' "${incs[@]}"
}

for f in "$@"; do
  [[ "$f" == *.c || "$f" == *.h ]] || continue
  [[ "$f" == third_party/* ]] && continue
  mapfile -t incs < <(includes_for "$f")
  case "$tool" in
    tidy)
      clang-tidy --quiet "$f" -- -std=c17 -xc "${incs[@]}" || status=1 ;;
    cppcheck)
      cppcheck --quiet --error-exitcode=1 --std=c17 --language=c \
        --enable=warning,style,performance,portability \
        --inline-suppr --suppress=missingIncludeSystem --suppress=unusedFunction \
        --suppress=checkersReport --suppress=normalCheckLevelMaxBranches \
        "${incs[@]}" "$f" || status=1 ;;
    *) echo "unknown tool $tool" >&2; exit 2 ;;
  esac
done
exit $status
