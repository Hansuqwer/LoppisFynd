#!/usr/bin/env bash
set -euo pipefail

prompt="${*:-Brainstorm options for the current task. Compare tradeoffs and recommend one path. Do not edit files.}"
codex exec --profile ask --sandbox read-only --ask-for-approval never "$prompt"
