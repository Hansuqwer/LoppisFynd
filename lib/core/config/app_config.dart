class AppConfig {
  const AppConfig({
    required this.traderaProxyUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.gemmaModelUrl,
  });

  final String traderaProxyUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String gemmaModelUrl;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      traderaProxyUrl: String.fromEnvironment(
        'TRADERA_PROXY_URL',
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
    );
  }

  bool get hasTraderaProxy => traderaProxyUrl.trim().isNotEmpty;

  bool get hasSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get hasGemmaModelUrl => gemmaModelUrl.trim().isNotEmpty;
}
