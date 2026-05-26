import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'gen/app_localizations.dart';

import 'core/app/providers.dart';
import 'core/config/app_config.dart';
import 'core/database/app_database.dart';
import 'core/tokens/app_tokens.dart';
import 'core/theme/app_theme.dart';
import 'shared/widgets/bento_card.dart';
import 'services/market/market_bridge.dart';
import 'services/market/market_data_source.dart';
import 'services/market/tradera_client.dart';
import 'services/sync/sync_scheduler.dart';
import 'services/analytics/analytics_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/onboarding/onboarding_gate.dart';
import 'features/onboarding/deep_link_gate.dart';
import 'services/sync/background/background_sync.dart';
import 'services/notifications/app_notifications.dart';
import 'core/config/feature_flags.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (details) {
    return Material(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: BentoCard(
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.errorSomethingWentWrong),
                    const SizedBox(height: AppSpacing.sm),
                    Text(details.exceptionAsString()),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  };

  GoogleFonts.config.allowRuntimeFetching = false;

  final config = AppConfig.fromEnvironment();

  if (!config.hasSentry) {
    await _bootstrapAndRun(config);
    return;
  }

  final packageInfo = await PackageInfo.fromPlatform();
  final release = 'bokfynd@${packageInfo.version}+${packageInfo.buildNumber}';

  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDsn;
      options.environment = config.appEnv;
      options.release = release;
      options.sendDefaultPii = false;
      options.tracesSampleRate = 0.0;
    },
    appRunner: () async {
      await runZonedGuarded(
        () async {
          await _bootstrapAndRun(config);
        },
        (error, stackTrace) {
          unawaited(Sentry.captureException(error, stackTrace: stackTrace));
        },
      );
    },
  );
}

Future<void> _bootstrapAndRun(AppConfig config) async {
  final db = AppDatabase.open();

  if (config.hasSupabase) {
    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
    );
  }

  await BackgroundSync.initialize();
  await BackgroundSync.scheduleIfConfigured(db: db);

  if (config.hasTraderaProxy) {
    await AppNotifications.initialize(requestPermissions: true);
  }
  final market = config.hasTraderaProxy
      ? MarketBridge(
          tradera: TraderaClient(
            functionUrl: Uri.parse(config.traderaProxyUrl),
          ),
          db: db,
        )
      : const NoopMarketDataSource();

  final flags = FeatureFlags.fromEnvironment();
  final analytics = (flags.enableAnalytics && config.hasSentry)
      ? const SentryAnalyticsService()
      : const NoopAnalyticsService();

  final syncScheduler = SyncScheduler(
    db: db,
    market: market,
    analytics: analytics,
    userIdProvider: () {
      if (!config.hasSupabase) return null;
      return Supabase.instance.client.auth.currentUser?.id;
    },
  );

  runApp(_AppRoot(db: db, config: config, syncScheduler: syncScheduler));
}

class _AppRoot extends StatefulWidget {
  const _AppRoot({
    required this.db,
    required this.config,
    required this.syncScheduler,
  });

  final AppDatabase db;
  final AppConfig config;
  final SyncScheduler syncScheduler;

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  void dispose() {
    widget.db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(widget.db),
        appConfigProvider.overrideWithValue(widget.config),
        syncSchedulerProvider.overrideWithValue(widget.syncScheduler),
      ],
      child: const BokfyndApp(),
    );
  }
}

class BokfyndApp extends ConsumerStatefulWidget {
  const BokfyndApp({super.key});

  @override
  ConsumerState<BokfyndApp> createState() => _BokfyndAppState();
}

class _BokfyndAppState extends ConsumerState<BokfyndApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final highContrast = ref
        .watch(highContrastEnabledProvider)
        .maybeWhen(data: (v) => v, orElse: () => false);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      theme: highContrast ? AppTheme.highContrast() : AppTheme.light(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('sv'),
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';
        if (name == '/' || name.isEmpty) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const OnboardingGate(),
          );
        }

        // Deep-link skeleton (v1.0): map paths to the app shell.
        switch (name) {
          case '/home':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DeepLinkGate(tabIndex: 0),
            );
          case '/scan':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DeepLinkGate(tabIndex: 1),
            );
          case '/inventory':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DeepLinkGate(tabIndex: 2),
            );
          case '/history':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DeepLinkGate(tabIndex: 3),
            );
          case '/profile':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const DeepLinkGate(tabIndex: 4),
            );
        }

        if (name.startsWith('/book/')) {
          final id = name.substring('/book/'.length);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => DeepLinkGate(scanItemId: id),
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const OnboardingGate(),
        );
      },
    );
  }
}
