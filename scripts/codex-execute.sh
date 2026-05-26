#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  printf 'Usage: %s \"Implement Phase 1 of <feature>\"\\n' "$0" >&2
  exit 2
fi

codex exec --profile fullAuto "$*"
