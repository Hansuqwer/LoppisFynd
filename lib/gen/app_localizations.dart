import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sv.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('sv'),
    Locale('en'),
  ];

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabScan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get tabScan;

  /// No description provided for @tabHaul.
  ///
  /// In en, this message translates to:
  /// **'Haul'**
  String get tabHaul;

  /// No description provided for @tabHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tabHistory;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Loppisfynd'**
  String get appTitle;

  /// No description provided for @snackbarSavedScan.
  ///
  /// In en, this message translates to:
  /// **'Saved scan {id}.'**
  String snackbarSavedScan(Object id);

  /// No description provided for @snackbarCaptureFailed.
  ///
  /// In en, this message translates to:
  /// **'Capture failed: {error}'**
  String snackbarCaptureFailed(Object error);

  /// No description provided for @snackbarCopiedBarcode.
  ///
  /// In en, this message translates to:
  /// **'Copied barcode to clipboard.'**
  String get snackbarCopiedBarcode;

  /// No description provided for @settingsAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get settingsAccessibility;

  /// No description provided for @settingsHighContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get settingsHighContrast;

  /// No description provided for @settingsContrastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated contrast setting.'**
  String get settingsContrastUpdated;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Scan items in-store, save offline, and fetch sold-price comps when you’re online.'**
  String get onboardingWelcomeBody;

  /// No description provided for @onboardingPermissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get onboardingPermissionsTitle;

  /// No description provided for @onboardingPermissionsBody.
  ///
  /// In en, this message translates to:
  /// **'Camera is required for scanning. Location is optional and only used to name hauls on the map.'**
  String get onboardingPermissionsBody;

  /// No description provided for @onboardingOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline-first'**
  String get onboardingOfflineTitle;

  /// No description provided for @onboardingOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Everything works without internet except price fetch. Your data stays on-device unless you enable cloud sync.'**
  String get onboardingOfflineBody;

  /// No description provided for @onboardingContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinue;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @bannerOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline mode: price fetch is paused.'**
  String get bannerOffline;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonInstall.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get commonInstall;

  /// No description provided for @commonOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get commonOff;

  /// No description provided for @commonHaul.
  ///
  /// In en, this message translates to:
  /// **'Haul'**
  String get commonHaul;

  /// No description provided for @errorCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get errorCameraTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No hauls yet'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a haul to start tracking your finds.'**
  String get historyEmptyMessage;

  /// No description provided for @historyTreasureMapTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasure Map'**
  String get historyTreasureMapTitle;

  /// No description provided for @historyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get historyHistoryTitle;

  /// No description provided for @historyNewHaulTitle.
  ///
  /// In en, this message translates to:
  /// **'New haul'**
  String get historyNewHaulTitle;

  /// No description provided for @historyHaulTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get historyHaulTitleLabel;

  /// No description provided for @historySuggestNameTooltip.
  ///
  /// In en, this message translates to:
  /// **'Suggest name'**
  String get historySuggestNameTooltip;

  /// No description provided for @historyEnterLatLngFirst.
  ///
  /// In en, this message translates to:
  /// **'Enter latitude + longitude first.'**
  String get historyEnterLatLngFirst;

  /// No description provided for @historyHaulLatitudeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Latitude (optional)'**
  String get historyHaulLatitudeOptionalLabel;

  /// No description provided for @historyHaulLongitudeOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Longitude (optional)'**
  String get historyHaulLongitudeOptionalLabel;

  /// No description provided for @historyFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get historyFilterAll;

  /// No description provided for @historyFilterProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get historyFilterProfit;

  /// No description provided for @historyFilterLoss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get historyFilterLoss;

  /// No description provided for @historyPinnedHaulsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pinned hauls'**
  String historyPinnedHaulsCount(Object count);

  /// No description provided for @historyNoPinnedHaulsYet.
  ///
  /// In en, this message translates to:
  /// **'No pinned hauls yet.'**
  String get historyNoPinnedHaulsYet;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Hunter Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Market pulse + recent hauls.'**
  String get dashboardSubtitle;

  /// No description provided for @dashboardQuickScan.
  ///
  /// In en, this message translates to:
  /// **'Quick Scan'**
  String get dashboardQuickScan;

  /// No description provided for @dashboardHaulSummary.
  ///
  /// In en, this message translates to:
  /// **'Haul Summary'**
  String get dashboardHaulSummary;

  /// No description provided for @scannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Rapid-Fire Scanner'**
  String get scannerTitle;

  /// No description provided for @scannerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Capture, store, thumbnail, and queue comps.'**
  String get scannerSubtitle;

  /// No description provided for @scannerCapture.
  ///
  /// In en, this message translates to:
  /// **'Capture'**
  String get scannerCapture;

  /// No description provided for @scannerSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get scannerSaving;

  /// No description provided for @scannerDoneScanning.
  ///
  /// In en, this message translates to:
  /// **'Done scanning'**
  String get scannerDoneScanning;

  /// No description provided for @scannerQueuedItems.
  ///
  /// In en, this message translates to:
  /// **'Queued {count} item(s) for sync.'**
  String scannerQueuedItems(Object count);

  /// No description provided for @scannerQueueFailed.
  ///
  /// In en, this message translates to:
  /// **'Queue failed: {error}'**
  String scannerQueueFailed(Object error);

  /// No description provided for @scannerNoCamerasAvailable.
  ///
  /// In en, this message translates to:
  /// **'No cameras available on this device.'**
  String get scannerNoCamerasAvailable;

  /// No description provided for @scannerCameraInitFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize camera: {error}'**
  String scannerCameraInitFailed(Object error);

  /// No description provided for @scannerBarcodeAimHint.
  ///
  /// In en, this message translates to:
  /// **'Aim at a barcode to detect instantly.'**
  String get scannerBarcodeAimHint;

  /// No description provided for @scannerNoScansYet.
  ///
  /// In en, this message translates to:
  /// **'No scans yet.'**
  String get scannerNoScansYet;

  /// No description provided for @scannerBatchTrayTitle.
  ///
  /// In en, this message translates to:
  /// **'Batch tray'**
  String get scannerBatchTrayTitle;

  /// No description provided for @haulTitle.
  ///
  /// In en, this message translates to:
  /// **'Current haul'**
  String get haulTitle;

  /// No description provided for @haulSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Offline-first. Add items while scanning, then sync comps when online.'**
  String get haulSubtitle;

  /// No description provided for @haulItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get haulItems;

  /// No description provided for @haulReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get haulReady;

  /// No description provided for @haulExpected.
  ///
  /// In en, this message translates to:
  /// **'Expected'**
  String get haulExpected;

  /// No description provided for @haulNetEst.
  ///
  /// In en, this message translates to:
  /// **'Net (est.)'**
  String get haulNetEst;

  /// No description provided for @haulOpenSummary.
  ///
  /// In en, this message translates to:
  /// **'Open haul summary'**
  String get haulOpenSummary;

  /// No description provided for @settingsMarketSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Market sync'**
  String get settingsMarketSyncTitle;

  /// No description provided for @settingsTraderaProxyConfigured.
  ///
  /// In en, this message translates to:
  /// **'Tradera proxy configured.'**
  String get settingsTraderaProxyConfigured;

  /// No description provided for @settingsTraderaProxyNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Tradera proxy not configured.'**
  String get settingsTraderaProxyNotConfigured;

  /// No description provided for @settingsTraderaProxyRunWith.
  ///
  /// In en, this message translates to:
  /// **'Run with: {command}'**
  String settingsTraderaProxyRunWith(Object command);

  /// No description provided for @settingsBackgroundInterval.
  ///
  /// In en, this message translates to:
  /// **'Background interval'**
  String get settingsBackgroundInterval;

  /// No description provided for @settingsInterval1h.
  ///
  /// In en, this message translates to:
  /// **'1h'**
  String get settingsInterval1h;

  /// No description provided for @settingsInterval6h.
  ///
  /// In en, this message translates to:
  /// **'6h'**
  String get settingsInterval6h;

  /// No description provided for @settingsInterval24h.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get settingsInterval24h;

  /// No description provided for @settingsSavedSyncInterval.
  ///
  /// In en, this message translates to:
  /// **'Saved sync interval.'**
  String get settingsSavedSyncInterval;

  /// No description provided for @settingsQuotaUnknown.
  ///
  /// In en, this message translates to:
  /// **'Quota: —'**
  String get settingsQuotaUnknown;

  /// No description provided for @settingsQuotaUsedToday.
  ///
  /// In en, this message translates to:
  /// **'Quota used today: {used}'**
  String settingsQuotaUsedToday(Object used);

  /// No description provided for @settingsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get settingsSyncing;

  /// No description provided for @settingsMarketSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed.'**
  String get settingsMarketSyncCompleted;

  /// No description provided for @settingsMarketSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String settingsMarketSyncFailed(Object error);

  /// No description provided for @settingsCloudSyncTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync'**
  String get settingsCloudSyncTitle;

  /// No description provided for @settingsSupabaseConfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase configured.'**
  String get settingsSupabaseConfigured;

  /// No description provided for @settingsSupabaseNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Supabase not configured.'**
  String get settingsSupabaseNotConfigured;

  /// No description provided for @settingsNotSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in.'**
  String get settingsNotSignedIn;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String settingsSignedInAs(Object email);

  /// No description provided for @settingsSyncMetadata.
  ///
  /// In en, this message translates to:
  /// **'Sync metadata'**
  String get settingsSyncMetadata;

  /// No description provided for @settingsSyncPhotos.
  ///
  /// In en, this message translates to:
  /// **'Sync photos'**
  String get settingsSyncPhotos;

  /// No description provided for @settingsCloudSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync completed.'**
  String get settingsCloudSyncCompleted;

  /// No description provided for @settingsCloudSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed: {error}'**
  String settingsCloudSyncFailed(Object error);

  /// No description provided for @settingsPhotoSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Photo sync completed.'**
  String get settingsPhotoSyncCompleted;

  /// No description provided for @settingsPhotoSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Photo sync failed: {error}'**
  String settingsPhotoSyncFailed(Object error);

  /// No description provided for @settingsOnDeviceModelTitle.
  ///
  /// In en, this message translates to:
  /// **'On-device model'**
  String get settingsOnDeviceModelTitle;

  /// No description provided for @settingsModelChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get settingsModelChecking;

  /// No description provided for @settingsModelInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed ({bytes} bytes)'**
  String settingsModelInstalled(Object bytes);

  /// No description provided for @settingsModelNotInstalled.
  ///
  /// In en, this message translates to:
  /// **'Not installed'**
  String get settingsModelNotInstalled;

  /// No description provided for @settingsModelExpectedPath.
  ///
  /// In en, this message translates to:
  /// **'Expected path: {path}'**
  String settingsModelExpectedPath(Object path);

  /// No description provided for @settingsDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get settingsDownloading;

  /// No description provided for @settingsDownloadModel.
  ///
  /// In en, this message translates to:
  /// **'Download model'**
  String get settingsDownloadModel;

  /// No description provided for @settingsInstallFromFilePathLabel.
  ///
  /// In en, this message translates to:
  /// **'Install from file path'**
  String get settingsInstallFromFilePathLabel;

  /// No description provided for @settingsInstallFromFilePathHint.
  ///
  /// In en, this message translates to:
  /// **'/path/to/gemma_vision.task'**
  String get settingsInstallFromFilePathHint;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sv'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sv':
      return AppLocalizationsSv();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
