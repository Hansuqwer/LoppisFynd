import '../../../core/database/app_database.dart';
import '../cloud/entity_keys.dart';

class CloudSyncSeedService {
  CloudSyncSeedService({required AppDatabase db}) : _db = db;

  final AppDatabase _db;

  Future<void> ensureSeeded({required String userId}) async {
    final key = 'cloud_seeded_v1_$userId';
    final done = (await _db.appSettingsDao.getInt(key)) == 1;
    if (done) return;

    final hauls = await _db.haulsDao.listAll(userId: userId);
    final items = await _db.scanItemsDao.listAll(userId: userId);

    for (final h in hauls) {
      await _db.pendingCloudSyncEntitiesDao.markDirty(
        entityKey: haulEntityKey(h.id),
        entityType: 'haul',
      );
    }
    for (final it in items) {
      await _db.pendingCloudSyncEntitiesDao.markDirty(
        entityKey: scanItemEntityKey(it.id),
        entityType: 'scan_item',
      );
      await _db.pendingCloudSyncEntitiesDao.markDirty(
        entityKey: scanPhotoEntityKey(it.id),
        entityType: 'scan_photo',
      );
    }

    await _db.appSettingsDao.setInt(key, 1);
  }
}
