import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/analytics/analytics_service.dart';

void main() {
  test('NoopAnalyticsService measure returns value', () async {
    const a = NoopAnalyticsService();
    final v = await a.measure('x', () async => 42);
    expect(v, 42);
  });
}
