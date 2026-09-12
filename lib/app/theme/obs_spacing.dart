/// Spacing/radius scale from docs-mobile/04-design-system.md — apply via
/// Row/Column/Wrap `spacing` or an explicit SizedBox gap, never accumulated
/// per-child margins.
abstract final class ObsSpace {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class ObsRadius {
  static const tile = 13.0;
  static const card = 14.0;
  // Buttons use `pill` (StadiumBorder) instead — this is only ever applied
  // to form inputs. Value matches the reference app's input radius.
  static const input = 8.0;
  static const pill = 999.0;
}
