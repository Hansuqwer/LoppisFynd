#!/usr/bin/env bash
set -euo pipefail

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  printf 'Not inside a git repository; cannot review staged diff.\n' >&2
  exit 1
fi

codex exec --profile flutter --sandbox read-only --ask-for-approval never \
  "Review the staged diff. Focus on Riverpod misuse, missing null safety, hardcoded strings that should be in ARB, missing tests for new providers or screens, and architecture violations such as upward imports. Output a numbered list of findings with severity. If there are no findings, say so clearly."
