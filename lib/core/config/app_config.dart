class AppConfig {
  const AppConfig({
    required this.appEnv,
    required this.traderaProxyUrl,
    required this.cloudAiProxyUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.gemmaModelUrl,
    required this.sentryDsn,
  });

  final String appEnv;
  final String traderaProxyUrl;
  final String cloudAiProxyUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String gemmaModelUrl;
  final String sentryDsn;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      appEnv: String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
      traderaProxyUrl: String.fromEnvironment(
        'TRADERA_PROXY_URL',
        defaultValue: '',
      ),
      cloudAiProxyUrl: String.fromEnvironment(
        'CLOUD_AI_PROXY_URL',
        defaultValue: '',
      ),
      supabaseUrl: String.fromEnvironment('SUPABASE_URL', defaultValue: ''),
      supabaseAnonKey: String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      ),
      gemmaModelUrl: String.fromEnvironment(
        'GEMMA_MODEL_URL',
        defaultValue: '',
      ),
      sentryDsn: String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
    );
  }

  bool get hasTraderaProxy => traderaProxyUrl.trim().isNotEmpty;

  bool get hasCloudAiProxy => cloudAiProxyUrl.trim().isNotEmpty;

  bool get hasSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get hasGemmaModelUrl => gemmaModelUrl.trim().isNotEmpty;

  bool get hasSentry => sentryDsn.trim().isNotEmpty;
}
