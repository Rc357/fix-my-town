import 'package:fixmytown_citizen/app/theme/fmt_colors.dart';
import 'package:fixmytown_citizen/app/theme/fmt_spacing.dart';
import 'package:fixmytown_citizen/app/theme/fmt_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A single, committed theme — not a light/dark pair. See
/// docs-mobile/04-design-system.md "One committed theme, not light/dark":
/// for a civic app used briefly and functionally, one consistent,
/// high-contrast presentation beats accommodating system dark mode.
abstract final class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: FmtColors.surface,
    colorScheme: ColorScheme.fromSeed(
      seedColor: FmtColors.brand,
      brightness: Brightness.light,
      primary: FmtColors.brand,
      onPrimary: Colors.white,
      surface: FmtColors.surface,
      onSurface: FmtColors.ink,
      error: FmtColors.red,
    ),
    // Inter via GoogleFonts.interTextTheme wraps our custom TextTheme so
    // the ambient DefaultTextStyle (what scattered inline
    // `TextStyle(fontSize: FmtFontSize.xxx)` literals across the app merge
    // onto) also falls back to Inter, not just the named FmtText roles.
    textTheme: GoogleFonts.interTextTheme(
      TextTheme(
        headlineMedium: FmtText.display,
        titleMedium: FmtText.title,
        bodyMedium: FmtText.body,
        labelLarge: FmtText.label,
        bodySmall: FmtText.caption,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: FmtColors.surface,
      foregroundColor: FmtColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: FmtText.title,
    ),
    cardTheme: CardThemeData(
      color: FmtColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FmtRadius.card),
        side: const BorderSide(color: FmtColors.line),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: FmtColors.line,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FmtColors.surface,
      labelStyle: const TextStyle(color: FmtColors.muted),
      floatingLabelStyle: const TextStyle(color: FmtColors.brand),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FmtRadius.input),
        borderSide: const BorderSide(color: FmtColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FmtRadius.input),
        borderSide: const BorderSide(color: FmtColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FmtRadius.input),
        borderSide: const BorderSide(color: FmtColors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FmtRadius.input),
        borderSide: const BorderSide(color: FmtColors.red),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: FmtColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: FmtColors.muted.withValues(alpha: 0.2),
        disabledForegroundColor: FmtColors.muted,
        minimumSize: const Size.fromHeight(50),
        // Pill/stadium shape — matches bluehive-project's RoundedCornerButton.
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontSize: FmtFontSize.xl, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: FmtColors.brandInk,
        minimumSize: const Size.fromHeight(50),
        side: const BorderSide(color: FmtColors.brand, width: 1.4),
        shape: const StadiumBorder(),
        textStyle: GoogleFonts.inter(fontSize: FmtFontSize.xl, fontWeight: FontWeight.w700),
      ),
    ),
    iconTheme: const IconThemeData(color: FmtColors.ink),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: FmtColors.surface,
      selectedItemColor: FmtColors.brand,
      unselectedItemColor: FmtColors.muted,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
