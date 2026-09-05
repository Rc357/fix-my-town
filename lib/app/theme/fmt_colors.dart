import 'package:flutter/material.dart';

/// Design tokens from docs-mobile/04-design-system.md. Semantic status
/// colors (amber/green/red/blue) are deliberately separate from the brand
/// accent — never repurpose a status color for a non-status UI element.
abstract final class FmtColors {
  static const ink = Color(0xFF16211D);
  static const paper = Color(0xFFF4F1E6);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFF5B6B66);
  static const line = Color(0xFFE3DDC9);

  static const brand = Color(0xFF06AED5); // boracay blue
  static const brandInk = Color(0xFF00576B);
  static const brandTint = Color(0xFFB1E9F6);

  static const amber = Color(0xFFC97A2B); // in-progress
  static const amberTint = Color(0xFFF6E6D3);
  static const green = Color(0xFF3F7D4C); // resolved
  static const greenTint = Color(0xFFDFEEE1);
  static const red = Color(0xFFB23A2E); // urgent / alert
  static const redTint = Color(0xFFF6DFDC);
  static const blue = Color(0xFF3A5A7D); // pending / informational
  static const blueTint = Color(0xFFDEE6EE);
}
