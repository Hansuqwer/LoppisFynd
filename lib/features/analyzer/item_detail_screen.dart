import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../gen/app_localizations.dart';
import 'flip_factor.dart';
import 'profit_calculator.dart';
import 'widgets/stat_line.dart';
import 'widgets/condition_adjuster.dart';
import 'widgets/market_stats_widget.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.scanItemId});

  final String scanItemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final _purchaseController = TextEditingController();
  final _fixedFeesController = TextEditingController();
  final _shippingController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  double? _lastPurchase;
  double? _lastFixedFees;
  double? _lastShipping;
  String? _lastCategory;
  String? _lastNotes;

  @override
  void dispose() {
    _purchaseController.dispose();
    _fixedFeesController.dispose();
    _shippingController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _savePurchasePrice(AppDatabase db, String text) async {
    final trimmed = text.trim();
    final parsed = trimmed.isEmpty ? null : double.tryParse(trimmed);
    await db.scanItemsDao.setPurchasePrice(
      id: widget.scanItemId,
      purchasePrice: parsed,
    );
  }

  Future<void> _saveFees(AppDatabase db) async {
    double? parseNullable(String text) {
      final trimmed = text.trim();
      return trimmed.isEmpty ? null : double.tryParse(trimmed);
    }

    await db.scanItemsDao.setFees(
      id: widget.scanItemId,
      fixedFeesSek: parseNullable(_fixedFeesController.text),
      shippingPaidBySellerSek: parseNullable(_shippingController.text),
    );
  }

  Future<void> _saveNotes(AppDatabase db, String text) {
    return db.scanItemsDao.setNotes(id: widget.scanItemId, notes: text);
  }

  Future<void> _saveCategory(AppDatabase db, String text) {
    return db.scanItemsDao.setCategory(id: widget.scanItemId, category: text);
  }
  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.itemDetailTitle)),
      body: SafeArea(
        child: StreamBuilder<ScanItem?>(
          stream: db.scanItemsDao.watchById(widget.scanItemId, userId: userId),
          builder: (context, snapshot) {
            final item = snapshot.data;
            if (item == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final purchase = item.purchasePrice;
            if (purchase != _lastPurchase) {
              _lastPurchase = purchase;
              _purchaseController.text = purchase == null
                  ? ''
                  : purchase.toStringAsFixed(purchase % 1 == 0 ? 0 : 2);
            }

            final fixedFees = item.fixedFeesSek;
            if (fixedFees != _lastFixedFees) {
              _lastFixedFees = fixedFees;
              _fixedFeesController.text = fixedFees == null
                  ? ''
                  : fixedFees.toStringAsFixed(fixedFees % 1 == 0 ? 0 : 2);
            }

            final shipping = item.shippingPaidBySellerSek;
            if (shipping != _lastShipping) {
              _lastShipping = shipping;
              _shippingController.text = shipping == null
                  ? ''
                  : shipping.toStringAsFixed(shipping % 1 == 0 ? 0 : 2);
            }

            final category = item.category;
            if (category != _lastCategory) {
              _lastCategory = category;
              _categoryController.text = category ?? '';
            }

            final notes = item.notes;
            if (notes != _lastNotes) {
              _lastNotes = notes;
              _notesController.text = notes ?? '';
            }

            final expected = item.medianPrice;
            final adjustedExpected = expected == null
                ? null
                : expected * item.conditionMultiplier;
            final profit = ProfitCalculator.grossProfit(
              purchasePrice: purchase,
              expectedSalePrice: adjustedExpected,
            );
            final netProfit = ProfitCalculator.netProfit(
              purchasePrice: purchase,
              expectedSalePrice: adjustedExpected,
              fixedFeesSek: fixedFees ?? 0,
              shippingPaidBySellerSek: shipping ?? 0,
            );
            final grade = (purchase != null && expected != null)
                ? FlipFactor.grade(
                    purchasePrice: purchase,
                    expectedSalePrice: adjustedExpected ?? expected,
                  )
                : '—';

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                BentoCard(
                  onTap: () {},
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: item.thumbPath == null
                            ? Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surface,
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_rounded),
                              )
                            : Image.file(
                                File(item.thumbPath!),
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                cacheWidth: 144,
                                cacheHeight: 144,
                                errorBuilder: (context, _, _) {
                                  return Container(
                                    width: 72,
                                    height: 72,
                                    color: AppColors.surface,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                    ),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.desc ??
                                  item.query ??
                                  l10n.itemDetailUnnamedItem,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              l10n.itemDetailStatusValue(item.status.name),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                MarketStatsWidget(item: item, db: db),
                const SizedBox(height: AppSpacing.lg),
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.itemDetailProfitTitle,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _purchaseController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: l10n.itemDetailPurchasePriceLabel,
                        ),
                        onSubmitted: (v) => _savePurchasePrice(db, v),
                        onEditingComplete: () =>
                            _savePurchasePrice(db, _purchaseController.text),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _fixedFeesController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.itemDetailFixedFeesLabel,
                              ),
                              onSubmitted: (_) => _saveFees(db),
                              onEditingComplete: () => _saveFees(db),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: TextField(
                              controller: _shippingController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText: l10n.itemDetailShippingSellerLabel,
                              ),
                              onSubmitted: (_) => _saveFees(db),
                              onEditingComplete: () => _saveFees(db),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ConditionAdjuster(
                        value: item.conditionMultiplier,
                        onChanged: (v) async {
                          await db.scanItemsDao.setConditionMultiplier(
                            id: item.id,
                            conditionMultiplier: v,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: l10n.itemDetailCategoryLabel,
                          hintText: l10n.itemDetailCategoryHint,
                        ),
                        textInputAction: TextInputAction.next,
                        onSubmitted: (v) => _saveCategory(db, v),
                        onEditingComplete: () =>
                            _saveCategory(db, _categoryController.text),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: l10n.itemDetailNotesLabel,
                          hintText: l10n.itemDetailNotesHint,
                        ),
                        onSubmitted: (v) => _saveNotes(db, v),
                        onEditingComplete: () =>
                            _saveNotes(db, _notesController.text),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: StatLine(
                              label: 'Expected',
                              value: _formatSek(adjustedExpected),
                            ),
                          ),
                          Expanded(
                            child: StatLine(
                              label: 'Gross',
                              value: profit == null ? '—' : _formatSek(profit),
                            ),
                          ),
                          Expanded(
                            child: StatLine(
                              label: 'Net (est.)',
                              value: netProfit == null
                                  ? '—'
                                  : _formatSek(netProfit),
                              emphasize: true,
                            ),
                          ),
                          Expanded(
                            child: StatLine(label: 'Flip', value: grade),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

String _formatSek(double? value) {
  if (value == null) return '—';
  final v = value.round();
  return '$v SEK';
}
