import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// `FmtText` without this would have left most on-screen text untouched.
abstract final class FmtFontSize {
  /// Smallest allowed anywhere — status chips, the Verified badge. Never go
  /// below this; older/low-vision users are exactly who a smaller-than-this
  /// size fails first.
  static const xs = 12.0;

  /// Captions, meta text, muted secondary lines (timestamps, tracking IDs).
  static const sm = 13.0;

  /// Secondary reading text — comment author names, helper/empty-state notes.
  static const md = 14.0;

  /// Card/list titles, comment bodies, one-line address/detail text.
  static const lg = 15.0;

  /// Body copy and buttons — the size most on-screen reading text should be.
  static const xl = 16.0;

  /// Section/screen titles.
  static const xxl = 18.0;

  /// Large display headlines (e.g. the welcome screen's app name).
  static const display = 26.0;
}

/// Font: Inter (via `google_fonts`) — matches the reference app
/// (bluehive-project/AfexVisitor2025), whose body text is Inter Regular at
/// the same 16sp/w400. Switched from an earlier Lexend pass: Lexend's
/// letterforms carry noticeably thicker strokes than Inter at the *same*
/// nominal weight, which read as "still bold" even after dialing weights
/// down — the font itself, not just the weight number, was the mismatch.
/// `static final`, not `const`, below — `GoogleFonts.inter(...)` isn't a
/// const constructor (it lazily registers/loads the font file on first
/// use), so nothing referencing these fields can be `const` either (see
/// AppTheme, which drops the `const` off its `TextTheme`/`AppBarTheme` for
/// the same reason).
///
/// Weights also dialed back from an earlier pass (display/title/label were
/// all w800, body w500) — heavy weight everywhere was a real contributor to
/// the app reading as "too bold," independent of font choice. Bold is
/// reserved for things that should stand out (titles, labels); body/caption
/// read at a normal weight.
abstract final class FmtText {
  static final display = GoogleFonts.inter(
    fontSize: FmtFontSize.display,
    fontWeight: FontWeight.w700,
    color: FmtColors.ink,
    letterSpacing: -0.1,
  );

  static final title = GoogleFonts.inter(
    fontSize: FmtFontSize.xxl,
    fontWeight: FontWeight.w700,
    color: FmtColors.ink,
  );

  static final body = GoogleFonts.inter(
    fontSize: FmtFontSize.xl,
    fontWeight: FontWeight.w400,
    color: FmtColors.ink,
    height: 1.4,
  );

  static final label = GoogleFonts.inter(
    fontSize: FmtFontSize.sm,
    fontWeight: FontWeight.w700,
    color: FmtColors.muted,
    letterSpacing: 0.6,
  );

  static final caption = GoogleFonts.inter(
    fontSize: FmtFontSize.sm,
    fontWeight: FontWeight.w500,
    color: FmtColors.muted,
  );

  static final mono = GoogleFonts.inter(
    fontSize: FmtFontSize.md,
    fontWeight: FontWeight.w700,
    color: FmtColors.ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
