# Remaining Architecture Cleanup Prompt

Execute the remaining architecture cleanup from `.planning/ARCHITECTURE_ANALYSIS.md`.

## Scope

1. Investigate whether `BookMarketDataDao` and `PriceButtonConfigDao` can be removed safely.
   - Check table declarations, `AppDatabase` registration, migrations, generated `.g.dart`, tests, and schema impact.
   - If removing tables requires a DB migration/schema version bump or generated Drift changes, do not delete blindly. Either implement the migration correctly or leave a documented follow-up.

2. Remove dead tested utilities or migrate tests away from them.
   - `lib/features/auth/email_masking.dart`
   - `lib/features/analyzer/flip_factor.dart`
   - `lib/services/sync/cloud_photo_paths.dart`
   - If a test exists only to preserve dead code, delete that test with the dead file.
   - If the concept is still valid, migrate tests to the replacement utility (e.g. `FlipScore`).

3. Localize hardcoded Swedish strings in:
   - `lib/features/analyzer/item_detail_screen.dart`
   - `lib/features/hauls/haul_screen.dart`
   - `lib/features/books/finds_screen.dart`
   - `lib/features/dashboard/dashboard_screen.dart`

   Rules:
   - Add every user-facing string to both `lib/l10n/app_en.arb` and `lib/l10n/app_sv.arb` in the same change.
   - Use natural English and Swedish translations.
   - Keep placeholder names stable and descriptive.
   - Regenerate localizations if required.

## Verification

- `flutter gen-l10n` if ARB changed.
- `dart analyze lib test`.
- Relevant tests for moved/deleted utilities and l10n compile.
- `flutter build apk --debug --flavor dev --no-pub`.

## Expected Output

Return:
- What was deleted.
- What was intentionally not deleted and why.
- New localization keys added.
- Verification results.
