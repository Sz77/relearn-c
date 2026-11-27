#!/usr/bin/env bash
# Compile every example with the strict flags so examples never rot.
#   topics/NN/examples/foo.c          -> standalone program
#   topics/NN/examples/bar/*.c        -> one program built from all files in the folder
# Examples are compiled, not run (some read stdin or demonstrate crashes on purpose).
# Usage: scripts/build-examples.sh [TOPIC_FILTER]
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
CC="${CC:-gcc}"
BUILD_DIR="${BUILD_DIR:-build}"
FLAGS=(-std=c17 -Wall -Wextra -Werror -pedantic -Wshadow -Wconversion -Wstrict-prototypes -g -O0)
filter="${1:-}"
fail=0; count=0
shopt -s nullglob
for ex_root in topics/*/examples; do
  topic="$(basename "$(dirname "$ex_root")")"
  [[ -n "$filter" && "$topic" != *"$filter"* ]] && continue
  out="$BUILD_DIR/$topic/examples"; mkdir -p "$out"
  for f in "$ex_root"/*.c; do
    count=$((count + 1))
    name="$(basename "$f" .c)"
    if ! "$CC" "${FLAGS[@]}" "$f" -lm -o "$out/$name" 2>"$out/$name.log"; then
      # A file whose first line contains EXPECT_COMPILE_ERROR demonstrates a compiler error on purpose.
      if head -n 3 "$f" | grep -q 'EXPECT_COMPILE_ERROR'; then continue; fi
      echo "FAIL $f"; cat "$out/$name.log"; fail=$((fail + 1))
    elif head -n 3 "$f" | grep -q 'EXPECT_COMPILE_ERROR'; then
      echo "FAIL $f (marked EXPECT_COMPILE_ERROR but compiled cleanly)"; fail=$((fail + 1))
    fi
  done
  for d in "$ex_root"/*/; do
    srcs=("$d"*.c); [[ ${#srcs[@]} -eq 0 ]] && continue
    count=$((count + 1))
    name="$(basename "$d")"
    if ! "$CC" "${FLAGS[@]}" -I"$d" "${srcs[@]}" -lm -o "$out/$name" 2>"$out/$name.log"; then
      echo "FAIL $d"; cat "$out/$name.log"; fail=$((fail + 1))
    fi
  done
done
echo "Examples: $count built, $fail failed"
[[ $fail -eq 0 ]]
