import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../analyzer/profit_calculator.dart';

class HaulSummaryScreen extends ConsumerWidget {
  const HaulSummaryScreen({super.key, required this.haulId});

  final String haulId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Haul Summary')),
      body: SafeArea(
        child: StreamBuilder(
          stream: db.scanItemsDao.watchByHaulId(haulId),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const [];

            final invested = items.fold<double>(
              0,
              (sum, it) => sum + (it.purchasePrice ?? 0),
            );

            final expected = items.fold<double>(
              0,
              (sum, it) =>
                  sum + ((it.medianPrice ?? 0) * it.conditionMultiplier),
            );

            final netProfit = items.fold<double>(0, (sum, it) {
              final p = it.purchasePrice;
              final m = it.medianPrice;
              if (p == null || m == null) return sum;
              return sum +
                  (ProfitCalculator.netProfit(
                        purchasePrice: p,
                        expectedSalePrice: (m * it.conditionMultiplier),
                      ) ??
                      0);
            });

            final completed = items
                .where((it) => it.status == ScanItemStatus.complete)
                .length;
            final failed = items
                .where((it) => it.status == ScanItemStatus.failed)
                .length;
            final pending = items.length - completed - failed;

            final co2SavedKg = completed * 2.0;

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                BentoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Totals',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              label: 'Items',
                              value: '${items.length}',
                            ),
                          ),
                          Expanded(
                            child: _Metric(
                              label: 'Invested',
                              value: _sek(invested),
                            ),
                          ),
                          Expanded(
                            child: _Metric(
                              label: 'Value',
                              value: _sek(expected),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              label: 'Net',
                              value: _sek(netProfit),
                              emphasize: true,
                            ),
                          ),
                          Expanded(
                            child: _Metric(
                              label: 'CO2 saved',
                              value: '${co2SavedKg.toStringAsFixed(1)} kg',
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
                        'Status',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: _Metric(
                              label: 'Complete',
                              value: '$completed',
                            ),
                          ),
                          Expanded(
                            child: _Metric(label: 'Pending', value: '$pending'),
                          ),
                          Expanded(
                            child: _Metric(label: 'Failed', value: '$failed'),
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

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final valueBase =
        (emphasize
                ? Theme.of(context).textTheme.titleLarge
                : Theme.of(context).textTheme.bodyLarge)
            ?.copyWith(
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            );
    final valueStyle = valueBase == null
        ? null
        : AppTypography.metricsFrom(valueBase);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: AppSpacing.xxs),
        Text(value, style: valueStyle),
      ],
    );
  }
}

String _sek(double value) {
  return '${value.round()} SEK';
}
