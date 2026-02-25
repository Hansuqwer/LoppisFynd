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
import 'package:fynd_loppis/main.dart';
import 'package:fynd_loppis/services/ai/inference/inference_isolate_service.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';

void main() {
  testWidgets('Core screens render and remain usable offline', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final root = Directory.systemTemp;

    final db = AppDatabase.inMemory();
    addTearDown(db.close);
    await db.haulsDao.upsert(id: 'haul_current_guest', title: 'Current haul');

    const scanItemId = 'scan_item_offline_1';
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
          onboardingCompleteProvider.overrideWith((ref) => Stream.value(true)),
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: const LoppisfyndApp(),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));
    final l10n = AppLocalizations.of(
      tester.element(find.byKey(const Key('nav_dashboard'))),
    )!;

    // Dashboard
    expect(find.text(l10n.dashboardTitle), findsWidgets);

    // Haul
    await tester.tap(find.byKey(const Key('nav_haul')));
    await tester.pumpAndSettle(const Duration(milliseconds: 900));
    expect(find.text(l10n.haulTitle), findsWidgets);

    // History
    await tester.tap(find.byKey(const Key('nav_history')));
    await tester.pumpAndSettle(const Duration(milliseconds: 900));
    expect(find.text(l10n.historyHistoryTitle), findsWidgets);

    // Draft editor can render + save offline.
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
          onboardingCompleteProvider.overrideWith((ref) => Stream.value(true)),
          isOnlineProvider.overrideWith((ref) => Stream.value(false)),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('sv'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SizedBox(
            width: 390,
            height: 844,
            child: DraftEditorScreen(scanItemId: scanItemId),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(seconds: 2));

    final priceField = find.byType(TextField).last;
    await tester.enterText(priceField, '200');
    await tester.pump(const Duration(milliseconds: 300));

    final saveInkWell = find
        .ancestor(of: find.text('Spara'), matching: find.byType(InkWell))
        .first;
    await tester.tap(saveInkWell);
    await tester.pumpAndSettle(const Duration(milliseconds: 900));
    expect(find.text('Utkast sparat.'), findsOneWidget);

    // Dispose the widget tree and flush any pending Drift timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
