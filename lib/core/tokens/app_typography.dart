import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // Roadmap recommendation.
  // Fonts are vendored in `Assets/fonts/` and runtime fetching is disabled.
  static const uiFontFamily = 'Outfit';
  static const metricsFontFamily = 'Space Grotesk';
  static const accentFontFamily = 'Homemade Apple';

  static final TextStyle accentBrand = accentFrom(
    const TextStyle(
      fontSize: 24,
      height: 1.0,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.2,
      color: AppColors.textPrimary,
    ),
  );

  static TextStyle uiFrom(TextStyle base) {
    return base.copyWith(fontFamily: uiFontFamily);
  }

  static TextStyle metricsFrom(TextStyle base) {
    return base.copyWith(fontFamily: metricsFontFamily);
  }

  static TextStyle accentFrom(TextStyle base) {
    return base.copyWith(fontFamily: accentFontFamily);
  }

  static final textTheme = TextTheme(
    headlineLarge: uiFrom(
      const TextStyle(
        fontSize: 32,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: AppColors.textPrimary,
      ),
    ),
    headlineSmall: uiFrom(
      const TextStyle(
        fontSize: 24,
        height: 1.15,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.textPrimary,
      ),
    ),
    titleLarge: uiFrom(
      const TextStyle(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      ),
    ),
    bodyLarge: uiFrom(
      const TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    ),
    bodyMedium: uiFrom(
      const TextStyle(
        fontSize: 14,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
    ),
    labelLarge: uiFrom(
      const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      ),
    ),
  );
}
