class AppConfig {
  const AppConfig({
    required this.appEnv,
    required this.traderaProxyUrl,
    this.googleBooksApiKey = '',
    this.bokfyndQaStableIsbnData = false,
    required this.cloudAiProxyUrl,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.sentryDsn,
    this.apifyApiToken = '',
    this.vintedScraperActorId = '',
    this.bokborsenScraperUrl = '',
    this.bookMarketAggregatorUrl = '',
  });

  final String appEnv;
  final String traderaProxyUrl;
  final String googleBooksApiKey;
  final bool bokfyndQaStableIsbnData;
  final String cloudAiProxyUrl;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String sentryDsn;
  final String apifyApiToken;
  final String vintedScraperActorId;
  final String bokborsenScraperUrl;
  final String bookMarketAggregatorUrl;

  factory AppConfig.fromEnvironment() {
    return const AppConfig(
      appEnv: String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
      traderaProxyUrl: String.fromEnvironment(
        'TRADERA_PROXY_URL',
        defaultValue: '',
      ),
      googleBooksApiKey: String.fromEnvironment(
        'GOOGLE_BOOKS_API_KEY',
        defaultValue: '',
      ),
      bokfyndQaStableIsbnData: bool.fromEnvironment(
        'BOKFYND_QA_STABLE_ISBN_DATA',
        defaultValue: false,
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
      sentryDsn: String.fromEnvironment('SENTRY_DSN', defaultValue: ''),
      apifyApiToken: String.fromEnvironment(
        'APIFY_API_TOKEN',
        defaultValue: '',
      ),
      vintedScraperActorId: String.fromEnvironment(
        'VINTED_SCRAPER_ACTOR_ID',
        defaultValue: '',
      ),
      bokborsenScraperUrl: String.fromEnvironment(
        'BOKBORSEN_SCRAPER_URL',
        defaultValue: '',
      ),
      bookMarketAggregatorUrl: String.fromEnvironment(
        'BOOK_MARKET_AGGREGATOR_URL',
        defaultValue: '',
      ),
    );
  }

  bool get hasTraderaProxy => traderaProxyUrl.trim().isNotEmpty;

  bool get hasGoogleBooksApiKey => googleBooksApiKey.trim().isNotEmpty;

  bool get useBokFyndQaStableIsbnData =>
      appEnv == 'dev' && bokfyndQaStableIsbnData;

  bool get hasCloudAiProxy => cloudAiProxyUrl.trim().isNotEmpty;

  bool get hasSupabase =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  bool get hasSentry => sentryDsn.trim().isNotEmpty;

  bool get hasApify => apifyApiToken.trim().isNotEmpty;

  bool get hasVintedScraper =>
      hasApify && vintedScraperActorId.trim().isNotEmpty;

  bool get hasBokborsenScraper => bokborsenScraperUrl.trim().isNotEmpty;

  bool get hasBookMarketAggregator => bookMarketAggregatorUrl.trim().isNotEmpty;
}
