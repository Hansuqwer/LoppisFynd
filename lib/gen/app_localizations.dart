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

  /// No description provided for @settingsThemeModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsThemeModeLabel;

  /// No description provided for @settingsThemeModeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeModeSystem;

  /// No description provided for @settingsThemeModeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeModeLight;

  /// No description provided for @settingsThemeModeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeModeDark;

  /// No description provided for @settingsThemeModeSaved.
  ///
  /// In en, this message translates to:
  /// **'Updated theme setting.'**
  String get settingsThemeModeSaved;

  /// No description provided for @settingsPrivacyDataSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Data'**
  String get settingsPrivacyDataSectionTitle;

  /// No description provided for @settingsCloudIdentificationToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Send crops for cloud identification'**
  String get settingsCloudIdentificationToggleTitle;

  /// No description provided for @settingsCloudIdentificationToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Uploads crops only (never the full photo).'**
  String get settingsCloudIdentificationToggleSubtitle;

  /// No description provided for @settingsFetchSoldPriceCompsToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Fetch sold-price comps'**
  String get settingsFetchSoldPriceCompsToggleTitle;

  /// No description provided for @settingsFetchSoldPriceCompsToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used for market charts and estimates.'**
  String get settingsFetchSoldPriceCompsToggleSubtitle;

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
  /// **'Get started'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @onboardingDownloadNow.
  ///
  /// In en, this message translates to:
  /// **'Download now'**
  String get onboardingDownloadNow;

  /// No description provided for @onboardingNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onboardingNotNow;

  /// No description provided for @cloudDisclosureTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud identification'**
  String get cloudDisclosureTitle;

  /// No description provided for @cloudDisclosureBullet1.
  ///
  /// In en, this message translates to:
  /// **'Uses cloud AI to suggest keywords for your item.'**
  String get cloudDisclosureBullet1;

  /// No description provided for @cloudDisclosureBullet2.
  ///
  /// In en, this message translates to:
  /// **'Uploads crops only (never the full photo).'**
  String get cloudDisclosureBullet2;

  /// No description provided for @cloudDisclosureBullet3.
  ///
  /// In en, this message translates to:
  /// **'You can turn this off anytime in Settings.'**
  String get cloudDisclosureBullet3;

  /// No description provided for @cloudDisclosureLearnMoreCta.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get cloudDisclosureLearnMoreCta;

  /// No description provided for @cloudDisclosureEnable.
  ///
  /// In en, this message translates to:
  /// **'Enable cloud identification'**
  String get cloudDisclosureEnable;

  /// No description provided for @cloudDisclosureNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get cloudDisclosureNotNow;

  /// No description provided for @cloudDisclosureLearnMoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get cloudDisclosureLearnMoreTitle;

  /// No description provided for @cloudDisclosureLearnMoreIntro.
  ///
  /// In en, this message translates to:
  /// **'Cloud identification uses cloud AI. Here’s what that means:'**
  String get cloudDisclosureLearnMoreIntro;

  /// No description provided for @cloudDisclosurePreviewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get cloudDisclosurePreviewLabel;

  /// No description provided for @cloudDisclosurePreviewPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'A crop preview will appear here when an image is available.'**
  String get cloudDisclosurePreviewPlaceholder;

  /// No description provided for @cloudDisclosureLearnMoreBullet1.
  ///
  /// In en, this message translates to:
  /// **'Provider is described as cloud AI (we don’t name the vendor here).'**
  String get cloudDisclosureLearnMoreBullet1;

  /// No description provided for @cloudDisclosureLearnMoreBullet2.
  ///
  /// In en, this message translates to:
  /// **'We upload crops only, never the full photo.'**
  String get cloudDisclosureLearnMoreBullet2;

  /// No description provided for @cloudDisclosureLearnMoreBullet3.
  ///
  /// In en, this message translates to:
  /// **'Metadata is stripped before upload.'**
  String get cloudDisclosureLearnMoreBullet3;

  /// No description provided for @cloudDisclosureLearnMoreBullet4.
  ///
  /// In en, this message translates to:
  /// **'Image data is processed transiently and not stored on our server.'**
  String get cloudDisclosureLearnMoreBullet4;

  /// No description provided for @cloudIdentifyDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Cloud identification is turned off. Enable it in Settings to use Identify.'**
  String get cloudIdentifyDisabledHint;

  /// No description provided for @cloudIdentifyOfflineTitle.
  ///
  /// In en, this message translates to:
  /// **'You’re offline'**
  String get cloudIdentifyOfflineTitle;

  /// No description provided for @cloudIdentifyOfflineBody.
  ///
  /// In en, this message translates to:
  /// **'Cloud identification needs an internet connection. Try again when you’re online.'**
  String get cloudIdentifyOfflineBody;

  /// No description provided for @cloudIdentifyNotAvailableYet.
  ///
  /// In en, this message translates to:
  /// **'Cloud identification isn’t wired up yet.'**
  String get cloudIdentifyNotAvailableYet;

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

  /// No description provided for @commonCopied.
  ///
  /// In en, this message translates to:
  /// **'Copied.'**
  String get commonCopied;

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

  /// No description provided for @commonOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get commonOpenSettings;

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

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @errorCameraTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get errorCameraTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Time for a fika?'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'No historic finds yet.\nGet out there and scan!'**
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

  /// No description provided for @historySuggestNameFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not suggest a name.'**
  String get historySuggestNameFailed;

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

  /// No description provided for @historyLocationOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Location is optional. It helps pin hauls on the map and suggest names.'**
  String get historyLocationOptionalHint;

  /// No description provided for @historyUseCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current'**
  String get historyUseCurrentLocation;

  /// No description provided for @historyLocationFetching.
  ///
  /// In en, this message translates to:
  /// **'Locating…'**
  String get historyLocationFetching;

  /// No description provided for @historyLocationPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Location permission'**
  String get historyLocationPermissionTitle;

  /// No description provided for @historyLocationPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Enable location to pin hauls on the map and auto-suggest haul names. You can still use the app without it.'**
  String get historyLocationPermissionBody;

  /// No description provided for @historyLocationPermissionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get historyLocationPermissionContinue;

  /// No description provided for @historyLocationPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get historyLocationPermissionNotNow;

  /// No description provided for @historyLocationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use current location.'**
  String get historyLocationPermissionDenied;

  /// No description provided for @historyLocationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location permission is disabled. Open system settings to enable it.'**
  String get historyLocationPermissionPermanentlyDenied;

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

  /// No description provided for @historyViewBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get historyViewBoth;

  /// No description provided for @historyViewMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get historyViewMap;

  /// No description provided for @historyViewList.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get historyViewList;

  /// No description provided for @historySortRecent.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get historySortRecent;

  /// No description provided for @historySortProfit.
  ///
  /// In en, this message translates to:
  /// **'Best margin'**
  String get historySortProfit;

  /// No description provided for @historySearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get historySearchLabel;

  /// No description provided for @historySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search history…'**
  String get historySearchHint;

  /// No description provided for @historyCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get historyCategoryAll;

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

  /// No description provided for @historyHaulsTitle.
  ///
  /// In en, this message translates to:
  /// **'Hauls'**
  String get historyHaulsTitle;

  /// No description provided for @historyNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get historyNoMatchesTitle;

  /// No description provided for @historyNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing your search or filters.'**
  String get historyNoMatchesMessage;

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

  /// No description provided for @dashboardDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get dashboardDraftsTitle;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardNoDraftsYet.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet.'**
  String get dashboardNoDraftsYet;

  /// No description provided for @dashboardUntitledDraft.
  ///
  /// In en, this message translates to:
  /// **'Untitled draft'**
  String get dashboardUntitledDraft;

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

  /// No description provided for @scannerCameraPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera permission'**
  String get scannerCameraPermissionTitle;

  /// No description provided for @scannerCameraPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Loppisfynd needs camera access to scan items. Photos stay on your device unless you enable cloud sync.'**
  String get scannerCameraPermissionBody;

  /// No description provided for @scannerCameraPermissionContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get scannerCameraPermissionContinue;

  /// No description provided for @scannerCameraPermissionNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get scannerCameraPermissionNotNow;

  /// No description provided for @scannerCameraPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is required to scan. You can enable it later.'**
  String get scannerCameraPermissionDenied;

  /// No description provided for @scannerCameraPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Camera permission is disabled. Open system settings to enable it.'**
  String get scannerCameraPermissionPermanentlyDenied;

  /// No description provided for @scannerCameraPermissionOpenSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get scannerCameraPermissionOpenSettings;

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

  /// No description provided for @scannerDeleteDropHint.
  ///
  /// In en, this message translates to:
  /// **'Drag here to delete'**
  String get scannerDeleteDropHint;

  /// No description provided for @scannerDeletedScan.
  ///
  /// In en, this message translates to:
  /// **'Removed scan.'**
  String get scannerDeletedScan;

  /// No description provided for @scannerDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String scannerDeleteFailed(Object error);

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

  /// No description provided for @settingsProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Treasure Hunter'**
  String get settingsProfileTitle;

  /// No description provided for @settingsVersionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Version unknown'**
  String get settingsVersionUnknown;

  /// No description provided for @settingsVersionPill.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (Build {build})'**
  String settingsVersionPill(Object version, Object build);

  /// No description provided for @settingsModuleSyncDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync & Data'**
  String get settingsModuleSyncDataTitle;

  /// No description provided for @settingsModuleSyncDataDescription.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync is under development.'**
  String get settingsModuleSyncDataDescription;

  /// No description provided for @settingsModuleAiModelTitle.
  ///
  /// In en, this message translates to:
  /// **'AI & Model'**
  String get settingsModuleAiModelTitle;

  /// No description provided for @settingsModulePrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsModulePrivacyTitle;

  /// No description provided for @settingsModuleLegalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal & Licenses'**
  String get settingsModuleLegalTitle;

  /// No description provided for @settingsOfflineIdentificationToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable offline identification'**
  String get settingsOfflineIdentificationToggleTitle;

  /// No description provided for @settingsOfflineIdentificationToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional on-device detection. Download required ({size}).'**
  String settingsOfflineIdentificationToggleSubtitle(String size);

  /// No description provided for @settingsOfflineDownloadSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Offline identification is enabled. Download the offline model now? ({size})'**
  String settingsOfflineDownloadSuggestion(String size);

  /// No description provided for @settingsOfflineDownloadSuggestionAction.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get settingsOfflineDownloadSuggestionAction;

  /// No description provided for @settingsOfflineDownloadStarted.
  ///
  /// In en, this message translates to:
  /// **'Starting offline model download…'**
  String get settingsOfflineDownloadStarted;

  /// No description provided for @settingsOfflineDownloadInProgress.
  ///
  /// In en, this message translates to:
  /// **'Offline model download in progress.'**
  String get settingsOfflineDownloadInProgress;

  /// No description provided for @settingsOfflineDownloadInstalled.
  ///
  /// In en, this message translates to:
  /// **'Offline model installed.'**
  String get settingsOfflineDownloadInstalled;

  /// No description provided for @settingsOfflineDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Offline model download failed: {error}'**
  String settingsOfflineDownloadFailed(String error);

  /// No description provided for @settingsOfflineAttributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline model attribution'**
  String get settingsOfflineAttributionTitle;

  /// No description provided for @settingsOfflineAttributionSummary.
  ///
  /// In en, this message translates to:
  /// **'Runtime and model weights are Apache-2.0; trained on COCO annotations (CC BY 4.0).'**
  String get settingsOfflineAttributionSummary;

  /// No description provided for @settingsOfflineAttributionViewFull.
  ///
  /// In en, this message translates to:
  /// **'View full license text'**
  String get settingsOfflineAttributionViewFull;

  /// No description provided for @offlineIdentifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline identification'**
  String get offlineIdentifyTitle;

  /// No description provided for @offlineIdentifyEvidenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Evidence'**
  String get offlineIdentifyEvidenceTitle;

  /// No description provided for @offlineIdentifyResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get offlineIdentifyResultsTitle;

  /// No description provided for @offlineIdentifyRunCta.
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get offlineIdentifyRunCta;

  /// No description provided for @offlineIdentifyReviewCta.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get offlineIdentifyReviewCta;

  /// No description provided for @offlineIdentifyRunningLabel.
  ///
  /// In en, this message translates to:
  /// **'Running…'**
  String get offlineIdentifyRunningLabel;

  /// No description provided for @offlineIdentifyWorkingOverlay.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get offlineIdentifyWorkingOverlay;

  /// No description provided for @offlineIdentifyApplyCta.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get offlineIdentifyApplyCta;

  /// No description provided for @offlineIdentifyNoResults.
  ///
  /// In en, this message translates to:
  /// **'Run offline identification to see detections here.'**
  String get offlineIdentifyNoResults;

  /// No description provided for @offlineIdentifyDisabledHint.
  ///
  /// In en, this message translates to:
  /// **'Offline identification is turned off. Enable it in Settings to run detection.'**
  String get offlineIdentifyDisabledHint;

  /// No description provided for @offlineIdentifyConfidenceSummary.
  ///
  /// In en, this message translates to:
  /// **'{percent} · {label}'**
  String offlineIdentifyConfidenceSummary(String percent, String label);

  /// No description provided for @offlineModelCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline model'**
  String get offlineModelCardTitle;

  /// No description provided for @offlineModelCardBody.
  ///
  /// In en, this message translates to:
  /// **'Download required to run offline identification. Size: {size}.'**
  String offlineModelCardBody(String size);

  /// No description provided for @offlineModelDownloadCta.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get offlineModelDownloadCta;

  /// No description provided for @offlineModelDownloadingLabel.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get offlineModelDownloadingLabel;

  /// No description provided for @offlineModelPausedLabel.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get offlineModelPausedLabel;

  /// No description provided for @offlineModelPauseCta.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get offlineModelPauseCta;

  /// No description provided for @offlineModelResumeCta.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get offlineModelResumeCta;

  /// No description provided for @offlineModelCancelCta.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get offlineModelCancelCta;

  /// No description provided for @offlineModelInstalledLabel.
  ///
  /// In en, this message translates to:
  /// **'Installed.'**
  String get offlineModelInstalledLabel;

  /// No description provided for @offlineModelInstalledCta.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get offlineModelInstalledCta;

  /// No description provided for @offlineModelFailedLabel.
  ///
  /// In en, this message translates to:
  /// **'Download failed: {error}'**
  String offlineModelFailedLabel(String error);

  /// No description provided for @offlineModelRetryCta.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get offlineModelRetryCta;

  /// No description provided for @settingsLegalDescription.
  ///
  /// In en, this message translates to:
  /// **'Licenses and attributions for Loppisfynd and the optional offline model.'**
  String get settingsLegalDescription;

  /// No description provided for @settingsOpenLegal.
  ///
  /// In en, this message translates to:
  /// **'Open legal'**
  String get settingsOpenLegal;

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

  /// No description provided for @settingsAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccountTitle;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsSigningOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out…'**
  String get settingsSigningOut;

  /// No description provided for @settingsSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out.'**
  String get settingsSignedOut;

  /// No description provided for @settingsSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign out failed: {error}'**
  String settingsSignOutFailed(Object error);

  /// No description provided for @settingsDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDeleteAccount;

  /// No description provided for @settingsDisplayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get settingsDisplayNameLabel;

  /// No description provided for @settingsDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get settingsDisplayNameHint;

  /// No description provided for @settingsSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save profile'**
  String get settingsSaveProfile;

  /// No description provided for @settingsProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved profile.'**
  String get settingsProfileSaved;

  /// No description provided for @settingsAiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get settingsAiTitle;

  /// No description provided for @settingsAiModeLabel.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get settingsAiModeLabel;

  /// No description provided for @settingsAiEco.
  ///
  /// In en, this message translates to:
  /// **'Eco'**
  String get settingsAiEco;

  /// No description provided for @settingsAiQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get settingsAiQuality;

  /// No description provided for @settingsAiModeSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved AI mode.'**
  String get settingsAiModeSaved;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Export your data, delete local/cloud data, and review what’s stored.'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsOpenPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Open privacy'**
  String get settingsOpenPrivacy;

  /// No description provided for @settingsSyncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get settingsSyncStatusTitle;

  /// No description provided for @settingsSyncStatusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See sync health, errors, and conflicts.'**
  String get settingsSyncStatusSubtitle;

  /// No description provided for @settingsOpenSyncStatus.
  ///
  /// In en, this message translates to:
  /// **'Open sync status'**
  String get settingsOpenSyncStatus;

  /// No description provided for @legalTitle.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legalTitle;

  /// No description provided for @legalLicensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Licenses'**
  String get legalLicensesTitle;

  /// No description provided for @legalLicensesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review third-party notices and offline model attributions.'**
  String get legalLicensesSubtitle;

  /// No description provided for @legalThirdPartyLicenses.
  ///
  /// In en, this message translates to:
  /// **'Third-party licenses'**
  String get legalThirdPartyLicenses;

  /// No description provided for @legalOfflineModelLicenses.
  ///
  /// In en, this message translates to:
  /// **'Offline model licenses'**
  String get legalOfflineModelLicenses;

  /// No description provided for @legalOfflineModelLicensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline model licenses'**
  String get legalOfflineModelLicensesTitle;

  /// No description provided for @legalOfflineModelSize.
  ///
  /// In en, this message translates to:
  /// **'Download size: {size}'**
  String legalOfflineModelSize(String size);

  /// No description provided for @legalOfflineLicenseRuntimeTitle.
  ///
  /// In en, this message translates to:
  /// **'Runtime / inference stack'**
  String get legalOfflineLicenseRuntimeTitle;

  /// No description provided for @legalOfflineLicenseRuntimeSummary.
  ///
  /// In en, this message translates to:
  /// **'TensorFlow Lite runtime used for on-device inference (Apache-2.0).'**
  String get legalOfflineLicenseRuntimeSummary;

  /// No description provided for @legalOfflineLicenseWeightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Model weights'**
  String get legalOfflineLicenseWeightsTitle;

  /// No description provided for @legalOfflineLicenseWeightsSummary.
  ///
  /// In en, this message translates to:
  /// **'The downloaded EfficientDet Lite0 weights artifact (Apache-2.0).'**
  String get legalOfflineLicenseWeightsSummary;

  /// No description provided for @legalOfflineLicenseDatasetTitle.
  ///
  /// In en, this message translates to:
  /// **'Dataset / training attribution'**
  String get legalOfflineLicenseDatasetTitle;

  /// No description provided for @legalOfflineLicenseDatasetSummary.
  ///
  /// In en, this message translates to:
  /// **'COCO annotations are licensed under CC BY 4.0.'**
  String get legalOfflineLicenseDatasetSummary;

  /// No description provided for @legalSourceUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Source URL'**
  String get legalSourceUrlLabel;

  /// No description provided for @legalCopySourceUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get legalCopySourceUrl;

  /// No description provided for @legalViewFullLicenseText.
  ///
  /// In en, this message translates to:
  /// **'View full license text'**
  String get legalViewFullLicenseText;

  /// No description provided for @draftEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft listing'**
  String get draftEditorTitle;

  /// No description provided for @draftEditorFieldsTitle.
  ///
  /// In en, this message translates to:
  /// **'Draft fields'**
  String get draftEditorFieldsTitle;

  /// No description provided for @draftEditorItemTitle.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get draftEditorItemTitle;

  /// No description provided for @draftEditorOpenAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'Open analyzer'**
  String get draftEditorOpenAnalyzer;

  /// No description provided for @draftEditorNoKeywordsYet.
  ///
  /// In en, this message translates to:
  /// **'No keywords yet.'**
  String get draftEditorNoKeywordsYet;

  /// No description provided for @draftEditorNoPhotosYet.
  ///
  /// In en, this message translates to:
  /// **'No photos yet.'**
  String get draftEditorNoPhotosYet;

  /// No description provided for @draftEditorTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get draftEditorTitleLabel;

  /// No description provided for @draftEditorTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Rorstrand Mon Amie plate'**
  String get draftEditorTitleHint;

  /// No description provided for @draftEditorDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get draftEditorDescriptionLabel;

  /// No description provided for @draftEditorDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Condition, size, defects…'**
  String get draftEditorDescriptionHint;

  /// No description provided for @draftEditorAskingPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Asking price (SEK)'**
  String get draftEditorAskingPriceLabel;

  /// No description provided for @draftEditorAskingPriceHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get draftEditorAskingPriceHint;

  /// No description provided for @draftEditorSave.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get draftEditorSave;

  /// No description provided for @draftEditorSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved.'**
  String get draftEditorSaved;

  /// No description provided for @draftEditorDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get draftEditorDelete;

  /// No description provided for @draftEditorDeleted.
  ///
  /// In en, this message translates to:
  /// **'Draft deleted.'**
  String get draftEditorDeleted;

  /// No description provided for @draftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get draftsTitle;

  /// No description provided for @draftsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet'**
  String get draftsEmptyTitle;

  /// No description provided for @draftsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a draft from any item to keep your listing text and price together.'**
  String get draftsEmptyMessage;

  /// No description provided for @draftsUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get draftsUntitled;

  /// No description provided for @draftsItemFallback.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get draftsItemFallback;

  /// No description provided for @draftsOpenAnalyzer.
  ///
  /// In en, this message translates to:
  /// **'Open analyzer'**
  String get draftsOpenAnalyzer;

  /// No description provided for @draftsAskingPrice.
  ///
  /// In en, this message translates to:
  /// **'Asking {sek} SEK'**
  String draftsAskingPrice(Object sek);

  /// No description provided for @itemDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Item'**
  String get itemDetailTitle;

  /// No description provided for @itemDetailCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get itemDetailCategoryLabel;

  /// No description provided for @itemDetailCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ceramics'**
  String get itemDetailCategoryHint;

  /// No description provided for @haulSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Haul Summary'**
  String get haulSummaryTitle;

  /// No description provided for @haulSummaryEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No items in this haul'**
  String get haulSummaryEmptyTitle;

  /// No description provided for @haulSummaryEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Scan items to see totals, profit estimates, and drafts.'**
  String get haulSummaryEmptyMessage;

  /// No description provided for @haulSummaryTotalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Totals'**
  String get haulSummaryTotalsTitle;

  /// No description provided for @haulSummaryItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get haulSummaryItems;

  /// No description provided for @haulSummaryInvested.
  ///
  /// In en, this message translates to:
  /// **'Invested'**
  String get haulSummaryInvested;

  /// No description provided for @haulSummaryValue.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get haulSummaryValue;

  /// No description provided for @haulSummaryNet.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get haulSummaryNet;

  /// No description provided for @haulSummaryStatusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get haulSummaryStatusComplete;

  /// No description provided for @haulSummaryStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get haulSummaryStatusPending;

  /// No description provided for @haulSummaryStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get haulSummaryStatusFailed;

  /// No description provided for @haulSummaryFiltersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get haulSummaryFiltersTitle;

  /// No description provided for @haulSummaryShowingCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count}'**
  String haulSummaryShowingCount(Object count);

  /// No description provided for @haulSummaryDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get haulSummaryDraftsTitle;

  /// No description provided for @haulSummaryNoDraftsYet.
  ///
  /// In en, this message translates to:
  /// **'No drafts yet for this haul.'**
  String get haulSummaryNoDraftsYet;

  /// No description provided for @haulSummaryInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get haulSummaryInventoryTitle;

  /// No description provided for @haulSummaryNoMatchesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matches'**
  String get haulSummaryNoMatchesTitle;

  /// No description provided for @haulSummaryNoMatchesMessage.
  ///
  /// In en, this message translates to:
  /// **'Try changing your filters.'**
  String get haulSummaryNoMatchesMessage;

  /// No description provided for @haulSummaryUnnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get haulSummaryUnnamedItem;

  /// No description provided for @haulSummaryDaysToSell.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String haulSummaryDaysToSell(Object days);

  /// No description provided for @filterStatusAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterStatusAll;

  /// No description provided for @filterStatusComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get filterStatusComplete;

  /// No description provided for @filterStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterStatusPending;

  /// No description provided for @filterStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterStatusFailed;

  /// No description provided for @filterMarginAll.
  ///
  /// In en, this message translates to:
  /// **'All margins'**
  String get filterMarginAll;

  /// No description provided for @filterMarginProfit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get filterMarginProfit;

  /// No description provided for @filterMarginHigh.
  ///
  /// In en, this message translates to:
  /// **'High margin'**
  String get filterMarginHigh;

  /// No description provided for @filterMarginNeedsData.
  ///
  /// In en, this message translates to:
  /// **'Needs data'**
  String get filterMarginNeedsData;

  /// No description provided for @filterHorizonAll.
  ///
  /// In en, this message translates to:
  /// **'All horizons'**
  String get filterHorizonAll;

  /// No description provided for @filterHorizonFast.
  ///
  /// In en, this message translates to:
  /// **'Fast'**
  String get filterHorizonFast;

  /// No description provided for @filterHorizonLongTerm.
  ///
  /// In en, this message translates to:
  /// **'Long-term'**
  String get filterHorizonLongTerm;

  /// No description provided for @filterHorizonUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get filterHorizonUnknown;

  /// No description provided for @filterCategoryNone.
  ///
  /// In en, this message translates to:
  /// **'No categories yet.'**
  String get filterCategoryNone;

  /// No description provided for @filterCategoryAll.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get filterCategoryAll;

  /// No description provided for @haulEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit haul'**
  String get haulEditTitle;

  /// No description provided for @haulEditNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get haulEditNameLabel;

  /// No description provided for @haulEditDateValue.
  ///
  /// In en, this message translates to:
  /// **'Date: {year}-{month}-{day}'**
  String haulEditDateValue(Object year, Object month, Object day);

  /// No description provided for @haulEditPickDate.
  ///
  /// In en, this message translates to:
  /// **'Pick date'**
  String get haulEditPickDate;

  /// No description provided for @haulEditLatitudeOptional.
  ///
  /// In en, this message translates to:
  /// **'Latitude (optional)'**
  String get haulEditLatitudeOptional;

  /// No description provided for @haulEditLongitudeOptional.
  ///
  /// In en, this message translates to:
  /// **'Longitude (optional)'**
  String get haulEditLongitudeOptional;

  /// No description provided for @accountDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get accountDeletionTitle;

  /// No description provided for @accountDeletionHeadline.
  ///
  /// In en, this message translates to:
  /// **'Account deletion'**
  String get accountDeletionHeadline;

  /// No description provided for @accountDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'Delete your cloud data and permanently delete your account. This action cannot be undone.'**
  String get accountDeletionBody;

  /// No description provided for @accountDeletionLocalOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Cloud account deletion requires Supabase to be configured. You can still delete local data from Privacy & data.'**
  String get accountDeletionLocalOnlyHint;

  /// No description provided for @accountDeletionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get accountDeletionConfirm;

  /// No description provided for @accountDeletionConfirmCta.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account'**
  String get accountDeletionConfirmCta;

  /// No description provided for @accountDeletionNoAuth.
  ///
  /// In en, this message translates to:
  /// **'Sign in to delete your account.'**
  String get accountDeletionNoAuth;

  /// No description provided for @accountDeletionNoCloud.
  ///
  /// In en, this message translates to:
  /// **'Cloud is not configured.'**
  String get accountDeletionNoCloud;

  /// No description provided for @accountDeletionDangerTitle.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete account?'**
  String get accountDeletionDangerTitle;

  /// No description provided for @accountDeletionDangerBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete your cloud data and your account. You will be signed out.'**
  String get accountDeletionDangerBody;

  /// No description provided for @accountDeletionDone.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested.'**
  String get accountDeletionDone;

  /// No description provided for @accountDeletionFailed.
  ///
  /// In en, this message translates to:
  /// **'Account deletion failed: {error}'**
  String accountDeletionFailed(Object error);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get privacyTitle;

  /// No description provided for @privacyStorageTitle.
  ///
  /// In en, this message translates to:
  /// **'What’s stored'**
  String get privacyStorageTitle;

  /// No description provided for @privacyStorageBodyLocalOnly.
  ///
  /// In en, this message translates to:
  /// **'Your hauls, items, drafts, and photos are stored on this device. Price comps and sync are disabled when you’re offline.'**
  String get privacyStorageBodyLocalOnly;

  /// No description provided for @privacyStorageBodyCloud.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored locally. If cloud sync is enabled, haul/item metadata and scan photos can also be synced to Supabase.'**
  String get privacyStorageBodyCloud;

  /// No description provided for @privacyExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get privacyExportTitle;

  /// No description provided for @privacyExportBody.
  ///
  /// In en, this message translates to:
  /// **'Exports are written to a file and the file path is copied to your clipboard.'**
  String get privacyExportBody;

  /// No description provided for @privacyExportJson.
  ///
  /// In en, this message translates to:
  /// **'Export JSON'**
  String get privacyExportJson;

  /// No description provided for @privacyExportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export CSV'**
  String get privacyExportCsv;

  /// No description provided for @privacyExporting.
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get privacyExporting;

  /// No description provided for @privacyExportedPathCopied.
  ///
  /// In en, this message translates to:
  /// **'Exported. Path copied: {path}'**
  String privacyExportedPathCopied(Object path);

  /// No description provided for @privacyExportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String privacyExportFailed(Object error);

  /// No description provided for @privacyToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get privacyToolsTitle;

  /// No description provided for @privacyToolsBody.
  ///
  /// In en, this message translates to:
  /// **'Maintenance and diagnostics for troubleshooting.'**
  String get privacyToolsBody;

  /// No description provided for @privacyClearScanCache.
  ///
  /// In en, this message translates to:
  /// **'Clear scan cache'**
  String get privacyClearScanCache;

  /// No description provided for @privacyCacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cleared {count} cached file(s).'**
  String privacyCacheCleared(Object count);

  /// No description provided for @privacyCacheClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Cache clear failed: {error}'**
  String privacyCacheClearFailed(Object error);

  /// No description provided for @privacyCopyDiagnostics.
  ///
  /// In en, this message translates to:
  /// **'Copy diagnostics'**
  String get privacyCopyDiagnostics;

  /// No description provided for @privacyDiagnosticsCopied.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics copied.'**
  String get privacyDiagnosticsCopied;

  /// No description provided for @privacyDiagnosticsCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'Copy failed: {error}'**
  String privacyDiagnosticsCopyFailed(Object error);

  /// No description provided for @privacyClearing.
  ///
  /// In en, this message translates to:
  /// **'Clearing…'**
  String get privacyClearing;

  /// No description provided for @privacyCopying.
  ///
  /// In en, this message translates to:
  /// **'Copying…'**
  String get privacyCopying;

  /// No description provided for @privacyDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get privacyDeleteTitle;

  /// No description provided for @privacyDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'Deleting is permanent. Local delete removes your on-device data. Cloud delete removes your synced data from Supabase.'**
  String get privacyDeleteBody;

  /// No description provided for @privacyDeleteLocalCta.
  ///
  /// In en, this message translates to:
  /// **'Delete local data'**
  String get privacyDeleteLocalCta;

  /// No description provided for @privacyDeleteCloudCta.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud data'**
  String get privacyDeleteCloudCta;

  /// No description provided for @privacyDeleteAccountCta.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get privacyDeleteAccountCta;

  /// No description provided for @privacyDeleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting…'**
  String get privacyDeleting;

  /// No description provided for @privacyDeleteLocalTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete local data?'**
  String get privacyDeleteLocalTitle;

  /// No description provided for @privacyDeleteLocalBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete all hauls, items, drafts, and scan photos stored on this device for the current profile.'**
  String get privacyDeleteLocalBody;

  /// No description provided for @privacyDeleteLocalDone.
  ///
  /// In en, this message translates to:
  /// **'Local data deleted.'**
  String get privacyDeleteLocalDone;

  /// No description provided for @privacyDeleteCloudTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete cloud data?'**
  String get privacyDeleteCloudTitle;

  /// No description provided for @privacyDeleteCloudBody.
  ///
  /// In en, this message translates to:
  /// **'This will delete synced hauls/items and attempt to remove scan photos from cloud storage.'**
  String get privacyDeleteCloudBody;

  /// No description provided for @privacyDeleteCloudDone.
  ///
  /// In en, this message translates to:
  /// **'Cloud delete done. Items: {items}, Hauls: {hauls}, Photos: {objects}'**
  String privacyDeleteCloudDone(Object items, Object hauls, Object objects);

  /// No description provided for @privacyDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed: {error}'**
  String privacyDeleteFailed(Object error);

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'A short, plain-language summary of how Loppisfynd handles your data.'**
  String get privacyPolicySubtitle;

  /// No description provided for @privacyPolicyOpen.
  ///
  /// In en, this message translates to:
  /// **'Read policy'**
  String get privacyPolicyOpen;

  /// No description provided for @privacyPolicyCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get privacyPolicyCopy;

  /// No description provided for @privacyPolicyCopied.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy copied.'**
  String get privacyPolicyCopied;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Loppisfynd stores your hauls, items, drafts, and scan photos on your device.\n\nIf you enable cloud sync, haul/item metadata and scan photos may be uploaded to your Supabase project so you can restore them after reinstall and use sync features.\n\nPrice comps are fetched from Tradera via a proxy when you are online.\n\nYou can export your data and delete local and cloud data from the Privacy & data screen.'**
  String get privacyPolicyBody;

  /// No description provided for @syncStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync status'**
  String get syncStatusTitle;

  /// No description provided for @syncStatusActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get syncStatusActionsTitle;

  /// No description provided for @syncStatusOnline.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get syncStatusOnline;

  /// No description provided for @syncStatusOffline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get syncStatusOffline;

  /// No description provided for @syncStatusSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncStatusSyncNow;

  /// No description provided for @syncStatusAllGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'All good'**
  String get syncStatusAllGoodTitle;

  /// No description provided for @syncStatusAllGoodMessage.
  ///
  /// In en, this message translates to:
  /// **'No sync problems detected.'**
  String get syncStatusAllGoodMessage;

  /// No description provided for @syncStatusProblemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Problems'**
  String get syncStatusProblemsTitle;

  /// No description provided for @loginAppName.
  ///
  /// In en, this message translates to:
  /// **'Loppisfynd'**
  String get loginAppName;

  /// No description provided for @loginTagline.
  ///
  /// In en, this message translates to:
  /// **'Scan. Decide. Flip.'**
  String get loginTagline;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get loginEmailLabel;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginWorking.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get loginWorking;

  /// No description provided for @loginSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginSignIn;

  /// No description provided for @loginSignUp.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get loginSignUp;

  /// No description provided for @loginAccountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created. You can sign in now.'**
  String get loginAccountCreated;

  /// No description provided for @loginOfflineFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Offline-first: scanning works without internet. Market data requires sync.'**
  String get loginOfflineFirstNote;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginWelcome;

  /// No description provided for @loginContinueAs.
  ///
  /// In en, this message translates to:
  /// **'Continue as {identity}'**
  String loginContinueAs(Object identity);

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get loginForgotPassword;

  /// No description provided for @loginSendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get loginSendCode;

  /// No description provided for @loginVerifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get loginVerifyCode;

  /// No description provided for @loginCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get loginCodeLabel;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get loginErrorGeneric;

  /// No description provided for @errorSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorSomethingWentWrong;

  /// No description provided for @syncStatusRowStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'{status} · {timestamp}'**
  String syncStatusRowStatusUpdated(String status, String timestamp);

  /// No description provided for @itemDetailKeywordAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add keyword'**
  String get itemDetailKeywordAddTitle;

  /// No description provided for @itemDetailKeywordEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit keyword'**
  String get itemDetailKeywordEditTitle;

  /// No description provided for @itemDetailKeywordHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. rorstrand'**
  String get itemDetailKeywordHint;

  /// No description provided for @itemDetailUnnamedItem.
  ///
  /// In en, this message translates to:
  /// **'Unnamed item'**
  String get itemDetailUnnamedItem;

  /// No description provided for @itemDetailStatusValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String itemDetailStatusValue(String status);

  /// No description provided for @itemDetailMarketTitle.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get itemDetailMarketTitle;

  /// No description provided for @itemDetailAiConfidence.
  ///
  /// In en, this message translates to:
  /// **'AI confidence: {percent}%'**
  String itemDetailAiConfidence(int percent);

  /// No description provided for @itemDetailStatMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get itemDetailStatMin;

  /// No description provided for @itemDetailStatMedian.
  ///
  /// In en, this message translates to:
  /// **'Median'**
  String get itemDetailStatMedian;

  /// No description provided for @itemDetailStatMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get itemDetailStatMax;

  /// No description provided for @itemDetailIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying…'**
  String get itemDetailIdentifying;

  /// No description provided for @itemDetailIdentifyNow.
  ///
  /// In en, this message translates to:
  /// **'Identify now'**
  String get itemDetailIdentifyNow;

  /// No description provided for @itemDetailDraftListing.
  ///
  /// In en, this message translates to:
  /// **'Draft listing'**
  String get itemDetailDraftListing;

  /// No description provided for @itemDetailTraderaQueryLabel.
  ///
  /// In en, this message translates to:
  /// **'Tradera query'**
  String get itemDetailTraderaQueryLabel;

  /// No description provided for @itemDetailTraderaQueryHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. rorstrand mon amie plate'**
  String get itemDetailTraderaQueryHint;

  /// No description provided for @itemDetailQueueSync.
  ///
  /// In en, this message translates to:
  /// **'Queue sync'**
  String get itemDetailQueueSync;

  /// No description provided for @itemDetailQueuedForSync.
  ///
  /// In en, this message translates to:
  /// **'Queued for sync.'**
  String get itemDetailQueuedForSync;

  /// No description provided for @itemDetailSyncCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sync completed.'**
  String get itemDetailSyncCompleted;

  /// No description provided for @itemDetailLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated: {timestamp}'**
  String itemDetailLastUpdated(String timestamp);

  /// No description provided for @itemDetailFeatureState.
  ///
  /// In en, this message translates to:
  /// **'{feature}: {state}'**
  String itemDetailFeatureState(String feature, String state);

  /// No description provided for @itemDetailLastSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Last sync failed'**
  String get itemDetailLastSyncFailed;

  /// No description provided for @itemDetailNextAttempt.
  ///
  /// In en, this message translates to:
  /// **'Next attempt: {timestamp}'**
  String itemDetailNextAttempt(String timestamp);

  /// No description provided for @itemDetailProfitTitle.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get itemDetailProfitTitle;

  /// No description provided for @itemDetailPurchasePriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Purchase price (SEK)'**
  String get itemDetailPurchasePriceLabel;

  /// No description provided for @itemDetailFixedFeesLabel.
  ///
  /// In en, this message translates to:
  /// **'Fixed fees (SEK)'**
  String get itemDetailFixedFeesLabel;

  /// No description provided for @itemDetailShippingSellerLabel.
  ///
  /// In en, this message translates to:
  /// **'Shipping (seller) (SEK)'**
  String get itemDetailShippingSellerLabel;

  /// No description provided for @itemDetailNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get itemDetailNotesLabel;

  /// No description provided for @itemDetailNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. defects, missing parts, color'**
  String get itemDetailNotesHint;

  /// No description provided for @itemDetailNoMarketDataYet.
  ///
  /// In en, this message translates to:
  /// **'No market data yet.'**
  String get itemDetailNoMarketDataYet;

  /// No description provided for @itemDetailConditionTitle.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get itemDetailConditionTitle;

  /// No description provided for @itemDetailConditionValue.
  ///
  /// In en, this message translates to:
  /// **'{label} ({percent}%)'**
  String itemDetailConditionValue(String label, String percent);

  /// No description provided for @itemDetailConditionMint.
  ///
  /// In en, this message translates to:
  /// **'Mint'**
  String get itemDetailConditionMint;

  /// No description provided for @itemDetailConditionGood.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get itemDetailConditionGood;

  /// No description provided for @itemDetailConditionFair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get itemDetailConditionFair;

  /// No description provided for @itemDetailConditionRough.
  ///
  /// In en, this message translates to:
  /// **'Rough'**
  String get itemDetailConditionRough;

  /// No description provided for @itemDetailFlipLabel.
  ///
  /// In en, this message translates to:
  /// **'Flip'**
  String get itemDetailFlipLabel;

  /// No description provided for @itemDetailKeywordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get itemDetailKeywordsTitle;

  /// No description provided for @authTitleWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get authTitleWelcome;

  /// No description provided for @authModeSignUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authModeSignUp;

  /// No description provided for @authModeSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authModeSignIn;

  /// No description provided for @authEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get authEmailLabel;

  /// No description provided for @authEmailHint.
  ///
  /// In en, this message translates to:
  /// **'name@example.com'**
  String get authEmailHint;

  /// No description provided for @authCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get authCodeLabel;

  /// No description provided for @authCtaCreateAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCtaCreateAccount;

  /// No description provided for @authCtaSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authCtaSignIn;

  /// No description provided for @authVerify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get authVerify;

  /// No description provided for @authResendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get authResendCode;

  /// No description provided for @authTroubleLink.
  ///
  /// In en, this message translates to:
  /// **'Trouble signing in?'**
  String get authTroubleLink;

  /// No description provided for @authTroubleTitle.
  ///
  /// In en, this message translates to:
  /// **'Trouble signing in?'**
  String get authTroubleTitle;

  /// No description provided for @authTroubleBody.
  ///
  /// In en, this message translates to:
  /// **'Check your spam folder and try resending a new code. If it still doesn’t work, try another email address.'**
  String get authTroubleBody;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong: {message}'**
  String authError(String message);

  /// No description provided for @homeHeroTitle.
  ///
  /// In en, this message translates to:
  /// **'Start Scanner'**
  String get homeHeroTitle;

  /// No description provided for @homeHeroBody.
  ///
  /// In en, this message translates to:
  /// **'Scan the price tag. Save offline. Sync prices when you’re online.'**
  String get homeHeroBody;

  /// No description provided for @homeTileActiveFinds.
  ///
  /// In en, this message translates to:
  /// **'Active finds'**
  String get homeTileActiveFinds;

  /// No description provided for @homeTileProfitEst.
  ///
  /// In en, this message translates to:
  /// **'Profit (est.)'**
  String get homeTileProfitEst;

  /// No description provided for @homeTileDrafts.
  ///
  /// In en, this message translates to:
  /// **'Drafts'**
  String get homeTileDrafts;

  /// No description provided for @homeTileHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get homeTileHistory;

  /// No description provided for @homeTileCtaOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get homeTileCtaOpen;

  /// No description provided for @homeTileCtaSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeTileCtaSeeAll;

  /// No description provided for @haulUnnamedFind.
  ///
  /// In en, this message translates to:
  /// **'Unnamed find'**
  String get haulUnnamedFind;

  /// No description provided for @haulStatusIdentifying.
  ///
  /// In en, this message translates to:
  /// **'Identifying…'**
  String get haulStatusIdentifying;

  /// No description provided for @haulStatusSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get haulStatusSaved;

  /// No description provided for @haulTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Total value: {value}'**
  String haulTotalValue(String value);

  /// No description provided for @draftTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get draftTitleLabel;

  /// No description provided for @draftDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get draftDescriptionLabel;

  /// No description provided for @draftPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Price (SEK)'**
  String get draftPriceLabel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;
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
