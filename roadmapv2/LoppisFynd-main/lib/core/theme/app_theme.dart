import 'package:flutter/material.dart';

import '../tokens/app_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryAction,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.success,
      onSecondary: AppColors.textPrimary,
      error: AppColors.dopamineRed,
      onError: AppColors.textOnPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      outline: AppColors.borderSubtle,
      outlineVariant: AppColors.borderSubtle,
      shadow: AppColors.shadowInk,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.deepSapphire,
      onInverseSurface: AppColors.cloudDancer,
      inversePrimary: AppColors.cloudDancer,
      tertiary: AppColors.highlight,
      onTertiary: AppColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          textStyle: AppTypography.textTheme.labelLarge,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Dark theme scaffold for future wiring.
  ///
  /// NOTE: Many widgets in the current repo still use fixed `AppColors.*`
  /// values directly. This theme is provided so the design system has a
  /// compile-ready dark ColorScheme + background tokens, but it is not
  /// enabled by default in `main.dart`.
  static ThemeData dark() {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primaryAction,
      onPrimary: AppColors.dark4,
      secondary: AppColors.success,
      onSecondary: AppColors.dark4,
      error: AppColors.semanticErrorDark,
      onError: AppColors.dark4,
      surface: AppColors.dark3,
      onSurface: AppColors.dark0,
      outline: AppColors.dark1,
      outlineVariant: AppColors.dark1,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: AppColors.neutral0,
      onInverseSurface: AppColors.ink0,
      inversePrimary: AppColors.neutral0,
      tertiary: AppColors.highlight,
      onTertiary: AppColors.dark0,
    );

    // Override typography colors for dark surfaces.
    final textTheme = AppTypography.textTheme.copyWith(
      headlineLarge: AppTypography.textTheme.headlineLarge?.copyWith(
        color: AppColors.dark0,
      ),
      headlineSmall: AppTypography.textTheme.headlineSmall?.copyWith(
        color: AppColors.dark0,
      ),
      titleLarge: AppTypography.textTheme.titleLarge?.copyWith(
        color: AppColors.dark0,
      ),
      bodyLarge: AppTypography.textTheme.bodyLarge?.copyWith(
        color: AppColors.dark0,
      ),
      bodyMedium: AppTypography.textTheme.bodyMedium?.copyWith(
        color: AppColors.dark0,
      ),
      labelLarge: AppTypography.textTheme.labelLarge?.copyWith(
        color: AppColors.dark0,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.dark4,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.dark0,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData highContrast() {
    final outline = AppColors.inkDeep.withValues(alpha: 0.38);
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryAction,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.success,
      onSecondary: AppColors.inkDeep,
      error: AppColors.dopamineRed,
      onError: AppColors.textOnPrimary,
      surface: AppColors.cloudDancer,
      onSurface: AppColors.inkDeep,
      outline: outline,
      outlineVariant: outline,
      shadow: AppColors.shadowInk,
      scrim: AppColors.scrim,
      inverseSurface: AppColors.inkDeep,
      onInverseSurface: AppColors.cloudDancer,
      inversePrimary: AppColors.cloudDancer,
      tertiary: AppColors.highlight,
      onTertiary: AppColors.textOnDark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.cloudDancer,
      textTheme: AppTypography.textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.cloudDancer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: outline, width: 1),
        ),
      ),
      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),
    );
  }
}
