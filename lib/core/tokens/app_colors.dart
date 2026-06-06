import 'package:flutter/material.dart';

abstract final class AppColors {
  static const cloudDancer = Color(0xFFF0EEE9);
  static const clay = Color(0xFFE8E4DE);
  // Redesign: card surface (slightly brighter than paper).
  static const card = Color(0xFFFBFAF7);
  static const deepSapphire = Color(0xFF1E2B3C);
  static const eucalyptus = Color(0xFF8AA399);
  // Redesign: deeper sage for profit indicators.
  static const sageDeep = Color(0xFF5E7D6F);
  static const terracottaClay = Color(0xFFCB8573);
  static const copperOak = Color(0xFF935233);
  static const atmosphericFog = Color(0xFF5B6C8F);
  static const dopamineRed = Color(0xFFFF3131);
  static const saturationRed = dopamineRed;
  // Redesign: mustard for best-find / star highlights.
  static const mustard = Color(0xFFC9A14A);
  static const neonPink = Color(0xFFFF1493);
  static const electricBlue = Color(0xFF00E5FF);

  static const background = cloudDancer;
  static const surface = clay;
  static const inkDeep = deepSapphire;
  static const textPrimary = deepSapphire;
  static const textWarm = copperOak;
  static const textOnDark = cloudDancer;
  static const textOnPrimary = Colors.white;

  static Color get textSecondary => deepSapphire.withValues(alpha: 0.72);
  static Color get textMuted => deepSapphire.withValues(alpha: 0.54);
  // Redesign: ink at 38% opacity for tertiary icons / separators.
  static Color get textFaint => deepSapphire.withValues(alpha: 0.38);

  static const success = eucalyptus;
  static const accentEarth = terracottaClay;
  static const primaryAction = dopamineRed;
  static const highlight = neonPink;
  static const alertProfit = neonPink;
  static const activeVoiceGps = electricBlue;

  static const borderSubtle = Color(0x1A1E2B3C);
  static const border = borderSubtle;
  static const shadowInk = Color(0x160F1720);

  static const heroScrim = Color(0x381E2B3C);
  static const scrim = Color(0x661E2B3C);

  static const glassFill = Color(0x33FFFFFF);
  static const glassStroke = Color(0x40FFFFFF);

  // ── Verdict palette (redesign) ─────────────────────────────
  static const verdictBuyText = Color(0xFF3F6650);
  static const verdictBuyBg = Color(0xFFDCE7DF);
  static const verdictMaybeText = Color(0xFF8A6516);
  static const verdictMaybeBg = Color(0xFFF1E6CB);
  static const verdictSkipText = Color(0xFF9A3A2A);
  static const verdictSkipBg = Color(0xFFF0DAD2);
}
