// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabHome => 'Home';

  @override
  String get tabScan => 'Scan';

  @override
  String get tabHaul => 'Haul';

  @override
  String get tabHistory => 'History';

  @override
  String get tabProfile => 'Profile';

  @override
  String get appTitle => 'Loppisfynd';

  @override
  String snackbarSavedScan(Object id) {
    return 'Saved scan $id.';
  }

  @override
  String snackbarCaptureFailed(Object error) {
    return 'Capture failed: $error';
  }

  @override
  String get snackbarCopiedBarcode => 'Copied barcode to clipboard.';

  @override
  String get settingsAccessibility => 'Accessibility';

  @override
  String get settingsHighContrast => 'High contrast';

  @override
  String get settingsContrastUpdated => 'Updated contrast setting.';

  @override
  String get onboardingWelcomeTitle => 'Welcome';

  @override
  String get onboardingWelcomeBody =>
      'Scan items in-store, save offline, and fetch sold-price comps when you’re online.';

  @override
  String get onboardingPermissionsTitle => 'Permissions';

  @override
  String get onboardingPermissionsBody =>
      'Camera is required for scanning. Location is optional and only used to name hauls on the map.';

  @override
  String get onboardingOfflineTitle => 'Offline-first';

  @override
  String get onboardingOfflineBody =>
      'Everything works without internet except price fetch. Your data stays on-device unless you enable cloud sync.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get onboardingStart => 'Start';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get bannerOffline => 'Offline mode: price fetch is paused.';

  @override
  String get buttonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonInstall => 'Install';

  @override
  String get commonOff => 'Off';

  @override
  String get commonHaul => 'Haul';

  @override
  String get errorCameraTitle => 'Camera error';

  @override
  String get historyEmptyTitle => 'No hauls yet';

  @override
  String get historyEmptyMessage =>
      'Create a haul to start tracking your finds.';

  @override
  String get historyTreasureMapTitle => 'Treasure Map';

  @override
  String get historyHistoryTitle => 'History';

  @override
  String get historyNewHaulTitle => 'New haul';

  @override
  String get historyHaulTitleLabel => 'Title';

  @override
  String get historySuggestNameTooltip => 'Suggest name';

  @override
  String get historyEnterLatLngFirst => 'Enter latitude + longitude first.';

  @override
  String get historyHaulLatitudeOptionalLabel => 'Latitude (optional)';

  @override
  String get historyHaulLongitudeOptionalLabel => 'Longitude (optional)';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterProfit => 'Profit';

  @override
  String get historyFilterLoss => 'Loss';

  @override
  String historyPinnedHaulsCount(Object count) {
    return '$count pinned hauls';
  }

  @override
  String get historyNoPinnedHaulsYet => 'No pinned hauls yet.';

  @override
  String get dashboardTitle => 'Hunter Dashboard';

  @override
  String get dashboardSubtitle => 'Market pulse + recent hauls.';

  @override
  String get dashboardQuickScan => 'Quick Scan';

  @override
  String get dashboardHaulSummary => 'Haul Summary';

  @override
  String get scannerTitle => 'Rapid-Fire Scanner';

  @override
  String get scannerSubtitle => 'Capture, store, thumbnail, and queue comps.';

  @override
  String get scannerCapture => 'Capture';

  @override
  String get scannerSaving => 'Saving…';

  @override
  String get scannerDoneScanning => 'Done scanning';

  @override
  String scannerQueuedItems(Object count) {
    return 'Queued $count item(s) for sync.';
  }

  @override
  String scannerQueueFailed(Object error) {
    return 'Queue failed: $error';
  }

  @override
  String get scannerNoCamerasAvailable =>
      'No cameras available on this device.';

  @override
  String scannerCameraInitFailed(Object error) {
    return 'Failed to initialize camera: $error';
  }

  @override
  String get scannerBarcodeAimHint => 'Aim at a barcode to detect instantly.';

  @override
  String get scannerNoScansYet => 'No scans yet.';

  @override
  String get scannerBatchTrayTitle => 'Batch tray';

  @override
  String get haulTitle => 'Current haul';

  @override
  String get haulSubtitle =>
      'Offline-first. Add items while scanning, then sync comps when online.';

  @override
  String get haulItems => 'Items';

  @override
  String get haulReady => 'Ready';

  @override
  String get haulExpected => 'Expected';

  @override
  String get haulNetEst => 'Net (est.)';

  @override
  String get haulOpenSummary => 'Open haul summary';

  @override
  String get settingsMarketSyncTitle => 'Market sync';

  @override
  String get settingsTraderaProxyConfigured => 'Tradera proxy configured.';

  @override
  String get settingsTraderaProxyNotConfigured =>
      'Tradera proxy not configured.';

  @override
  String settingsTraderaProxyRunWith(Object command) {
    return 'Run with: $command';
  }

  @override
  String get settingsBackgroundInterval => 'Background interval';

  @override
  String get settingsInterval1h => '1h';

  @override
  String get settingsInterval6h => '6h';

  @override
  String get settingsInterval24h => '24h';

  @override
  String get settingsSavedSyncInterval => 'Saved sync interval.';

  @override
  String get settingsQuotaUnknown => 'Quota: —';

  @override
  String settingsQuotaUsedToday(Object used) {
    return 'Quota used today: $used';
  }

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncing => 'Syncing…';

  @override
  String get settingsMarketSyncCompleted => 'Sync completed.';

  @override
  String settingsMarketSyncFailed(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get settingsCloudSyncTitle => 'Cloud sync';

  @override
  String get settingsSupabaseConfigured => 'Supabase configured.';

  @override
  String get settingsSupabaseNotConfigured => 'Supabase not configured.';

  @override
  String get settingsNotSignedIn => 'Not signed in.';

  @override
  String settingsSignedInAs(Object email) {
    return 'Signed in as $email';
  }

  @override
  String get settingsSyncMetadata => 'Sync metadata';

  @override
  String get settingsSyncPhotos => 'Sync photos';

  @override
  String get settingsCloudSyncCompleted => 'Cloud sync completed.';

  @override
  String settingsCloudSyncFailed(Object error) {
    return 'Cloud sync failed: $error';
  }

  @override
  String get settingsPhotoSyncCompleted => 'Photo sync completed.';

  @override
  String settingsPhotoSyncFailed(Object error) {
    return 'Photo sync failed: $error';
  }

  @override
  String get settingsOnDeviceModelTitle => 'On-device model';

  @override
  String get settingsModelChecking => 'Checking…';

  @override
  String settingsModelInstalled(Object bytes) {
    return 'Installed ($bytes bytes)';
  }

  @override
  String get settingsModelNotInstalled => 'Not installed';

  @override
  String settingsModelExpectedPath(Object path) {
    return 'Expected path: $path';
  }

  @override
  String get settingsDownloading => 'Downloading…';

  @override
  String get settingsDownloadModel => 'Download model';

  @override
  String get settingsInstallFromFilePathLabel => 'Install from file path';

  @override
  String get settingsInstallFromFilePathHint => '/path/to/gemma_vision.task';
}
