import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';

class BookDecisionScreen extends ConsumerWidget {
  const BookDecisionScreen({super.key, required this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final bookAsync = ref.watch(_bookProvider(bookId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.bookDecisionTitle),
        backgroundColor: Colors.transparent,
      ),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return Center(child: Text(l10n.errorSomethingWentWrong));
          }
          return _BookDecisionBody(book: book);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}

class _BookDecisionBody extends ConsumerWidget {
  const _BookDecisionBody({required this.book});

  final dynamic book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BookCoverSection(
            coverUrl: book.coverUrl as String?,
            title: book.title as String,
            author: book.author as String?,
            publishYear: book.publishYear as int?,
            isbn: book.isbn as String,
          ),
          const SizedBox(height: AppSpacing.lg),
          _MarketStatsSection(
            highestPrice: book.highestSoldPriceSek as int?,
            averagePrice: book.averageSoldPriceSek as int?,
            lowestPrice: book.lowestSoldPriceSek as int?,
            salesPerMonth: book.salesPerMonth as double?,
            totalSales: book.totalSales as int?,
          ),
          const SizedBox(height: AppSpacing.lg),
          _QuickPriceButtons(
            bookId: book.id as String,
            averagePrice: book.averageSoldPriceSek as int?,
          ),
        ],
      ),
    );
  }
}

class _BookCoverSection extends StatelessWidget {
  const _BookCoverSection({
    required this.coverUrl,
    required this.title,
    required this.author,
    required this.publishYear,
    required this.isbn,
  });

  final String? coverUrl;
  final String title;
  final String? author;
  final int? publishYear;
  final String isbn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BentoCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.borderSubtle,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: coverUrl != null && coverUrl!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.network(
                      coverUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _BookPlaceholder(),
                    ),
                  )
                : _BookPlaceholder(),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (author != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    author!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (publishYear != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    publishYear.toString(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'ISBN: $isbn',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.menu_book_outlined,
        size: 32,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _MarketStatsSection extends StatelessWidget {
  const _MarketStatsSection({
    required this.highestPrice,
    required this.averagePrice,
    required this.lowestPrice,
    required this.salesPerMonth,
    required this.totalSales,
  });

  final int? highestPrice;
  final int? averagePrice;
  final int? lowestPrice;
  final double? salesPerMonth;
  final int? totalSales;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (highestPrice == null && averagePrice == null && lowestPrice == null) {
      return BentoCard(
        child: Center(
          child: Column(
            children: [
              Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.bookNoMarketData,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookMarketStats,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.bookHighestPrice,
                  value: highestPrice != null ? '$highestPrice kr' : '—',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: l10n.bookAveragePrice,
                  value: averagePrice != null ? '$averagePrice kr' : '—',
                  color: AppColors.primaryAction,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _StatTile(
                  label: l10n.bookLowestPrice,
                  value: lowestPrice != null ? '$lowestPrice kr' : '—',
                  color: AppColors.textWarm,
                ),
              ),
            ],
          ),
          if (totalSales != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bookTotalSales,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '$totalSales',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
          if (salesPerMonth != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.bookSalesPerMonth,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  salesPerMonth!.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _QuickPriceButtons extends ConsumerWidget {
  const _QuickPriceButtons({required this.bookId, required this.averagePrice});

  final String bookId;
  final int? averagePrice;

  static const _defaultPrices = [5, 10, 15, 20, 25, 30];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bookPurchasePrice,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _defaultPrices.map((price) {
              return FilledButton(
                onPressed: () => _onPriceSelected(context, ref, price),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                ),
                child: Text('$price kr'),
              );
            }).toList(),
          ),
          if (averagePrice != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.success, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.bookProfitHint(averagePrice!),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _onPriceSelected(
    BuildContext context,
    WidgetRef ref,
    int price,
  ) async {
    final db = ref.read(appDatabaseProvider);
    await db.booksDao.setPurchasePrice(
      id: bookId,
      priceSek: price,
      saved: true,
    );
    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

final _bookProvider = FutureProvider.autoDispose.family<dynamic, String>((
  ref,
  bookId,
) async {
  final db = ref.watch(appDatabaseProvider);
  return db.booksDao.getById(bookId);
});
