#!/usr/bin/env bash
# Program test for ex01-hello-streams. $1 is the path to the compiled binary.
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

check "no arguments" 0 "Hello, toolchain!${nl}" "hello: done${nl}" --
check "one argument" 1 "" "usage: hello${nl}" -- x
check "three arguments" 1 "" "usage: hello${nl}" -- a b c
check "empty-string argument" 1 "" "usage: hello${nl}" -- ""
check "argument that looks like a flag" 1 "" "usage: hello${nl}" -- --help

# stdout must be flushed even when it is a pipe (fully buffered), not a terminal.
piped="$("$bin" 2>/dev/null </dev/null | cat)" || true
if [[ "$piped" != "Hello, toolchain!" ]]; then
  printf 'FAIL piped stdout: expected %q, got %q\n' "Hello, toolchain!" "$piped"
  failures=$((failures + 1))
fi

if [[ $failures -gt 0 ]]; then
  printf '%d check(s) failed\n' "$failures"
  exit 1
fi
echo "all checks passed"
