import 'package:flutter/foundation.dart';
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
    this.supabaseUrl,
    this.supabasePublishableKey,
    this.firebaseApiKeyAndroid,
    this.firebaseApiKeyIos,
    this.firebaseAppIdAndroid,
    this.firebaseAppIdIos,
    this.firebaseMessagingSenderId,
    this.firebaseProjectId,
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
        defaultValue: 'Obserba',
      ),
      apiBaseUrl: Uri.parse(
        configuredUrl.isEmpty ? _defaultApiUrl(flavor) : configuredUrl,
      ),
      enableVerboseLogs: const bool.fromEnvironment(
        'VERBOSE_LOGS',
        defaultValue: false,
      ),
      supabaseUrl: _optional(const String.fromEnvironment('SUPABASE_URL')),
      supabasePublishableKey: _optional(
        const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY'),
      ),
      firebaseApiKeyAndroid: _optional(
        const String.fromEnvironment('FIREBASE_API_KEY_ANDROID'),
      ),
      firebaseApiKeyIos: _optional(
        const String.fromEnvironment('FIREBASE_API_KEY_IOS'),
      ),
      firebaseAppIdAndroid: _optional(
        const String.fromEnvironment('FIREBASE_APP_ID_ANDROID'),
      ),
      firebaseAppIdIos: _optional(
        const String.fromEnvironment('FIREBASE_APP_ID_IOS'),
      ),
      firebaseMessagingSenderId: _optional(
        const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID'),
      ),
      firebaseProjectId: _optional(
        const String.fromEnvironment('FIREBASE_PROJECT_ID'),
      ),
    );
  }

  final AppFlavor flavor;
  final String appName;
  final Uri apiBaseUrl;
  final bool enableVerboseLogs;

  /// Null unless both are supplied via `--dart-define` — Supabase is opt-in,
  /// not required to run the app (same principle as Firebase below).
  /// "Publishable key" is Supabase's current name for what used to be
  /// called the "anon key" — same thing, safe to expose client-side.
  final String? supabaseUrl;
  final String? supabasePublishableKey;
  bool get hasSupabase => supabaseUrl != null && supabasePublishableKey != null;

  /// Deliberately configured via FirebaseOptions/dart-define rather than
  /// google-services.json/GoogleService-Info.plist — keeps this in the same
  /// typed, compile-time-config pattern as the rest of AppConfig instead of
  /// introducing a second, file-based configuration mechanism.
  ///
  /// apiKey and appId are per-platform in Firebase — the Android and iOS app
  /// registrations under the same project each get their own values, unlike
  /// messagingSenderId/projectId which are shared project-wide. Hence the
  /// _Android/_Ios split below rather than one shared pair.
  final String? firebaseApiKeyAndroid;
  final String? firebaseApiKeyIos;
  final String? firebaseAppIdAndroid;
  final String? firebaseAppIdIos;
  final String? firebaseMessagingSenderId;
  final String? firebaseProjectId;

  String? get firebaseApiKey => defaultTargetPlatform == TargetPlatform.iOS
      ? firebaseApiKeyIos
      : firebaseApiKeyAndroid;
  String? get firebaseAppId => defaultTargetPlatform == TargetPlatform.iOS
      ? firebaseAppIdIos
      : firebaseAppIdAndroid;

  bool get hasFirebase =>
      firebaseApiKey != null &&
      firebaseAppId != null &&
      firebaseMessagingSenderId != null &&
      firebaseProjectId != null;

  static String _defaultApiUrl(AppFlavor flavor) => switch (flavor) {
    AppFlavor.development => 'http://10.0.2.2:8080',
    AppFlavor.staging => 'https://staging-api.example.com',
    AppFlavor.production => 'https://api.example.com',
  };

  /// `--dart-define` has no notion of "unset" — an unsupplied key just
  /// resolves to ''. This turns that back into a real null so `hasSupabase`/
  /// `hasFirebase` can tell "not configured" apart from "configured empty."
  /// Takes the already-resolved value, not the define name — `fromEnvironment`
  /// itself must stay a literal `const` expression at its call site above,
  /// it can't be factored through a helper that takes the name as a param.
  static String? _optional(String value) => value.isEmpty ? null : value;
}

final appConfigProvider = Provider<AppConfig>(
  (ref) => throw StateError(
    'AppConfig must be supplied by bootstrap or overridden in a test.',
  ),
);
