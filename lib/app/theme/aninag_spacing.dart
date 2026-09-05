/// Spacing/radius scale from docs-mobile/04-design-system.md — apply via
/// Row/Column/Wrap `spacing` or an explicit SizedBox gap, never accumulated
/// per-child margins.
abstract final class AninagSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class AninagRadius {
  static const tile = 13.0;
  static const card = 14.0;
  static const button = 12.0;
  static const pill = 999.0;
}
