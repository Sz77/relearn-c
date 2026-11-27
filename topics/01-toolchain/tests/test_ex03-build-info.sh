#!/usr/bin/env bash
# Program test for ex03-build-info. $1 is the path to the compiled binary.
# The binary is built with -std=c17 -O0 and without -DNDEBUG.
set -euo pipefail

bin="$1"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

failures=0

# check NAME EXPECTED_STATUS EXPECTED_STDOUT EXPECTED_STDERR -- ARGS...
check() {
  local name="$1" want_status="$2" want_out="$3" want_err="$4"
  shift 5
  local status=0
  "$bin" "$@" </dev/null >"$tmp/out" 2>"$tmp/err" || status=$?
  local got_out got_err
  got_out="$(cat "$tmp/out"; printf x)"
  got_out="${got_out%x}"
  got_err="$(cat "$tmp/err"; printf x)"
  got_err="${got_err%x}"
  if [[ "$status" != "$want_status" ]]; then
    printf 'FAIL %s: exit status: expected %s, got %s\n' "$name" "$want_status" "$status"
    failures=$((failures + 1))
  fi
  if [[ "$got_out" != "$want_out" ]]; then
    printf 'FAIL %s: stdout:\n  expected: %q\n  got:      %q\n' "$name" "$want_out" "$got_out"
    failures=$((failures + 1))
  fi
  if [[ "$got_err" != "$want_err" ]]; then
    printf 'FAIL %s: stderr:\n  expected: %q\n  got:      %q\n' "$name" "$want_err" "$got_err"
    failures=$((failures + 1))
  fi
}

nl=$'\n'
all="c_standard=201710${nl}stdc=1${nl}hosted=1${nl}optimized=no${nl}asserts=on${nl}"
usage="usage: build-info [KEY]${nl}"

# 1. no arguments: everything
check "no arguments lists all facts" 0 "$all" "" --

# 2. one known key: just the value
check "key c_standard" 0 "201710${nl}" "" -- c_standard
check "key stdc" 0 "1${nl}" "" -- stdc
check "key hosted" 0 "1${nl}" "" -- hosted
check "key optimized" 0 "no${nl}" "" -- optimized
check "key asserts" 0 "on${nl}" "" -- asserts

# 3. one unknown key: error on stderr, status 2
check "unknown key" 2 "" "build-info: unknown key 'colour'${nl}" -- colour
check "empty key" 2 "" "build-info: unknown key ''${nl}" -- ""
check "keys are case-sensitive" 2 "" "build-info: unknown key 'HOSTED'${nl}" -- HOSTED
check "prefix of a key is not a key" 2 "" "build-info: unknown key 'host'${nl}" -- host
check "one-letter prefix is not a key" 2 "" "build-info: unknown key 'c'${nl}" -- c
check "key plus suffix is not a key" 2 "" "build-info: unknown key 'hosted='${nl}" -- hosted=
check "key with trailing space is not a key" 2 "" "build-info: unknown key 'asserts '${nl}" -- "asserts "
check "whole line is not a key" 2 "" "build-info: unknown key 'optimized=no'${nl}" -- optimized=no
long_key="$(printf 'k%.0s' {1..300})"
check "very long unknown key" 2 "" "build-info: unknown key '${long_key}'${nl}" -- "$long_key"

# 4. too many arguments: usage, status 1 (even if both are valid keys)
check "two valid keys" 1 "" "$usage" -- hosted stdc
check "two unknown keys" 1 "" "$usage" -- a b
check "three arguments" 1 "" "$usage" -- a b c

# stdout must be flushed when it is a pipe (fully buffered), not a terminal.
piped="$("$bin" 2>/dev/null </dev/null | cat)" || true
if [[ "$piped$nl" != "$all" ]]; then
  printf 'FAIL piped stdout:\n  expected: %q\n  got:      %q\n' "$all" "$piped$nl"
  failures=$((failures + 1))
fi

if [[ $failures -gt 0 ]]; then
  printf '%d check(s) failed\n' "$failures"
  exit 1
fi
echo "all checks passed"
