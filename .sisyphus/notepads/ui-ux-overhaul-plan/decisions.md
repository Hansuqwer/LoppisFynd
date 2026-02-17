## Decisions

- Sync controls are hidden for normal users and visible only in existing Dev Mode.
- Use existing `GEMMA_MODEL_URL` (`AppConfig.gemmaModelUrl`) for on-device model download.
- Model storage stays cross-platform via `path_provider` app-support `models/`.
- Gated model management controls (download, install from path, delete) behind `_devModeEnabled` in Settings. Normal users only see status (installed/not installed). Rationale: Prevent normal users from breaking the app state or downloading large files unnecessarily; Dev Mode is the appropriate place for power user controls.

## Scanner Overlay Tokenization
- Replaced hardcoded `Colors.black.withValues(alpha: 0.58)` in scanner guidance with `AppColors.inkDeep.withValues(alpha: 0.58)` to align with the dark ink theme.
- Replaced `Colors.white.withValues(alpha: 0.12)` border with `AppColors.textOnDark.withValues(alpha: 0.12)` for consistency.
- Replaced `Colors.white` text with `AppColors.textOnDark` (which maps to `cloudDancer` off-white) for softer contrast.
- Replaced `Colors.black.withValues(alpha: 0.42)` in scanner overlay scrim with `AppColors.inkDeep.withValues(alpha: 0.42)`.
