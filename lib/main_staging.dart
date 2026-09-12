import 'package:obserba/app/config/app_config.dart';
import 'package:obserba/bootstrap.dart';

Future<void> main() =>
    bootstrap(AppConfig.fromEnvironment(fallbackFlavor: AppFlavor.staging));

/*
Android — uses the "staging" product flavor (app ID suffix ".stg", see
android/app/build.gradle.kts):

  flutter run --flavor staging -t lib/main_staging.dart --dart-define=APP_FLAVOR=staging --dart-define=API_BASE_URL=https://staging-api.example.com
  flutter run --flavor staging -t lib/main_staging.dart --dart-define-from-file=config/staging.json

  flutter build apk --flavor staging -t lib/main_staging.dart --dart-define=APP_FLAVOR=staging --dart-define=API_BASE_URL=https://staging-api.example.com

  flutter build appbundle --flavor staging -t lib/main_staging.dart --dart-define=APP_FLAVOR=staging --dart-define=API_BASE_URL=https://staging-api.example.com

iOS — per-flavor Xcode schemes aren't set up yet (see ../SETUP.md); run
against the default Runner scheme/configuration instead:

  flutter run -t lib/main_staging.dart --dart-define=APP_FLAVOR=staging --dart-define=API_BASE_URL=https://staging-api.example.com
*/
