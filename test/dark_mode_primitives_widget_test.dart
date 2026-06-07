import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:fynd_loppis/shared/widgets/bento_card.dart';
import 'package:fynd_loppis/shared/widgets/error_banner.dart';
import 'package:fynd_loppis/shared/widgets/offline_banner.dart';

void main() {
  testWidgets('BentoCard renders in dark mode', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              height: 220,
              child: BentoCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Market Pulse',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Trending categories'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Market Pulse'), findsOneWidget);
  });

  testWidgets('OfflineBanner is legible in dark mode', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: OfflineBanner(message: 'Offline mode: price fetch is paused.'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Offline mode: price fetch is paused.'), findsOneWidget);
  });

  testWidgets('ErrorBanner is legible in dark mode', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        locale: const Locale('sv'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: ErrorBanner(
              title: 'Sync error',
              message: 'Failed to fetch price comps.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Sync error'), findsOneWidget);
    expect(find.text('Failed to fetch price comps.'), findsOneWidget);
  });
}
