#!/usr/bin/env bash
set -euo pipefail

codex exec --profile fullAuto \
  "Run fvm flutter test. If it fails, analyze the failure and fix the underlying production code rather than weakening tests. Re-run the tests. Loop up to 3 times total. Stop and report clearly if unresolved."
