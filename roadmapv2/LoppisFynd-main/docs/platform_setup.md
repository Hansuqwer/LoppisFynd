# Platform setup (background sync + notifications)

This app uses:
- `workmanager` for periodic background work (market sync)
- `flutter_local_notifications` for local notifications when sync finishes

## Android

Already configured in this repo:
- `compileSdk = 36`: `android/app/build.gradle.kts`
- core library desugaring enabled + `desugar_jdk_libs`: `android/app/build.gradle.kts`
- `POST_NOTIFICATIONS` permission: `android/app/src/main/AndroidManifest.xml`

Runtime permission:
- On Android 13+ the app prompts for notifications permission when `TRADERA_PROXY_URL` is configured (see `lib/main.dart`).

## iOS

Already configured in this repo:
- Background fetch declared in Info.plist: `ios/Runner/Info.plist`
- Notification center delegate set: `ios/Runner/AppDelegate.swift`

Manual Xcode setup (required):
1) Open `ios/Runner.xcworkspace` in Xcode
2) Runner target -> Signing & Capabilities
3) Add capability: `Background Modes`
4) Enable: `Background fetch`

Notes:
- iOS decides actual run frequency; 6h is best-effort.
