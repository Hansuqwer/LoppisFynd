// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Swedish (`sv`).
class AppLocalizationsSv extends AppLocalizations {
  AppLocalizationsSv([String locale = 'sv']) : super(locale);

  @override
  String get tabHome => 'Hem';

  @override
  String get tabScan => 'Skanna';

  @override
  String get tabHaul => 'Fynd';

  @override
  String get tabHistory => 'Historik';

  @override
  String get tabProfile => 'Profil';

  @override
  String get appTitle => 'Loppisfynd';

  @override
  String snackbarSavedScan(Object id) {
    return 'Sparade fynd $id.';
  }

  @override
  String snackbarCaptureFailed(Object error) {
    return 'Kunde inte spara: $error';
  }

  @override
  String get snackbarCopiedBarcode => 'Kopierade streckkod.';

  @override
  String get settingsAccessibility => 'Tillgänglighet';

  @override
  String get settingsHighContrast => 'Hög kontrast';

  @override
  String get settingsContrastUpdated => 'Uppdaterade kontrastinställning.';

  @override
  String get onboardingWelcomeTitle => 'Välkommen';

  @override
  String get onboardingWelcomeBody =>
      'Skanna i butik, spara offline och hämta sålddata när du är online.';

  @override
  String get onboardingPermissionsTitle => 'Behörigheter';

  @override
  String get onboardingPermissionsBody =>
      'Kamera krävs för att skanna. Plats är valfritt och används bara för att namnge fynd på kartan.';

  @override
  String get onboardingOfflineTitle => 'Offline först';

  @override
  String get onboardingOfflineBody =>
      'Allt fungerar utan internet förutom prishämtning. Din data stannar på enheten om du inte aktiverar molnsynk.';

  @override
  String get onboardingContinue => 'Fortsätt';

  @override
  String get onboardingStart => 'Börja';

  @override
  String get onboardingSkip => 'Hoppa över';

  @override
  String get bannerOffline => 'Offline-läge: prishämtning är pausad.';

  @override
  String get buttonRetry => 'Försök igen';

  @override
  String get commonCancel => 'Avbryt';

  @override
  String get commonCreate => 'Skapa';

  @override
  String get commonDelete => 'Ta bort';

  @override
  String get commonInstall => 'Installera';

  @override
  String get commonOff => 'Av';

  @override
  String get commonHaul => 'Fynd';

  @override
  String get errorCameraTitle => 'Kamerafel';

  @override
  String get historyEmptyTitle => 'Inga fynd ännu';

  @override
  String get historyEmptyMessage =>
      'Skapa ett fynd för att börja spåra dina köp.';

  @override
  String get historyTreasureMapTitle => 'Skattkarta';

  @override
  String get historyHistoryTitle => 'Historik';

  @override
  String get historyNewHaulTitle => 'Nytt fynd';

  @override
  String get historyHaulTitleLabel => 'Titel';

  @override
  String get historySuggestNameTooltip => 'Föreslå namn';

  @override
  String get historyEnterLatLngFirst => 'Fyll i latitud och longitud först.';

  @override
  String get historyHaulLatitudeOptionalLabel => 'Latitud (valfritt)';

  @override
  String get historyHaulLongitudeOptionalLabel => 'Longitud (valfritt)';

  @override
  String get historyFilterAll => 'Alla';

  @override
  String get historyFilterProfit => 'Vinst';

  @override
  String get historyFilterLoss => 'Förlust';

  @override
  String historyPinnedHaulsCount(Object count) {
    return '$count pinnade fynd';
  }

  @override
  String get historyNoPinnedHaulsYet => 'Inga pinnade fynd ännu.';

  @override
  String get dashboardTitle => 'Jagarens tavla';

  @override
  String get dashboardSubtitle => 'Marknadspuls och senaste fynd.';

  @override
  String get dashboardQuickScan => 'Snabbskanna';

  @override
  String get dashboardHaulSummary => 'Fyndsammanfattning';

  @override
  String get scannerTitle => 'Snabbskanner';

  @override
  String get scannerSubtitle => 'Fota, spara, skapa miniatyr och köa comps.';

  @override
  String get scannerCapture => 'Fota';

  @override
  String get scannerSaving => 'Sparar…';

  @override
  String get scannerDoneScanning => 'Klar';

