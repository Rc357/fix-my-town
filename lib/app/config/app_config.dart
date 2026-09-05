import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor {
  development,
  staging,
  production;

  static AppFlavor parse(String value, AppFlavor fallback) {
    return AppFlavor.values
            .where((flavor) => flavor.name == value)
            .firstOrNull ??
        fallback;
  }
}

class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.enableVerboseLogs,
  });

  factory AppConfig.fromEnvironment({
    AppFlavor fallbackFlavor = AppFlavor.development,
  }) {
    const flavorValue = String.fromEnvironment('APP_FLAVOR');
    final flavor = AppFlavor.parse(flavorValue, fallbackFlavor);
    const configuredUrl = String.fromEnvironment('API_BASE_URL');

    return AppConfig(
      flavor: flavor,
      appName: const String.fromEnvironment(
        'APP_NAME',
        defaultValue: 'FixMyTown Citizen',
      ),
      apiBaseUrl: Uri.parse(
        configuredUrl.isEmpty ? _defaultApiUrl(flavor) : configuredUrl,
      ),
      enableVerboseLogs: const bool.fromEnvironment(
        'VERBOSE_LOGS',
        defaultValue: false,
      ),
    );
  }

  final AppFlavor flavor;
  final String appName;
  final Uri apiBaseUrl;
  final bool enableVerboseLogs;

  static String _defaultApiUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.development => 'http://10.0.2.2:8080',
    AppFlavor.staging => 'https://staging-api.example.com',
    AppFlavor.production => 'https://api.example.com',
  };
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw StateError(
    'AppConfig must be supplied by bootstrap or overridden in a test.',
  ),
);
