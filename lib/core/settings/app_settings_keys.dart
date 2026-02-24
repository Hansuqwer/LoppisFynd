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
