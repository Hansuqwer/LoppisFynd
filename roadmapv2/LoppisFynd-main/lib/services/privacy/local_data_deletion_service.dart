import 'dart:io';

import '../../core/database/app_database.dart';

class LocalDataDeletionService {
  LocalDataDeletionService({required this.db});

  final AppDatabase db;

  Future<void> deleteAllLocalData({required String? userId}) async {
    final items = await db.scanItemsDao.listAll(userId: userId);
    final itemIds = items.map((it) => it.id).toList(growable: false);
    final photos = await db.scanItemPhotosDao.listByScanItemIds(itemIds);

    final paths = <String>{};
    for (final it in items) {
      final img = it.imagePath;
      if (img != null && img.trim().isNotEmpty) paths.add(img);
      final thumb = it.thumbPath;
      if (thumb != null && thumb.trim().isNotEmpty) paths.add(thumb);
    }
    for (final p in photos) {
      if (p.localPath.trim().isNotEmpty) paths.add(p.localPath);
      final thumb = p.thumbPath;
      if (thumb != null && thumb.trim().isNotEmpty) paths.add(thumb);
    }

    await db.transaction(() async {
      await db.scanItemsDao.deleteAllForUser(userId: userId);
      await db.haulsDao.deleteAllForUser(userId: userId);

      if (userId != null) {
        await db.appSettingsDao.deleteByKeyPrefix(
          'profile_display_name_$userId',
        );
        await db.appSettingsDao.deleteByKey('claimed_guest_data_$userId');
        await db.appSettingsDao.deleteByKey('ai_accuracy_mode_$userId');
      } else {
        await db.appSettingsDao.deleteByKey('ai_accuracy_mode_guest');
      }
    });

    for (final path in paths) {
      try {
        final f = File(path);
        if (await f.exists()) {
          await f.delete();
        }
      } catch (_) {
        // Best-effort.
      }
    }
  }
}
