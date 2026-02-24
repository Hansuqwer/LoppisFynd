import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' as legacy;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/feature_flags.dart';
import '../database/app_database.dart';
import '../settings/app_settings_keys.dart';
import '../storage/scan_image_storage.dart';
import '../../services/ai/inference/inference_isolate_service.dart';
import '../../services/sync/sync_scheduler.dart';
import '../../services/sync/cloud/cloud_sync_coordinator.dart';
import '../../services/analytics/analytics_service.dart';
import '../../services/offline_detection/offline_detector.dart';

T _uninitialized<T>(String name) {
  throw StateError('$name is not initialized. Override it in ProviderScope.');
}

final appConfigProvider = Provider<AppConfig>((ref) {
  return _uninitialized<AppConfig>('appConfigProvider');
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return _uninitialized<AppDatabase>('appDatabaseProvider');
});

final scanImageStorageProvider = Provider<ScanImageStorage>((ref) {
  return _uninitialized<ScanImageStorage>('scanImageStorageProvider');
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

final aiInferenceProvider = Provider<AiInferenceIsolateService>((ref) {
  return _uninitialized<AiInferenceIsolateService>('aiInferenceProvider');
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  return _uninitialized<SyncScheduler>('syncSchedulerProvider');
});

final cloudSyncCoordinatorProvider = Provider<CloudSyncCoordinator>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(scanImageStorageProvider);
  final analytics = ref.watch(analyticsProvider);
  return CloudSyncCoordinator(
    db: db,
    config: config,
    imageStorage: storage,
    analytics: analytics,
  );
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

final offlineDetectorProvider = Provider<OfflineDetector>((ref) {
  return OfflineDetector();
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
