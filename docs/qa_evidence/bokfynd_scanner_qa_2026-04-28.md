# BokFynd scanner QA evidence - 2026-04-28

Status: blocked before manual execution  
Target requested: Android device or Android emulator  
QA plan: `docs/bokfynd_scanner_qa_plan.md`

## Summary

The BokFynd scanner manual QA checklist was not executed because no usable Android device or emulator was available from this session.

This is a valid stop condition. The QA plan explicitly says not to proceed to live-device testing until the target environment is stable. Running the checklist on macOS desktop would not satisfy the Android scanner requirement and would not exercise the camera/ML Kit target path.

## Device discovery

Command:

```sh
flutter devices
```

Result:

- `macOS (desktop)` was the only connected Flutter device.
- No Android device was connected.
- No wireless devices were found.

Command:

```sh
adb devices
```

Result:

- ADB daemon started successfully after escalation.
- Device list was empty.

Command:

```sh
flutter emulators
```

Result:

- Android AVD available: `rorbevis_api35`
- iOS simulator also available.

## Android emulator launch attempt

Command:

```sh
flutter emulators --launch rorbevis_api35
```

Result:

- Emulator startup failed with exit code `1`.
- Flutter did not provide a detailed failure cause.

Command:

```sh
/opt/homebrew/share/android-commandlinetools/emulator/emulator -avd rorbevis_api35 -no-window -no-audio -gpu swiftshader_indirect -no-snapshot
```

Result:

```text
FATAL | CPU Architecture 'arm' is not supported by the QEMU2 emulator, (the classic engine is deprecated!)
```

Conclusion:

- The available AVD is not usable in this environment.
- The current Android emulator image must be replaced with a supported image before manual QA can run.

## Checklist execution status

| QA item | Status | Evidence |
| --- | --- | --- |
| Normal scanner tab remains unchanged | Not executed | No Android target |
| Draft editor opens opt-in scanner route | Not executed manually | Covered by widget test, but not manual Android QA |
| Success path | Not executed | No Android target and no stable fake lookup session attached |
| Not-found path | Not executed | No Android target |
| Error path | Not executed | No Android target |
| Duplicate scan suppression | Not executed manually | Covered by controller test, but not manual Android QA |
| Multiple barcodes visible | Not executed | No Android target |
| Back to draft action | Not executed manually | Snackbar behavior covered by state mapping, but not manual Android QA |

## Existing automated coverage remains green

Before this manual attempt, the BokFynd draft/scanner/service slice was green:

- `flutter test --no-pub ...`: 69 tests passed.
- Focused analyzer checks passed.
- Localization generation passed.

This does not replace Android manual QA. It only confirms the current source state did not have known controller/service/widget regressions before the device blocker.

## Decision

Do not attempt a live camera/device scanner test yet.

Next required action:

1. Create or install a supported Android emulator image for the host architecture.
2. Re-run `flutter devices` and confirm an Android target is connected.
3. Run the app against that target with stable ISBN lookup data.
4. Execute `docs/bokfynd_scanner_qa_plan.md`.
5. Record pass/fail evidence in a new dated note.

Recommended emulator fix:

- Use an Android API 35 or API 36 Google APIs image compatible with the current Apple Silicon host.
- Confirm the AVD boots before running LoppisFynd.

## Live camera test decision

Live camera/device testing is not approved from this evidence note.

Reason:

- No usable Android device or emulator was available.
- The manual checklist was not executed.
- The available AVD is blocked by unsupported CPU architecture.

## Follow-up: Android AVD recreated

Status: Android emulator target ready; manual checklist still pending  
Time: later on 2026-04-28

The broken `rorbevis_api35` AVD was not deleted. A new compatible AVD was created instead:

```sh
/opt/homebrew/share/android-commandlinetools/cmdline-tools/latest/bin/avdmanager create avd --force --name bokfynd_api35_arm64 --package "system-images;android-35;google_apis;arm64-v8a" --device "pixel_6"
```

Result:

- New AVD: `bokfynd_api35_arm64`
- Target: Android 15 API 35
- ABI: `google_apis/arm64-v8a`
- Device profile: `pixel_6`

Flutter now lists the emulator:

```text
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 15 (API 35) (emulator)
```

ADB boot checks:

```text
sys.boot_completed = 1
ro.product.cpu.abi = arm64-v8a
```

The app dev flavor was built, installed, and launched once:

```sh
flutter run -d emulator-5554 --debug --no-pub --flavor dev
```

Result:

- Built `build/app/outputs/flutter-apk/app-dev-debug.apk`.
- Installed package `se.fyndloppis.fynd_loppis.dev`.
- App process launched successfully during `flutter run`.
- Host `flutter run` was then terminated to avoid leaving an attached runner open.

Package install evidence:

```text
package:se.fyndloppis.fynd_loppis.dev
```

## Updated checklist execution status

| QA item | Status | Evidence |
| --- | --- | --- |
| Android target availability | Pass | `bokfynd_api35_arm64`, `emulator-5554`, Android 15 API 35, arm64-v8a |
| Dev app install/launch | Pass | `app-dev-debug.apk` installed as `se.fyndloppis.fynd_loppis.dev` |
| Normal scanner tab remains unchanged | Pending manual execution | Requires interactive UI/camera session |
| Draft editor opens opt-in scanner route | Pending manual execution | Widget-covered, not manually verified on emulator |
| Success path | Pending manual execution | Requires stable fake ISBN lookup data or controlled network |
| Not-found path | Pending manual execution | Requires stable fake ISBN lookup data or controlled network |
| Error path | Pending manual execution | Requires controlled failing lookup/orchestration setup |
| Duplicate scan suppression | Pending manual execution | Controller-covered, not manually verified on emulator |
| Multiple barcodes visible | Pending manual execution | Requires interactive scanner/camera setup |
| Back to draft action | Pending manual execution | Snackbar mapping covered, not manually verified on emulator |

