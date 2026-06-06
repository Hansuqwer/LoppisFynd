import 'package:flutter/material.dart';

import '../../core/tokens/app_tokens.dart';

/// Verdict enum matching the redesign's KÖP / KANSKE / SKIPPA system.
enum Verdict { buy, maybe, skip }

extension VerdictExtension on Verdict {
  String get label => switch (this) {
        Verdict.buy => 'KÖP',
        Verdict.maybe => 'KANSKE',
        Verdict.skip => 'SKIPPA',
      };

  String get subtitle => switch (this) {
        Verdict.buy => 'Säkert fynd',
        Verdict.maybe => 'Tveksamt',
        Verdict.skip => 'Lägg tillbaka',
      };

  Color get textColor => switch (this) {
        Verdict.buy => AppColors.verdictBuyText,
        Verdict.maybe => AppColors.verdictMaybeText,
        Verdict.skip => AppColors.verdictSkipText,
      };

  Color get bgColor => switch (this) {
        Verdict.buy => AppColors.verdictBuyBg,
        Verdict.maybe => AppColors.verdictMaybeBg,
        Verdict.skip => AppColors.verdictSkipBg,
      };

  Color get ringColor => switch (this) {
        Verdict.buy => AppColors.sageDeep,
        Verdict.maybe => AppColors.mustard,
        Verdict.skip => AppColors.terracottaClay,
      };

  /// Derive verdict from a 0–100 fyndfaktor score.
  static Verdict fromScore(int score) {
    if (score >= 70) return Verdict.buy;
    if (score >= 45) return Verdict.maybe;
    return Verdict.skip;
  }
}

/// Small pill chip showing KÖP / KANSKE / SKIPPA.
class VerdictChip extends StatelessWidget {
  const VerdictChip({super.key, required this.verdict});

  final Verdict verdict;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: verdict.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        verdict.label,
        style: TextStyle(
          fontFamily: AppTypography.uiFontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 11,
          letterSpacing: 0.04,
          color: verdict.textColor,
        ),
      ),
    );
  }
}

/// Large verdict hero block used in the Decision screen.
class VerdictHero extends StatelessWidget {
  const VerdictHero({
    super.key,
    required this.verdict,
    required this.possibleProfit,
    required this.scoreWidget,
  });

  final Verdict verdict;
  final double possibleProfit;
  final Widget scoreWidget;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: verdict.bgColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdict.label,
                  style: TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight: FontWeight.w800,
                    fontSize: 38,
                    color: verdict.textColor,
                    letterSpacing: 0.01,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  verdict.subtitle,
                  style: TextStyle(
                    fontFamily: AppTypography.uiFontFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: verdict.textColor.withValues(alpha: 0.80),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'Möjlig vinst',
                      style: TextStyle(
                        fontFamily: AppTypography.uiFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: verdict.textColor.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '+${possibleProfit.round()} kr',
                      style: TextStyle(
                        fontFamily: AppTypography.metricsFontFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                        color: verdict.textColor,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          scoreWidget,
        ],
      ),
    );
  }
}
