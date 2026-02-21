import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../../core/database/app_database.dart';
import '../../core/storage/scan_image_storage.dart';
import '../../core/database/tables/scan_items.dart';
import 'cloud_photo_paths.dart';
import 'cloud/entity_keys.dart';

class CloudPhotoSyncService {
  CloudPhotoSyncService({
    required AppDatabase db,
    required AppConfig config,
    required ScanImageStorage imageStorage,
  }) : _db = db,
       _config = config,
       _imageStorage = imageStorage;

  final AppDatabase _db;
  final AppConfig _config;
  final ScanImageStorage _imageStorage;

  Future<void> syncBidirectional() async {
    await uploadLocalToCloud();
    await downloadMissingFromCloud();
  }

  Future<void> uploadLocalToCloud() async {
    final user = _requireUser();
    final storage = Supabase.instance.client.storage.from(
      CloudPhotoPaths.bucketId,
    );

    final dirty = await _db.pendingCloudSyncEntitiesDao.listByType(
      'scan_photo',
    );
    if (dirty.isEmpty) return;

    final ids = dirty
        .map((d) => _idFromKey(prefix: 'scan_photo:', key: d.entityKey))
        .whereType<String>()
        .toList(growable: false);

    final scanItems = await _db.scanItemsDao.listByIds(ids, userId: user.id);
    for (final item in scanItems) {
      await _db.entitySyncStatusesDao.set(
        entityKey: scanPhotoEntityKey(item.id),
        status: 'syncing',
      );

      final imagePath = item.imagePath;
      try {
        if (imagePath != null && await File(imagePath).exists()) {
          await storage.upload(
            CloudPhotoPaths.imagePath(userId: user.id, scanItemId: item.id),
            File(imagePath),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
              cacheControl: '3600',
            ),
          );
        }

        final thumbPath = item.thumbPath;
        if (thumbPath != null && await File(thumbPath).exists()) {
          await storage.upload(
            CloudPhotoPaths.thumbPath(userId: user.id, scanItemId: item.id),
            File(thumbPath),
            fileOptions: const FileOptions(
              upsert: true,
              contentType: 'image/jpeg',
              cacheControl: '3600',
            ),
          );
        }

        await _db.entitySyncStatusesDao.set(
          entityKey: scanPhotoEntityKey(item.id),
          status: 'synced',
          lastError: null,
        );

        await _db.pendingCloudSyncEntitiesDao.deleteByKeys([
          scanPhotoEntityKey(item.id),
        ]);
      } catch (e) {
        await _db.entitySyncStatusesDao.set(
          entityKey: scanPhotoEntityKey(item.id),
          status: 'failed',
          lastError: e.toString(),
        );
      }
    }
  }

  String? _idFromKey({required String prefix, required String key}) {
    if (!key.startsWith(prefix)) return null;
    final id = key.substring(prefix.length).trim();
    if (id.isEmpty) return null;
    return id;
  }

  Future<void> downloadMissingFromCloud() async {
    final user = _requireUser();
    final storage = Supabase.instance.client.storage.from(
      CloudPhotoPaths.bucketId,
    );

    final scanItems = await _db.scanItemsDao.listAll(userId: user.id);
    for (final item in scanItems) {
      if (item.imagePath != null && await File(item.imagePath!).exists()) {
        continue;
      }

      try {
        await _db.entitySyncStatusesDao.set(
          entityKey: scanPhotoEntityKey(item.id),
          status: 'syncing',
        );

        final bytes = await storage.download(
          CloudPhotoPaths.imagePath(userId: user.id, scanItemId: item.id),
        );

        final tmp = await File(
          '${Directory.systemTemp.path}/scan_${item.id}.jpg',
        ).writeAsBytes(bytes, flush: true);
        final stored = await _imageStorage.importImage(
          scanId: item.id,
          sourceImage: tmp,
        );

        await _db.scanItemsDao.setImagePaths(
          id: item.id,
          imagePath: stored.imagePath,
          thumbPath: stored.thumbPath,
        );

        final status = item.status;
        if (status == ScanItemStatus.failed) {
          await _db.scanItemsDao.transitionStatus(
            id: item.id,
            to: ScanItemStatus.pendingIdentify,
          );
        }

        await _db.entitySyncStatusesDao.set(
          entityKey: scanPhotoEntityKey(item.id),
          status: 'synced',
          lastError: null,
        );
      } catch (e) {
        await _db.entitySyncStatusesDao.set(
          entityKey: scanPhotoEntityKey(item.id),
          status: 'failed',
          lastError: e.toString(),
        );
      }
    }
  }

  User _requireUser() {
    if (!_config.hasSupabase) {
      throw const _CloudSyncNotConfigured();
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw const _CloudSyncNotSignedIn();
    }
    return user;
  }
}

class _CloudSyncNotConfigured implements Exception {
  const _CloudSyncNotConfigured();
  @override
  String toString() => 'Cloud sync not configured';
}

class _CloudSyncNotSignedIn implements Exception {
  const _CloudSyncNotSignedIn();
  @override
  String toString() => 'Not signed in';
}
