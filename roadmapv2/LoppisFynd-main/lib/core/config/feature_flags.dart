class FeatureFlags {
  const FeatureFlags({
    required this.enableSync,
    required this.enableMarket,
    required this.enableAi,
    required this.enableAnalytics,
  });

  final bool enableSync;
  final bool enableMarket;
  final bool enableAi;
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
    const disableAi = bool.fromEnvironment(
      'FF_DISABLE_AI',
      defaultValue: false,
    );
    const disableAnalytics = bool.fromEnvironment(
      'FF_DISABLE_ANALYTICS',
      defaultValue: false,
    );

    return const FeatureFlags(
      enableSync: !disableSync,
      enableMarket: !disableMarket,
      enableAi: !disableAi,
      enableAnalytics: !disableAnalytics,
    );
  }
}
