import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/books/book_decision_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';

Widget _wrap({
  required AppDatabase db,
  required String bookId,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: BookDecisionScreen(bookId: bookId),
    ),
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('BookDecisionScreen', () {
    testWidgets('renders book details with market stats (English)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      const bookId = 'book_test_1';
      final now = DateTime.now();

      await db.booksDao.upsert(
        id: bookId,
        isbn: '9789170379382',
        title: 'Pippi Långstrump',
        author: 'Astrid Lindgren',
        publishYear: 1945,
        scannedAt: now,
        updatedAt: now,
      );

      await db.booksDao.setMarketStats(
        id: bookId,
        highestSoldPriceSek: 250,
        averageSoldPriceSek: 150,
        lowestSoldPriceSek: 80,
        totalSales: 12,
        salesPerMonth: 1.5,
      );

      await db.booksDao.setPurchasePrice(
        id: bookId,
        priceSek: 50,
        saved: true,
      );

      await tester.pumpWidget(_wrap(db: db, bookId: bookId));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(BookDecisionScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.bookDecisionTitle), findsOneWidget);
      expect(find.text('Pippi Långstrump'), findsOneWidget);
      expect(find.text('Astrid Lindgren'), findsOneWidget);
      expect(find.text('1945'), findsOneWidget);
      expect(find.text('ISBN: 9789170379382'), findsOneWidget);

      expect(find.text(l10n.bookMarketStats), findsOneWidget);
      expect(find.text('250 kr'), findsOneWidget);
      expect(find.text('150 kr'), findsOneWidget);
      expect(find.text('80 kr'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('renders book details with market stats (Swedish)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      const bookId = 'book_test_2';
      final now = DateTime.now();

      await db.booksDao.upsert(
        id: bookId,
        isbn: '9789170379382',
        title: 'Pippi Långstrump',
        author: 'Astrid Lindgren',
        publishYear: 1945,
        scannedAt: now,
        updatedAt: now,
      );

      await db.booksDao.setMarketStats(
        id: bookId,
        highestSoldPriceSek: 250,
        averageSoldPriceSek: 150,
        lowestSoldPriceSek: 80,
        totalSales: 12,
        salesPerMonth: 1.5,
      );

      await tester.pumpWidget(
        _wrap(db: db, bookId: bookId, locale: const Locale('sv')),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(BookDecisionScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.bookDecisionTitle), findsOneWidget);
      expect(find.text(l10n.bookMarketStats), findsOneWidget);
      expect(find.text(l10n.bookHighestPrice), findsOneWidget);
      expect(find.text(l10n.bookAveragePrice), findsOneWidget);
      expect(find.text(l10n.bookLowestPrice), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows no market data message when stats are missing', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      const bookId = 'book_test_3';
      final now = DateTime.now();

      await db.booksDao.upsert(
        id: bookId,
        isbn: '9789170379382',
        title: 'Test Book',
        scannedAt: now,
        updatedAt: now,
      );

      await tester.pumpWidget(_wrap(db: db, bookId: bookId));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(BookDecisionScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.bookNoMarketData), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows error when book not found', (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await tester.pumpWidget(_wrap(db: db, bookId: 'nonexistent'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(BookDecisionScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.errorSomethingWentWrong), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
