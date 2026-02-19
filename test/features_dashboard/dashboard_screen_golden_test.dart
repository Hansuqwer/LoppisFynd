import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/storage/scan_image_storage.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/core/navigation/app_nav_shell.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';
import 'package:fynd_loppis/services/ai/model_manager.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';

void main() {
  testWidgets('Dashboard (Home tab) golden', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final root = Directory.systemTemp;

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    await db.haulsDao.upsert(id: 'haul_current_guest', title: 'Current haul');

    const config = AppConfig(
      appEnv: 'test',
      traderaProxyUrl: '',
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

    final boundaryKey = GlobalKey();

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
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('sv'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: RepaintBoundary(
            key: boundaryKey,
            child: const SizedBox(
              width: 390,
              height: 844,
              child: AppNavShell(),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('../goldens/dashboard_screen.png'),
    );

    // Dispose widget tree and flush pending Drift stream timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
