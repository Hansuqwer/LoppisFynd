import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/main.dart';
import 'package:fynd_loppis/services/market/market_data_source.dart';
import 'package:fynd_loppis/services/sync/sync_scheduler.dart';
import 'package:fynd_loppis/shared/widgets/capsule_nav_bar.dart';
import 'package:fynd_loppis/features/scanner/scanner_screen.dart';

void main() {
  testWidgets('Bottom nav tabs switch without crashing', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

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

    final syncScheduler = SyncScheduler(
      db: db,
      market: const NoopMarketDataSource(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          appConfigProvider.overrideWithValue(config),
          syncSchedulerProvider.overrideWithValue(syncScheduler),
          highContrastEnabledProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          onboardingCompleteProvider.overrideWith((ref) => Stream.value(true)),
          isOnlineProvider.overrideWith((ref) => Stream.value(true)),
        ],
        child: const BokfyndApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    final nav = find.byKey(const Key('capsule_nav'));
    expect(nav, findsOneWidget);

    // Contract: exactly 5 destinations.
    const destinationKeys = <Key>[
      Key('nav_dashboard'),
      Key('nav_scanner'),
      Key('nav_inventory'),
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
    expect(
      tester
          .widget<ScannerScreen>(find.byType(ScannerScreen))
          .bookDraftScanItemId,
      isNull,
    );

    // Inventory – just verify the tab key exists (screen uses stream builder)
    expect(find.byKey(const Key('nav_inventory')), findsOneWidget);
    await tester.tap(find.byKey(const Key('nav_inventory')));
    await tester.pump(const Duration(milliseconds: 700));

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
