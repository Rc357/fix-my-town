import 'package:flutter/material.dart';

/// Design tokens from docs-mobile/04-design-system.md.
///
/// Only 3 main colors are independently chosen: [ink] (text), [surface]
/// (background), [brand] (accent) — everything else here is either derived
/// from one of those three, a structural neutral (`muted`/`line`), or a
/// semantic status color. Semantic status colors (amber/green/red/blue) are
/// deliberately separate from the brand accent — never repurpose a status
/// color for a non-status UI element.
abstract final class FmtColors {
  static const ink = Color(0xFF16211D);
  static const surface = Color(0xFFFFFFFF);
  static const brand = Color(0xFF06AED5); // boracay blue

  static const muted = Color(0xFF5B6B66);
  static const line = Color(0xFFE3DDC9);

  /// Darker shade of [brand] for text/icons on light backgrounds (e.g. on
  /// [brandTint]) where raw `brand` wouldn't have enough contrast — derived,
  /// not a separately hand-picked hue, so there's still only one accent
  /// color to keep in sync.
  static final brandInk = Color.lerp(brand, Colors.black, 0.5)!;

  /// Light wash of [brand] for selected/filled backgrounds — also derived,
  /// not a separate pick.
  static final brandTint = brand.withValues(alpha: 0.3);

  static const amber = Color(0xFFC97A2B); // in-progress
  static const amberTint = Color(0xFFF6E6D3);
  static const green = Color(0xFF3F7D4C); // resolved
  static const greenTint = Color(0xFFDFEEE1);
  static const red = Color(0xFFB23A2E); // urgent / alert
  static const redTint = Color(0xFFF6DFDC);
  static const blue = Color(0xFF3A5A7D); // pending / informational
  static const blueTint = Color(0xFFDEE6EE);
}
