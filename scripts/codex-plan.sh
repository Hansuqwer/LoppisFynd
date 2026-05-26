#!/usr/bin/env bash
set -euo pipefail

prompt="${*:-Create an implementation plan for the current task. Do not edit files.}"
codex exec --profile plan --sandbox read-only --ask-for-approval never "$prompt"
