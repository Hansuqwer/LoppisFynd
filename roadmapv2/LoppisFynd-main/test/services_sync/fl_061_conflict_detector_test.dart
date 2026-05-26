import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/services/sync/cloud/conflict_detector.dart';

void main() {
  test('isLwwConflict detects local-changed-then-cloud-newer', () {
    final last = DateTime(2026, 1, 1, 10);
    final local = DateTime(2026, 1, 1, 11);
    final cloud = DateTime(2026, 1, 1, 12);
    expect(
      isLwwConflict(
        localUpdatedAt: local,
        cloudUpdatedAt: cloud,
        lastSyncAt: last,
      ),
      isTrue,
    );
  });

  test('isLwwConflict is false when local not changed since last sync', () {
    final last = DateTime(2026, 1, 1, 10);
    final local = DateTime(2026, 1, 1, 10);
    final cloud = DateTime(2026, 1, 1, 12);
    expect(
      isLwwConflict(
        localUpdatedAt: local,
        cloudUpdatedAt: cloud,
        lastSyncAt: last,
      ),
      isFalse,
    );
  });

  test('isLwwConflict is false when cloud not newer than local', () {
    final last = DateTime(2026, 1, 1, 10);
    final local = DateTime(2026, 1, 1, 11);
    final cloud = DateTime(2026, 1, 1, 11);
    expect(
      isLwwConflict(
        localUpdatedAt: local,
        cloudUpdatedAt: cloud,
        lastSyncAt: last,
      ),
      isFalse,
    );
  });
}
