# Handoff 2026-02-15 (Play foundations)

Roadmap reference: `docs/roadmap_refactored(1).md` (EPIC 0: tooling & environments).

## What changed

### Android flavors
- Added product flavors: `dev`, `staging`, `prod`.
- `dev`/`staging` use `applicationIdSuffix` + `versionNameSuffix`; `prod` is the default.

File:
- `android/app/build.gradle.kts`

### Android release signing (optional)
- Release builds use `android/key.properties` if present; otherwise they fall back to the debug keystore.
- `android/key.properties` and `android/app/*.jks` are ignored via `.gitignore`.

Files:
- `android/app/build.gradle.kts`
- `.gitignore`

### R8 / MediaPipe missing classes fix
- `flutter build appbundle --flavor staging --release` initially failed with R8 missing-class errors for MediaPipe proto types.
- Added a Proguard rules file with the generated `-dontwarn` entries.

Files:
- `android/app/proguard-rules.pro`
- `android/app/build.gradle.kts`

### CI
- Added GitHub Actions workflow to run `flutter analyze`, `flutter test`, and build a staging AAB.
- Flutter SDK is pinned to the repo's `.metadata` revision.
- Optional Android signing via GitHub secrets.

File:
- `.github/workflows/ci.yml`

### Docs
- Play/release notes are documented in `docs/release_playstore.md` and linked from `README.md`.

## How to use

Build staging AAB locally:

```bash
flutter build appbundle --flavor staging --release
```

## Verification
- `flutter analyze`: clean
- `flutter test`: passing
- `flutter build appbundle --flavor staging --release`: success

## Notes
- iOS flavors/schemes are not set up yet (this work focused on Google Play foundations).
