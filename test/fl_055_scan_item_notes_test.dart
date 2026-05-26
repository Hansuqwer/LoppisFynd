import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';

void main() {
  test('ScanItemsDao setNotes trims and persists', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Saturday haul');
    await db.scanItemsDao.insertNew(
      id: 'scan-1',
      haulId: 'haul-1',
      userId: null,
      imagePath: '/tmp/image.jpg',
      thumbPath: '/tmp/thumb.jpg',
    );

    await db.scanItemsDao.setNotes(id: 'scan-1', notes: '  chipped rim  ');
    final item = await db.scanItemsDao.getById('scan-1');
    expect(item, isNotNull);
    expect(item!.notes, 'chipped rim');

    await db.scanItemsDao.setNotes(id: 'scan-1', notes: '   ');
    final cleared = await db.scanItemsDao.getById('scan-1');
    expect(cleared!.notes, isNull);
  });
}
