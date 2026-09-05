import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:flutter/material.dart';

/// Type scale from docs-mobile/04-design-system.md. One family (Roboto,
/// Flutter's Material default on both platforms) — see that doc for why
/// platform-native font-swapping isn't worth the complexity here.
abstract final class FmtText {
  static const display = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: FmtColors.ink,
    letterSpacing: -0.2,
  );

  static const title = TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w800,
    color: FmtColors.ink,
    letterSpacing: -0.1,
  );

  static const body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: FmtColors.ink,
    height: 1.4,
  );

  static const label = TextStyle(
    fontSize: 10.5,
    fontWeight: FontWeight.w800,
    color: FmtColors.muted,
    letterSpacing: 0.9,
  );

  static const caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: FmtColors.muted,
  );

  static const mono = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: FmtColors.ink,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
