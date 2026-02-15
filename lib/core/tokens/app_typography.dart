import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTypography {
  // Roadmap recommendation.
  // These fonts are currently loaded via `google_fonts` (runtime fetch + cache).
  // If you want strict offline fonts, vendor the TTFs and add `flutter: fonts:`.
  static const uiFontFamily = 'Outfit';
  static const metricsFontFamily = 'Space Grotesk';
  static const accentFontFamily = 'Homemade Apple';

  static TextStyle uiFrom(TextStyle base) {
    return GoogleFonts.outfit(textStyle: base);
  }

  static TextStyle metricsFrom(TextStyle base) {
    return GoogleFonts.spaceGrotesk(textStyle: base);
  }

  static TextStyle accentFrom(TextStyle base) {
    return GoogleFonts.homemadeApple(textStyle: base);
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