  @override
  String scannerQueuedItems(Object count) {
    return 'Köade $count fynd för synk.';
  }

  @override
  String scannerQueueFailed(Object error) {
    return 'Kunde inte köa: $error';
  }

  @override
  String get scannerNoCamerasAvailable =>
      'Inga kameror tillgängliga på den här enheten.';

  @override
  String scannerCameraInitFailed(Object error) {
    return 'Kunde inte starta kameran: $error';
  }

  @override
  String get scannerBarcodeAimHint =>
      'Rikta mot en streckkod för att upptäcka direkt.';

  @override
  String get scannerNoScansYet => 'Inga skanningar ännu.';

  @override
  String get scannerBatchTrayTitle => 'Skanningsbricka';

  @override
  String get haulTitle => 'Aktuellt fynd';

  @override
  String get haulSubtitle =>
      'Offline först. Lägg till medan du skannar, synka comps när du är online.';

  @override
  String get haulItems => 'Fynd';

  @override
  String get haulReady => 'Klart';

  @override
  String get haulExpected => 'Förväntat';

  @override
  String get haulNetEst => 'Netto (est.)';

  @override
  String get haulOpenSummary => 'Öppna sammanfattning';

  @override
  String get settingsMarketSyncTitle => 'Marknadssynk';

  @override
  String get settingsTraderaProxyConfigured => 'Tradera-proxy konfigurerad.';

  @override
  String get settingsTraderaProxyNotConfigured =>
      'Tradera-proxy är inte konfigurerad.';

  @override
  String settingsTraderaProxyRunWith(Object command) {
    return 'Kör med: $command';
  }

  @override
  String get settingsBackgroundInterval => 'Bakgrundsintervall';

  @override
  String get settingsInterval1h => '1h';

  @override
  String get settingsInterval6h => '6h';

  @override
  String get settingsInterval24h => '24h';

  @override
  String get settingsSavedSyncInterval => 'Sparade synkintervall.';

  @override
  String get settingsQuotaUnknown => 'Kvot: —';

  @override
  String settingsQuotaUsedToday(Object used) {
    return 'Kvot använd idag: $used';
  }

  @override
  String get settingsSyncNow => 'Synka nu';

  @override
  String get settingsSyncing => 'Synkar…';

  @override
  String get settingsMarketSyncCompleted => 'Synk klar.';

  @override
  String settingsMarketSyncFailed(Object error) {
    return 'Synk misslyckades: $error';
  }

  @override
  String get settingsCloudSyncTitle => 'Molnsynk';

  @override
  String get settingsSupabaseConfigured => 'Supabase konfigurerad.';

  @override
  String get settingsSupabaseNotConfigured => 'Supabase är inte konfigurerad.';

  @override
  String get settingsNotSignedIn => 'Inte inloggad.';

  @override
  String settingsSignedInAs(Object email) {
    return 'Inloggad som $email';
  }

  @override
  String get settingsSyncMetadata => 'Synka metadata';

  @override
  String get settingsSyncPhotos => 'Synka bilder';

  @override
  String get settingsCloudSyncCompleted => 'Molnsynk klar.';

  @override
  String settingsCloudSyncFailed(Object error) {
    return 'Molnsynk misslyckades: $error';
  }

  @override
  String get settingsPhotoSyncCompleted => 'Bildsynk klar.';

  @override
  String settingsPhotoSyncFailed(Object error) {
    return 'Bildsynk misslyckades: $error';
  }

  @override
  String get settingsOnDeviceModelTitle => 'Modell på enheten';

  @override
  String get settingsModelChecking => 'Kontrollerar…';

  @override
  String settingsModelInstalled(Object bytes) {
    return 'Installerad ($bytes byte)';
  }

  @override
  String get settingsModelNotInstalled => 'Inte installerad';

  @override
  String settingsModelExpectedPath(Object path) {
    return 'Förväntad sökväg: $path';
  }

  @override
  String get settingsDownloading => 'Laddar ner…';

  @override
  String get settingsDownloadModel => 'Ladda ner modell';

  @override
  String get settingsInstallFromFilePathLabel => 'Installera från filsökväg';

  @override
  String get settingsInstallFromFilePathHint => '/path/to/gemma_vision.task';
}
