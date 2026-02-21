import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/database/tables/scan_items.dart';

void main() {
  test('HaulsDao upsert + getById works', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Saturday haul');
    final haul = await db.haulsDao.getById('haul-1');

    expect(haul, isNotNull);
    expect(haul!.id, 'haul-1');
    expect(haul.title, 'Saturday haul');
  });

  test('ScanItemsDao insert + watchByHaulId works', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.upsert(id: 'haul-1', title: 'Saturday haul');

    final events = expectLater(
      db.scanItemsDao.watchByHaulId('haul-1'),
      emitsThrough(
        predicate<List<ScanItem>>(
          (items) =>
              items.length == 1 &&
              items.first.id == 'scan-1' &&
              items.first.status == ScanItemStatus.pendingIdentify,
        ),
      ),
    );

    await db.scanItemsDao.insertNew(
      id: 'scan-1',
      haulId: 'haul-1',
      imagePath: '/tmp/image.jpg',
      thumbPath: '/tmp/thumb.jpg',
    );

    await events;
  });
}
