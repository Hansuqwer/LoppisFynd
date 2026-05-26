import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/services/privacy/local_data_deletion_service.dart';

void main() {
  test(
    'LocalDataDeletionService deletes scoped data and media files',
    () async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      final dir = await Directory.systemTemp.createTemp('loppisfynd_delete');
      addTearDown(() async {
        if (await dir.exists()) await dir.delete(recursive: true);
      });

      final image = File('${dir.path}/img.jpg')..writeAsStringSync('x');
      final thumb = File('${dir.path}/thumb.jpg')..writeAsStringSync('y');

      await db.haulsDao.upsert(
        id: 'haul-1',
        title: 'Saturday haul',
        userId: null,
      );
      await db.scanItemsDao.insertNew(
        id: 'scan-1',
        haulId: 'haul-1',
        userId: null,
        imagePath: image.path,
        thumbPath: thumb.path,
      );
      await db.draftListingsDao.upsert(scanItemId: 'scan-1', title: 'Draft');
      await db.appSettingsDao.setString('profile_display_name_user-1', 'Alice');

      expect(await image.exists(), isTrue);
      expect(await thumb.exists(), isTrue);

      await LocalDataDeletionService(db: db).deleteAllLocalData(userId: null);

      expect(await db.scanItemsDao.listAll(userId: null), isEmpty);
      expect(await db.haulsDao.listAll(userId: null), isEmpty);
      expect(await image.exists(), isFalse);
      expect(await thumb.exists(), isFalse);
    },
  );
}
