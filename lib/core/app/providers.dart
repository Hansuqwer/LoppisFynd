import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/feature_flags.dart';
import '../database/app_database.dart';
import '../settings/app_settings_keys.dart';
import '../../features/scanner/barcode/mlkit_book_isbn_adapter.dart';
import '../../services/books/book_barcode_isbn_handoff_service.dart';
import '../../services/books/book_isbn_draft_flow_controller.dart';
import '../../services/books/book_market_service.dart';
import '../../services/books/aggregated_book_market_service.dart';
import '../../services/books/vinted_book_market_source.dart';
import '../../services/books/bokborsen_book_market_source.dart';
import '../../services/books/book_inventory_draft_application_service.dart';
import '../../services/books/book_inventory_draft_mapper.dart';
import '../../services/books/book_inventory_draft_orchestration_service.dart';
import '../../services/books/book_scanner_isbn_handoff_coordinator.dart';
import '../../services/books/isbn_lookup_service.dart';
import '../../services/books/book_pricing_draft_service.dart';
import '../../services/books/qa_isbn_lookup_service.dart';
import '../../services/market/tradera_client.dart';
import '../../services/market/apify_client.dart';
import '../../services/market/vinted_market_data_source.dart';
import '../../services/market/bokborsen_market_data_source.dart';
import '../../services/sync/sync_scheduler.dart';
import '../../services/sync/cloud/cloud_sync_coordinator.dart';
import '../../services/analytics/analytics_service.dart';

T _uninitialized<T>(String name) {
  throw StateError('$name is not initialized. Override it in ProviderScope.');
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return _uninitialized<AppConfig>('appConfigProvider');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return _uninitialized<AppDatabase>('appDatabaseProvider');
});

final activeUserIdProvider = Provider<String?>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.hasSupabase) return null;
  final session = ref
      .watch(authSessionProvider)
      .maybeWhen(data: (v) => v, orElse: () => null);
  return session?.user.id;
});

final defaultHaulIdProvider = Provider<String>((ref) {
  final userId = ref.watch(activeUserIdProvider);
  return userId == null ? 'haul_current_guest' : 'haul_current_$userId';
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  return _uninitialized<SyncScheduler>('syncSchedulerProvider');
});

final isbnLookupServiceProvider = Provider<BookMetadataLookup>((ref) {
  final config = ref.watch(appConfigProvider);
  if (config.useBokFyndQaStableIsbnData) {
    return const QaStableIsbnLookupService();
  }
  return IsbnLookupService(googleBooksApiKey: config.googleBooksApiKey);
});

final bookMarketServiceProvider = Provider<BookMarketService?>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.hasTraderaProxy) return null;

  return BookMarketService(
    traderaClient: TraderaClient(
      functionUrl: Uri.parse(config.traderaProxyUrl),
      anonKey: config.supabaseAnonKey.trim().isEmpty
          ? null
          : config.supabaseAnonKey,
    ),
  );
});

final apifyClientProvider = Provider<ApifyClient?>((ref) {
  final config = ref.watch(appConfigProvider);
  if (!config.hasApify) return null;
  return ApifyClient(apiToken: config.apifyApiToken);
});

final vintedMarketDataSourceProvider = Provider<VintedMarketDataSource?>((ref) {
  final config = ref.watch(appConfigProvider);
  final apifyClient = ref.watch(apifyClientProvider);
  if (!config.hasVintedScraper || apifyClient == null) return null;
  return VintedMarketDataSource(
    apifyClient: apifyClient,
    actorId: config.vintedScraperActorId,
  );
});

final bokborsenMarketDataSourceProvider = Provider<BokborsenMarketDataSource?>((
  ref,
) {
  final config = ref.watch(appConfigProvider);
  if (!config.hasBokborsenScraper) return null;
  return BokborsenMarketDataSource(
    functionUrl: Uri.parse(config.bokborsenScraperUrl),
    anonKey: config.supabaseAnonKey.trim().isEmpty
        ? null
        : config.supabaseAnonKey,
  );
});

final aggregatedBookMarketServiceProvider =
    Provider<AggregatedBookMarketService?>((ref) {
      final traderaService = ref.watch(bookMarketServiceProvider);
      final vintedSource = ref.watch(vintedMarketDataSourceProvider);
      final bokborsenSource = ref.watch(bokborsenMarketDataSourceProvider);

      final sources = <BookMarketSource>[];
      if (traderaService != null) {
        sources.add(TraderaBookMarketSource(service: traderaService));
      }
      if (vintedSource != null) {
        sources.add(VintedBookMarketSource(dataSource: vintedSource));
      }
      if (bokborsenSource != null) {
        sources.add(BokborsenBookMarketSource(dataSource: bokborsenSource));
      }

      if (sources.isEmpty) {
        return null;
      }

      return AggregatedBookMarketService(sources: sources);
    });

final bookPricingDraftServiceProvider = Provider<BookPricingDraftService>((
  ref,
) {
  final aggregated = ref.watch(aggregatedBookMarketServiceProvider);
  final traderaOnly = ref.watch(bookMarketServiceProvider);
  return BookPricingDraftService(
    metadataLookup: ref.watch(isbnLookupServiceProvider),
    marketLookup: aggregated ?? traderaOnly,
  );
});