## Updated decision

Do not attempt a live camera/device scanner test yet.

Reason:

- The Android emulator has been fixed and the dev app can install/launch.
- The manual QA checklist still has not been executed.
- Stable fake ISBN lookup data is not available as a runtime app mode.
- This session does not provide an interactive manual camera/scanner path.

Next required action:

1. Add or configure stable ISBN lookup data for manual QA, or choose a controlled network setup.
2. Use the `bokfynd_api35_arm64` emulator or a physical Android device.
3. Execute `docs/bokfynd_scanner_qa_plan.md` interactively.
4. Record pass/fail evidence in a new dated note.
5. Only then decide whether to attempt a live camera/device scanner test.

## Follow-up: dev-only stable ISBN lookup seam

Status: stable lookup data available; Android dev launch rerun complete  
Time: later on 2026-04-28

A dev-only runtime seam was added for predictable BokFynd ISBN lookup data:

```sh
flutter run -d emulator-5554 --debug --no-pub --flavor dev \
  --dart-define=APP_ENV=dev \
  --dart-define=BOKFYND_QA_STABLE_ISBN_DATA=true
```

Stable ISBN data:

| Path | ISBN | Expected lookup result |
| --- | --- | --- |
| Success | `9780306406157` | `BokFynd QA Stable Book` from `qa_stable` |
| Not found | `9780143127796` | `null` metadata |
| Error | `0306406152` | controlled `StateError` |

The seam is restricted to `APP_ENV=dev`. Setting
`BOKFYND_QA_STABLE_ISBN_DATA=true` in `APP_ENV=prod` keeps the normal ISBN
lookup provider.

Automated coverage added:

- `test/services_books/qa_isbn_lookup_service_test.dart`
- provider coverage proving the seam is dev-only

Updated checklist execution status:

| QA item | Status | Evidence |
| --- | --- | --- |
| Stable ISBN lookup data | Pass | dev-only `BOKFYND_QA_STABLE_ISBN_DATA=true` seam |
| Android target availability | Pass | `bokfynd_api35_arm64`, Android 15 API 35, arm64-v8a |
| Normal scanner tab remains unchanged | Pending manual execution | Requires interactive UI/camera session |
| Draft editor opens opt-in scanner route | Pending manual execution | Widget-covered, not manually verified on emulator |
| Success path | Pending manual execution | Stable ISBN now available: `9780306406157` |
| Not-found path | Pending manual execution | Stable ISBN now available: `9780143127796` |
| Error path | Pending manual execution | Stable ISBN now available: `0306406152` |
| Duplicate scan suppression | Pending manual execution | Controller-covered, not manually verified on emulator |
| Multiple barcodes visible | Pending manual execution | Requires interactive scanner/camera setup |
| Back to draft action | Pending manual execution | Snackbar mapping covered, not manually verified on emulator |

## Follow-up: Android dev launch with stable ISBN data

Status: Android runtime seam verified; interactive manual checklist still pending  
Time: later on 2026-04-28

The `bokfynd_api35_arm64` emulator was booted again and Flutter detected it:

```text
sdk gphone64 arm64 (mobile) • emulator-5554 • android-arm64 • Android 15 (API 35) (emulator)
```

ADB boot check:

```text
sys.boot_completed = 1
```

The app was built, installed, and launched with the stable QA ISBN lookup mode:

```sh
flutter run -d emulator-5554 --debug --no-pub --flavor dev \
  --dart-define=APP_ENV=dev \
  --dart-define=BOKFYND_QA_STABLE_ISBN_DATA=true
```

Result:

- Built `build/app/outputs/flutter-apk/app-dev-debug.apk`.
- Installed package `se.fyndloppis.fynd_loppis.dev`.
- App process launched and Flutter attached successfully.
- Dart defines included `APP_ENV=dev` and `BOKFYND_QA_STABLE_ISBN_DATA=true`.
- Host `flutter run` was stopped after launch evidence was captured.

Package install evidence:

```text
package:se.fyndloppis.fynd_loppis.dev
```

Final checklist status for this session:

| QA item | Status | Evidence |
| --- | --- | --- |
| Android target availability | Pass | `bokfynd_api35_arm64`, Android 15 API 35, arm64-v8a |
| Dev app install/launch with stable ISBN data | Pass | launched with `BOKFYND_QA_STABLE_ISBN_DATA=true` |
| Stable success ISBN | Ready for manual QA | `9780306406157` |
| Stable not-found ISBN | Ready for manual QA | `9780143127796` |
| Stable error ISBN | Ready for manual QA | `0306406152` |
| Normal scanner tab remains unchanged | Pending manual execution | Requires interactive UI/camera session |
| Draft editor opens opt-in scanner route | Pending manual execution | Widget-covered, not manually verified on emulator |
| Success path | Pending manual execution | Runtime data ready; scan/manual interaction not executed from this headless session |
| Not-found path | Pending manual execution | Runtime data ready; scan/manual interaction not executed from this headless session |
| Error path | Pending manual execution | Runtime data ready; scan/manual interaction not executed from this headless session |
| Duplicate scan suppression | Pending manual execution | Controller-covered, not manually verified on emulator |
| Multiple barcodes visible | Pending manual execution | Requires interactive scanner/camera setup |
| Back to draft action | Pending manual execution | Snackbar mapping covered, not manually verified on emulator |

Decision:

- The dev-only stable ISBN data seam is ready for interactive manual QA.
- The Android emulator and dev flavor launch path are working.
- Do not claim the manual scanner checklist as passed yet; this session verified runtime readiness, not a live interactive camera/manual run.
