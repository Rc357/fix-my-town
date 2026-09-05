import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:flutter/material.dart';

/// Type scale from docs-mobile/04-design-system.md. One family (Roboto,
/// Flutter's Material default on both platforms) — see that doc for why
/// platform-native font-swapping isn't worth the complexity here.
abstract final class AninagText {
  static const display = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AninagColors.ink,
    letterSpacing: -0.2,
  );

  static const title = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w800,
    color: AninagColors.ink,
    letterSpacing: -0.1,
  );

  static const body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AninagColors.ink,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    color: AninagColors.muted,
    letterSpacing: 0.9,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AninagColors.muted,
  );

  static const mono = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AninagColors.ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
