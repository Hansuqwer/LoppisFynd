import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';

void main() {
  test('AppSettingsDao setString/getString works', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.appSettingsDao.setString('greeting', 'hej');
    expect(await db.appSettingsDao.getString('greeting'), 'hej');

    await db.appSettingsDao.setString('greeting', null);
    expect(await db.appSettingsDao.getString('greeting'), isNull);
  });
}
