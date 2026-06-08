class FeatureFlags {
  const FeatureFlags({
    required this.enableSync,
    required this.enableMarket,
    required this.enableAnalytics,
  });

  final bool enableSync;
  final bool enableMarket;
  final bool enableAnalytics;

  factory FeatureFlags.fromEnvironment() {
    const disableSync = bool.fromEnvironment(
      'FF_DISABLE_SYNC',
      defaultValue: false,
    );
    const disableMarket = bool.fromEnvironment(
      'FF_DISABLE_MARKET',
      defaultValue: false,
    );
    const disableAnalytics = bool.fromEnvironment(
      'FF_DISABLE_ANALYTICS',
      defaultValue: false,
    );

    return const FeatureFlags(
      enableSync: !disableSync,
      enableMarket: !disableMarket,
      enableAnalytics: !disableAnalytics,
    );
  }
}
