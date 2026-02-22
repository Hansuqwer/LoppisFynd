import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/storage/scan_image_storage.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/drafts/draft_editor_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';

void main() {
  testWidgets('Draft editor golden', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final root = Directory.systemTemp;

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    await db.haulsDao.upsert(id: 'haul_current_guest', title: 'Current haul');

    const scanItemId = 'scan_item_draft_1';
    await db
        .into(db.scanItems)
        .insert(
          ScanItemsCompanion.insert(
            id: scanItemId,
            haulId: 'haul_current_guest',
            query: const Value('keramik vas vintage'),
            desc: const Value('Handmalad vas med fin glasyr'),
            category: const Value('Keramik'),
          ),
        );
    await db.draftListingsDao.upsert(
      scanItemId: scanItemId,
      title: 'Maffig vas',
      description: 'Fin vas, retrokansla',
      askingPriceSek: 150,
    );

    const config = AppConfig(
      appEnv: 'test',
      traderaProxyUrl: '',
      cloudAiProxyUrl: '',
      supabaseUrl: '',
      supabaseAnonKey: '',
      sentryDsn: '',
    );

    final storage = ScanImageStorage(rootDir: root);
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
          appConfigProvider.overrideWithValue(config),
          syncSchedulerProvider.overrideWithValue(syncScheduler),
          aiInferenceProvider.overrideWithValue(aiInference),
          highContrastEnabledProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
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
              child: DraftEditorScreen(scanItemId: scanItemId),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('../goldens/draft_editor.png'),
    );

    // Dispose widget tree and flush pending Drift stream timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