final bookInventoryDraftMapperProvider = Provider<BookInventoryDraftMapper>((
  ref,
) {
  return const BookInventoryDraftMapper();
});

final bookInventoryDraftApplicationServiceProvider =
    Provider<BookInventoryDraftApplicationService>((ref) {
      return BookInventoryDraftApplicationService(
        db: ref.watch(appDatabaseProvider),
      );
    });

final bookInventoryDraftOrchestrationServiceProvider =
    Provider<BookInventoryDraftOrchestrationService>((ref) {
      return BookInventoryDraftOrchestrationService(
        pricingDraftCreator: ref.watch(bookPricingDraftServiceProvider),
        mapper: ref.watch(bookInventoryDraftMapperProvider),
        draftApplier: ref.watch(bookInventoryDraftApplicationServiceProvider),
      );
    });

final bookIsbnDraftFlowControllerProvider =
    Provider<BookIsbnDraftFlowController>((ref) {
      final controller = BookIsbnDraftFlowController(
        orchestrator: ref.watch(bookInventoryDraftOrchestrationServiceProvider),
      );
      ref.onDispose(controller.dispose);
      return controller;
    });

final bookBarcodeIsbnHandoffServiceProvider =
    Provider<BookBarcodeIsbnHandoffService>((ref) {
      return BookBarcodeIsbnHandoffService(
        controller: ref.watch(bookIsbnDraftFlowControllerProvider),
      );
    });

final mlKitBookIsbnAdapterProvider = Provider<MlKitBookIsbnAdapter>((ref) {
  return const MlKitBookIsbnAdapter();
});

final bookScannerIsbnHandoffCoordinatorProvider =
    Provider<BookScannerIsbnHandoffCoordinator>((ref) {
      return BookScannerIsbnHandoffCoordinator(
        isbnAdapter: ref.watch(mlKitBookIsbnAdapterProvider),
        handoff: ref.watch(bookBarcodeIsbnHandoffServiceProvider),
      );
    });

final cloudSyncCoordinatorProvider = Provider<CloudSyncCoordinator>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final config = ref.watch(appConfigProvider);
  final analytics = ref.watch(analyticsProvider);
  return CloudSyncCoordinator(db: db, config: config, analytics: analytics);
});

final highContrastEnabledProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.appSettingsDao
      .watchInt('high_contrast_enabled')
      .map((v) => (v ?? 0) == 1);
});

final onboardingCompleteProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.appSettingsDao
      .watchInt('onboarding_complete')
      .map((v) => (v ?? 0) == 1);
});

final cloudIdentificationEnabledProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.appSettingsDao
      .watchInt(kPrivacyCloudIdentificationEnabledKeyV1)
      .map((v) => (v ?? 1) == 1);
});

final fetchSoldPriceCompsEnabledProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.appSettingsDao
      .watchInt(kPrivacyFetchSoldPriceCompsEnabledKeyV1)
      .map((v) => (v ?? 1) == 1);
});

final offlineIdentificationEnabledProvider = StreamProvider<bool>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.appSettingsDao
      .watchInt(kOfflineIdentificationEnabledKeyV1)
      .map((v) => (v ?? 0) == 1);
});

final offlineDetectorProvider = Provider<dynamic>((ref) {
  return _uninitialized<dynamic>('offlineDetectorProvider');
});

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return FeatureFlags.fromEnvironment();
});

final analyticsProvider = Provider<AnalyticsService>((ref) {
  final flags = ref.watch(featureFlagsProvider);
  if (!flags.enableAnalytics) return const NoopAnalyticsService();

  final config = ref.watch(appConfigProvider);
  if (!config.hasSentry) return const NoopAnalyticsService();
  return const SentryAnalyticsService();
});

final appStartAtProvider = Provider<DateTime>((ref) => DateTime.now());

final startupMetricsReportedProvider = legacy.StateProvider<bool>(
  (ref) => false,
);

final authSessionProvider = StreamProvider<Session?>((ref) async* {
  final config = ref.watch(appConfigProvider);
  if (!config.hasSupabase) {
    yield null;
    return;
  }

  final auth = Supabase.instance.client.auth;
  yield auth.currentSession;
  await for (final _ in auth.onAuthStateChange) {
    yield auth.currentSession;
  }
});

final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  try {
    final initial = await connectivity.checkConnectivity();
    yield !_isOfflineConnectivity(initial);
  } catch (_) {
    yield true;
  }

  await for (final r in connectivity.onConnectivityChanged) {
    yield !_isOfflineConnectivity(r);
  }
});

// Deep-link skeleton: routes can set these before landing in the app shell.
final deepLinkTabIndexProvider = legacy.StateProvider<int?>((ref) => null);
final deepLinkScanItemIdProvider = legacy.StateProvider<String?>((ref) => null);

bool _isOfflineConnectivity(List<ConnectivityResult> results) {
  return results.length == 1 && results.single == ConnectivityResult.none;
}
