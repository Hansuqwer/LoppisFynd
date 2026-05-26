Flutter mobile app (iOS + Android) for the Swedish market.

## Architecture (Enforced)

Use these layers:

- `lib/presentation/`: widgets and screens.
- `lib/application/`: Riverpod providers, view models, and use cases.
- `lib/domain/`: entities, value objects, and abstract repositories. Pure Dart only.
- `lib/infrastructure/`: concrete repositories, API clients, and platform code.

Dependency direction is `presentation -> application -> domain`. Infrastructure implements domain contracts. No upward imports.

## Build, Test, And Lint

- `fvm flutter pub get`
- `fvm dart run build_runner build --delete-conflicting-outputs`
- `fvm dart format .`
- `fvm flutter analyze`
- `fvm flutter test`
- `fvm flutter test test/path/to/file_test.dart`

## Codex Workflows

- `/plan`: use Codex built-in plan mode for read-only planning.
- `/brainstorm`: use the repo `brainstorm` skill for read-only options and tradeoffs.
- `/review`: use Codex built-in review mode or `scripts/codex-review.sh`.
- `/execute fullAuto`: use the `fullAuto` profile for repo-local implementation only.
- `/FullAutoApproval`: use the `FullAutoApproval` profile for one approved repo-local phase.
- `/refactor`: use the repo `refactor` skill for behavior-preserving refactors.

Full-auto workflows may write only inside this repository by default. Commits, PR creation, package installs, and dependency changes are allowed when the agent first preserves a clear revert path. Stop before secrets, native iOS/Android signing or app identity config, `.github/workflows/`, destructive commands, pushes to `main`, merges, or outside-repo source writes.

Revertability requirement: before dependency changes, commits, package installs, or PR creation, capture the current state (`git status`, branch name, and relevant diff). Prefer feature branches and small commits. Report exactly how to revert the operation.

## Localization

Every user-facing string must be added to both `lib/l10n/app_en.arb` and `lib/l10n/app_sv.arb` in the same change.

Use `[[TRANSLATE]]` in Swedish copy only when final Swedish wording is not ready, but the key must still exist.

## Definition Of Done

- `flutter analyze` has zero issues.
- Tests pass.
- New screens have widget tests rendered in English and Swedish.
- New providers have unit tests.
- ARB entries exist in both locales.
- PR body has a summary, screenshots or recording for UI changes, and a test plan.

## Sensitive Paths

Do not read or write:

- `**/.env`
- `**/.env.*`
- `**/secrets/**`
- `**/*.p8`
- `**/*.mobileprovision`
- `android/key.properties`
- `android/keystore/**`
- `ios/Runner/GoogleService-Info-Prod.plist`
- `android/app/google-services-prod.json`
