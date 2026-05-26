#!/usr/bin/env bash
set -euo pipefail

if [[ $# -eq 0 ]]; then
  printf 'Usage: %s \"Refactor <area> without behavior changes\"\\n' "$0" >&2
  exit 2
fi

codex exec --profile flutter "$*"
