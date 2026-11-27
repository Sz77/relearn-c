#!/usr/bin/env bash
# One-time setup after a fresh clone: ./setup.sh
# Installs the toolchain, installs git hooks, and runs a self-check. Safe to re-run.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

say() { printf '\n\033[1;36m==> %s\033[0m\n' "$*"; }
have() { command -v "$1" >/dev/null 2>&1; }
SUDO=""
[[ $EUID -ne 0 ]] && SUDO="sudo"

say "Installing system packages (compilers, sanitizers, cppcheck, node, gh)"
if have dnf; then
  $SUDO dnf install -y gcc clang make cppcheck libasan libubsan git gh nodejs python3 gdb
elif have apt-get; then
  $SUDO apt-get update
  $SUDO apt-get install -y gcc clang make cppcheck git gh nodejs npm python3 python3-venv pipx gdb
elif have pacman; then
  $SUDO pacman -S --needed --noconfirm gcc clang make cppcheck git github-cli nodejs npm python python-pipx gdb
else
  echo "Unsupported package manager. Install manually: gcc clang make cppcheck git gh nodejs python3, then re-run." >&2
fi

say "Installing pre-commit"
if have pre-commit; then
  echo "pre-commit already installed: $(pre-commit --version)"
elif have uv; then
  uv tool install pre-commit
elif have pipx; then
  pipx install pre-commit
else
  python3 -m pip install --user pre-commit
fi
export PATH="$HOME/.local/bin:$PATH"

say "Installing git hooks (format, lint, Conventional Commits)"
pre-commit install --install-hooks

say "Self-check: compile examples, starters, run tests (gcc and clang, with sanitizers)"
make examples
make starters
make test
CC=clang make test

if have gh && ! gh auth status >/dev/null 2>&1; then
  echo
  echo "Note: GitHub CLI is not logged in. Run: gh auth login"
fi

cat <<'EOF'

Setup complete.

Start working:
  1. Open curriculum/ROADMAP.md and find the topic marked 🟡 in progress (say NN-name).
  2. git switch main && git pull
  3. git switch -c solve/NN-name
  4. make start T=NN          # copies the starter files into topics/NN-name/solutions/
  5. Read topics/NN-name/README.md, solve the exercises, run: make test T=NN
  6. git add -A && git commit -m "feat(topic-NN): solve exercise 1"
  7. make submit               # pushes and opens the PR; the review agent reviews it

Run `make help` to see every command.
EOF
