import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../services/books/flip_score.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/glass_button.dart';
import '../../shared/widgets/score_ring.dart';
import '../../shared/widgets/sparkline_chart.dart';
import '../../shared/widgets/verdict_chip.dart';
import '../offline_detection/offline_detection_screen.dart';
import 'profit_calculator.dart';
import 'widgets/condition_adjuster.dart';
import 'widgets/market_stats_widget.dart';

/// Redesign Decision / Fynd-analys screen.
///
/// Wraps the existing [MarketStatsWidget] (market data + sync) in the new
/// visual shell: verdict hero, cost stepper, quick metrics, sparkline,
/// range bar, and a prominent CTA button.
class ItemDetailScreen extends ConsumerStatefulWidget {
  const ItemDetailScreen({super.key, required this.scanItemId});

  final String scanItemId;

  @override
  ConsumerState<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends ConsumerState<ItemDetailScreen> {
  // Purchase-price stepper (redesign cost stepper).
  double _cost = 0;
  bool _costInitialised = false;

  // Saved / bookmark state.
  bool _saved = false;

  // Success overlay after CTA tap.
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.cloudDancer,
      body: SafeArea(
        child: StreamBuilder<ScanItem?>(
          stream: db.scanItemsDao.watchById(widget.scanItemId, userId: userId),
          builder: (context, snapshot) {
            final item = snapshot.data;
            if (item == null) {
              return const Center(child: CircularProgressIndicator());
            }

            // Initialise cost from DB once.
            if (!_costInitialised) {
              _cost = item.purchasePrice ?? 0;
              _costInitialised = true;
            }

            final median = item.medianPrice;
            final adjusted = median == null
                ? null
                : median * item.conditionMultiplier;

            final net = ProfitCalculator.netProfit(
                  purchasePrice: _cost,
                  expectedSalePrice: adjusted,
                ) ??
                0.0;
            final roi = _cost > 0 ? ((net / _cost) * 100).round() : 0;

            // Score: derive from flip factor if no explicit score field.
            final score = _scoreFromItem(item);
            final verdict = VerdictExtension.fromScore(score);

            // Sold prices for sparkline.
            final soldPrices = _soldPrices(item);

            // Price range.
            final low = item.minPrice ?? 0.0;
            final high = item.maxPrice ?? 0.0;
            final avgPos = (high - low) > 0
                ? ((adjusted ?? low) - low) / (high - low)
                : 0.5;

            return Stack(
              children: [
                Column(
                  children: [
                    // ── Top bar ──────────────────────────────────
                    _TopBar(
                      saved: _saved,
                      onBack: () => Navigator.of(context).pop(),
                      onSave: () => setState(() => _saved = !_saved),
                    ),

                    // ── Scrollable content ───────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          130,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Book hero.
                            _BookHero(item: item),
                            const SizedBox(height: AppSpacing.md),

                            // Verdict hero.
                            VerdictHero(
                              verdict: verdict,
                              possibleProfit: net,
                              scoreWidget: ScoreRing(
                                score: score,
                                size: 96,
                                color: verdict.ringColor,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Cost stepper.
                            _CostStepperCard(
                              cost: _cost,
                              net: net,
                              roi: roi,
                              item: item,
                              onCostChanged: (v) async {
                                setState(() => _cost = v);
                                await db.scanItemsDao.setPurchasePrice(
                                  id: item.id,
                                  purchasePrice: v,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Market price card.
                            if (median != null)
                              _MarketPriceCard(
                                avg: adjusted ?? median,
                                low: low,
                                high: high,
                                avgPos: avgPos.clamp(0.0, 1.0),
                                soldPrices: soldPrices,
                                item: item,
                              ),
                            if (median != null)
                              const SizedBox(height: AppSpacing.md),

                            // Full market widget (sync, keywords, etc.).
                            MarketStatsWidget(item: item, db: db),
                            const SizedBox(height: AppSpacing.md),

                            // Condition adjuster.
                            _ConditionCard(
                              item: item,
                              onChanged: (v) async {
                                await db.scanItemsDao.setConditionMultiplier(
                                  id: item.id,
                                  conditionMultiplier: v,
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GlassButton(
                              label: l10n.offlineIdentifyRunCta,
                              icon: const Icon(Icons.document_scanner_outlined),
                              onPressed: () {
                                Navigator.of(context).push(
                                  SpringRoute(
                                    builder: (_) => OfflineDetectionScreen(
                                      scanItemId: item.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ── CTA bar ──────────────────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _CtaBar(
                    verdict: verdict,
                    cost: _cost,
                    onBuy: () async {
                      final nav = Navigator.of(context);
                      await HapticFeedback.lightImpact();
                      if (!mounted) return;
                      setState(() => _done = true);
                      await Future<void>.delayed(
                        const Duration(milliseconds: 1500),
                      );
                      if (mounted) nav.pop();
                    },
                  ),
                ),

                // ── Success overlay ──────────────────────────────
                if (_done) _SuccessOverlay(title: item.desc ?? item.query),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────

int _scoreFromItem(ScanItem item) {
  return FlipScore.fromPrices(
    purchasePrice: item.purchasePrice,
    medianPrice: item.medianPrice,
  );
}

List<double> _soldPrices(ScanItem item) {
  final median = item.medianPrice;
  final min = item.minPrice;
  final max = item.maxPrice;
  if (median == null) return const [];
  // Synthesise a sparkline from min/median/max if no raw history.
  return [
    min ?? median * 0.7,
    median * 0.85,
    median,
    median * 1.1,
    max ?? median * 1.3,
  ];
}

// ── Sub-widgets ──────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.saved,
    required this.onBack,
    required this.onSave,
  });
  final bool saved;
  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.xs,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Row(
        children: [
          _IconBtn(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
            semanticLabel: MaterialLocalizations.of(context).backButtonTooltip,
          ),
          Expanded(
            child: Text(
              l10n.itemDetailTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.uiFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: AppColors.inkDeep,
              ),
            ),
          ),
          _IconBtn(
            icon: saved ? Icons.star_rounded : Icons.star_border_rounded,
            onTap: onSave,
            color: saved ? AppColors.mustard : AppColors.inkDeep,
            semanticLabel: l10n.commonSave,
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderSubtle),
            color: AppColors.card,
          ),
          child: Icon(icon, size: 22, color: color ?? AppColors.inkDeep),
        ),
      ),
    );
  }
}

class _BookHero extends StatelessWidget {
  const _BookHero({required this.item});
  final ScanItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.desc ?? item.query ?? '—';
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cover — typographic or photo.
        item.thumbPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: Image.file(
                  File(item.thumbPath!),
                  width: 96,
                  height: 144,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, st) =>
                      BookCover(title: title, author: '', width: 96),
                ),
              )
            : BookCover(title: title, author: '', width: 96),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: AppColors.inkDeep,
                    height: 1.1,
                    letterSpacing: -0.02,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.query ?? '',
                  style: TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CostStepperCard extends StatelessWidget {
  const _CostStepperCard({
    required this.cost,
    required this.net,
    required this.roi,
    required this.item,
    required this.onCostChanged,
  });
  final double cost;
  final double net;
  final int roi;
  final ScanItem item;
  final ValueChanged<double> onCostChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.bento,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.itemDetailFleaMarketPriceTitle,
                      style: TextStyle(
                        fontFamily: AppTypography.uiFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.inkDeep,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      l10n.itemDetailAdjustForProfit,
                      style: TextStyle(
                        fontFamily: AppTypography.uiFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Stepper buttons.
              _StepBtn(
                label: '–',
                onTap: () => onCostChanged(math.max(0, cost - 5)),
              ),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 72,
                child: Text(
                  '${cost.round()} kr',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTypography.metricsFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 24,
                    color: AppColors.inkDeep,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              _StepBtn(label: '+', onTap: () => onCostChanged(cost + 5)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _MiniMetric(
                value: '${net >= 0 ? '+' : ''}${net.round()} kr',
                label: l10n.itemDetailNetProfitMetric,
                color: net > 0 ? AppColors.sageDeep : AppColors.copperOak,
              ),
              const SizedBox(width: AppSpacing.xs),
              _MiniMetric(
                value: '$roi%',
                label: l10n.itemDetailRoiMetric,
                color: AppColors.inkDeep,
              ),
              const SizedBox(width: AppSpacing.xs),
              _MiniMetric(
                value: item.medianPrice != null ? '~7 dgr' : '—',
                label: l10n.itemDetailSellTimeMetric,
                color: AppColors.atmosphericFog,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
          color: AppColors.clay,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: AppTypography.metricsFontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: AppColors.inkDeep,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.value,
    required this.label,
    required this.color,
  });
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: AppColors.clay,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontFamily: AppTypography.metricsFontFamily,
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTypography.uiFontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketPriceCard extends StatelessWidget {
  const _MarketPriceCard({
    required this.avg,
    required this.low,
    required this.high,
    required this.avgPos,
    required this.soldPrices,
    required this.item,
  });
  final double avg, low, high, avgPos;
  final List<double> soldPrices;
  final ScanItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.bento,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.itemDetailMarketPriceTitle,
                      style: TextStyle(
                        fontFamily: AppTypography.uiFontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppColors.inkDeep,
                      ),
                    ),
                    Text(
                      l10n.itemDetailRecentlySoldSubtitle,
                      style: TextStyle(
                        fontFamily: AppTypography.uiFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${avg.round()} kr',
                    style: TextStyle(
                      fontFamily: AppTypography.metricsFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                      color: AppColors.inkDeep,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    l10n.itemDetailAveragePriceLabel,
                    style: TextStyle(
                      fontFamily: AppTypography.uiFontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (soldPrices.length >= 2)
            SparklineChart(
              prices: soldPrices,
              color: AppColors.sageDeep,
              height: 50,
            ),
          const SizedBox(height: AppSpacing.md),
          // Range bar.
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth;
              return Column(
                children: [
                  SizedBox(
                    height: 6,
                    child: Stack(
                      children: [
                        // Track.
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.clay,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        // Gradient fill.
                        Positioned(
                          left: w * 0.08,
                          right: w * 0.08,
                          top: 0,
                          bottom: 0,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x66CB8573), Color(0x995E7D6F)],
                              ),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        // Avg dot.
                        Positioned(
                          left: w * avgPos - 6,
                          top: -3,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.inkDeep,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.card,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.itemDetailLowestPrice(low.round()),
                        style: TextStyle(
                          fontFamily: AppTypography.metricsFontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Text(
                        l10n.itemDetailHighestPrice(high.round()),
                        style: TextStyle(
                          fontFamily: AppTypography.metricsFontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: AppColors.textMuted,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ConditionCard extends StatelessWidget {
  const _ConditionCard({required this.item, required this.onChanged});
  final ScanItem item;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.bento,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.itemDetailConditionTitle,
            style: TextStyle(
              fontFamily: AppTypography.uiFontFamily,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.inkDeep,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ConditionAdjuster(
            value: item.conditionMultiplier,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _CtaBar extends StatelessWidget {
  const _CtaBar({
    required this.verdict,
    required this.cost,
    required this.onBuy,
  });
  final Verdict verdict;
  final double cost;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSkip = verdict == Verdict.skip;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cloudDancer.withValues(alpha: 0),
            AppColors.cloudDancer.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: FilledButton(
        onPressed: onBuy,
        style: FilledButton.styleFrom(
          backgroundColor: isSkip ? AppColors.inkDeep : AppColors.dopamineRed,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: isSkip ? 0 : 6,
          shadowColor: AppColors.inkDeep.withValues(alpha: 0.26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shopping_bag_outlined, size: 21),
            const SizedBox(width: 9),
            Text(
              isSkip
                  ? l10n.itemDetailAddAnyway
                  : l10n.itemDetailBuyFor(cost.round()),
              style: const TextStyle(
                fontFamily: AppTypography.uiFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 17,
                letterSpacing: 0.01,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessOverlay extends StatelessWidget {
  const _SuccessOverlay({required this.title});
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cloudDancer.withValues(alpha: 0.96),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1.0),
              duration: const Duration(milliseconds: 500),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.eucalyptus,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Tillagd i lager',
              style: TextStyle(
                fontFamily: AppTypography.uiFontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.inkDeep,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title ?? '',
              style: TextStyle(
                fontFamily: AppTypography.uiFontFamily,
                fontWeight: FontWeight.w500,
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
