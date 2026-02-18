abstract final class AppRadius {
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const pill = 999.0;

  /// Alias for contract naming (bento default).
  static const xxl = lg;

  /// Contract radius for large glass boards.
  static const double board = 36.0;

  /// Contract radius for tighter capsules (keeps [pill] semantics intact).
  static const double capsule = 30.0;
}
