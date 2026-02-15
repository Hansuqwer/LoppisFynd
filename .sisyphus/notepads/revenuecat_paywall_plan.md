# RevenueCat paywall plan (EPIC 17)

Goal (roadmap): monetization that is compliant, reversible, and does not block the core loop for free users.

## Product rules (v1 defaults)

- Free tier
  - Scans: limited per day (local AI inference) OR limited “comps fetch” per day (online cost center)
  - Export: locked (CSV/JSON)
  - Advanced analytics: locked (keep basic totals and history)
- Pro subscription
  - Unlimited scans
  - Export enabled
  - Advanced analytics enabled

Paywall triggers:
- On scan attempt after daily limit
- On export attempt
- On opening advanced analytics entry points

Restore purchases:
- Profile/Settings: "Restore purchases" button

## Where to gate (current repo)

Existing feature flag pattern:
- `lib/core/config/feature_flags.dart` (FF_DISABLE_* for sync/market/ai/analytics)
- `lib/core/app/providers.dart` is the central place to add new Riverpod providers

Practical gate points:
- Export: `lib/features/settings/privacy_screen.dart` (uses `DataExportService`)
- Market comps: `lib/services/sync/sync_scheduler.dart` (calls `_market.fetchComps`) and `lib/features/analyzer/item_detail_screen.dart`
- AI scans: `lib/features/scanner/scan_capture_service.dart` (creation of items) + `lib/services/ai/inference/inference_isolate_service.dart` (inference calls)

## RevenueCat integration (implementation outline)

Dependencies:
- `purchases_flutter` (RevenueCat SDK)
- Optional: `purchases_ui_flutter` (RevenueCatUI paywalls)

Runtime config (suggested `--dart-define` keys):
- `REVENUECAT_ANDROID_API_KEY`
- `REVENUECAT_IOS_API_KEY`
- `REVENUECAT_ENTITLEMENT_ID` (e.g. `pro`)

Service + provider:
- Add a thin wrapper `RevenueCatService` (init, customerInfo stream, restore, logIn/logOut)
- Add `proEntitlementProvider` (Stream/State provider) in `lib/core/app/providers.dart`
- Gate helpers:
  - `isProProvider`
  - `canExportProvider`
  - `canScanUnlimitedProvider`
  - `canUseAdvancedAnalyticsProvider`

Auth linking:
- When Supabase user is present, call `Purchases.logIn(userId)`
- On sign-out, call `Purchases.logOut()`
- Use the Supabase `user.id` only (no email/PII)

Offline-first:
- RevenueCat caches `CustomerInfo`; when offline, use cached entitlements
- Also persist the last-known entitlement active flag in `AppSettings` as a fallback for UI gating

UI integration:
- If using `purchases_ui_flutter`, present paywall via RevenueCatUI at trigger points
- Provide a non-blocking upsell sheet (BentoCard style) before showing the paywall

Platform notes:
- Android: ensure Play Billing is available; RevenueCatUI may require `MainActivity` to extend `FlutterFragmentActivity` instead of `FlutterActivity`
  - Current file: `android/app/src/main/kotlin/se/fyndloppis/fynd_loppis/MainActivity.kt`

## Daily limits (implementation choices)

Option A (cheapest to ship): gate *comps fetch* using existing daily quota.
- Existing code already tracks daily market calls in `sync_quotas` via `SyncScheduler.maxCallsPerDay`
- Free tier can lower `maxCallsPerDay` and/or require Pro to fetch comps

Option B (matches roadmap wording): gate *scans per day*.
- Add a `scan_quotas` table (or reuse `AppSettings`) keyed by day; increment in `ScanCaptureService`
- If user is Pro, bypass

## Local LLM preinstall requirement (your note)

Current behavior:
- Model downloads best-effort at startup from `GEMMA_MODEL_URL` (see `lib/main.dart`, `lib/services/ai/model_manager.dart`)

If you want the model to be present immediately after install (no post-install download):
- Recommended for Play: use an install-time asset delivery mechanism (Android Play Asset Delivery) so the model is delivered with the Play install, without bundling it into the base module.
- Simpler but risky for size: bundle the model as a Flutter asset and copy it into the app support directory on first run.

Important: we should NOT commit the model file into git; treat it as a build artifact.
