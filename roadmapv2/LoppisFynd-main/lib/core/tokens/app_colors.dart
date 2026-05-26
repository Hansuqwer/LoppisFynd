import 'package:flutter/material.dart';

/// Color tokens.
///
/// This file contains:
/// - Palette ramps (neutral / ink / terracotta / cool)
/// - Semantic tokens (error / warning / link)
/// - Legacy aliases used across the current codebase
///
/// Keep this file **pure** (no BuildContext) so it can be referenced anywhere.
abstract final class AppColors {
  // ---------------------------------------------------------------------------
  // Minimalistic Palette (New Light) — "v1" brand anchors
  // ---------------------------------------------------------------------------

  /// Off-white warm base.
  static const minimalNeutralWarm0 = Color(0xFFF2ECE0);
  static const minimalNeutralWarm1 = Color(0xFFF0EAD8);
  static const minimalEucalyptus = Color(0xFF7A9673);
  static const minimalCoolTeal = Color(0xFF5C8682);
  static const minimalTerracotta = Color(0xFFC0856E);
  static const minimalRose = Color(0xFFB07980);
  static const minimalInkBase = Color(0xFF4E5850);

  // ---------------------------------------------------------------------------
  // Palette v2 — Neutral ramp
  // ---------------------------------------------------------------------------

  static const neutral0 = Color(0xFFF7F2EC);
  static const neutral1 = Color(0xFFF1EBE2);
  static const neutral2 = Color(0xFFF1EADC);
  static const neutral3 = Color(0xFFF2EAD8);
  static const neutral4 = Color(0xFFE8DED1);
  static const neutral5 = Color(0xFFD4CCBF);

  // ---------------------------------------------------------------------------
  // Ink ramp
  // ---------------------------------------------------------------------------

  static const inkTint0 = Color(0xFFACDDE4);
  static const inkTint1 = Color(0xFF5C8784);
  static const inkTint2 = Color(0xFF30484B);
  static const ink0 = Color(0xFF2F3A34);
  static const ink1 = Color(0xFF4E5C56);
  static const ink2 = Color(0xFF6E7C75);

  // ---------------------------------------------------------------------------
  // Terracotta ramp
  // ---------------------------------------------------------------------------

  static const terracotta0 = Color(0xFFF5E2DB);
  static const terracotta1 = Color(0xFFDFA094);
  static const terracotta2 = Color(0xFFD59D89);
  static const terracotta3 = Color(0xFFC18870);
  static const terracotta4 = Color(0xFF8D5132);
  static const terracotta5 = Color(0xFF552E21);

  // ---------------------------------------------------------------------------
  // Cool Counterweight ramp
  // ---------------------------------------------------------------------------

  static const cool0 = Color(0xFFADDEE6);
  static const cool1 = Color(0xFF5C8886);
  static const cool2 = Color(0xFF31494E);

  // ---------------------------------------------------------------------------
  // Dark ramp (from asset.background.hero.dark)
  // ---------------------------------------------------------------------------

  static const dark0 = Color(0xFFE2DBD2);
  static const dark1 = Color(0xFF80888E);
  static const dark2 = Color(0xFF324E59);
  static const dark3 = Color(0xFF012027);
  static const dark4 = Color(0xFF000201);

  // ---------------------------------------------------------------------------
  // Semantic tokens (Light/Dark)
  // ---------------------------------------------------------------------------

  // Light
  static const semanticErrorLight = Color(0xFFFF3131);
  static const semanticWarningLight = Color(0xFFE8A84C);
  static const semanticLinkLight = Color(0xFF00E5FF);

  // Dark (kept for future dark theme wiring)
  static const semanticErrorDark = Color(0xFFFF6B6B);
  static const semanticWarningDark = Color(0xFFF5C842);
  static const semanticInkDark = Color(0xFF64B5F6);

  // ---------------------------------------------------------------------------
  // Legacy aliases (kept to avoid touching every file at once)
  // ---------------------------------------------------------------------------

  /// Legacy name for the light background base.
  static const cloudDancer = neutral0;

  /// Legacy light surface.
  static const clay = neutral4;

  /// Legacy deep background / ink.
  static const deepSapphire = ink0;

  /// Brand green.
  static const eucalyptus = minimalEucalyptus;

  /// Brand terracotta.
  static const terracottaClay = terracotta3;

  /// Deep warm accent.
  static const copperOak = terracotta4;

  /// Atmospheric wash.
  static const atmosphericFog = cool1;

  /// Error red.
  static const dopamineRed = semanticErrorLight;
  static const saturationRed = dopamineRed;

  /// Legacy pink highlight — mapped to the v1 rose accent.
  static const neonPink = minimalRose;

  /// Link/laser accent.
  static const electricBlue = semanticLinkLight;

  // ---------------------------------------------------------------------------
  // Role tokens
  // ---------------------------------------------------------------------------

  static const background = cloudDancer;

  /// Default "bento" surface.
  static const surface = neutral2;

  /// Default ink used for icons/labels.
  static const inkDeep = deepSapphire;

  static const textPrimary = ink0;
  static const textWarm = copperOak;
  static const textOnDark = cloudDancer;
  static const textOnPrimary = neutral0;

  static Color get textSecondary => ink0.withValues(alpha: 0.72);
  static Color get textMuted => ink0.withValues(alpha: 0.54);

  static const success = eucalyptus;
  static const accentEarth = terracottaClay;

  /// Primary "call to action" color.
  static const primaryAction = terracotta3;

  static const highlight = neonPink;

  /// Used for scanner glow/bounding boxes.
  static const alertProfit = electricBlue;

  static const activeVoiceGps = electricBlue;

  // ---------------------------------------------------------------------------
  // Outlines / shadows / scrims
  // ---------------------------------------------------------------------------

  /// Subtle outline on light surfaces.
  static const borderSubtle = Color(0x1A2F3A34); // ink0 @ ~10%
  static const border = borderSubtle;
  static const shadowInk = Color(0x160F1720);

  static const heroScrim = Color(0x382F3A34); // ink0 @ ~22%
  static const scrim = Color(0x662F3A34); // ink0 @ ~40%

  // ---------------------------------------------------------------------------
  // Glass tokens
  // ---------------------------------------------------------------------------

  /// Default glass fill for small tiles.
  ///
  /// Maps to: neutral.0 @ opacity.glassTile (0.40).
  static const glassFill = Color(0x66F7F2EC);

  /// Default glass stroke.
  ///
  /// Maps to: neutral.0 @ ~0.45.
  static const glassStroke = Color(0x73F7F2EC);
}
