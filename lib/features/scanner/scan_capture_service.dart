import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/settings/app_settings_keys.dart';
import '../../core/storage/scan_image_storage.dart';
import '../../core/utils/serial_task_queue.dart';
import '../../services/ai/inference/ai_types.dart';
import '../../services/ai/inference/inference_isolate_service.dart';
import '../../services/analytics/analytics_service.dart';

class CapturedScan {
  const CapturedScan({required this.id, required this.backgroundWork});

  final String id;
  final Future<void> backgroundWork;
}

class ScanCaptureService {
  ScanCaptureService({
    required this.config,
    required AppDatabase db,
    required ScanImageStorage imageStorage,
    required AiInferenceIsolateService aiInference,
    required AnalyticsService analytics,
    Future<bool> Function()? isOnline,
    Uuid? uuid,
  }) : _db = db,
       _imageStorage = imageStorage,
       _aiInference = aiInference,
       _analytics = analytics,
       _isOnline = isOnline ?? _defaultIsOnline,
       _uuid = uuid ?? const Uuid();

  final AppConfig config;
  final AppDatabase _db;
  final ScanImageStorage _imageStorage;
  final AiInferenceIsolateService _aiInference;
  final AnalyticsService _analytics;
  final Future<bool> Function() _isOnline;
  final Uuid _uuid;

  // Guardrail: if users capture rapidly, serialize follow-up work
  // (thumb generation + inference + DB writes) to avoid CPU spikes.
  final SerialTaskQueue _backgroundQueue = SerialTaskQueue();

  Future<CapturedScan> persistCapturedImage({
    required String haulId,
    required String? userId,
    required File sourceImage,
    String? scanId,
  }) async {
    final id = scanId ?? _uuid.v4();

    final stored = await _imageStorage.importImageDeferred(
      scanId: id,
      sourceImage: sourceImage,
    );

    final photoId = _uuid.v4();

    await _db.scanItemsDao.insertNew(
      id: id,
      userId: userId,
      haulId: haulId,
      imagePath: stored.imagePath,
      thumbPath: stored.thumbPath,
    );

    await _db.scanItemPhotosDao.insertNew(
      id: photoId,
      scanItemId: id,
      localPath: stored.imagePath,
    );

    _analytics.event('item_saved');

    final backgroundWork = _backgroundQueue.add(() async {
      try {
        final thumbPath = await stored.thumbReady;
        await _db.scanItemsDao.setThumbPath(id: id, thumbPath: thumbPath);
        await _db.scanItemPhotosDao.setThumbPath(
          id: photoId,
          thumbPath: thumbPath,
        );
      } catch (e) {
        await _db.scanItemsDao.transitionStatus(
          id: id,
          to: ScanItemStatus.failed,
        );
        rethrow;
      }

      // Best-effort: thumbnail generation is critical; AI can be installed later.
      try {
        int? privacyEnabled;
        int? disclosureChoice;
        try {
          privacyEnabled = await _db.appSettingsDao.getInt(
            kPrivacyCloudIdentificationEnabledKeyV1,
          );
          disclosureChoice = await _db.appSettingsDao.getInt(
            kCloudIdentificationDisclosureChoiceKeyV1,
          );
        } catch (_) {
          return;
        }

        final cloudEnabled = (privacyEnabled ?? 1) == 1;
        final disclosureAccepted = disclosureChoice == 1;
        if (!cloudEnabled || !disclosureAccepted) {
          return;
        }

        if (!config.hasCloudAiProxy) {
          return;
        }

        var online = false;
        try {
          online = await _isOnline();
        } catch (_) {
          online = false;
        }
        if (!online) {
          return;
        }

        final modeKey = userId == null
            ? 'ai_accuracy_mode_guest'
            : 'ai_accuracy_mode_$userId';
        final mode = await _db.appSettingsDao.getInt(modeKey) ?? 1;
        final maxTokens = mode == 0 ? 384 : 1024;

        final inference = await _analytics.measure(
          'inference_single_item',
          () => _aiInference.run(
            AiInferenceRequest(
              task: const SingleItemTask(),
              imageFile: File(stored.imagePath),
              maxTokens: maxTokens,
            ),
          ),
        );

        if (inference is SingleItemInferenceResult) {
          await _db.scanItemsDao.setAiResult(
            id: id,
            aiJson: inference.value.rawJson,
            query: inference.value.query,
            desc: inference.value.desc,
            confidence: inference.value.confidence,
          );

          await _db.scanItemsDao.transitionStatus(
            id: id,
            to: ScanItemStatus.pendingSync,
          );

          _analytics.event(
            'keyword_ready',
            data: {'confidence': inference.value.confidence},
          );
        }
      } on ModelNotInstalledException {
        // Keep status as pendingIdentify; user can install model later.
      } catch (e) {
        await _db.scanItemsDao.transitionStatus(
          id: id,
          to: ScanItemStatus.failed,
        );
      }
    });
    unawaited(backgroundWork);

    return CapturedScan(id: id, backgroundWork: backgroundWork);
  }

  static Future<bool> _defaultIsOnline() async {
    final connectivity = Connectivity();
    try {
      final results = await connectivity.checkConnectivity();
      return !_isOfflineConnectivity(results);
    } catch (_) {
      // Fail closed for background inference.
      return false;
    }
  }

  static bool _isOfflineConnectivity(List<ConnectivityResult> results) {
    return results.length == 1 && results.single == ConnectivityResult.none;
  }
}
