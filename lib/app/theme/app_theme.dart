import 'package:aninag_citizen/app/theme/aninag_colors.dart';
import 'package:aninag_citizen/app/theme/aninag_spacing.dart';
import 'package:aninag_citizen/app/theme/aninag_text_styles.dart';
import 'package:flutter/material.dart';

/// A single, committed theme — not a light/dark pair. See
/// docs-mobile/04-design-system.md "One committed theme, not light/dark":
/// for a civic app used briefly and functionally, one consistent,
/// high-contrast presentation beats accommodating system dark mode.
abstract final class AppTheme {
  static final theme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AninagColors.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AninagColors.brand,
      brightness: Brightness.light,
      primary: AninagColors.brand,
      onPrimary: Colors.white,
      surface: AninagColors.surface,
      onSurface: AninagColors.ink,
      error: AninagColors.red,
    ),
    textTheme: const TextTheme(
      headlineMedium: AninagText.display,
      titleMedium: AninagText.title,
      bodyMedium: AninagText.body,
      labelLarge: AninagText.label,
      bodySmall: AninagText.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AninagColors.paper,
      foregroundColor: AninagColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AninagText.title,
    ),
    cardTheme: CardThemeData(
      color: AninagColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AninagRadius.card),
        side: const BorderSide(color: AninagColors.line),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(
      color: AninagColors.line,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AninagColors.surface,
      labelStyle: const TextStyle(color: AninagColors.muted),
      floatingLabelStyle: const TextStyle(color: AninagColors.brand),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AninagRadius.button),
        borderSide: const BorderSide(color: AninagColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AninagRadius.button),
        borderSide: const BorderSide(color: AninagColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AninagRadius.button),
        borderSide: const BorderSide(color: AninagColors.brand, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AninagRadius.button),
        borderSide: const BorderSide(color: AninagColors.red),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AninagColors.brand,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AninagColors.line,
        disabledForegroundColor: AninagColors.muted,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AninagRadius.button),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AninagColors.brandInk,
        minimumSize: const Size.fromHeight(48),
        side: const BorderSide(color: AninagColors.brand, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AninagRadius.button),
        ),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
    ),
    iconTheme: const IconThemeData(color: AninagColors.ink),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AninagColors.surface,
      selectedItemColor: AninagColors.brand,
      unselectedItemColor: AninagColors.muted,
      type: BottomNavigationBarType.fixed,
    ),
  );
}
