import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:obserba/app/theme/obs_colors.dart';
import 'package:obserba/app/theme/obs_spacing.dart';
import 'package:obserba/app/theme/obs_text_styles.dart';

/// Light and dark, via ObsColors' brightness-aware getters — see that
/// file's doc comment. `theme` is a `static get`, not `static final`: a
/// `final` would memoize this ThemeData on first access and never rebuild
/// it for a later brightness change, same reasoning as ObsText. Nothing
/// below can be `const` for the same reason ObsColors' fields aren't —
/// they're no longer compile-time constants.
abstract final class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: ObsColors.brightness,
    scaffoldBackgroundColor: ObsColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ObsColors.brand,
      brightness: ObsColors.brightness,
      primary: ObsColors.brand,
      onPrimary: Colors.white,
      surface: ObsColors.surface,
      onSurface: ObsColors.ink,
      error: ObsColors.red,
    ),
    // Inter via GoogleFonts.interTextTheme wraps our custom TextTheme so
    // the ambient DefaultTextStyle (what scattered inline
    // `TextStyle(fontSize: ObsFontSize.xxx)` literals across the app merge
    // onto) also falls back to Inter, not just the named ObsText roles.
    textTheme: GoogleFonts.interTextTheme(
      TextTheme(
        headlineMedium: ObsText.display,
        titleMedium: ObsText.title,
        bodyMedium: ObsText.body,
        labelLarge: ObsText.label,
        bodySmall: ObsText.caption,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ObsColors.surface,
      foregroundColor: ObsColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: ObsText.title,
    ),
    cardTheme: CardThemeData(
      color: ObsColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ObsRadius.card),
        side: BorderSide(color: ObsColors.line),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: DividerThemeData(color: ObsColors.line, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ObsColors.surface,
      labelStyle: TextStyle(color: ObsColors.muted),
      floatingLabelStyle: TextStyle(color: ObsColors.brand),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ObsRadius.input),
        borderSide: BorderSide(color: ObsColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ObsRadius.input),
        borderSide: BorderSide(color: ObsColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ObsRadius.input),
        borderSide: BorderSide(color: ObsColors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ObsRadius.input),
        borderSide: BorderSide(color: ObsColors.red),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: ObsColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: ObsColors.muted.withValues(alpha: 0.2),
        disabledForegroundColor: ObsColors.muted,
        minimumSize: const Size.fromHeight(50),
        // Pill/stadium shape — matches bluehive-project's RoundedCornerButton.
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontSize: ObsFontSize.xl, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ObsColors.brandInk,
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: ObsColors.brand, width: 1.4),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontSize: ObsFontSize.xl, fontWeight: FontWeight.w700),
      ),
    ),
    iconTheme: IconThemeData(color: ObsColors.ink),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: ObsColors.surface,
      selectedItemColor: ObsColors.brand,
      unselectedItemColor: ObsColors.muted,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
