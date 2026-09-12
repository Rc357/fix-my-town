import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Must be overridden in bootstrap() with a real instance —
/// SharedPreferences.getInstance() is async, so this can't construct one
/// lazily here the way most providers in this app do.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in bootstrap()',
  ),
);

const _themeModePrefKey = 'fmt_theme_mode';

/// The citizen's Light/Dark/System choice (Profile screen), persisted so it
/// survives an app restart. Defaults to System — matching the phone's own
/// setting is the least surprising first-run behavior.
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final saved = ref.read(sharedPreferencesProvider).getString(_themeModePrefKey);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(_themeModePrefKey, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
