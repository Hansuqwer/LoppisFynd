import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/services/sync/background/background_sync.dart';
import 'package:workmanager/workmanager.dart';

class _FakeWorkmanagerPlatform extends WorkmanagerPlatform {
  final cancelledUniqueNames = <String>[];

  @override
  Future<void> initialize(
    Function callbackDispatcher, {
    @Deprecated(
      'Use WorkmanagerDebug handlers instead. This parameter has no effect.',
    )
    bool isInDebugMode = false,
  }) async {}

  @override
  Future<void> registerOneOffTask(
    String uniqueName,
    String taskName, {
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
    OutOfQuotaPolicy? outOfQuotaPolicy,
  }) async {}

  @override
  Future<void> registerPeriodicTask(
    String uniqueName,
    String taskName, {
    Duration? frequency,
    Duration? flexInterval,
    Map<String, dynamic>? inputData,
    Duration? initialDelay,
    Constraints? constraints,
    ExistingPeriodicWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    Duration? backoffPolicyDelay,
    String? tag,
  }) async {}

  @override
  Future<void> registerProcessingTask(
    String uniqueName,
    String taskName, {
    Duration? initialDelay,
    Map<String, dynamic>? inputData,
    Constraints? constraints,
  }) async {}

  @override
  Future<void> cancelByUniqueName(String uniqueName) async {
    cancelledUniqueNames.add(uniqueName);
  }

  @override
  Future<void> cancelByTag(String tag) async {}

  @override
  Future<void> cancelAll() async {}

  @override
  Future<bool> isScheduledByUniqueName(String uniqueName) async => false;

  @override
  Future<String> printScheduledTasks() async => '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WorkmanagerPlatform original;
  late _FakeWorkmanagerPlatform fake;

  setUp(() {
    original = WorkmanagerPlatform.instance;
    fake = _FakeWorkmanagerPlatform();
    WorkmanagerPlatform.instance = fake;
  });

  tearDown(() {
    WorkmanagerPlatform.instance = original;
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'BackgroundSync.scheduleIfConfigured cancels stale work when Tradera proxy is not configured',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await BackgroundSync.scheduleIfConfigured(db: db);

      expect(fake.cancelledUniqueNames, contains('market_sync'));
    },
  );
}
