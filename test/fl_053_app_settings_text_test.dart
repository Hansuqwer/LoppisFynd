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

  test('AppSettingsDao stores auth_last_email_v1 and can clear it', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.appSettingsDao.setString('auth_last_email_v1', 'anna@gmail.com');
    expect(
      await db.appSettingsDao.getString('auth_last_email_v1'),
      'anna@gmail.com',
    );

    await db.appSettingsDao.setString('auth_last_email_v1', null);
    expect(await db.appSettingsDao.getString('auth_last_email_v1'), isNull);
  });
}
