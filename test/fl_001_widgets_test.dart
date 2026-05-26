import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/shared/widgets/bento_card.dart';
import 'package:fynd_loppis/shared/widgets/glass_button.dart';
import 'package:fynd_loppis/shared/widgets/glass_overlay.dart';

void main() {
  testWidgets('BentoCard calls onTap when tapped', (WidgetTester tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BentoCard(
            onTap: () => tapped = true,
            child: const Text('Card'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Card'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('GlassButton calls onPressed when tapped', (
    WidgetTester tester,
  ) async {
    var pressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: GlassButton(label: 'Go', onPressed: () => pressed = true),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(pressed, isTrue);
  });

  testWidgets('GlassOverlay builds BackdropFilter', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GlassOverlay(child: Text('Glass'))),
      ),
    );

    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
