import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/services/sync/cloud/cloud_sync_seed_service.dart';
import 'package:fynd_loppis/services/sync/cloud/entity_keys.dart';

void main() {
  test('CloudSyncSeedService seeds pending entities once per user', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'h1', title: 'H1', userId: 'u1');
    await db.haulsDao.upsert(id: 'h2', title: 'H2', userId: 'u1');
    await db.scanItemsDao.insertNew(
      id: 's1',
      haulId: 'h1',
      userId: 'u1',
      imagePath: '/tmp/i.jpg',
      thumbPath: '/tmp/t.jpg',
    );

    final svc = CloudSyncSeedService(db: db);
    await svc.ensureSeeded(userId: 'u1');

    final rows = await db.pendingCloudSyncEntitiesDao.listAll();
    final keys = rows.map((r) => r.entityKey).toSet();
    expect(keys, contains(haulEntityKey('h1')));
    expect(keys, contains(haulEntityKey('h2')));
    expect(keys, contains(scanItemEntityKey('s1')));
    expect(keys, contains(scanPhotoEntityKey('s1')));

    final beforeCount = rows.length;
    await svc.ensureSeeded(userId: 'u1');
    final rows2 = await db.pendingCloudSyncEntitiesDao.listAll();
    expect(rows2.length, beforeCount);
  });
}
