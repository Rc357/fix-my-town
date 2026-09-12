import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obserba/app/theme/obs_colors.dart';

/// `ObsText` without this would have left most on-screen text untouched.
abstract final class ObsFontSize {
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
/// `static get`, not `static final` — a `final` field memoizes on first
/// access for the process lifetime, which would freeze these at whichever
/// ObsColors.ink/.muted value was current the first time each was touched,
/// never picking up a later dark-mode change. A getter re-evaluates every
/// access instead, so it always reflects ObsColors' current brightness.
/// `GoogleFonts.inter(...)` isn't a const constructor either way (it lazily
/// registers/loads the font file on first use), so nothing referencing
/// these fields can be `const` (see AppTheme, which drops the `const` off
/// its `TextTheme`/`AppBarTheme` for the same reason).
///
/// Weights also dialed back from an earlier pass (display/title/label were
/// all w800, body w500) — heavy weight everywhere was a real contributor to
/// the app reading as "too bold," independent of font choice. Bold is
/// reserved for things that should stand out (titles, labels); body/caption
/// read at a normal weight.
abstract final class ObsText {
  static TextStyle get display => GoogleFonts.inter(
    fontSize: ObsFontSize.display,
    fontWeight: FontWeight.w700,
    color: ObsColors.ink,
    letterSpacing: -0.1,
  );

  static TextStyle get title => GoogleFonts.inter(
    fontSize: ObsFontSize.xxl,
    fontWeight: FontWeight.w700,
    color: ObsColors.ink,
  );

  static TextStyle get body => GoogleFonts.inter(
    fontSize: ObsFontSize.xl,
    fontWeight: FontWeight.w400,
    color: ObsColors.ink,
    height: 1.4,
  );

  static TextStyle get label => GoogleFonts.inter(
    fontSize: ObsFontSize.sm,
    fontWeight: FontWeight.w700,
    color: ObsColors.muted,
    letterSpacing: 0.6,
  );

  static TextStyle get caption => GoogleFonts.inter(
    fontSize: ObsFontSize.sm,
    fontWeight: FontWeight.w500,
    color: ObsColors.muted,
  );

  static TextStyle get mono => GoogleFonts.inter(
    fontSize: ObsFontSize.md,
    fontWeight: FontWeight.w700,
    color: ObsColors.ink,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
