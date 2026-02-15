import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../config/app_config.dart';
import '../database/app_database.dart';
import '../storage/scan_image_storage.dart';
import '../../services/ai/inference/inference_isolate_service.dart';
import '../../services/ai/model_manager.dart';
import '../../services/sync/sync_scheduler.dart';

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

final defaultHaulIdProvider = Provider<String>((ref) {
  return _uninitialized<String>('defaultHaulIdProvider');
});

final modelManagerProvider = Provider<ModelManager>((ref) {
  return _uninitialized<ModelManager>('modelManagerProvider');
});

final aiInferenceProvider = Provider<AiInferenceIsolateService>((ref) {
  return _uninitialized<AiInferenceIsolateService>('aiInferenceProvider');
});

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  return _uninitialized<SyncScheduler>('syncSchedulerProvider');
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

bool _isOfflineConnectivity(List<ConnectivityResult> results) {
  return results.length == 1 && results.single == ConnectivityResult.none;
}
