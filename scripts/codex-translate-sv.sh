#!/usr/bin/env bash
set -euo pipefail

codex exec --profile fullAuto \
  "Find all [[TRANSLATE]] markers in lib/l10n/app_sv.arb. Translate them to natural sv-SE Swedish suitable for app UI. Preserve placeholders and ICU plurals exactly. Then run fvm flutter gen-l10n. Do not touch unrelated strings."
