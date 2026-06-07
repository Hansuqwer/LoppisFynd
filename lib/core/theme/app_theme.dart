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
      error: AppColors.primaryAction,
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

  static ThemeData highContrast() {
    final outline = AppColors.inkDeep.withValues(alpha: 0.38);
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryAction,
      onPrimary: AppColors.textOnPrimary,
      secondary: AppColors.success,
      onSecondary: AppColors.inkDeep,
      error: AppColors.primaryAction,
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

  static ThemeData dark() {
    const surface = Color(0xFF1A1F2E);
    const background = Color(0xFF121520);
    const card = Color(0xFF212737);
    const onSurface = Color(0xFFE8E4DE);

    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.dopamineRed,
      onPrimary: Colors.white,
      secondary: AppColors.sageDeep,
      onSecondary: onSurface,
      error: AppColors.dopamineRed,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      outline: const Color(0x33E8E4DE),
      outlineVariant: const Color(0x26E8E4DE),
      shadow: const Color(0x66121520),
      scrim: const Color(0xAA000000),
      inverseSurface: AppColors.cloudDancer,
      onInverseSurface: AppColors.deepSapphire,
      inversePrimary: AppColors.deepSapphire,
      tertiary: AppColors.mustard,
      onTertiary: surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTypography.textTheme.apply(
        bodyColor: onSurface,
        displayColor: onSurface,
      ),
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: onSurface.withValues(alpha: 0.10), width: 1),
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
      dividerTheme: DividerThemeData(
        color: onSurface.withValues(alpha: 0.12),
        thickness: 1,
        space: 1,
      ),
    );
  }
}
