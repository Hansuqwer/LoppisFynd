import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/config/app_config.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/drafts/draft_editor_screen.dart';
import 'package:fynd_loppis/features/scanner/scanner_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_mapper.dart';
import 'package:fynd_loppis/services/books/book_inventory_draft_orchestration_service.dart';
import 'package:fynd_loppis/services/books/book_isbn_draft_flow_controller.dart';
import 'package:fynd_loppis/services/books/book_pricing_draft_service.dart';
import 'package:fynd_loppis/services/books/isbn_lookup_service.dart';

void main() {
  testWidgets('manual BokFynd ISBN seam calls controller and shows state', (
    tester,
  ) async {
    final orchestrator = _FakeOrchestrator(result: _appliedDraft());
    await _pumpEditor(tester, orchestrator);

    expect(
      find.text('Enter an ISBN to create a BokFynd draft.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('bokfynd_isbn_manual_field')),
      ' 9780143127796 ',
    );
    await tester.tap(find.byKey(const Key('bokfynd_isbn_apply_button')));
    await tester.pumpAndSettle();

    expect(orchestrator.calls, 1);
    expect(orchestrator.lastScanItemId, 'scan-1');
    expect(orchestrator.lastIsbn, '9780143127796');
    expect(find.text('BokFynd draft ready.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('manual BokFynd ISBN seam shows not-found state', (tester) async {
    final orchestrator = _FakeOrchestrator(result: null);
    await _pumpEditor(tester, orchestrator);

    await tester.enterText(
      find.byKey(const Key('bokfynd_isbn_manual_field')),
      '9780000000000',
    );
    await tester.tap(find.byKey(const Key('bokfynd_isbn_apply_button')));
    await tester.pumpAndSettle();

    expect(orchestrator.calls, 1);
    expect(find.text('No book metadata found for this ISBN.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('manual BokFynd ISBN seam shows error state', (tester) async {
    final orchestrator = _FakeOrchestrator(error: StateError('lookup failed'));
    await _pumpEditor(tester, orchestrator);

    await tester.enterText(
      find.byKey(const Key('bokfynd_isbn_manual_field')),
      '9780143127796',
    );
    await tester.tap(find.byKey(const Key('bokfynd_isbn_apply_button')));
    await tester.pumpAndSettle();

    expect(orchestrator.calls, 1);
    expect(find.textContaining('lookup failed'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });

  testWidgets('BokFynd scan action opens scanner with draft context', (
    tester,
  ) async {
    final orchestrator = _FakeOrchestrator(result: null);
    await _pumpEditor(tester, orchestrator);

    final scanButton = find.byKey(const Key('bokfynd_isbn_scan_button'));
    await tester.ensureVisible(scanButton);
    await tester.pumpAndSettle();
    await tester.tap(scanButton);
    await tester.pump(const Duration(milliseconds: 500));

    final scanner = tester.widget<ScannerScreen>(
      find.byType(ScannerScreen, skipOffstage: false),
    );
    expect(scanner.bookDraftScanItemId, 'scan-1');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  });
}

Future<void> _pumpEditor(
  WidgetTester tester,
  _FakeOrchestrator orchestrator,
) async {
  final db = AppDatabase.inMemory();
  addTearDown(db.close);
  await db.haulsDao.upsert(id: 'haul-1', title: 'Book haul');
  await db.scanItemsDao.insertNew(
    id: 'scan-1',
    haulId: 'haul-1',
    imagePath: '/tmp/book.jpg',
    thumbPath: '/tmp/book-thumb.jpg',
  );

  final controller = BookIsbnDraftFlowController(orchestrator: orchestrator);
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        appConfigProvider.overrideWithValue(_config()),
        bookIsbnDraftFlowControllerProvider.overrideWithValue(controller),
        highContrastEnabledProvider.overrideWith((ref) => Stream.value(false)),
        isOnlineProvider.overrideWith((ref) => Stream.value(true)),
      ],
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const SizedBox(
          width: 390,
          height: 844,
          child: DraftEditorScreen(scanItemId: 'scan-1'),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

AppConfig _config() {
  return const AppConfig(
    appEnv: 'test',
    traderaProxyUrl: '',
    cloudAiProxyUrl: '',
    supabaseUrl: '',
    supabaseAnonKey: '',
    sentryDsn: '',
  );
}

AppliedBookInventoryDraft _appliedDraft() {
  return AppliedBookInventoryDraft(
    pricingDraft: const BookPricingDraft(
      isbn: '9780143127796',
      metadata: BookMetadata(
        isbn: '9780143127796',
        title: 'Sapiens',
        source: 'google_books',
      ),
      marketQuery: 'Sapiens',
    ),
    payload: const BookInventoryDraftPayload(
      scanItem: BookScanItemDraftPayload(
        query: 'Sapiens',
        desc: 'Sapiens',
        category: 'Books',
      ),
      listing: BookListingDraftPayload(
        platform: 'tradera',
        title: 'Sapiens',
        description: 'Sapiens\nISBN: 9780143127796',
      ),
    ),
  );
}

class _FakeOrchestrator implements BookInventoryDraftOrchestrator {
  _FakeOrchestrator({this.result, this.error});

  final AppliedBookInventoryDraft? result;
  final Object? error;
  int calls = 0;
  String? lastScanItemId;
  String? lastIsbn;

  @override
  Future<AppliedBookInventoryDraft?> createAndApplyForIsbn({
    required String scanItemId,
    required String isbn,
    DateTime? now,
  }) async {
    calls += 1;
    lastScanItemId = scanItemId;
    lastIsbn = isbn;
    final thrown = error;
    if (thrown != null) throw thrown;
    return result;
  }
}
