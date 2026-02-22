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
import 'package:fynd_loppis/shared/widgets/capsule_nav_bar.dart';

void main() {
  testWidgets('Bottom nav tabs switch without crashing', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final root = Directory.systemTemp;

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    await db.haulsDao.upsert(id: 'haul_current_guest', title: 'Current haul');

    const config = AppConfig(
      appEnv: 'test',
      traderaProxyUrl: '',
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

    final nav = find.byKey(const Key('capsule_nav'));
    expect(nav, findsOneWidget);

    // Contract: exactly 5 destinations.
    const destinationKeys = <Key>[
      Key('nav_dashboard'),
      Key('nav_scanner'),
      Key('nav_haul'),
      Key('nav_history'),
      Key('nav_profile'),
    ];
    for (final key in destinationKeys) {
      expect(
        find.descendant(of: nav, matching: find.byKey(key)),
        findsOneWidget,
      );
    }
    expect(
      tester.widget<CapsuleNavBar>(find.byType(CapsuleNavBar)).destinations,
      hasLength(5),
    );

    // Scanner
    await tester.tap(find.byKey(const Key('nav_scanner')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Snabbskanner'), findsWidgets);

    // Haul
    await tester.tap(find.byKey(const Key('nav_haul')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Pågående fynd'), findsWidgets);

    // History
    await tester.tap(find.byKey(const Key('nav_history')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Historik'), findsWidgets);

    // Profile
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Tillgänglighet'), findsWidgets);

    // Back home
    await tester.tap(find.byKey(const Key('nav_dashboard')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Jagarens tavla'), findsWidgets);

    // Dispose the widget tree and flush any pending Drift timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
