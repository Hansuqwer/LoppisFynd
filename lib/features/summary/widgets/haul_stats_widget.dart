import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';
import '../../../shared/widgets/bento_card.dart';
import 'inventory_row.dart';
import 'metric.dart';

class HaulStatsWidget extends StatelessWidget {
  const HaulStatsWidget({
    super.key,
    required this.itemCount,
    required this.invested,
    required this.expected,
    required this.netProfit,
    required this.completedCount,
    required this.pendingCount,
    required this.failedCount,
  });

  final int itemCount;
  final double invested;
  final double expected;
  final double netProfit;
  final int completedCount;
  final int pendingCount;
  final int failedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.haulSummaryTotalsTitle,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Metric(
                  label: l10n.haulSummaryItems,
                  value: '$itemCount',
                ),
              ),
              Expanded(
                child: Metric(
                  label: l10n.haulSummaryInvested,
                  value: formatSek(invested),
                ),
              ),
              Expanded(
                child: Metric(
                  label: l10n.haulSummaryValue,
                  value: formatSek(expected),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: AppMotion.fast,
                  switchInCurve: AppMotion.curve,
                  switchOutCurve: AppMotion.curve,
                  child: Metric(
                    key: ValueKey(netProfit.round()),
                    label: l10n.haulSummaryNet,
                    value: formatSek(netProfit),
                    emphasize: true,
                  ),
                ),
              ),
              Expanded(
                child: Metric(
                  label: l10n.haulSummaryStatusComplete,
                  value: '$completedCount',
                ),
              ),
              Expanded(
                child: Metric(
                  label: l10n.haulSummaryStatusPending,
                  value: '$pendingCount',
                ),
              ),
              Expanded(
                child: Metric(
                  label: l10n.haulSummaryStatusFailed,
                  value: '$failedCount',
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 220.ms)
        .slideY(begin: 0.04, end: 0);
  }
}
