import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/empty_state.dart';
import 'book_decision_screen.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.inventoryTitle),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<Book>>(
        stream: db.booksDao.watchSaved(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return EmptyState(
              icon: Icons.library_books_outlined,
              title: l10n.inventoryEmpty,
              message: l10n.inventoryEmptyHint,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return _BookInventoryCard(book: book);
            },
          );
        },
      ),
    );
  }
}

class _BookInventoryCard extends ConsumerWidget {
  const _BookInventoryCard({required this.book});

  final Book book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: BentoCard(
        onTap: () => _openBookDetail(context),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Image.network(
                        book.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _MiniBookPlaceholder(),
                      ),
                    )
                  : _MiniBookPlaceholder(),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.author != null) ...[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      book.author!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (book.purchasePriceSek != null)
                        _PriceChip(
                          label: l10n.inventoryBoughtFor,
                          value: '${book.purchasePriceSek} kr',
                          color: AppColors.textWarm,
                        ),
                      if (book.purchasePriceSek != null &&
                          book.averageSoldPriceSek != null)
                        const SizedBox(width: AppSpacing.xs),
                      if (book.averageSoldPriceSek != null)
                        _PriceChip(
                          label: l10n.inventoryAvgSell,
                          value: '${book.averageSoldPriceSek} kr',
                          color: AppColors.success,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (book.purchasePriceSek != null &&
                book.averageSoldPriceSek != null)
              _ProfitIndicator(
                purchasePrice: book.purchasePriceSek!,
                averageSellPrice: book.averageSoldPriceSek!,
              ),
          ],
        ),
      ),
    );
  }

  void _openBookDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BookDecisionScreen(bookId: book.id)),
    );
  }
}

class _MiniBookPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.menu_book_outlined,
        size: 20,
        color: AppColors.textMuted,
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        '$label $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProfitIndicator extends StatelessWidget {
  const _ProfitIndicator({
    required this.purchasePrice,
    required this.averageSellPrice,
  });

  final int purchasePrice;
  final int averageSellPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profit = averageSellPrice - purchasePrice;
    final isProfitable = profit > 0;
    final color = isProfitable ? AppColors.success : AppColors.primaryAction;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        children: [
          Icon(
            isProfitable ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 20,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${profit > 0 ? '+' : ''}$profit kr',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
