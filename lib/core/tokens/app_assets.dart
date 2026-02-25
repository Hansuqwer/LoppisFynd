/// Asset path tokens.
///
/// Keep these centralized so widgets don't hard-code file paths.
abstract final class AppAssets {
  // ---------------------------------------------------------------------------
  // Background images
  // ---------------------------------------------------------------------------

  /// Bright "market day" photo background.
  /// Token in the design system: `asset.background.market.day.1`.
  static const String backgroundMarketDay1 =
      'Assets/backgrounds/market_day_1.png';

  /// Warm indoor market photo background (variant 1).
  /// Token in the design system: `asset.background.market.warm.1`.
  static const String backgroundMarketWarm1 =
      'Assets/backgrounds/market_warm_1.png';

  /// Warm indoor market photo background (variant 2).
  /// Token in the design system: `asset.background.market.warm.2`.
  static const String backgroundMarketWarm2 =
      'Assets/backgrounds/market_warm_2.png';

  /// Dark mode hero background.
  /// Token in the design system: `asset.background.hero.dark`.
  static const String backgroundHeroDark = 'Assets/backgrounds/hero_dark.jpg';

  /// Motif image used for the login wallpaper / repeated marks.
  /// Token in the design system: `asset.background.login.motif`.
  ///
  /// Canonical source uses logo variant 1 photo.
  static const String backgroundLoginMotif =
      'Assets/logos/logo_variant_1_photo.jpg';

  // ---------------------------------------------------------------------------
  // Textures
  // ---------------------------------------------------------------------------

  /// Token in the design system: `texture.paper.ramp`.
  static const String texturePaperRamp =
      'Assets/textures/texture_paper_ramp.png';

  /// Token in the design system: `texture.paper.tornRamp`.
  static const String texturePaperTornRamp =
      'Assets/textures/texture_paper_torn_ramp.png';

  /// Token in the design system: `texture.ink.ramp`.
  static const String textureInkRamp = 'Assets/textures/texture_ink_ramp.png';

  /// Token in the design system: `texture.terracotta.ramp`.
  static const String textureTerracottaRamp =
      'Assets/textures/texture_terracotta_ramp.png';

  // ---------------------------------------------------------------------------
  // Logos
  // ---------------------------------------------------------------------------

  /// Logo Variant 1: photo lockup.
  static const String logoVariant1Photo =
      'Assets/logos/logo_variant_1_photo.jpg';

  /// Logo Variant 2: flat lockup.
  static const String logoVariant2Flat = 'Assets/logos/logo_variant_2_flat.png';
}
