import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import 'flip_factor.dart';
import 'profit_calculator.dart';

class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.scanItemId});

  final String scanItemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  final _purchaseController = TextEditingController();
  final _queryController = TextEditingController();
  double? _lastPurchase;
  String? _lastQuery;

  @override
  void dispose() {
    _purchaseController.dispose();
    _queryController.dispose();
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

  Future<void> _queueSync(AppDatabase db) async {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    await db.scanItemsDao.setQuery(id: widget.scanItemId, query: query);
    await db.scanItemsDao.transitionStatus(
      id: widget.scanItemId,
      to: ScanItemStatus.pendingSync,
    );
  }

  Future<void> _setQuery(AppDatabase db, String query) {
    final trimmed = query.trim();
    _queryController.text = trimmed;
    return db.scanItemsDao.setQuery(
      id: widget.scanItemId,
      query: trimmed.isEmpty ? null : trimmed,
    );
  }

  List<String> _tokensFromQuery(String? query) {
    final q = (query ?? '').trim();
    if (q.isEmpty) return const [];
    return q
        .split(RegExp(r'\s+'))
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .take(5)
        .toList(growable: false);
  }

  Future<String?> _promptForToken({
    required BuildContext context,
    String? initial,
  }) {
    final controller = TextEditingController(text: initial ?? '');
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(initial == null ? 'Add keyword' : 'Edit keyword'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. rorstrand'),
            onSubmitted: (v) => Navigator.of(context).pop(v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final syncScheduler = ref.watch(syncSchedulerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Item')),
      body: SafeArea(
        child: StreamBuilder<ScanItem?>(
          stream: db.scanItemsDao.watchById(widget.scanItemId),
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

            final query = item.query;
            if (query != _lastQuery) {
              _lastQuery = query;
              _queryController.text = query ?? '';
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
                              item.desc ?? item.query ?? 'Unnamed item',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Status: ${item.status.name}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _PriceChart(
                        min: item.minPrice,
                        median: item.medianPrice,
                        max: item.maxPrice,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _StatLine(
                              label: 'Min',
                              value: _formatSek(item.minPrice),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: 'Median',
                              value: _formatSek(item.medianPrice),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: 'Max',
                              value: _formatSek(item.maxPrice),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _KeywordChips(
                        tokens: _tokensFromQuery(item.query),
                        onAdd: () async {
                          final v = await _promptForToken(context: context);
                          if (v == null) return;
                          final nextToken = v.trim();
                          if (nextToken.isEmpty) return;
                          final tokens = [..._tokensFromQuery(item.query)];
                          if (tokens.length >= 5) return;
                          tokens.add(nextToken);
                          await _setQuery(db, tokens.join(' '));
                        },
                        onEdit: (index) async {
                          final tokens = [..._tokensFromQuery(item.query)];
                          if (index < 0 || index >= tokens.length) return;
                          final v = await _promptForToken(
                            context: context,
                            initial: tokens[index],
                          );
                          if (v == null) return;
                          final next = v.trim();
                          if (next.isEmpty) return;
                          tokens[index] = next;
                          await _setQuery(db, tokens.join(' '));
                        },
                        onDelete: (index) async {
                          final tokens = [..._tokensFromQuery(item.query)];
                          if (index < 0 || index >= tokens.length) return;
                          tokens.removeAt(index);
                          await _setQuery(db, tokens.join(' '));
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _queryController,
                        decoration: const InputDecoration(
                          labelText: 'Tradera query',
                          hintText: 'e.g. rorstrand mon amie tallrik',
                        ),
                        onSubmitted: (v) => _setQuery(db, v),
                        onEditingComplete: () =>
                            _setQuery(db, _queryController.text),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: GlassButton(
                              label: 'Queue sync',
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await _queueSync(db);
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Queued for sync.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.cloud_upload_rounded),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: GlassButton(
                              label: 'Sync now',
                              tone: GlassButtonTone.neutral,
                              onPressed: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                await _queueSync(db);
                                await syncScheduler.syncOnce();
                                if (!mounted) return;
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Sync completed.'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.sync_rounded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profit',
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
                        decoration: const InputDecoration(
                          labelText: 'Purchase price (SEK)',
                          hintText: '0',
                        ),
                        onSubmitted: (v) => _savePurchasePrice(db, v),
                        onEditingComplete: () =>
                            _savePurchasePrice(db, _purchaseController.text),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _ConditionAdjuster(
                        value: item.conditionMultiplier,
                        onChanged: (v) async {
                          await db.scanItemsDao.setConditionMultiplier(
                            id: item.id,
                            conditionMultiplier: v,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: _StatLine(
                              label: 'Expected',
                              value: _formatSek(adjustedExpected),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: 'Gross',
                              value: profit == null ? '—' : _formatSek(profit),
                            ),
                          ),
                          Expanded(
                            child: _StatLine(
                              label: 'Net (est.)',
                              value: netProfit == null
                                  ? '—'
                                  : _formatSek(netProfit),
                              emphasize: true,
                            ),
                          ),
                          Expanded(
                            child: _StatLine(label: 'Flip', value: grade),
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

class _StatLine extends StatelessWidget {
  const _StatLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final valueStyle = emphasize
        ? Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)
        : Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700);

    final valueStyleMetrics = valueStyle == null
        ? null
        : AppTypography.metricsFrom(valueStyle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: valueStyleMetrics),
      ],
    );
  }
}

class _ConditionAdjuster extends StatelessWidget {
  const _ConditionAdjuster({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.7, 1.1);
    final label = _conditionLabel(clamped);
    final percent = ((clamped - 1.0) * 100).round();
    final sign = percent > 0 ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Condition',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '$label ($sign$percent%)',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        Slider(
          value: clamped,
          min: 0.7,
          max: 1.1,
          divisions: 8,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _KeywordChips extends StatelessWidget {
  const _KeywordChips({
    required this.tokens,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<String> tokens;
  final VoidCallback onAdd;
  final ValueChanged<int> onEdit;
  final ValueChanged<int> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Keywords', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (var i = 0; i < tokens.length; i++)
              InputChip(
                label: Text(tokens[i]),
                onPressed: () => onEdit(i),
                onDeleted: () => onDelete(i),
              ),
            ActionChip(
              label: const Text('Add'),
              onPressed: tokens.length >= 5 ? null : onAdd,
              avatar: const Icon(Icons.add_rounded, size: 18),
            ),
          ],
        ),
      ],
    );
  }
}

String _conditionLabel(double multiplier) {
  if (multiplier >= 1.05) return 'Mint';
  if (multiplier >= 0.95) return 'Good';
  if (multiplier >= 0.85) return 'Fair';
  return 'Rough';
}

class _PriceChart extends StatelessWidget {
  const _PriceChart({
    required this.min,
    required this.median,
    required this.max,
  });

  final double? min;
  final double? median;
  final double? max;

  @override
  Widget build(BuildContext context) {
    if (min == null || median == null || max == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: const Text('No market data yet.'),
      );
    }

    final points = <FlSpot>[
      FlSpot(0, min!),
      FlSpot(1, median!),
      FlSpot(2, max!),
    ];

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final label = switch (value.toInt()) {
                    0 => 'Min',
                    1 => 'Median',
                    2 => 'Max',
                    _ => '',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: AppColors.deepSapphire,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryAction,
                    strokeWidth: 2,
                    strokeColor: AppColors.cloudDancer,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.deepSapphire.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        duration: AppMotion.normal,
        curve: AppMotion.curve,
      ),
    );
  }
}

String _formatSek(double? value) {
  if (value == null) return '—';
  final v = value.round();
  return '$v SEK';
}
