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
  String get commonSave => 'Save';

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
  String get historySuggestNameFailed => 'Could not suggest a name.';

  @override
  String get historyEnterLatLngFirst => 'Enter latitude + longitude first.';

  @override
  String get historyHaulLatitudeOptionalLabel => 'Latitude (optional)';

  @override
  String get historyHaulLongitudeOptionalLabel => 'Longitude (optional)';

  @override
  String get historyLocationOptionalHint =>
      'Location is optional. It helps pin hauls on the map and suggest names.';

  @override
  String get historyUseCurrentLocation => 'Use current';

  @override
  String get historyLocationFetching => 'Locating…';

  @override
  String get historyLocationPermissionTitle => 'Location permission';

  @override
  String get historyLocationPermissionBody =>
      'Enable location to pin hauls on the map and auto-suggest haul names. You can still use the app without it.';

  @override
  String get historyLocationPermissionContinue => 'Continue';

  @override
  String get historyLocationPermissionNotNow => 'Not now';

  @override
  String get historyLocationPermissionDenied =>
      'Location permission is required to use current location.';

  @override
  String get historyLocationPermissionPermanentlyDenied =>
      'Location permission is disabled. Open system settings to enable it.';

  @override
  String get historyFilterAll => 'All';

  @override
  String get historyFilterProfit => 'Profit';

  @override
  String get historyFilterLoss => 'Loss';

  @override
  String get historyViewBoth => 'Both';

  @override
  String get historyViewMap => 'Map';

  @override
  String get historyViewList => 'List';

  @override
  String get historySortRecent => 'Recent';

  @override
  String get historySortProfit => 'Best margin';

  @override
  String get historySearchLabel => 'Search';

  @override
  String get historySearchHint => 'Search hauls…';

  @override
  String get historyCategoryAll => 'All categories';

  @override
  String historyPinnedHaulsCount(Object count) {
    return '$count pinned hauls';
  }

  @override
  String get historyNoPinnedHaulsYet => 'No pinned hauls yet.';

  @override
  String get historyHaulsTitle => 'Hauls';

  @override
  String get historyNoMatchesTitle => 'No matches';

  @override
  String get historyNoMatchesMessage => 'Try changing your search or filters.';

  @override
  String get dashboardTitle => 'Hunter Dashboard';

  @override
  String get dashboardSubtitle => 'Market pulse + recent hauls.';

  @override
  String get dashboardQuickScan => 'Quick Scan';

  @override
  String get dashboardHaulSummary => 'Haul Summary';

  @override
  String get dashboardDraftsTitle => 'Drafts';

  @override
  String get dashboardSeeAll => 'See all';

  @override
  String get dashboardNoDraftsYet => 'No drafts yet.';

  @override
  String get dashboardUntitledDraft => 'Untitled draft';

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
  String get scannerCameraPermissionTitle => 'Camera permission';

  @override
  String get scannerCameraPermissionBody =>
      'Loppisfynd needs camera access to scan items. Photos stay on your device unless you enable cloud sync.';

  @override
  String get scannerCameraPermissionContinue => 'Continue';

  @override
  String get scannerCameraPermissionNotNow => 'Not now';

  @override
  String get scannerCameraPermissionDenied =>
      'Camera permission is required to scan. You can enable it later.';

  @override
  String get scannerCameraPermissionPermanentlyDenied =>
      'Camera permission is disabled. Open system settings to enable it.';

  @override
  String get scannerCameraPermissionOpenSettings => 'Open settings';

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
  String get settingsAccountTitle => 'Account';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSigningOut => 'Signing out…';

  @override
  String get settingsSignedOut => 'Signed out.';

  @override
  String settingsSignOutFailed(Object error) {
    return 'Sign out failed: $error';
  }

  @override
  String get settingsDeleteAccount => 'Delete account';

  @override
  String get settingsDisplayNameLabel => 'Display name';

  @override
  String get settingsDisplayNameHint => 'Your name';

  @override
  String get settingsSaveProfile => 'Save profile';

  @override
  String get settingsProfileSaved => 'Saved profile.';

  @override
  String get settingsAiTitle => 'AI';

  @override
  String get settingsAiModeLabel => 'Mode';

  @override
  String get settingsAiEco => 'Eco';

  @override
  String get settingsAiQuality => 'Quality';

  @override
  String get settingsAiModeSaved => 'Saved AI mode.';

  @override
  String get settingsPrivacyTitle => 'Privacy & data';

  @override
  String get settingsPrivacySubtitle =>
      'Export your data, delete local/cloud data, and review what’s stored.';

  @override
  String get settingsOpenPrivacy => 'Open privacy';

  @override
  String get settingsSyncStatusTitle => 'Sync status';

  @override
  String get settingsSyncStatusSubtitle =>
      'See sync health, errors, and conflicts.';

  @override
  String get settingsOpenSyncStatus => 'Open sync status';

  @override
  String get draftEditorTitle => 'Draft listing';

  @override
  String get draftEditorFieldsTitle => 'Draft fields';

  @override
  String get draftEditorItemTitle => 'Item';

  @override
  String get draftEditorOpenAnalyzer => 'Open analyzer';

  @override
  String get draftEditorNoKeywordsYet => 'No keywords yet.';

  @override
  String get draftEditorNoPhotosYet => 'No photos yet.';

  @override
  String get draftEditorTitleLabel => 'Title';

  @override
  String get draftEditorTitleHint => 'e.g. Rorstrand Mon Amie plate';

  @override
  String get draftEditorDescriptionLabel => 'Description';

  @override
  String get draftEditorDescriptionHint => 'Condition, size, defects…';

  @override
  String get draftEditorAskingPriceLabel => 'Asking price (SEK)';

  @override
  String get draftEditorAskingPriceHint => '0';

  @override
  String get draftEditorSave => 'Save draft';

  @override
  String get draftEditorSaved => 'Draft saved.';

  @override
  String get draftEditorDelete => 'Delete';

  @override
  String get draftEditorDeleted => 'Draft deleted.';

  @override
  String get draftsTitle => 'Drafts';

  @override
  String get draftsEmptyTitle => 'No drafts yet';

  @override
  String get draftsEmptyMessage =>
      'Create a draft from any item to keep your listing text and price together.';

  @override
  String get draftsUntitled => 'Untitled';

  @override
  String get draftsItemFallback => 'Unnamed item';

  @override
  String get draftsOpenAnalyzer => 'Open analyzer';

  @override
  String draftsAskingPrice(Object sek) {
    return 'Asking $sek SEK';
  }

  @override
  String get itemDetailTitle => 'Item';

  @override
  String get itemDetailCategoryLabel => 'Category';

  @override
  String get itemDetailCategoryHint => 'e.g. ceramics';

  @override
  String get haulSummaryTitle => 'Haul Summary';

  @override
  String get haulSummaryEmptyTitle => 'No items in this haul';

  @override
  String get haulSummaryEmptyMessage =>
      'Scan items to see totals, profit estimates, and drafts.';

  @override
  String get haulSummaryTotalsTitle => 'Totals';

  @override
  String get haulSummaryItems => 'Items';

  @override
  String get haulSummaryInvested => 'Invested';

  @override
  String get haulSummaryValue => 'Value';

  @override
  String get haulSummaryNet => 'Net';

  @override
  String get haulSummaryStatusComplete => 'Complete';

  @override
  String get haulSummaryStatusPending => 'Pending';

  @override
  String get haulSummaryStatusFailed => 'Failed';

  @override
  String get haulSummaryFiltersTitle => 'Filters';

  @override
  String haulSummaryShowingCount(Object count) {
    return 'Showing $count';
  }

  @override
  String get haulSummaryDraftsTitle => 'Drafts';

  @override
  String get haulSummaryNoDraftsYet => 'No drafts yet for this haul.';

  @override
  String get haulSummaryInventoryTitle => 'Inventory';

  @override
  String get haulSummaryNoMatchesTitle => 'No matches';

  @override
  String get haulSummaryNoMatchesMessage => 'Try changing your filters.';

  @override
  String get haulSummaryUnnamedItem => 'Unnamed item';

  @override
  String haulSummaryDaysToSell(Object days) {
    return '${days}d';
  }

  @override
  String get filterStatusAll => 'All';

  @override
  String get filterStatusComplete => 'Complete';

  @override
  String get filterStatusPending => 'Pending';

  @override
  String get filterStatusFailed => 'Failed';

  @override
  String get filterMarginAll => 'All margins';

  @override
  String get filterMarginProfit => 'Profit';

  @override
  String get filterMarginHigh => 'High margin';

  @override
  String get filterMarginNeedsData => 'Needs data';

  @override
  String get filterHorizonAll => 'All horizons';

  @override
  String get filterHorizonFast => 'Fast';

  @override
  String get filterHorizonLongTerm => 'Long-term';

  @override
  String get filterHorizonUnknown => 'Unknown';

  @override
  String get filterCategoryNone => 'No categories yet.';

  @override
  String get filterCategoryAll => 'All categories';

  @override
  String get haulEditTitle => 'Edit haul';

  @override
  String get haulEditNameLabel => 'Name';

  @override
  String haulEditDateValue(Object year, Object month, Object day) {
    return 'Date: $year-$month-$day';
  }

  @override
  String get haulEditPickDate => 'Pick date';

  @override
  String get haulEditLatitudeOptional => 'Latitude (optional)';

  @override
  String get haulEditLongitudeOptional => 'Longitude (optional)';

  @override
  String get accountDeletionTitle => 'Delete account';

  @override
  String get accountDeletionHeadline => 'Account deletion';

  @override
  String get accountDeletionBody =>
      'Delete your cloud data and permanently delete your account. This action cannot be undone.';

  @override
  String get accountDeletionLocalOnlyHint =>
      'Cloud account deletion requires Supabase to be configured. You can still delete local data from Privacy & data.';

  @override
  String get accountDeletionConfirm => 'Delete';

  @override
  String get accountDeletionConfirmCta => 'Permanently delete account';

  @override
  String get accountDeletionNoAuth => 'Sign in to delete your account.';

  @override
  String get accountDeletionNoCloud => 'Cloud is not configured.';

  @override
  String get accountDeletionDangerTitle => 'Permanently delete account?';

  @override
  String get accountDeletionDangerBody =>
      'This will delete your cloud data and your account. You will be signed out.';

  @override
  String get accountDeletionDone => 'Account deletion requested.';

  @override
  String accountDeletionFailed(Object error) {
    return 'Account deletion failed: $error';
  }

  @override
  String get privacyTitle => 'Privacy & data';

  @override
  String get privacyStorageTitle => 'What’s stored';

  @override
  String get privacyStorageBodyLocalOnly =>
      'Your hauls, items, drafts, and photos are stored on this device. Price comps and sync are disabled when you’re offline.';

  @override
  String get privacyStorageBodyCloud =>
      'Your data is stored locally. If cloud sync is enabled, haul/item metadata and scan photos can also be synced to Supabase.';

  @override
  String get privacyExportTitle => 'Export';

  @override
  String get privacyExportBody =>
      'Exports are written to a file and the file path is copied to your clipboard.';

  @override
  String get privacyExportJson => 'Export JSON';

  @override
  String get privacyExportCsv => 'Export CSV';

  @override
  String get privacyExporting => 'Exporting…';

  @override
  String privacyExportedPathCopied(Object path) {
    return 'Exported. Path copied: $path';
  }

  @override
  String privacyExportFailed(Object error) {
    return 'Export failed: $error';
  }

  @override
  String get privacyToolsTitle => 'Tools';

  @override
  String get privacyToolsBody =>
      'Maintenance and diagnostics for troubleshooting.';

  @override
  String get privacyClearScanCache => 'Clear scan cache';

  @override
  String privacyCacheCleared(Object count) {
    return 'Cleared $count cached file(s).';
  }

  @override
  String privacyCacheClearFailed(Object error) {
    return 'Cache clear failed: $error';
  }

  @override
  String get privacyCopyDiagnostics => 'Copy diagnostics';

  @override
  String get privacyDiagnosticsCopied => 'Diagnostics copied.';

  @override
  String privacyDiagnosticsCopyFailed(Object error) {
    return 'Copy failed: $error';
  }

  @override
  String get privacyClearing => 'Clearing…';

  @override
  String get privacyCopying => 'Copying…';

  @override
  String get privacyDeleteTitle => 'Delete';

  @override
  String get privacyDeleteBody =>
      'Deleting is permanent. Local delete removes your on-device data. Cloud delete removes your synced data from Supabase.';

  @override
  String get privacyDeleteLocalCta => 'Delete local data';

  @override
  String get privacyDeleteCloudCta => 'Delete cloud data';

  @override
  String get privacyDeleteAccountCta => 'Delete account';

  @override
  String get privacyDeleting => 'Deleting…';

  @override
  String get privacyDeleteLocalTitle => 'Delete local data?';

  @override
  String get privacyDeleteLocalBody =>
      'This will delete all hauls, items, drafts, and scan photos stored on this device for the current profile.';

  @override
  String get privacyDeleteLocalDone => 'Local data deleted.';

  @override
  String get privacyDeleteCloudTitle => 'Delete cloud data?';

  @override
  String get privacyDeleteCloudBody =>
      'This will delete synced hauls/items and attempt to remove scan photos from cloud storage.';

  @override
  String privacyDeleteCloudDone(Object items, Object hauls, Object objects) {
    return 'Cloud delete done. Items: $items, Hauls: $hauls, Photos: $objects';
  }

  @override
  String privacyDeleteFailed(Object error) {
    return 'Delete failed: $error';
  }

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicySubtitle =>
      'A short, plain-language summary of how Loppisfynd handles your data.';

  @override
  String get privacyPolicyOpen => 'Read policy';

  @override
  String get privacyPolicyCopy => 'Copy';

  @override
  String get privacyPolicyCopied => 'Privacy policy copied.';

  @override
  String get privacyPolicyBody =>
      'Loppisfynd stores your hauls, items, drafts, and scan photos on your device.\n\nIf you enable cloud sync, haul/item metadata and scan photos may be uploaded to your Supabase project so you can restore them after reinstall and use sync features.\n\nPrice comps are fetched from Tradera via a proxy when you are online.\n\nYou can export your data and delete local and cloud data from the Privacy & data screen.';

  @override
  String get syncStatusTitle => 'Sync status';

  @override
  String get syncStatusActionsTitle => 'Actions';

  @override
  String get syncStatusOnline => 'Online';

  @override
  String get syncStatusOffline => 'Offline';

  @override
  String get syncStatusSyncNow => 'Sync now';

  @override
  String get syncStatusAllGoodTitle => 'All good';

  @override
  String get syncStatusAllGoodMessage => 'No sync problems detected.';

  @override
  String get syncStatusProblemsTitle => 'Problems';

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
