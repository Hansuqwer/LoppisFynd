import 'dart:async';
import 'dart:io';

import 'package:uuid/uuid.dart';

import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/storage/scan_image_storage.dart';
import '../../services/ai/inference/ai_types.dart';
import '../../services/ai/inference/inference_isolate_service.dart';

class CapturedScan {
  const CapturedScan({required this.id, required this.backgroundWork});

  final String id;
  final Future<void> backgroundWork;
}

class ScanCaptureService {
  ScanCaptureService({
    required AppDatabase db,
    required ScanImageStorage imageStorage,
    required AiInferenceIsolateService aiInference,
    Uuid? uuid,
  }) : _db = db,
       _imageStorage = imageStorage,
       _aiInference = aiInference,
       _uuid = uuid ?? const Uuid();

  final AppDatabase _db;
  final ScanImageStorage _imageStorage;
  final AiInferenceIsolateService _aiInference;
  final Uuid _uuid;

  Future<CapturedScan> persistCapturedImage({
    required String haulId,
    required File sourceImage,
    String? scanId,
  }) async {
    final id = scanId ?? _uuid.v4();

    final stored = await _imageStorage.importImageDeferred(
      scanId: id,
      sourceImage: sourceImage,
    );

    await _db.scanItemsDao.insertNew(
      id: id,
      haulId: haulId,
      imagePath: stored.imagePath,
      thumbPath: stored.thumbPath,
    );

    final backgroundWork = () async {
      try {
        final thumbPath = await stored.thumbReady;
        await _db.scanItemsDao.setThumbPath(id: id, thumbPath: thumbPath);
      } catch (e) {
        await _db.scanItemsDao.transitionStatus(
          id: id,
          to: ScanItemStatus.failed,
        );
        rethrow;
      }

      // Best-effort: thumbnail generation is critical; AI can be installed later.
      try {
        final inference = await _aiInference.run(
          AiInferenceRequest(
            task: const SingleItemTask(),
            imageFile: File(stored.imagePath),
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
        }
      } on ModelNotInstalledException {
        // Keep status as pendingIdentify; user can install model later.
      } catch (e) {
        await _db.scanItemsDao.transitionStatus(
          id: id,
          to: ScanItemStatus.failed,
        );
      }
    }();
    unawaited(backgroundWork);

    return CapturedScan(id: id, backgroundWork: backgroundWork);
  }
}
