#!/usr/bin/env bash
# Build and run exercise tests.
#
# Layout (see curriculum/AUTHORING.md):
#   topics/NN-name/exercises/exMM-slug/        README.md, headers (*.h), starter *.c
#   topics/NN-name/tests/test_exMM-slug.c      Unity test (solution must NOT define main)
#   topics/NN-name/tests/test_exMM-slug.sh     Program test (solution defines main; script gets binary path as $1)
#   topics/NN-name/solutions/exMM-slug/*.c     the learner's code
#
# Usage: scripts/run-tests.sh [options] [TOPIC_FILTER]
#   TOPIC_FILTER          substring/prefix of the topic folder, e.g. "01" or "01-hello"
#   --solutions-root DIR  take solution sources from DIR/exMM-slug/*.c instead of
#                         topics/NN/solutions (used to validate tests against a reference)
#   --starters            use the starter files in exercises/ as the "solution"
#   --compile-only        only compile, do not run tests
#   --require-solutions   a missing or not-started solution is a failure instead of a skip
#
# A solution identical to its starter file counts as not started (SKIP), so a PR can
# contain only some exercises of a topic.
#
# Environment: CC (default gcc), SAN=0 disables sanitizers, BUILD_DIR (default build).
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT" || exit 2

CC="${CC:-gcc}"
BUILD_DIR="${BUILD_DIR:-build}"
SAN="${SAN:-1}"
STD_FLAGS=(-std=c17 -Wall -Wextra -Werror -pedantic -Wshadow -Wconversion -Wstrict-prototypes -Wmissing-prototypes -g -O0)
SAN_FLAGS=()
if [[ "$SAN" == "1" ]]; then
  # shellcheck disable=SC2054 # the comma is part of the gcc flag
  SAN_FLAGS=(-fsanitize=address,undefined -fno-omit-frame-pointer -fno-sanitize-recover=all)
fi
export ASAN_OPTIONS="${ASAN_OPTIONS:-detect_leaks=1:abort_on_error=0:detect_stack_use_after_return=1}"
export UBSAN_OPTIONS="${UBSAN_OPTIONS:-print_stacktrace=1:halt_on_error=1}"

solutions_root=""
mode="solutions"
compile_only=0
require=0
filter=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --solutions-root) solutions_root="$(cd "$2" && pwd)"; shift 2 ;;
    --starters) mode="starters"; shift ;;
    --compile-only) compile_only=1; shift ;;
    --require-solutions) require=1; shift ;;
    -h|--help) sed -n '2,20p' "$0"; exit 0 ;;
    *) filter="$1"; shift ;;
  esac
done

if [[ -t 1 ]]; then G=$'\e[32m'; R=$'\e[31m'; Y=$'\e[33m'; B=$'\e[1m'; N=$'\e[0m'; else G=; R=; Y=; B=; N=; fi

pass=0; fail=0; skip=0
failed_list=()

unity_obj="$BUILD_DIR/unity/unity-${CC##*/}-san${SAN}.o"
build_unity() {
  if [[ ! -f "$unity_obj" ]]; then
    mkdir -p "$(dirname "$unity_obj")"
    # Unity itself is third-party: compile it without -Werror/-pedantic extras.
    "$CC" -std=c17 -g -O0 "${SAN_FLAGS[@]}" -c third_party/unity/unity.c -o "$unity_obj" || exit 2
  fi
}

shopt -s nullglob
for topic_dir in topics/*/; do
  topic="$(basename "$topic_dir")"
  [[ -n "$filter" && "$topic" != *"$filter"* ]] && continue
  [[ -d "$topic_dir/exercises" ]] || continue
  printf '%s== %s ==%s\n' "$B" "$topic" "$N"
  for ex_dir in "$topic_dir"exercises/*/; do
    ex="$(basename "$ex_dir")"
    ex_dir="${ex_dir%/}"
    case "$mode" in
      starters) sol_dir="$ex_dir" ;;
      *) if [[ -n "$solutions_root" ]]; then sol_dir="$solutions_root/$ex"; else sol_dir="${topic_dir}solutions/$ex"; fi ;;
    esac
    srcs=("$sol_dir"/*.c)
    unit_test="${topic_dir}tests/test_${ex}.c"
    prog_test="${topic_dir}tests/test_${ex}.sh"
    out_dir="$BUILD_DIR/$topic/$ex"
    mkdir -p "$out_dir"
    # A solution whose .c files are all byte-identical to the starter is "not started".
    why="no solution yet"
    if [[ ${#srcs[@]} -gt 0 && "$mode" == solutions && -z "$solutions_root" ]]; then
      unchanged=1
      for f in "${srcs[@]}"; do
        if [[ ! -f "$ex_dir/$(basename "$f")" ]] || ! cmp -s "$f" "$ex_dir/$(basename "$f")"; then
          unchanged=0; break
        fi
      done
      if [[ $unchanged -eq 1 ]]; then srcs=(); why="starter unchanged: not started"; fi
    fi
    if [[ ${#srcs[@]} -eq 0 ]]; then
      if [[ $require -eq 1 ]]; then
        printf '  %sFAIL%s %s (%s)\n' "$R" "$N" "$ex" "$why"; fail=$((fail + 1)); failed_list+=("$topic/$ex")
      else
        printf '  %sSKIP%s %s (%s)\n' "$Y" "$N" "$ex" "$why"; skip=$((skip + 1))
      fi
      continue
    fi
    incs=(-I"$ex_dir" -I"$sol_dir" -Ithird_party/unity)
    log="$out_dir/build.log"
    ok=1
    if [[ -f "$unit_test" ]]; then
      build_unity
      bin="$out_dir/test_${ex}"
      if ! "$CC" "${STD_FLAGS[@]}" "${SAN_FLAGS[@]}" "${incs[@]}" "${srcs[@]}" "$unit_test" "$unity_obj" -lm -o "$bin" >"$log" 2>&1; then
        ok=0
      elif [[ $compile_only -eq 0 ]]; then
        if ! "$bin" >"$out_dir/run.log" 2>&1; then ok=0; log="$out_dir/run.log"; fi
      fi
    elif [[ -f "$prog_test" ]]; then
      bin="$out_dir/$ex"
      if ! "$CC" "${STD_FLAGS[@]}" "${SAN_FLAGS[@]}" "${incs[@]}" "${srcs[@]}" -lm -o "$bin" >"$log" 2>&1; then
        ok=0
      elif [[ $compile_only -eq 0 ]]; then
        if ! bash "$prog_test" "$ROOT/$bin" >"$out_dir/run.log" 2>&1; then ok=0; log="$out_dir/run.log"; fi
      fi
    else
      printf '  %sFAIL%s %s (no tests/test_%s.c or .sh)\n' "$R" "$N" "$ex" "$ex"; fail=$((fail + 1)); failed_list+=("$topic/$ex"); continue
    fi
    if [[ $ok -eq 1 ]]; then
      printf '  %sPASS%s %s\n' "$G" "$N" "$ex"; pass=$((pass + 1))
    else
      printf '  %sFAIL%s %s\n' "$R" "$N" "$ex"; fail=$((fail + 1)); failed_list+=("$topic/$ex")
      sed 's/^/      /' "$log" | tail -n 60
    fi
  done
done

printf '\n%sSummary:%s %s%d passed%s, %s%d failed%s, %s%d skipped%s\n' "$B" "$N" "$G" "$pass" "$N" "$R" "$fail" "$N" "$Y" "$skip" "$N"
if [[ $fail -gt 0 ]]; then
  printf 'Failed: %s\n' "${failed_list[*]}"
  exit 1
fi
exit 0
