import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';

void main() {
  test('DAOs can filter data by userId', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.insertNew(id: 'h_guest', title: 'Guest');
    await db.haulsDao.insertNew(id: 'h_u1', userId: 'u1', title: 'U1');

    await db.scanItemsDao.insertNew(
      id: 's_guest',
      haulId: 'h_guest',
      imagePath: '/tmp/image.jpg',
      thumbPath: '/tmp/thumb.jpg',
    );
    await db.scanItemsDao.insertNew(
      id: 's_u1',
      userId: 'u1',
      haulId: 'h_u1',
      imagePath: '/tmp/image.jpg',
      thumbPath: '/tmp/thumb.jpg',
    );

    final guest = await db.scanItemsDao.listAll();
    expect(guest.map((e) => e.id).toList(), ['s_guest']);

    final u1 = await db.scanItemsDao.listAll(userId: 'u1');
    expect(u1.map((e) => e.id).toList(), ['s_u1']);
  });
}
