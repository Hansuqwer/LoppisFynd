import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/services/privacy/data_export_service.dart';

void main() {
  test('DataExportService exports JSON and CSV files', () async {
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
    await db.draftListingsDao.upsert(
      scanItemId: 'scan-1',
      title: 'Draft title',
      askingPriceSek: 100,
    );

    final dir = await Directory.systemTemp.createTemp('loppisfynd_export');
    addTearDown(() async {
      if (await dir.exists()) await dir.delete(recursive: true);
    });

    final service = DataExportService(documentsDirProvider: () async => dir);
    final jsonFile = await service.exportJson(db: db, userId: null);
    expect(await jsonFile.exists(), isTrue);
    expect(await jsonFile.readAsString(), contains('"scanItems"'));

    final csvFile = await service.exportCsv(db: db, userId: null);
    expect(await csvFile.exists(), isTrue);
    final csvText = await csvFile.readAsString();
    expect(csvText, contains('type,id,haulId'));
    expect(csvText, contains('scan-1'));
  });
}
