import 'package:flutter/material.dart';

/// Design tokens from docs-mobile/04-design-system.md.
///
/// Only 3 main colors are independently chosen per brightness: [ink] (text),
/// [surface] (background), [brand] (accent) — everything else here is either
/// derived from one of those three, a structural neutral (`muted`/`line`),
/// or a semantic status color. Semantic status colors (amber/green/red/blue)
/// are deliberately separate from the brand accent — never repurpose a
/// status color for a non-status UI element.
///
/// Every field below is a `static get`, not `static const` — dark mode needs
/// these to resolve differently depending on [setBrightness]'s current
/// value, and a getter is read with the exact same `ObsColors.ink` syntax a
/// const field would be, so no call site anywhere in the app needed to
/// change. The real cost is the opposite direction: anywhere a widget tree
/// wrapped one of these in a `const` expression, that `const` now has to
/// come off, since these are no longer compile-time constants. See
/// AppThemeScope for where [setBrightness] actually gets called.
abstract final class ObsColors {
  static Brightness _brightness = Brightness.light;
  static bool get _isDark => _brightness == Brightness.dark;

  /// Called once per resolved-brightness change, from the app's root
  /// theme-mode wrapper — never from a widget's build method directly.
  static void setBrightness(Brightness brightness) => _brightness = brightness;

  /// The brightness ObsColors is currently resolving against — AppTheme
  /// reads this to build a matching ColorScheme rather than hardcoding
  /// Brightness.light.
  static Brightness get brightness => _brightness;

  static Color get ink =>
      _isDark ? const Color(0xFFECEFEC) : const Color(0xFF16211D);
  static Color get surface =>
      _isDark ? const Color(0xFF121417) : const Color(0xFFFFFFFF);
  static Color get brand =>
      _isDark ? const Color(0xFF2BC4E8) : const Color(0xFF06AED5); // boracay blue

  static Color get muted =>
      _isDark ? const Color(0xFF98A69F) : const Color(0xFF5B6B66);
  static Color get line =>
      _isDark ? const Color(0xFF2E3234) : const Color(0xFFE3DDC9);

  /// Contrast-safe shade of [brand] for text/icons on light backgrounds
  /// (e.g. on [brandTint]) where raw `brand` wouldn't have enough contrast —
  /// derived, not a separately hand-picked hue, so there's still only one
  /// accent color to keep in sync. Lerps toward black in light mode
  /// (darkening for contrast against a light tint) and toward white in dark
  /// mode (lightening for contrast against a dark tint) — the same
  /// contrast-direction flip every derived tint below needs.
  static Color get brandInk =>
      Color.lerp(brand, _isDark ? Colors.white : Colors.black, 0.5)!;

  /// Wash of [brand] for selected/filled backgrounds — also derived, not a
  /// separate pick. Lower alpha in dark mode: the same alpha blended over a
  /// near-black surface reads much more saturated than over white.
  static Color get brandTint => brand.withValues(alpha: _isDark ? 0.24 : 0.3);

  static Color get amber =>
      _isDark ? const Color(0xFFE0A360) : const Color(0xFFC97A2B); // in-progress
  static Color get amberTint =>
      _isDark ? const Color(0xFF3A2E1C) : const Color(0xFFF6E6D3);
  static Color get green =>
      _isDark ? const Color(0xFF6FBF7C) : const Color(0xFF3F7D4C); // resolved
  static Color get greenTint =>
      _isDark ? const Color(0xFF1E3324) : const Color(0xFFDFEEE1);
  static Color get red =>
      _isDark ? const Color(0xFFE0685A) : const Color(0xFFB23A2E); // urgent / alert
  static Color get redTint =>
      _isDark ? const Color(0xFF3A1E1B) : const Color(0xFFF6DFDC);
  static Color get blue =>
      _isDark ? const Color(0xFF7FA4C9) : const Color(0xFF3A5A7D); // pending / informational
  static Color get blueTint =>
      _isDark ? const Color(0xFF1E2A38) : const Color(0xFFDEE6EE);
}
