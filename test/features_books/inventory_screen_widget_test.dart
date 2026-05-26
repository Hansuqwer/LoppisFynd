import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fynd_loppis/core/app/providers.dart';
import 'package:fynd_loppis/core/database/app_database.dart';
import 'package:fynd_loppis/core/theme/app_theme.dart';
import 'package:fynd_loppis/features/books/inventory_screen.dart';
import 'package:fynd_loppis/gen/app_localizations.dart';

Widget _wrap({
  required AppDatabase db,
  Locale locale = const Locale('en'),
}) {
  return ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      theme: AppTheme.light(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const InventoryScreen(),
    ),
  );
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('InventoryScreen', () {
    testWidgets('shows empty state when no books saved (English)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(InventoryScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.inventoryTitle), findsOneWidget);
      expect(find.text(l10n.inventoryEmpty), findsOneWidget);
      expect(find.text(l10n.inventoryEmptyHint), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows empty state when no books saved (Swedish)', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      await tester.pumpWidget(_wrap(db: db, locale: const Locale('sv')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final context = tester.element(find.byType(InventoryScreen));
      final l10n = AppLocalizations.of(context)!;

      expect(find.text(l10n.inventoryTitle), findsOneWidget);
      expect(find.text(l10n.inventoryEmpty), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('displays saved books with purchase and market prices', (
      tester,
    ) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      final now = DateTime.now();

      await db.booksDao.upsert(
        id: 'book_1',
        isbn: '9789170379382',
        title: 'Pippi Långstrump',
        author: 'Astrid Lindgren',
        scannedAt: now,
        updatedAt: now,
      );

      await db.booksDao.setPurchasePrice(
        id: 'book_1',
        priceSek: 50,
        saved: true,
      );

      await db.booksDao.setMarketStats(
        id: 'book_1',
        averageSoldPriceSek: 150,
      );

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Pippi Långstrump'), findsOneWidget);
      expect(find.text('Astrid Lindgren'), findsOneWidget);
      expect(find.textContaining('50 kr'), findsWidgets);
      expect(find.textContaining('150 kr'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });

    testWidgets('shows multiple books in list', (tester) async {
      final db = AppDatabase.inMemory();
      addTearDown(db.close);

      final now = DateTime.now();

      await db.booksDao.upsert(
        id: 'book_1',
        isbn: '9789170379382',
        title: 'Book One',
        author: 'Author A',
        scannedAt: now,
        updatedAt: now,
      );

      await db.booksDao.setPurchasePrice(
        id: 'book_1',
        priceSek: 30,
        saved: true,
      );

      await db.booksDao.upsert(
        id: 'book_2',
        isbn: '9789170379383',
        title: 'Book Two',
        author: 'Author B',
        scannedAt: now,
        updatedAt: now,
      );

      await db.booksDao.setPurchasePrice(
        id: 'book_2',
        priceSek: 40,
        saved: true,
      );

      await tester.pumpWidget(_wrap(db: db));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Book One'), findsOneWidget);
      expect(find.text('Book Two'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    });
  });
}
