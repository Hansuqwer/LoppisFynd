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
  String get onboardingStart => 'Kom igång';

  @override
  String get onboardingSkip => 'Hoppa över';

  @override
  String get onboardingBack => 'Tillbaka';

  @override
  String get onboardingDownloadNow => 'Ladda ner nu';

  @override
  String get onboardingNotNow => 'Inte nu';

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
  String get commonSave => 'Spara';

  @override
  String get commonAdd => 'Lägg till';

  @override
  String get errorCameraTitle => 'Kamerafel';

  @override
  String get historyEmptyTitle => 'Dags för en fika?';

  @override
  String get historyEmptyMessage =>
      'Inga historiska fynd ännu.\nGe dig ut och scanna!';

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
  String get historySuggestNameFailed => 'Kunde inte föreslå ett namn.';

  @override
  String get historyEnterLatLngFirst => 'Fyll i latitud och longitud först.';

  @override
  String get historyHaulLatitudeOptionalLabel => 'Latitud (valfritt)';

  @override
  String get historyHaulLongitudeOptionalLabel => 'Longitud (valfritt)';

  @override
  String get historyLocationOptionalHint =>
      'Plats är valfritt. Det hjälper att fästa fynd på kartan och föreslå namn.';

  @override
  String get historyUseCurrentLocation => 'Använd nuvarande';

  @override
  String get historyLocationFetching => 'Hämtar…';

  @override
  String get historyLocationPermissionTitle => 'Platsbehörighet';

  @override
  String get historyLocationPermissionBody =>
      'Aktivera plats för att fästa fynd på kartan och automatiskt föreslå namn. Appen fungerar utan det.';

  @override
  String get historyLocationPermissionContinue => 'Fortsätt';

  @override
  String get historyLocationPermissionNotNow => 'Inte nu';

  @override
  String get historyLocationPermissionDenied =>
      'Platsbehörighet krävs för att använda nuvarande plats.';

  @override
  String get historyLocationPermissionPermanentlyDenied =>
      'Platsbehörigheten är avstängd. Öppna inställningar för att aktivera den.';

  @override
  String get historyFilterAll => 'Alla';

  @override
  String get historyFilterProfit => 'Vinst';

  @override
  String get historyFilterLoss => 'Förlust';

  @override
  String get historyViewBoth => 'Båda';

  @override
  String get historyViewMap => 'Karta';

  @override
  String get historyViewList => 'Lista';

  @override
  String get historySortRecent => 'Senaste';

  @override
  String get historySortProfit => 'Bäst marginal';

  @override
  String get historySearchLabel => 'Sök';

  @override
  String get historySearchHint => 'Sök i historik…';

  @override
  String get historyCategoryAll => 'Alla kategorier';

  @override
  String historyPinnedHaulsCount(Object count) {
    return '$count pinnade fynd';
  }

  @override
  String get historyNoPinnedHaulsYet => 'Inga pinnade fynd ännu.';

  @override
  String get historyHaulsTitle => 'Fynd';

  @override
  String get historyNoMatchesTitle => 'Inga träffar';

  @override
  String get historyNoMatchesMessage =>
      'Prova att ändra sökningen eller dina filter.';

  @override
  String get dashboardTitle => 'Jagarens tavla';

  @override
  String get dashboardSubtitle => 'Marknadspuls och senaste fynd.';

  @override
  String get dashboardQuickScan => 'Snabbskanna';

  @override
  String get dashboardHaulSummary => 'Fyndsammanfattning';

  @override
  String get dashboardDraftsTitle => 'Utkast';

  @override
  String get dashboardSeeAll => 'Se alla';

  @override
  String get dashboardNoDraftsYet => 'Inga utkast ännu.';

  @override
  String get dashboardUntitledDraft => 'Namnlöst utkast';

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
  String get scannerCameraPermissionTitle => 'Kamerabehörighet';

  @override
  String get scannerCameraPermissionBody =>
      'Loppisfynd behöver kameran för att skanna fynd. Bilder stannar på din enhet om du inte aktiverar molnsynk.';

  @override
  String get scannerCameraPermissionContinue => 'Fortsätt';

  @override
  String get scannerCameraPermissionNotNow => 'Inte nu';

  @override
  String get scannerCameraPermissionDenied =>
      'Kamerabehörighet krävs för att skanna. Du kan aktivera den senare.';

  @override
  String get scannerCameraPermissionPermanentlyDenied =>
      'Kamerabehörigheten är avstängd. Öppna inställningar för att aktivera den.';

  @override
  String get scannerCameraPermissionOpenSettings => 'Öppna inställningar';

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
  String get haulTitle => 'Pågående fynd';

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
  String get settingsAccountTitle => 'Konto';

  @override
  String get settingsSignOut => 'Logga ut';

  @override
  String get settingsSigningOut => 'Loggar ut…';

  @override
  String get settingsSignedOut => 'Utloggad.';

  @override
  String settingsSignOutFailed(Object error) {
    return 'Utloggning misslyckades: $error';
  }

  @override
  String get settingsDeleteAccount => 'Ta bort konto';

  @override
  String get settingsDisplayNameLabel => 'Visningsnamn';

  @override
  String get settingsDisplayNameHint => 'Ditt namn';

  @override
  String get settingsSaveProfile => 'Spara profil';

  @override
  String get settingsProfileSaved => 'Sparade profil.';

  @override
  String get settingsAiTitle => 'AI';

  @override
  String get settingsAiModeLabel => 'Läge';

  @override
  String get settingsAiEco => 'Eco';

  @override
  String get settingsAiQuality => 'Kvalitet';

  @override
  String get settingsAiModeSaved => 'Sparade AI-läge.';

  @override
  String get settingsPrivacyTitle => 'Integritet och data';

  @override
  String get settingsPrivacySubtitle =>
      'Exportera, radera lokal/molndata och se vad som sparas.';

  @override
  String get settingsOpenPrivacy => 'Öppna integritet';

  @override
  String get settingsSyncStatusTitle => 'Synkstatus';

  @override
  String get settingsSyncStatusSubtitle => 'Se synkhälsa, fel och konflikter.';

  @override
  String get settingsOpenSyncStatus => 'Öppna synkstatus';

  @override
  String get draftEditorTitle => 'Annonsutkast';

  @override
  String get draftEditorFieldsTitle => 'Utkastfält';

  @override
  String get draftEditorItemTitle => 'Fynd';

  @override
  String get draftEditorOpenAnalyzer => 'Öppna analys';

  @override
  String get draftEditorNoKeywordsYet => 'Inga nyckelord ännu.';

  @override
  String get draftEditorNoPhotosYet => 'Inga bilder ännu.';

  @override
  String get draftEditorTitleLabel => 'Titel';

  @override
  String get draftEditorTitleHint => 't.ex. Rorstrand Mon Amie tallrik';

  @override
  String get draftEditorDescriptionLabel => 'Beskrivning';

  @override
  String get draftEditorDescriptionHint => 'Skick, storlek, defekter…';

  @override
  String get draftEditorAskingPriceLabel => 'Begärt pris (kr)';

  @override
  String get draftEditorAskingPriceHint => '0';

  @override
  String get draftEditorSave => 'Spara utkast';

  @override
  String get draftEditorSaved => 'Utkast sparat.';

  @override
  String get draftEditorDelete => 'Ta bort';

  @override
  String get draftEditorDeleted => 'Utkast borttaget.';

  @override
  String get draftsTitle => 'Utkast';

  @override
  String get draftsEmptyTitle => 'Inga utkast ännu';

  @override
  String get draftsEmptyMessage =>
      'Skapa ett utkast från ett fynd för att spara annonstext och pris.';

  @override
  String get draftsUntitled => 'Namnlöst';

  @override
  String get draftsItemFallback => 'Namnlöst fynd';

  @override
  String get draftsOpenAnalyzer => 'Öppna analys';

  @override
  String draftsAskingPrice(Object sek) {
    return 'Begärt $sek kr';
  }

  @override
  String get itemDetailTitle => 'Fynd';

  @override
  String get itemDetailCategoryLabel => 'Kategori';

  @override
  String get itemDetailCategoryHint => 't.ex. keramik';

  @override
  String get haulSummaryTitle => 'Fyndsammanfattning';

  @override
  String get haulSummaryEmptyTitle => 'Inga föremål i detta fynd';

  @override
  String get haulSummaryEmptyMessage =>
      'Skanna föremål för att se totaler, vinstestimat och utkast.';

  @override
  String get haulSummaryTotalsTitle => 'Totaler';

  @override
  String get haulSummaryItems => 'Föremål';

  @override
  String get haulSummaryInvested => 'Insats';

  @override
  String get haulSummaryValue => 'Värde';

  @override
  String get haulSummaryNet => 'Netto';

  @override
  String get haulSummaryStatusComplete => 'Klart';

  @override
  String get haulSummaryStatusPending => 'Pågår';

  @override
  String get haulSummaryStatusFailed => 'Misslyckat';

  @override
  String get haulSummaryFiltersTitle => 'Filter';

  @override
  String haulSummaryShowingCount(Object count) {
    return 'Visar $count';
  }

  @override
  String get haulSummaryDraftsTitle => 'Utkast';

  @override
  String get haulSummaryNoDraftsYet => 'Inga utkast ännu för detta fynd.';

  @override
  String get haulSummaryInventoryTitle => 'Inventarie';

  @override
  String get haulSummaryNoMatchesTitle => 'Inga träffar';

  @override
  String get haulSummaryNoMatchesMessage => 'Prova att ändra dina filter.';

  @override
  String get haulSummaryUnnamedItem => 'Namnlöst fynd';

  @override
  String haulSummaryDaysToSell(Object days) {
    return '${days}d';
  }

  @override
  String get filterStatusAll => 'Alla';

  @override
  String get filterStatusComplete => 'Klart';

  @override
  String get filterStatusPending => 'Pågår';

  @override
  String get filterStatusFailed => 'Misslyckat';

  @override
  String get filterMarginAll => 'Alla marginaler';

  @override
  String get filterMarginProfit => 'Vinst';

  @override
  String get filterMarginHigh => 'Hög marginal';

  @override
  String get filterMarginNeedsData => 'Saknar data';

  @override
  String get filterHorizonAll => 'Alla horisonter';

  @override
  String get filterHorizonFast => 'Snabb';

  @override
  String get filterHorizonLongTerm => 'Långsiktig';

  @override
  String get filterHorizonUnknown => 'Okänd';

  @override
  String get filterCategoryNone => 'Inga kategorier ännu.';

  @override
  String get filterCategoryAll => 'Alla kategorier';

  @override
  String get haulEditTitle => 'Redigera fynd';

  @override
  String get haulEditNameLabel => 'Namn';

  @override
  String haulEditDateValue(Object year, Object month, Object day) {
    return 'Datum: $year-$month-$day';
  }

  @override
  String get haulEditPickDate => 'Välj datum';

  @override
  String get haulEditLatitudeOptional => 'Latitud (valfritt)';

  @override
  String get haulEditLongitudeOptional => 'Longitud (valfritt)';

  @override
  String get accountDeletionTitle => 'Ta bort konto';

  @override
  String get accountDeletionHeadline => 'Kontoborttagning';

  @override
  String get accountDeletionBody =>
      'Radera din molndata och ta bort ditt konto permanent. Detta kan inte ångras.';

  @override
  String get accountDeletionLocalOnlyHint =>
      'Kontoborttagning i molnet kräver att Supabase är konfigurerat. Du kan fortfarande radera lokal data via Integritet och data.';

  @override
  String get accountDeletionConfirm => 'Ta bort';

  @override
  String get accountDeletionConfirmCta => 'Ta bort konto permanent';

  @override
  String get accountDeletionNoAuth => 'Logga in för att ta bort ditt konto.';

  @override
  String get accountDeletionNoCloud => 'Moln är inte konfigurerat.';

  @override
  String get accountDeletionDangerTitle => 'Ta bort konto permanent?';

  @override
  String get accountDeletionDangerBody =>
      'Detta raderar din molndata och ditt konto. Du loggas ut.';

  @override
  String get accountDeletionDone => 'Kontoborttagning begärd.';

  @override
  String accountDeletionFailed(Object error) {
    return 'Kontoborttagning misslyckades: $error';
  }

  @override
  String get privacyTitle => 'Integritet och data';

  @override
  String get privacyStorageTitle => 'Vad som sparas';

  @override
  String get privacyStorageBodyLocalOnly =>
      'Dina fynd, föremål, utkast och bilder sparas på den här enheten. Prishämtning och synk kräver internet.';

  @override
  String get privacyStorageBodyCloud =>
      'Din data sparas lokalt. Om molnsynk är aktiverad kan fynd/föremålsdata och skanningsbilder också synkas till Supabase.';

  @override
  String get privacyExportTitle => 'Export';

  @override
  String get privacyExportBody =>
      'Exporten skrivs till en fil och filsökvägen kopieras till urklipp.';

  @override
  String get privacyExportJson => 'Exportera JSON';

  @override
  String get privacyExportCsv => 'Exportera CSV';

  @override
  String get privacyExporting => 'Exporterar…';

  @override
  String privacyExportedPathCopied(Object path) {
    return 'Exporterad. Sökväg kopierad: $path';
  }

  @override
  String privacyExportFailed(Object error) {
    return 'Export misslyckades: $error';
  }

  @override
  String get privacyToolsTitle => 'Verktyg';

  @override
  String get privacyToolsBody => 'Underhåll och diagnostik för felsökning.';

  @override
  String get privacyClearScanCache => 'Rensa skanningscache';

  @override
  String privacyCacheCleared(Object count) {
    return 'Rensade $count cachad fil(er).';
  }

  @override
  String privacyCacheClearFailed(Object error) {
    return 'Kunde inte rensa cache: $error';
  }

  @override
  String get privacyCopyDiagnostics => 'Kopiera diagnostik';

  @override
  String get privacyDiagnosticsCopied => 'Diagnostik kopierad.';

  @override
  String privacyDiagnosticsCopyFailed(Object error) {
    return 'Kopiering misslyckades: $error';
  }

  @override
  String get privacyClearing => 'Rensar…';

  @override
  String get privacyCopying => 'Kopierar…';

  @override
  String get privacyDeleteTitle => 'Radera';

  @override
  String get privacyDeleteBody =>
      'Radering är permanent. Lokal radering tar bort data på enheten. Molnradering tar bort synkad data från Supabase.';

  @override
  String get privacyDeleteLocalCta => 'Radera lokal data';

  @override
  String get privacyDeleteCloudCta => 'Radera molndata';

  @override
  String get privacyDeleteAccountCta => 'Ta bort konto';

  @override
  String get privacyDeleting => 'Raderar…';

  @override
  String get privacyDeleteLocalTitle => 'Radera lokal data?';

  @override
  String get privacyDeleteLocalBody =>
      'Detta raderar alla fynd, föremål, utkast och skanningsbilder som sparats på den här enheten för aktuell profil.';

  @override
  String get privacyDeleteLocalDone => 'Lokal data raderad.';

  @override
  String get privacyDeleteCloudTitle => 'Radera molndata?';

  @override
  String get privacyDeleteCloudBody =>
      'Detta raderar synkade fynd/föremål och försöker ta bort skanningsbilder från molnlagring.';

  @override
  String privacyDeleteCloudDone(Object items, Object hauls, Object objects) {
    return 'Molnradering klar. Föremål: $items, Fynd: $hauls, Bilder: $objects';
  }

  @override
  String privacyDeleteFailed(Object error) {
    return 'Radering misslyckades: $error';
  }

  @override
  String get privacyPolicyTitle => 'Integritetspolicy';

  @override
  String get privacyPolicySubtitle =>
      'En kort sammanfattning av hur Loppisfynd hanterar din data.';

  @override
  String get privacyPolicyOpen => 'Läs policy';

  @override
  String get privacyPolicyCopy => 'Kopiera';

  @override
  String get privacyPolicyCopied => 'Integritetspolicy kopierad.';

  @override
  String get privacyPolicyBody =>
      'Loppisfynd sparar dina fynd, föremål, utkast och skanningsbilder på din enhet.\n\nOm du aktiverar molnsynk kan fynd/föremålsdata och skanningsbilder laddas upp till ditt Supabase-projekt så att du kan återställa dem efter ominstallation och använda synkfunktioner.\n\nPrishistorik hämtas från Tradera via en proxy när du är online.\n\nDu kan exportera din data och radera lokal och molndata från skärmen Integritet och data.';

  @override
  String get syncStatusTitle => 'Synkstatus';

  @override
  String get syncStatusActionsTitle => 'Åtgärder';

  @override
  String get syncStatusOnline => 'Online';

  @override
  String get syncStatusOffline => 'Offline';

  @override
  String get syncStatusSyncNow => 'Synka nu';

  @override
  String get syncStatusAllGoodTitle => 'Allt ser bra ut';

  @override
  String get syncStatusAllGoodMessage => 'Inga synkproblem upptäckta.';

  @override
  String get syncStatusProblemsTitle => 'Problem';

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
  String get settingsInstallFromFilePathHint =>
      '/path/to/gemma_vision.litertlm';

  @override
  String get loginAppName => 'Loppisfynd';

  @override
  String get loginTagline => 'Skanna. Bestäm. Flippa.';

  @override
  String get loginTitle => 'Logga in';

  @override
  String get loginEmailLabel => 'Användarnamn';

  @override
  String get loginPasswordLabel => 'Lösenord';

  @override
  String get loginWorking => 'Arbetar…';

  @override
  String get loginSignIn => 'Logga in';

  @override
  String get loginSignUp => 'Skapa konto';

  @override
  String get loginAccountCreated => 'Konto skapat. Du kan logga in nu.';

  @override
  String get loginOfflineFirstNote =>
      'Offline-först: skanning fungerar utan internet. Marknadsdata kräver synk.';

  @override
  String get loginWelcome => 'Välkommen';

  @override
  String loginContinueAs(Object identity) {
    return 'Fortsätt som $identity';
  }

  @override
  String get loginForgotPassword => 'Glömt lösenord?';

  @override
  String get loginSendCode => 'Skicka kod';

  @override
  String get loginVerifyCode => 'Verifiera kod';

  @override
  String get loginCodeLabel => 'Kod';

  @override
  String get loginErrorGeneric => 'Något gick fel.';

  @override
  String get errorSomethingWentWrong => 'Något gick fel.';

  @override
  String syncStatusRowStatusUpdated(String status, String timestamp) {
    return '$status · $timestamp';
  }

  @override
  String get itemDetailKeywordAddTitle => 'Lägg till nyckelord';

  @override
  String get itemDetailKeywordEditTitle => 'Redigera nyckelord';

  @override
  String get itemDetailKeywordHint => 't.ex. rorstrand';

  @override
  String get itemDetailUnnamedItem => 'Namnlöst fynd';

  @override
  String itemDetailStatusValue(String status) {
    return 'Status: $status';
  }

  @override
  String get itemDetailMarketTitle => 'Marknad';

  @override
  String itemDetailAiConfidence(int percent) {
    return 'AI-säkerhet: $percent%';
  }

  @override
  String get itemDetailStatMin => 'Min';

  @override
  String get itemDetailStatMedian => 'Median';

  @override
  String get itemDetailStatMax => 'Max';

  @override
  String get itemDetailIdentifying => 'Identifierar…';

  @override
  String get itemDetailIdentifyNow => 'Identifiera nu';

  @override
  String get itemDetailDraftListing => 'Annonsutkast';

  @override
  String get itemDetailTraderaQueryLabel => 'Tradera-sökning';

  @override
  String get itemDetailTraderaQueryHint => 't.ex. rorstrand mon amie tallrik';

  @override
  String get itemDetailQueueSync => 'Köa synk';

  @override
  String get itemDetailQueuedForSync => 'Köad för synk.';

  @override
  String get itemDetailSyncCompleted => 'Synk klar.';

  @override
  String get itemDetailProfitTitle => 'Vinst';

  @override
  String get itemDetailPurchasePriceLabel => 'Inköp (SEK)';

  @override
  String get itemDetailFixedFeesLabel => 'Fasta avgifter (SEK)';

  @override
  String get itemDetailShippingSellerLabel => 'Frakt (säljare) (SEK)';

  @override
  String get itemDetailNotesLabel => 'Anteckningar';

  @override
  String get itemDetailNotesHint => 't.ex. defekter, saknade delar, färg';

  @override
  String get itemDetailNoMarketDataYet => 'Ingen marknadsdata ännu.';

  @override
  String get itemDetailConditionTitle => 'Skick';

  @override
  String itemDetailConditionValue(String label, String percent) {
    return '$label ($percent%)';
  }

  @override
  String get itemDetailConditionMint => 'Toppskick';

  @override
  String get itemDetailConditionGood => 'Bra';

  @override
  String get itemDetailConditionFair => 'OK';

  @override
  String get itemDetailConditionRough => 'Slitet';

  @override
  String get itemDetailFlipLabel => 'Flip';

  @override
  String get itemDetailKeywordsTitle => 'Nyckelord';

  @override
  String get modelCalloutTitle => 'Ladda ned AI-modellen (Gemma)';

  @override
  String get modelCalloutBody =>
      'Gör identifiering snabbare offline. Du kan ladda ned nu eller senare i Inställningar.';

  @override
  String get modelDownloadCta => 'Ladda ned';

  @override
  String get modelRetry => 'Försök igen';

  @override
  String get modelNotInstalled => 'Inte installerad';

  @override
  String get modelDownloading => 'Hämtar…';

  @override
  String modelDownloadingPercent(int percent) {
    return 'Hämtar $percent%';
  }

  @override
  String get modelInstalling => 'Installerar…';

  @override
  String get modelInstalled => 'Installerad ✓';

  @override
  String modelFailed(String message) {
    return 'Misslyckades: $message';
  }

  @override
  String get modelWhyLink => 'Varför?';

  @override
  String get modelWhyTitle => 'Varför behöver jag ladda ned en modell?';

  @override
  String get modelWhyBody =>
      'För att kunna använda AI-funktioner offline. Modellen laddas ner till din enhet (ca 1 GB) och skickas inte till en server. På wifi tar det ofta ca 2–10 minuter.';

  @override
  String get modelInstall_chipLabelDownloading => 'Laddar ner';

  @override
  String get modelInstall_chipLabelInstalling => 'Installerar';

  @override
  String get modelInstall_chipLabelReady => 'Klar';

  @override
  String get modelInstall_chipLabelFailed => 'Misslyckades';

  @override
  String get modelInstall_chipRetryCta => 'Försök igen';

  @override
  String get modelInstall_popupTitle => 'AI är redo';

  @override
  String get modelInstall_popupBody =>
      'AI-modellen är nu installerad. Du kan skanna och identifiera snabbare, även offline, med bättre träffar.';

  @override
  String get modelInstall_popupPrimaryCta => 'Toppen';

  @override
  String get modelInstall_popupSecondaryCta => 'Stäng';

  @override
  String get authTitleWelcome => 'Välkommen';

  @override
  String get authModeSignUp => 'Skapa konto';

  @override
  String get authModeSignIn => 'Logga in';

  @override
  String get authEmailLabel => 'E-post';

  @override
  String get authEmailHint => 'namn@exempel.se';

  @override
  String get authCodeLabel => 'Kod';

  @override
  String get authCtaCreateAccount => 'Skapa konto';

  @override
  String get authCtaSignIn => 'Logga in';

  @override
  String get authVerify => 'Verifiera';

  @override
  String get authResendCode => 'Skicka igen';

  @override
  String get authTroubleLink => 'Problem att logga in?';

  @override
  String get authTroubleTitle => 'Problem att logga in?';

  @override
  String get authTroubleBody =>
      'Kontrollera skräppost, och försök skicka en ny kod. Om det fortfarande inte fungerar kan du prova en annan e-postadress.';

  @override
  String authError(String message) {
    return 'Något gick fel: $message';
  }

  @override
  String get homeHeroTitle => 'Starta Scanner';

  @override
  String get homeHeroBody =>
      'Skanna prislappen. Spara offline. Synka priser när du är online.';

  @override
  String get homeTileActiveFinds => 'Aktiva fynd';

  @override
  String get homeTileProfitEst => 'Vinst (est.)';

  @override
  String get homeTileDrafts => 'Utkast';

  @override
  String get homeTileHistory => 'Historik';

  @override
  String get homeTileCtaOpen => 'Öppna';

  @override
  String get homeTileCtaSeeAll => 'Se alla';

  @override
  String get haulUnnamedFind => 'Namnlöst fynd';

  @override
  String get haulStatusIdentifying => 'Identifierar…';

  @override
  String get haulStatusSaved => 'Sparad';

  @override
  String haulTotalValue(String value) {
    return 'Totalt värde: $value';
  }

  @override
  String get draftTitleLabel => 'Rubrik';

  @override
  String get draftDescriptionLabel => 'Beskrivning';

  @override
  String get draftPriceLabel => 'Pris (SEK)';

  @override
  String get save => 'Spara';

  @override
  String get delete => 'Ta bort';
}
