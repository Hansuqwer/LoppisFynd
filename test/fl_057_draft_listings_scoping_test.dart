import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/database/tables/scan_items.dart';

void main() {
  test('DraftListingsDao scopes by userId and haulId', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(
      id: 'haul-guest',
      title: 'Guest haul',
      userId: null,
    );
    await db.haulsDao.upsert(
      id: 'haul-user',
      title: 'User haul',
      userId: 'user-1',
    );

    await db.scanItemsDao.insertNew(
      id: 'scan-guest',
      haulId: 'haul-guest',
      userId: null,
      imagePath: '/tmp/image.jpg',
      thumbPath: '/tmp/thumb.jpg',
      status: ScanItemStatus.complete,
    );
    await db.scanItemsDao.insertNew(
      id: 'scan-user',
      haulId: 'haul-user',
      userId: 'user-1',
      imagePath: '/tmp/image.jpg',
      thumbPath: '/tmp/thumb.jpg',
      status: ScanItemStatus.complete,
    );

    await db.draftListingsDao.upsert(
      scanItemId: 'scan-guest',
      title: 'Guest draft',
      askingPriceSek: 50,
    );
    await db.draftListingsDao.upsert(
      scanItemId: 'scan-user',
      title: 'User draft',
      askingPriceSek: 100,
    );

    final guest = await db.draftListingsDao.watchAllForUser(userId: null).first;
    expect(guest.map((r) => r.item.id), ['scan-guest']);

    final user = await db.draftListingsDao
        .watchAllForUser(userId: 'user-1')
        .first;
    expect(user.map((r) => r.item.id), ['scan-user']);

    final userHaul = await db.draftListingsDao
        .watchByHaulId(haulId: 'haul-user', userId: 'user-1')
        .first;
    expect(userHaul.map((r) => r.item.id), ['scan-user']);
  });
}
