# relearn-c — every command you need. Run `make help`.
#
# Strict flags everywhere: -std=c17 -Wall -Wextra -Werror -pedantic (+ a few more).
# Tests run as debug builds with AddressSanitizer + UndefinedBehaviorSanitizer.

ifeq ($(origin CC),default)
CC = gcc
endif
export CC
T ?=

.DEFAULT_GOAL := help
.PHONY: help test test-all examples starters lint format check start submit clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36mmake %-10s\033[0m %s\n", $$1, $$2}'
	@echo ""
	@echo "  Variables: T=01 (limit to a topic), CC=clang, SAN=0 (no sanitizers)"

test: ## Run tests for every exercise that has a solution (T=01 for one topic)
	@scripts/run-tests.sh $(T)

test-all: ## Like test, but a missing solution counts as a failure
	@scripts/run-tests.sh --require-solutions $(T)

examples: ## Compile all topic examples with the strict flags
	@scripts/build-examples.sh $(T)

starters: ## Check that all starter files compile against their tests
	@scripts/run-tests.sh --starters --compile-only $(T)

lint: ## Run every pre-commit hook (format, clang-tidy, cppcheck, ...) on all files
	@pre-commit run --all-files

format: ## Auto-format all C files with clang-format
	@pre-commit run clang-format --all-files || true

check: examples starters test lint ## Everything CI runs

start: ## Copy starter files into solutions/ for topic T (e.g. make start T=01)
	@test -n "$(T)" || { echo "usage: make start T=01"; exit 1; }
	@scripts/start-topic.sh $(T)

submit: ## Push your solve/NN-name branch and open the PR for review
	@scripts/submit.sh

clean: ## Remove build output
	rm -rf build
