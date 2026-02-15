import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../shared/widgets/bento_card.dart';
import '../../shared/widgets/glass_button.dart';
import '../summary/haul_summary_screen.dart';
import '../analyzer/profit_calculator.dart';
import '../../gen/app_localizations.dart';

class HaulScreen extends ConsumerWidget {
  const HaulScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final haulId = ref.watch(defaultHaulIdProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.haulTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.haulSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                StreamBuilder<List<ScanItem>>(
                  stream: db.scanItemsDao.watchByHaulId(haulId, userId: userId),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? const [];

                    final counts = _counts(items);
                    final totals = _totals(items);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetricRow(
                          leftLabel: l10n.haulItems,
                          leftValue: '${items.length}',
                          rightLabel: l10n.haulReady,
                          rightValue: '${counts.ready}',
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _MetricRow(
                          leftLabel: l10n.haulExpected,
                          leftValue: _formatSek(totals.expected),
                          rightLabel: l10n.haulNetEst,
                          rightValue: _formatSek(totals.gross),
                          emphasizeRight: true,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        GlassButton(
                          label: l10n.haulOpenSummary,
                          icon: const Icon(Icons.assessment_rounded),
                          onPressed: () {
                            Navigator.of(context).push(
                              SpringRoute(
                                builder: (_) =>
                                    HaulSummaryScreen(haulId: haulId),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

({int ready}) _counts(List<ScanItem> items) {
  var ready = 0;
  for (final it in items) {
    if (it.status == ScanItemStatus.complete) ready += 1;
  }
  return (ready: ready);
}

({double expected, double gross}) _totals(List<ScanItem> items) {
  var expected = 0.0;
  var gross = 0.0;
  for (final it in items) {
    final m = it.medianPrice;
    if (m != null) {
      expected += (m * it.conditionMultiplier);
    }

    final p = it.purchasePrice;
    if (p != null && m != null) {
      gross +=
          (ProfitCalculator.netProfit(
            purchasePrice: p,
            expectedSalePrice: (m * it.conditionMultiplier),
            fixedFeesSek: it.fixedFeesSek ?? 0,
            shippingPaidBySellerSek: it.shippingPaidBySellerSek ?? 0,
          ) ??
          0);
    }
  }
  return (expected: expected, gross: gross);
}

String _formatSek(double v) {
  return '${v.round()} SEK';
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
    this.emphasizeRight = false,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;
  final bool emphasizeRight;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatLine(label: leftLabel, value: leftValue),
        ),
        Expanded(
          child: _StatLine(
            label: rightLabel,
            value: rightValue,
            emphasize: emphasizeRight,
          ),
        ),
      ],
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
