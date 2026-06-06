import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/bars_chart.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/stat_pill.dart';
import '../../shared/widgets/verdict_chip.dart';
import '../analyzer/item_detail_screen.dart';
import '../analyzer/profit_calculator.dart';
import '../summary/haul_summary_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final defaultHaulId = ref.watch(defaultHaulIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.xxxl,
        ),
        child: StreamBuilder<List<ScanItem>>(
          stream: db.scanItemsDao.watchByHaulId(
            defaultHaulId,
            userId: userId,
          ),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <ScanItem>[];
            final bought = items
                .where((i) => i.purchasePrice != null)
                .length;
            final sold = 0; // Placeholder — add sold status when available.
            final weekProfit = _estimateNetProfit(items) ?? 0.0;

            // Weekly day distribution (mock until real per-day data lands).
            final weekDaily = _weekDailyMock(weekProfit);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Screen header ──────────────────────────────
                _ScreenHeader(l10n: l10n),
                const SizedBox(height: AppSpacing.md),

                // ── Hero profit card ───────────────────────────
                _HeroCard(
                  weekProfit: weekProfit,
                  weekDaily: weekDaily,
                  onTap: () => Navigator.of(context).push(
                    SpringRoute(
                      builder: (_) => HaulSummaryScreen(haulId: defaultHaulId),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Quick stat pills ───────────────────────────
                _StatRow(
                  scanned: items.length,
                  bought: bought,
                  sold: sold,
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Recent scans ───────────────────────────────
                if (items.isNotEmpty) ...[
                  Text(
                    l10n.homeRecentScans,
                    style: TextStyle(
                      fontFamily: AppTypography.uiFontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ...items.take(6).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _ScanRow(
                      item: item,
                      onTap: () => Navigator.of(context).push(
                        SpringRoute(
                          builder: (_) =>
                              ItemDetailScreen(scanItemId: item.id),
                        ),
                      ),
                    ),
                  )),
                ] else ...[
                  // Empty state.
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.qr_code_scanner_rounded,
                          size: 56,
                          color: AppColors.inkDeep.withValues(alpha: 0.18),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.scannerNoScansYet,
                          style: TextStyle(
                            fontFamily: AppTypography.uiFontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 15,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────

double? _estimateNetProfit(List<ScanItem> items) {
  var any = false;
  var total = 0.0;
  for (final it in items) {
    final purchase = it.purchasePrice;
    final median = it.medianPrice;
    if (purchase == null || median == null) continue;
    final net = ProfitCalculator.netProfit(
      purchasePrice: purchase,
      expectedSalePrice: median * it.conditionMultiplier,
      fixedFeesSek: it.fixedFeesSek ?? 0,
      shippingPaidBySellerSek: it.shippingPaidBySellerSek ?? 0,
    );
    if (net == null) continue;
    any = true;
    total += net;
  }
  return any ? total : null;
}

List<double> _weekDailyMock(double total) {
  // Split total into 7 day-ish values for the bar chart.
  if (total <= 0) return List.filled(7, 0);
  final slice = total / 7;
  return [
    slice * 0.6,
    0,
    slice * 1.4,
    slice * 0.8,
    slice * 2.1,
    slice * 1.2,
    slice,
  ];
}

String _formatSek(double value) {
  final f = intl.NumberFormat.decimalPattern(
    intl.Intl.getCurrentLocale(),
  );
  return f.format(value.round());
}

// ── Sub-widgets ──────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  const _ScreenHeader({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'loppisfynd',
                style: TextStyle(
                  fontFamily: AppTypography.accentFontFamily,
                  fontSize: 15,
                  color: AppColors.terracottaClay,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.dashboardTitle,
                style: const TextStyle(
                  fontFamily: AppTypography.uiFontFamily,
                  fontWeight: FontWeight.w700,
                  fontSize: 30,
                  letterSpacing: -0.03,
                  color: AppColors.inkDeep,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
        // Avatar initial.
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.clay,
            border: Border.all(color: AppColors.borderSubtle),
          ),
          alignment: Alignment.center,
          child: Text(
            'E',
            style: TextStyle(
              fontFamily: AppTypography.uiFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: AppColors.inkDeep,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.weekProfit,
    required this.weekDaily,
    required this.onTap,
  });
  final double weekProfit;
  final List<double> weekDaily;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.inkDeep,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: const [
            BoxShadow(
              color: Color(0x471E2B3C),
              blurRadius: 40,
              offset: Offset(0, 18),
              spreadRadius: -6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Veckans vinst',
                        style: TextStyle(
                          fontFamily: AppTypography.uiFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.cloudDancer.withValues(alpha: 0.60),
                          letterSpacing: 0.02,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            _formatSek(weekProfit),
                            style: const TextStyle(
                              fontFamily: AppTypography.metricsFontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 40,
                              color: AppColors.cloudDancer,
                              letterSpacing: -0.02,
                              height: 1.0,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'kr',
                            style: TextStyle(
                              fontFamily: AppTypography.metricsFontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: AppColors.cloudDancer.withValues(alpha: 0.60),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            BarsChart(
              data: weekDaily,
              color: AppColors.cloudDancer,
              accentColor: AppColors.dopamineRed,
              accentLast: true,
              height: 44,
            ),
            const SizedBox(height: 6),
            Row(
              children: ['M', 'T', 'O', 'T', 'F', 'L', 'S']
                  .asMap()
                  .entries
                  .map(
                    (e) => Expanded(
                      child: Text(
                        e.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.uiFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 10.5,
                          color: e.key == 6
                              ? AppColors.terracottaClay
                              : AppColors.cloudDancer.withValues(alpha: 0.40),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.scanned,
    required this.bought,
    required this.sold,
  });
  final int scanned, bought, sold;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xs,
        horizontal: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.bento,
      ),
      child: Row(
        children: [
          StatPill(
            value: '$scanned',
            label: 'Skannade',
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.borderSubtle,
          ),
          StatPill(
            value: '$bought',
            label: 'Köpta',
            valueColor: AppColors.copperOak,
          ),
          Container(
            width: 1,
            height: 30,
            color: AppColors.borderSubtle,
          ),
          StatPill(
            value: '$sold',
            label: 'Sålda',
            valueColor: AppColors.sageDeep,
          ),
        ],
      ),
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.item, required this.onTap});
  final ScanItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (item.desc ?? item.query ?? '—').trim();
    final median = item.medianPrice;
    final purchase = item.purchasePrice;

    // Derive verdict for the chip.
    int score = 0;
    if (purchase != null && median != null && purchase > 0) {
      final ratio = median / purchase;
      if (ratio >= 1.8) {
        score = 80;
      } else if (ratio >= 1.3) {
        score = 60;
      } else if (ratio >= 1.0) {
        score = 45;
      }
    }
    final verdict = VerdictExtension.fromScore(score);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.bento,
        ),
        child: Row(
          children: [
            BookCover(
              title: title,
              author: '',
              width: 40,
              style: BookCoverStyle.sapphire,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppTypography.uiFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  if (median != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Snitt ${median.round()} kr',
                      style: TextStyle(
                        fontFamily: AppTypography.metricsFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.5,
                        color: AppColors.textMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (purchase != null) VerdictChip(verdict: verdict),
          ],
        ),
      ),
    );
  }
}
