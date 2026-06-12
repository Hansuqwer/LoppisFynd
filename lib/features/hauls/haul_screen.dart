import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/database/tables/scan_items.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/text/sek_formatter.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/verdict_chip.dart';
import '../analyzer/item_detail_screen.dart';
import '../summary/haul_summary_screen.dart';

class HaulScreen extends ConsumerWidget {
  const HaulScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final haulId = ref.watch(defaultHaulIdProvider);
    final userId = ref.watch(activeUserIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: StreamBuilder<List<ScanItem>>(
        stream: db.scanItemsDao.watchByHaulId(haulId, userId: userId),
        builder: (context, snapshot) {
          final items = snapshot.data ?? const <ScanItem>[];
          final projected = _totalValue(items);
          final spent = items.fold<double>(
            0,
            (s, i) => s + (i.purchasePrice ?? 0),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.xxxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HaulScreenHeader(l10n: l10n),
                const SizedBox(height: AppSpacing.md),
                _MonthSummaryCard(
                  projected: projected,
                  spent: spent,
                  itemCount: items.length,
                  onTap: () => Navigator.of(context).push(
                    SpringRoute(
                      builder: (_) => HaulSummaryScreen(haulId: haulId),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl,
                    ),
                    child: Center(
                      child: Text(
                        l10n.scannerNoScansYet,
                        style: TextStyle(
                          fontFamily: AppTypography.uiFontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  _ActiveHaulCard(
                    items: items,
                    l10n: l10n,
                    onItemTap: (id) => Navigator.of(context).push(
                      SpringRoute(
                        builder: (_) => ItemDetailScreen(scanItemId: id),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────

double _totalValue(List<ScanItem> items) {
  var total = 0.0;
  for (final it in items) {
    final m = it.medianPrice;
    if (m == null) continue;
    total += m * it.conditionMultiplier;
  }
  return total;
}

String _formatSek(double value) {
  return formatSekAmount(value);
}

String _statusLabel(AppLocalizations l10n, ScanItemStatus status) {
  return switch (status) {
    ScanItemStatus.pendingIdentify ||
    ScanItemStatus.pendingSync ||
    ScanItemStatus.syncing => l10n.haulStatusIdentifying,
    ScanItemStatus.complete => l10n.haulStatusSaved,
    ScanItemStatus.failed => l10n.itemDetailStatusValue(status.name),
  };
}

// ── Sub-widgets ───────────────────────────────────────────────

class _HaulScreenHeader extends StatelessWidget {
  const _HaulScreenHeader({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.haulEyebrow,
          style: TextStyle(
            fontFamily: AppTypography.accentFontFamily,
            fontSize: 15,
            color: AppColors.terracottaClay,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.haulTitle,
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
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({
    required this.projected,
    required this.spent,
    required this.itemCount,
    required this.onTap,
  });

  final double projected;
  final double spent;
  final int itemCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final margin = spent > 0 ? (projected / spent).toStringAsFixed(1) : '—';
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                        l10n.haulActiveRun,
                        style: TextStyle(
                          fontFamily: AppTypography.uiFontFamily,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.cloudDancer.withValues(alpha: 0.60),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '+${_formatSek(projected)}',
                            style: const TextStyle(
                              fontFamily: AppTypography.metricsFontFamily,
                              fontWeight: FontWeight.w600,
                              fontSize: 34,
                              color: AppColors.cloudDancer,
                              letterSpacing: -0.02,
                              height: 1.0,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.haulProjectedCurrencySuffix,
                            style: TextStyle(
                              fontFamily: AppTypography.metricsFontFamily,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8AA399).withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    l10n.haulBookCount(itemCount),
                    style: const TextStyle(
                      fontFamily: AppTypography.uiFontFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFCFE0D2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _SummaryMetric(
                  value: '${_formatSek(spent)} kr',
                  label: l10n.haulSpentMetric,
                  color: const Color(0xFFE8CFC6),
                ),
                _SummaryMetric(
                  value: spent > 0
                      ? '${_formatSek(spent / (itemCount > 0 ? itemCount : 1))} kr'
                      : '—',
                  label: l10n.haulAveragePerBookMetric,
                  color: AppColors.cloudDancer.withValues(alpha: 0.85),
                ),
                _SummaryMetric(
                  value: '${margin}x',
                  label: l10n.haulMarginMetric,
                  color: const Color(0xFFCFE0D2),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
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
      child: Padding(
        padding: const EdgeInsets.only(left: 14),
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
                fontSize: 11.5,
                color: AppColors.cloudDancer.withValues(alpha: 0.50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveHaulCard extends StatefulWidget {
  const _ActiveHaulCard({
    required this.items,
    required this.l10n,
    required this.onItemTap,
  });

  final List<ScanItem> items;
  final AppLocalizations l10n;
  final ValueChanged<String> onItemTap;

  @override
  State<_ActiveHaulCard> createState() => _ActiveHaulCardState();
}

class _ActiveHaulCardState extends State<_ActiveHaulCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppShadows.bento,
      ),
      child: Column(
        children: [
          // Accordion header.
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.haulActiveRun,
                              style: const TextStyle(
                                fontFamily: AppTypography.uiFontFamily,
                                fontWeight: FontWeight.w700,
                                fontSize: 15.5,
                                color: AppColors.inkDeep,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: AppColors.dopamineRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.dopamineRed.withValues(
                                      alpha: 0.18,
                                    ),
                                    blurRadius: 0,
                                    spreadRadius: 3,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.haulBookCount(widget.items.length),
                          style: TextStyle(
                            fontFamily: AppTypography.uiFontFamily,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _CoverStack(books: widget.items.take(4).toList()),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textFaint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded book rows.
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                color: AppColors.clay,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppRadius.lg),
                  bottomRight: Radius.circular(AppRadius.lg),
                ),
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Column(
                children: widget.items
                    .asMap()
                    .entries
                    .map(
                      (entry) => _HaulBookRow(
                        item: entry.value,
                        l10n: widget.l10n,
                        isLast: entry.key == widget.items.length - 1,
                        onTap: () => widget.onItemTap(entry.value.id),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _CoverStack extends StatelessWidget {
  const _CoverStack({required this.books});
  final List<ScanItem> books;

  @override
  Widget build(BuildContext context) {
    const size = 34.0;
    return Row(
      children: books.asMap().entries.map((e) {
        final title = (e.value.desc ?? e.value.query ?? '—').trim();
        return Transform.translate(
          offset: Offset(e.key * -(size * 0.42), 0),
          child: BookCover(
            title: title,
            author: '',
            width: size,
            style: BookCoverStyle.sapphire,
          ),
        );
      }).toList(),
    );
  }
}

class _HaulBookRow extends StatelessWidget {
  const _HaulBookRow({
    required this.item,
    required this.l10n,
    required this.isLast,
    required this.onTap,
  });

  final ScanItem item;
  final AppLocalizations l10n;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = (item.desc ?? item.query ?? l10n.haulUnnamedFind).trim();
    final purchase = item.purchasePrice;
    final median = item.medianPrice;

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
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(bottom: BorderSide(color: AppColors.borderSubtle)),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 11,
        ),
        child: Row(
          children: [
            BookCover(
              title: title,
              author: '',
              width: 30,
              style: BookCoverStyle.cream,
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
                      fontSize: 13.5,
                      color: AppColors.inkDeep,
                    ),
                  ),
                  if (purchase != null && median != null)
                    Text(
                      l10n.haulBoughtAveragePrice(
                        purchase.round(),
                        median.round(),
                      ),
                      style: TextStyle(
                        fontFamily: AppTypography.metricsFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    )
                  else
                    Text(
                      _statusLabel(l10n, item.status),
                      style: TextStyle(
                        fontFamily: AppTypography.uiFontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 11.5,
                        color: AppColors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            VerdictChip(verdict: verdict),
          ],
        ),
      ),
    );
  }
}
