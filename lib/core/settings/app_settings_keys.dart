/// Stable keys for `AppSettingsDao` persisted app settings.
///
/// Keep these names versioned (`*_v1`) so future migrations can coexist.
const String kPrivacyCloudIdentificationEnabledKeyV1 =
    'privacy_cloud_identification_enabled_v1';

const String kPrivacyFetchSoldPriceCompsEnabledKeyV1 =
    'privacy_fetch_sold_price_comps_enabled_v1';

/// 0/absent = unknown, 1 = accepted, 2 = not now.
const String kCloudIdentificationDisclosureChoiceKeyV1 =
    'cloud_identification_disclosure_choice_v1';

/// 0/absent = disabled, 1 = enabled.
const String kOfflineIdentificationEnabledKeyV1 =
    'offline_identification_enabled_v1';

/// 0/absent = not shown, 1 = shown.
///
/// Used to proactively suggest downloading the offline model once after
/// enabling offline identification.
const String kOfflineModelDownloadSuggestionShownKeyV1 =
    'offline_model_download_suggestion_shown_v1';

/// 0/absent = system, 1 = light, 2 = dark.
const String kThemeModePreferenceKeyV1 = 'theme_mode_preference_v1';
