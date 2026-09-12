import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:obserba/app/app.dart';
import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/app/theme/theme_mode_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  final logger = Logger();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.e(
      'Uncaught Flutter error',
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  // Both are opt-in: absent config means the app keeps running against the
  // in-memory adapters, same as before this was wired up. A failure here
  // (bad URL, unreachable project) must not take the whole app down with it.
  if (config.hasSupabase) {
    try {
      await Supabase.initialize(
        url: config.supabaseUrl!,
        publishableKey: config.supabasePublishableKey!,
      );
    } catch (error, stackTrace) {
      logger.e(
        'Supabase initialization failed — falling back to in-memory data',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
  if (config.hasFirebase) {
    try {
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: config.firebaseApiKey!,
          appId: config.firebaseAppId!,
          messagingSenderId: config.firebaseMessagingSenderId!,
          projectId: config.firebaseProjectId!,
        ),
      );
    } catch (error, stackTrace) {
      logger.e(
        'Firebase initialization failed — push notifications disabled',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  final sharedPreferences = await SharedPreferences.getInstance();

  // Deliberately not runZonedGuarded: it requires ensureInitialized() and
  // runApp() to execute in the *same* zone, and initializing the binding
  // outside a runZonedGuarded callback (as above — needed so it runs before
  // any await) while running the app inside one is exactly the "zone
  // mismatch" Flutter's binding now treats as fatal. onError below already
  // catches uncaught async/platform errors without that hazard.
  PlatformDispatcher.instance.onError = (error, stackTrace) {
    logger.e('Uncaught platform error', error: error, stackTrace: stackTrace);
    return true;
  };

  runApp(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
