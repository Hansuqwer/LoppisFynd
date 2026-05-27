import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../analyzer/item_detail_screen.dart';
import '../analyzer/profit_calculator.dart';
import '../drafts/draft_editor_screen.dart';
import '../../services/sync/cloud/entity_keys.dart';
import 'widgets/haul_stats_widget.dart';
import 'widgets/inventory_row.dart';
import 'widgets/summary_card_widget.dart';

enum _StatusFilter { all, complete, pending, failed }

enum _MarginFilter { all, profit, highMargin, needsData }

enum _FlipHorizon { all, fast, longTerm, unknown }

class HaulSummaryScreen extends ConsumerStatefulWidget {
  const HaulSummaryScreen({super.key, required this.haulId});

  final String haulId;

  @override
  ConsumerState<HaulSummaryScreen> createState() => _HaulSummaryScreenState();
}

class _HaulSummaryScreenState extends ConsumerState<HaulSummaryScreen> {
  var _status = _StatusFilter.all;
  var _margin = _MarginFilter.all;
  var _horizon = _FlipHorizon.all;
  String? _category;

  Future<void> _editHaul({
    required BuildContext context,
    required AppDatabase db,
    required String? userId,
    required Haul haul,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final titleController = TextEditingController(text: haul.title);
    final latController = TextEditingController(
      text: haul.lat == null ? '' : haul.lat!.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: haul.lng == null ? '' : haul.lng!.toStringAsFixed(6),
    );

    var startedAt = haul.startedAt;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(l10n.haulEditTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: l10n.haulEditNameLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.haulEditDateValue(
                            startedAt.year,
                            startedAt.month,
                            startedAt.day,
                          ),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: startedAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked == null) return;
                          setState(() {
                            startedAt = DateTime(
                              picked.year,
                              picked.month,
                              picked.day,
                              startedAt.hour,
                              startedAt.minute,
                              startedAt.second,
                            );
                          });
                        },
                        child: Text(l10n.haulEditPickDate),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: latController,
                    decoration: InputDecoration(
                      labelText: l10n.haulEditLatitudeOptional,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: lngController,
                    decoration: InputDecoration(
                      labelText: l10n.haulEditLongitudeOptional,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.commonCancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.commonSave),
                ),
              ],
            );
          },
        );
      },
    );

    final title = titleController.text.trim();
    final lat = double.tryParse(latController.text.trim());
    final lng = double.tryParse(lngController.text.trim());

    titleController.dispose();
    latController.dispose();
    lngController.dispose();

    if (ok != true) return;
    if (title.isEmpty) return;

    await db.haulsDao.updateDetails(
      id: haul.id,
      userId: userId,
      title: title,
      startedAt: startedAt,
      endedAt: haul.endedAt,
      lat: lat,
      lng: lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<Haul?>(
      stream: db.haulsDao.watchById(widget.haulId, userId: userId),
      builder: (context, haulSnapshot) {
        final haul = haulSnapshot.data;

        return Scaffold(
          appBar: AppBar(
            title: Text(haul == null ? l10n.haulSummaryTitle : haul.title),
            actions: [
              if (haul != null)
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  tooltip: l10n.haulEditTitle,
                  onPressed: () => _editHaul(
                    context: context,
                    db: db,
                    userId: userId,
                    haul: haul,
                  ),
                ),
            ],
          ),
          body: SafeArea(
            child: StreamBuilder<List<ScanItem>>(
              stream: db.scanItemsDao.watchByHaulId(
                widget.haulId,
                userId: userId,
              ),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const [];
                if (items.isEmpty) {
                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      EmptyState(
                        title: l10n.haulSummaryEmptyTitle,
                        message: l10n.haulSummaryEmptyMessage,
                        icon: Icons.shopping_bag_outlined,
                      ),
                    ],
                  );
                }

                final categories =
                    items
                        .map((it) => it.category?.trim())
                        .where((c) => c != null && c.isNotEmpty)
                        .cast<String>()
                        .toSet()
                        .toList()
                      ..sort();

                if (_category != null && !categories.contains(_category)) {
                  _category = null;
                }

                final computed = items
                    .map((it) => (item: it, net: _netProfit(it)))
                    .toList(growable: false);

                final invested = items.fold<double>(
                  0,
                  (sum, it) => sum + (it.purchasePrice ?? 0),
                );

                final expected = items.fold<double>(
                  0,
                  (sum, it) =>
                      sum + ((it.medianPrice ?? 0) * it.conditionMultiplier),
                );

                final netProfit = computed.fold<double>(
                  0,
                  (sum, it) => sum + (it.net ?? 0),
                );

                final completed = items.where(
                  (it) => it.status == ScanItemStatus.complete,
                );
                final failed = items.where(
                  (it) => it.status == ScanItemStatus.failed,
                );
                final pending = items.length - completed.length - failed.length;

                final filtered = computed
                    .where((pair) {
                      final it = pair.item;
                      final net = pair.net;

                      if (_category != null &&
                          (it.category?.trim() != _category)) {
                        return false;
                      }

                      final okStatus = switch (_status) {
                        _StatusFilter.all => true,
                        _StatusFilter.complete =>
                          it.status == ScanItemStatus.complete,
                        _StatusFilter.failed =>
                          it.status == ScanItemStatus.failed,
                        _StatusFilter.pending =>
                          it.status != ScanItemStatus.complete &&
                              it.status != ScanItemStatus.failed,
                      };
                      if (!okStatus) return false;

                      final okMargin = switch (_margin) {
                        _MarginFilter.all => true,
                        _MarginFilter.needsData => net == null,
                        _MarginFilter.profit => (net ?? 0) > 0,
                        _MarginFilter.highMargin => _isHighMargin(net, it),
                      };
                      if (!okMargin) return false;

                      final okHorizon = switch (_horizon) {
                        _FlipHorizon.all => true,
                        _FlipHorizon.fast =>
                          (it.daysToSellEst != null) && it.daysToSellEst! <= 30,
                        _FlipHorizon.longTerm =>
                          (it.daysToSellEst != null) && it.daysToSellEst! > 30,
                        _FlipHorizon.unknown => it.daysToSellEst == null,
                      };
                      if (!okHorizon) return false;

                      return true;
                    })
                    .toList(growable: false);

                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    HaulStatsWidget(
                      itemCount: items.length,
                      invested: invested,
                      expected: expected,
                      netProfit: netProfit,
                      completedCount: completed.length,
                      pendingCount: pending,
                      failedCount: failed.length,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    BentoCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  l10n.haulSummaryFiltersTitle,
                                  style: Theme.of(context).textTheme.titleLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text(
                                l10n.haulSummaryShowingCount(filtered.length),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              ChoiceChip(
                                label: Text(l10n.filterStatusAll),
                                selected: _status == _StatusFilter.all,
                                onSelected: (_) =>
                                    setState(() => _status = _StatusFilter.all),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterStatusComplete),
                                selected: _status == _StatusFilter.complete,
                                onSelected: (_) => setState(
                                  () => _status = _StatusFilter.complete,
                                ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterStatusPending),
                                selected: _status == _StatusFilter.pending,
                                onSelected: (_) => setState(
                                  () => _status = _StatusFilter.pending,
                                ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterStatusFailed),
                                selected: _status == _StatusFilter.failed,
                                onSelected: (_) => setState(
                                  () => _status = _StatusFilter.failed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              ChoiceChip(
                                label: Text(l10n.filterMarginAll),
                                selected: _margin == _MarginFilter.all,
                                onSelected: (_) =>
                                    setState(() => _margin = _MarginFilter.all),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterMarginProfit),
                                selected: _margin == _MarginFilter.profit,
                                onSelected: (_) => setState(
                                  () => _margin = _MarginFilter.profit,
                                ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterMarginHigh),
                                selected: _margin == _MarginFilter.highMargin,
                                onSelected: (_) => setState(
                                  () => _margin = _MarginFilter.highMargin,
                                ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterMarginNeedsData),
                                selected: _margin == _MarginFilter.needsData,
                                onSelected: (_) => setState(
                                  () => _margin = _MarginFilter.needsData,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: [
                              ChoiceChip(
                                label: Text(l10n.filterHorizonAll),
                                selected: _horizon == _FlipHorizon.all,
                                onSelected: (_) =>
                                    setState(() => _horizon = _FlipHorizon.all),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterHorizonFast),
                                selected: _horizon == _FlipHorizon.fast,
                                onSelected: (_) => setState(
                                  () => _horizon = _FlipHorizon.fast,
                                ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterHorizonLongTerm),
                                selected: _horizon == _FlipHorizon.longTerm,
                                onSelected: (_) => setState(
                                  () => _horizon = _FlipHorizon.longTerm,
                                ),
                              ),
                              ChoiceChip(
                                label: Text(l10n.filterHorizonUnknown),
                                selected: _horizon == _FlipHorizon.unknown,
                                onSelected: (_) => setState(
                                  () => _horizon = _FlipHorizon.unknown,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          if (categories.isEmpty)
                            Text(
                              l10n.filterCategoryNone,
                              style: Theme.of(context).textTheme.bodyMedium,
                            )
                          else
                            Wrap(
                              spacing: AppSpacing.xs,
                              runSpacing: AppSpacing.xs,
                              children: [
                                ChoiceChip(
                                  label: Text(l10n.filterCategoryAll),
                                  selected: _category == null,
                                  onSelected: (_) =>
                                      setState(() => _category = null),
                                ),
                                ...categories.map(
                                  (c) => ChoiceChip(
                                    label: Text(c),
                                    selected: _category == c,
                                    onSelected: (_) =>
                                        setState(() => _category = c),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DraftsSummaryCard(
                      db: db,
                      haulId: widget.haulId,
                      userId: userId,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l10n.haulSummaryInventoryTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (filtered.isEmpty)
                      EmptyState(
                        title: l10n.haulSummaryNoMatchesTitle,
                        message: l10n.haulSummaryNoMatchesMessage,
                        icon: Icons.filter_alt_off_rounded,
                      )
                    else
                      StreamBuilder<Map<String, EntitySyncStatuse>>(
                        stream: db.entitySyncStatusesDao.watchMany(
                          filtered.expand((p) {
                            return [
                              scanItemEntityKey(p.item.id),
                              scanPhotoEntityKey(p.item.id),
                            ];
                          }),
                        ),
                        builder: (context, statusSnapshot) {
                          final statuses = statusSnapshot.data ?? const {};

                          String? mergedStatusFor(String scanItemId) {
                            final meta =
                                statuses[scanItemEntityKey(scanItemId)]?.status;
                            final photo =
                                statuses[scanPhotoEntityKey(scanItemId)]
                                    ?.status;

                            int rank(String? s) => switch (s) {
                              'conflict' => 3,
                              'failed' => 2,
                              'syncing' => 1,
                              'synced' => 0,
                              _ => -1,
                            };

                            final a = meta;
                            final b = photo;
                            if (rank(a) >= rank(b)) return a;
                            return b;
                          }

                          return Column(
                            children: [
                              for (final pair in filtered)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.sm,
                                  ),
                                  child: BentoCard(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        SpringRoute(
                                          builder: (_) => ItemDetailScreen(
                                            scanItemId: pair.item.id,
                                          ),
                                        ),
                                      );
                                    },
                                    padding: const EdgeInsets.all(
                                      AppSpacing.md,
                                    ),
                                    child: InventoryRow(
                                      item: pair.item,
                                      net: pair.net,
                                      cloudStatus: mergedStatusFor(
                                        pair.item.id,
                                      ),
                                      onOpenDraft: () {
                                        Navigator.of(context).push(
                                          SpringRoute(
                                            builder: (_) => DraftEditorScreen(
                                              scanItemId: pair.item.id,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

double? _netProfit(ScanItem it) {
  final p = it.purchasePrice;
  final m = it.medianPrice;
  if (p == null || m == null) return null;
  return ProfitCalculator.netProfit(
    purchasePrice: p,
    expectedSalePrice: (m * it.conditionMultiplier),
    fixedFeesSek: it.fixedFeesSek ?? 0,
    shippingPaidBySellerSek: it.shippingPaidBySellerSek ?? 0,
  );
}

bool _isHighMargin(double? net, ScanItem it) {
  if (net == null) return false;
  final p = it.purchasePrice;
  if (p == null || p <= 0) return net >= 200;
  return (net / p) >= 1.0;
}
