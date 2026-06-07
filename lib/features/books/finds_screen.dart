import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app/providers.dart';
import '../../core/database/app_database.dart';
import '../../core/navigation/spring_route.dart';
import '../../core/tokens/app_tokens.dart';
import '../../gen/app_localizations.dart';
import '../../shared/widgets/book_cover.dart';
import '../../shared/widgets/score_ring.dart';
import '../../shared/widgets/verdict_chip.dart';
import '../analyzer/item_detail_screen.dart';

/// Redesign FindsScreen — ranked scan items by fyndfaktor (score).
///
/// Shows all scanned items ordered by potential profitability,
/// each with a ScoreRing and verdict chip.
class FindsScreen extends ConsumerWidget {
  const FindsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);
    final userId = ref.watch(activeUserIdProvider);
    final haulId = ref.watch(defaultHaulIdProvider);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: StreamBuilder<List<ScanItem>>(
        stream: db.scanItemsDao.watchByHaulId(haulId, userId: userId),
        builder: (context, snapshot) {
          final raw = snapshot.data ?? const <ScanItem>[];

          // Rank by fyndfaktor score descending.
          final ranked = [...raw]
            ..sort((a, b) {
              return _score(b).compareTo(_score(a));
            });

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
                // Screen header.
                Text(
                  'värt att leta efter',
                  style: TextStyle(
                    fontFamily: AppTypography.accentFontFamily,
                    fontSize: 15,
                    color: AppColors.terracottaClay,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.findsTitle,
                  style: const TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 30,
                    letterSpacing: -0.03,
                    color: AppColors.inkDeep,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.findsSubtitle,
                  style: TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppColors.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                if (ranked.isEmpty)
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
                  ...ranked.asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final item = entry.value;
                    final score = _score(item);
                    final verdict = VerdictExtension.fromScore(score);
                    final title = (item.desc ?? item.query ?? '—').trim();
                    final median = item.medianPrice;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 11),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          SpringRoute(
                            builder: (_) =>
                                ItemDetailScreen(scanItemId: item.id),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            border: Border.all(color: AppColors.borderSubtle),
                            boxShadow: AppShadows.bento,
                          ),
                          child: Row(
                            children: [
                              // Rank number.
                              SizedBox(
                                width: 18,
                                child: Text(
                                  '$rank',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: AppTypography.metricsFontFamily,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                    color: AppColors.textFaint,
                                    fontFeatures: const [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              BookCover(
                                title: title,
                                author: '',
                                width: 48,
                                style: BookCoverStyle.sapphire,
                              ),
                              const SizedBox(width: 13),
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
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppColors.inkDeep,
                                      ),
                                    ),
                                    if (median != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        'Snitt ${median.round()} kr',
                                        style: TextStyle(
                                          fontFamily:
                                              AppTypography.metricsFontFamily,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 12.5,
                                          color: AppColors.textMuted,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 6),
                                    VerdictChip(verdict: verdict),
                                  ],
                                ),
                              ),
                              ScoreRing(
                                score: score,
                                size: 46,
                                stroke: 5,
                                color: verdict.ringColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

int _score(ScanItem item) {
  final purchase = item.purchasePrice;
  final median = item.medianPrice;
  if (purchase == null || median == null || purchase <= 0) return 0;
  final ratio = median / purchase;
  if (ratio < 1.0) return ((ratio * 40).clamp(0, 39)).round();
  if (ratio < 1.3) return (40 + ((ratio - 1.0) / 0.3) * 29).round();
  if (ratio < 2.0) return (69 + ((ratio - 1.3) / 0.7) * 21).round();
  return (90 + (ratio - 2.0) * 5).clamp(0, 100).round();
}
