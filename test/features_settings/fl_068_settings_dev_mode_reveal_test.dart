import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/storage/scan_image_storage.dart';
import 'package:fynd_loppis/main.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';
import 'package:fynd_loppis/services/ai/model_manager.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:workmanager/workmanager.dart';

class _FakeWorkmanagerPlatform extends WorkmanagerPlatform {
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
  Future<void> cancelByUniqueName(String uniqueName) async {}

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

  setUp(() {
    original = WorkmanagerPlatform.instance;
    WorkmanagerPlatform.instance = _FakeWorkmanagerPlatform();

    addTearDown(() {
      WorkmanagerPlatform.instance = original;
    });
  });

  testWidgets('7 taps on version reveals dev-only sync controls', (
    tester,
  ) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final root = Directory.systemTemp;
    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    await db.haulsDao.upsert(id: 'haul_current_guest', title: 'Current haul');

    const config = AppConfig(
      appEnv: 'test',
      traderaProxyUrl: 'https://example.invalid/functions/v1/tradera-proxy',
      cloudAiProxyUrl: '',
      supabaseUrl: '',
      supabaseAnonKey: '',
      gemmaModelUrl: '',
      sentryDsn: '',
    );

    final storage = ScanImageStorage(rootDir: root);
    final modelManager = ModelManager(
      spec: const ModelSpec(
        id: 'gemma_vision',
        fileName: 'gemma_vision.litertlm',
      ),
      baseDirProvider: () async => root,
    );
    final aiInference = AiInferenceIsolateService();
    final syncScheduler = SyncScheduler(
      db: db,
      market: const NoopMarketDataSource(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          scanImageStorageProvider.overrideWithValue(storage),
          modelManagerProvider.overrideWithValue(modelManager),
          appConfigProvider.overrideWithValue(config),
          syncSchedulerProvider.overrideWithValue(syncScheduler),
          aiInferenceProvider.overrideWithValue(aiInference),
          highContrastEnabledProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          onboardingCompleteProvider.overrideWith((ref) => Stream.value(true)),
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const LoppisfyndApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Tillgänglighet'), findsWidgets);

    final l10n = AppLocalizations.of(
      tester.element(find.text('Tillgänglighet').first),
    )!;

    // Dev-only sync controls should be hidden in normal mode.
    expect(find.text(l10n.settingsMarketSyncTitle), findsNothing);
    expect(
      find.textContaining('--dart-define=TRADERA_PROXY_URL='),
      findsNothing,
    );

    final versionTapTarget = find.byKey(
      const Key('settings_dev_mode_tap_target'),
    );
    expect(versionTapTarget, findsOneWidget);

    for (var i = 0; i < 7; i++) {
      await tester.tap(versionTapTarget);
      await tester.pump(const Duration(milliseconds: 10));
    }
    await tester.pumpAndSettle();

    expect(await db.appSettingsDao.getInt('dev_mode_enabled_v1'), 1);

    // Dev-only sync section becomes visible once dev mode is enabled.
    final marketSyncTitle = find.text(l10n.settingsMarketSyncTitle);
    expect(marketSyncTitle, findsWidgets);
    expect(
      find.textContaining('--dart-define=TRADERA_PROXY_URL='),
      findsOneWidget,
    );

    // Dispose the widget tree and flush any pending Drift timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
