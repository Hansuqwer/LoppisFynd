import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';

void main() {
  test('HaulsDao insertNew + setLocation persists lat/lng', () async {
    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    await db.haulsDao.insertNew(id: 'h1', title: 'Morning haul');
    var haul = await db.haulsDao.getById('h1');
    expect(haul, isNotNull);
    expect(haul!.lat, isNull);
    expect(haul.lng, isNull);

    await db.haulsDao.setLocation(id: 'h1', lat: 59.33, lng: 18.06);
    haul = await db.haulsDao.getById('h1');
    expect(haul, isNotNull);
    expect(haul!.lat, closeTo(59.33, 0.0001));
    expect(haul.lng, closeTo(18.06, 0.0001));
  });
}
