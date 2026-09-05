import 'package:fixmytown_citizen/app/app.dart';
import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

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
      overrides: [appConfigProvider.overrideWithValue(config)],
      child: const App(),
    ),
  );
}
