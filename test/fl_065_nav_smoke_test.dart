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
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
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
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const LoppisfyndApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final nav = find.byKey(const Key('capsule_nav'));
    expect(nav, findsOneWidget);
    final l10n = AppLocalizations.of(tester.element(nav))!;

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
    expect(find.text(l10n.scannerTitle), findsWidgets);

    // Haul
    await tester.tap(find.byKey(const Key('nav_haul')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text(l10n.haulTitle), findsWidgets);

    // History
    await tester.tap(find.byKey(const Key('nav_history')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text(l10n.historyHistoryTitle), findsWidgets);

    // Profile
    await tester.tap(find.byKey(const Key('nav_profile')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text(l10n.settingsAccessibility), findsWidgets);

    // Back home
    await tester.tap(find.byKey(const Key('nav_dashboard')));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text(l10n.dashboardTitle), findsWidgets);

    // Dispose the widget tree and flush any pending Drift timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
