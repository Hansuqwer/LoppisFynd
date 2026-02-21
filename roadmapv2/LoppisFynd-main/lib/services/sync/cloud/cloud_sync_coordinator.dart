import '../../../core/config/app_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/storage/scan_image_storage.dart';
import '../../../core/utils/serial_task_queue.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../cloud_metadata_sync_service.dart';
import '../cloud_photo_sync_service.dart';
import '../../analytics/analytics_service.dart';
import 'cloud_sync_seed_service.dart';

class CloudSyncCoordinator {
  CloudSyncCoordinator({
    required AppDatabase db,
    required AppConfig config,
    required ScanImageStorage imageStorage,
    required AnalyticsService analytics,
  }) : _db = db,
       _config = config,
       _imageStorage = imageStorage,
       _analytics = analytics;

  final AppDatabase _db;
  final AppConfig _config;
  final ScanImageStorage _imageStorage;
  final AnalyticsService _analytics;

  final SerialTaskQueue _queue = SerialTaskQueue();

  static const _kAutoSyncLastMs = 'cloud_auto_sync_last_ms';

  Future<void> syncIfNeeded({
    required bool isOnline,
    bool force = false,
    Duration minInterval = const Duration(minutes: 10),
  }) {
    return _queue.add(() async {
      if (!_config.hasSupabase) return;
      if (!isOnline) return;

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      if (!force) {
        final lastMs = await _db.appSettingsDao.getInt(_kAutoSyncLastMs) ?? 0;
        if (lastMs > 0) {
          final last = DateTime.fromMillisecondsSinceEpoch(lastMs);
          if (DateTime.now().difference(last) < minInterval) return;
        }
      }

      await _db.appSettingsDao.setInt(
        _kAutoSyncLastMs,
        DateTime.now().millisecondsSinceEpoch,
      );

      final meta = CloudMetadataSyncService(db: _db, config: _config);
      final photos = CloudPhotoSyncService(
        db: _db,
        config: _config,
        imageStorage: _imageStorage,
      );

      try {
        await CloudSyncSeedService(db: _db).ensureSeeded(userId: user.id);
      } catch (_) {}

      try {
        await _analytics.measure('cloud_sync_metadata', meta.syncBidirectional);
        await _db.entitySyncStatusesDao.set(
          entityKey: 'cloud:metadata',
          status: 'synced',
          lastError: null,
        );
      } catch (e) {
        await _db.entitySyncStatusesDao.set(
          entityKey: 'cloud:metadata',
          status: 'failed',
          lastError: e.toString(),
        );
      }

      try {
        await _analytics.measure('cloud_sync_photos', photos.syncBidirectional);
        await _db.entitySyncStatusesDao.set(
          entityKey: 'cloud:photos',
          status: 'synced',
          lastError: null,
        );
      } catch (e) {
        await _db.entitySyncStatusesDao.set(
          entityKey: 'cloud:photos',
          status: 'failed',
          lastError: e.toString(),
        );
      }
    });
  }
}
