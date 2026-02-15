import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/shared/widgets/bento_card.dart';

void main() {
  testWidgets('BentoCard golden', (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;

    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(
                width: 360,
                height: 220,
                child: BentoCard(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Market Pulse',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Trending categories'),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle(const Duration(milliseconds: 300));

    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('goldens/bento_card.png'),
    );
  });
}
