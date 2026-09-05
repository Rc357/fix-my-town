import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/bootstrap.dart';

Future<void> main() => bootstrap(AppConfig.fromEnvironment());

/*
Default entry point — no flavor, no --dart-define needed. Falls back to
AppFlavor.development (see AppConfig.fromEnvironment's default) and the
matching default API URL in app_config.dart. This is what plain
`flutter run` uses; prefer lib/main_development.dart directly once you
also need the "development" Android product flavor / distinct app ID
installed side-by-side with staging/production.

Run:
  flutter run

Build APK:
  flutter build apk

Build App Bundle:
  flutter build appbundle
*/
