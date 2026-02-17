import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fynd_loppis/features/model_manager/widgets/model_download_card.dart';

void main() {
  group('ModelDownloadCard', () {
    testWidgets('renders idle state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModelDownloadCard(title: 'Gemma 2B', subtitle: 'Size: 1.5GB'),
          ),
        ),
      );

      expect(find.text('Gemma 2B'), findsOneWidget);
      expect(find.text('Size: 1.5GB'), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders downloading state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModelDownloadCard(
              title: 'Gemma 2B',
              subtitle: 'Size: 1.5GB',
              isDownloading: true,
              progress: 0.45,
            ),
          ),
        ),
      );

      expect(find.text('Downloading... 45%'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsNothing);
    });

    testWidgets('renders completed state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModelDownloadCard(
              title: 'Gemma 2B',
              subtitle: 'Size: 1.5GB',
              isCompleted: true,
            ),
          ),
        ),
      );

      expect(find.text('Ready to use'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.download_rounded), findsNothing);
    });

    testWidgets('renders error state correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ModelDownloadCard(
              title: 'Gemma 2B',
              subtitle: 'Size: 1.5GB',
              errorText: 'Download failed',
            ),
          ),
        ),
      );

      expect(find.text('Download failed'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ModelDownloadCard(
              title: 'Gemma 2B',
              subtitle: 'Size: 1.5GB',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ModelDownloadCard));
      expect(tapped, isTrue);
    });
  });
}
