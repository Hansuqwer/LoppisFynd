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

void main() {
  testWidgets('App boots and shows nav shell', (WidgetTester tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final db = AppDatabase.inMemory();
    addTearDown(db.close);

    // Ensure the guest current haul exists.
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

    expect(find.byKey(const Key('capsule_nav')), findsOneWidget);
    expect(find.byKey(const Key('nav_dashboard')), findsOneWidget);
    expect(find.byKey(const Key('nav_scanner')), findsOneWidget);
    expect(find.byKey(const Key('nav_inventory')), findsOneWidget);
    expect(find.byKey(const Key('nav_history')), findsOneWidget);
    expect(find.byKey(const Key('nav_profile')), findsOneWidget);

    // Dispose the widget tree and flush any pending Drift timers.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}
