import 'dart:convert';

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
          stream: db.scanItemsDao.watchByHaulId(defaultHaulId, userId: userId),
          builder: (context, snapshot) {
            final items = snapshot.data ?? const <ScanItem>[];
            final bought = items.where((i) => i.purchasePrice != null).length;
            return StreamBuilder<List<ScanItemComp>>(
              stream: db.scanItemCompsDao.watchByHaulId(
                defaultHaulId,
                userId: userId,
              ),
              builder: (context, compsSnapshot) {
                final market = _dashboardMarketSnapshot(
                  compsSnapshot.data ?? const <ScanItemComp>[],
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Screen header ──────────────────────────────
                    _ScreenHeader(l10n: l10n),
                    const SizedBox(height: AppSpacing.md),

                    // ── Hero profit card ───────────────────────────
                    _HeroCard(
                      l10n: l10n,
                      weekProfit: market.weekTotalSek,
                      weekDaily: market.weekDaily,
                      onTap: () => Navigator.of(context).push(
                        SpringRoute(
                          builder: (_) =>
                              HaulSummaryScreen(haulId: defaultHaulId),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // ── Quick stat pills ───────────────────────────
                    _StatRow(
                      l10n: l10n,
                      scanned: items.length,
                      bought: bought,
                      sold: market.soldCount,
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
                      ...items
                          .take(6)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _ScanRow(
                                l10n: l10n,
                                item: item,
                                onTap: () => Navigator.of(context).push(
                                  SpringRoute(
                                    builder: (_) =>
                                        ItemDetailScreen(scanItemId: item.id),
                                  ),
                                ),
                              ),
                            ),
                          ),
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
            );
          },
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────

_DashboardMarketSnapshot _dashboardMarketSnapshot(List<ScanItemComp> comps) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = today.subtract(Duration(days: now.weekday - 1));
  final weekEnd = weekStart.add(const Duration(days: 7));
  final daily = List<double>.filled(7, 0);
  var soldCount = 0;

  for (final comp in comps) {
    try {
      final decoded = jsonDecode(comp.rawJson);
      if (decoded is! Map) continue;
      final sales = decoded['sales'];
      var countedFromSales = false;
      if (sales is! List) {
        for (final sale in sales) {
          if (sale is! Map) continue;
          final priceAny = sale['priceSek'];
          final endAny = sale['endDate'];
          final price = priceAny is num ? priceAny.toDouble() : null;
          final endedAt = endAny is String ? DateTime.tryParse(endAny) : null;
          if (price == null || endedAt == null) continue;
          countedFromSales = true;
          soldCount += 1;
          final local = endedAt.toLocal();
          if (local.isBefore(weekStart) || !local.isBefore(weekEnd)) continue;
          daily[local.weekday - 1] += price;
        }
      }
      if (countedFromSales) continue;

      final stats = decoded['stats'];
      if (stats is! Map) continue;
      final countAny = stats['count'];
      final medianAny = stats['medianSek'];
      final count = countAny is num ? countAny.toInt() : 0;
      final median = medianAny is num ? medianAny.toDouble() : comp.medianPrice;
      if (count <= 0 || median == null) continue;
      soldCount += count;

      final fetched = comp.fetchedAt.toLocal();
      if (fetched.isBefore(weekStart) || !fetched.isBefore(weekEnd)) continue;
      daily[fetched.weekday - 1] += median * count;
    } catch (_) {
      continue;
    }
  }

  return _DashboardMarketSnapshot(
    soldCount: soldCount,
    weekDaily: daily,
    weekTotalSek: daily.fold(0, (sum, value) => sum + value),
  );
}

String _formatSek(double value) {
  final f = intl.NumberFormat.decimalPattern(intl.Intl.getCurrentLocale());
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
    required this.l10n,
    required this.weekProfit,
    required this.weekDaily,
    required this.onTap,
  });
  final AppLocalizations l10n;
  final double weekProfit;
  final List<double> weekDaily;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dayLabels = _weekDayLabels(l10n.localeName);

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
                        l10n.dashboardWeeklySoldPrices,
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
                            l10n.dashboardCurrencySek,
                            style: TextStyle(
                              fontFamily: AppTypography.metricsFontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                              color: AppColors.cloudDancer.withValues(
                                alpha: 0.60,
                              ),
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
              children: dayLabels
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
    required this.l10n,
    required this.scanned,
    required this.bought,
    required this.sold,
  });
  final AppLocalizations l10n;
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
          StatPill(value: '$scanned', label: l10n.dashboardScanned),
          Container(width: 1, height: 30, color: AppColors.borderSubtle),
          StatPill(
            value: '$bought',
            label: l10n.dashboardBought,
            valueColor: AppColors.copperOak,
          ),
          Container(width: 1, height: 30, color: AppColors.borderSubtle),
          StatPill(
            value: '$sold',
            label: l10n.dashboardSold,
            valueColor: AppColors.sageDeep,
          ),
        ],
      ),
    );
  }
}

class _ScanRow extends StatelessWidget {
  const _ScanRow({required this.l10n, required this.item, required this.onTap});
  final AppLocalizations l10n;
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
                      '${l10n.bookAveragePrice} ${median.round()} ${l10n.dashboardCurrencySek}',
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

List<String> _weekDayLabels(String localeName) {
  final monday = DateTime.utc(2024, 1, 1);
  final formatter = intl.DateFormat.E(localeName);
  return List.generate(7, (index) {
    final label = formatter.format(monday.add(Duration(days: index)));
    return label.isEmpty ? '' : label.substring(0, 1).toUpperCase();
  });
}

class _DashboardMarketSnapshot {
  const _DashboardMarketSnapshot({
    required this.soldCount,
    required this.weekDaily,
    required this.weekTotalSek,
  });

  final int soldCount;
  final List<double> weekDaily;
  final double weekTotalSek;
}
