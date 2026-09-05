import 'package:fixmytown_citizen/app/config/app_config.dart';
import 'package:fixmytown_citizen/bootstrap.dart';

Future<void> main() =>
    bootstrap(AppConfig.fromEnvironment(fallbackFlavor: AppFlavor.production));

/*
Android — uses the "production" product flavor (bare app ID, no suffix,
see android/app/build.gradle.kts):

  flutter run \
    --flavor production \
    -t lib/main_production.dart \
    --dart-define=APP_FLAVOR=production \
    --dart-define=API_BASE_URL=https://api.example.com

  flutter build apk \
    --flavor production \
    -t lib/main_production.dart \
    --dart-define=APP_FLAVOR=production \
    --dart-define=API_BASE_URL=https://api.example.com \
    --obfuscate --split-debug-info=build/symbols

  flutter build appbundle \
    --flavor production \
    -t lib/main_production.dart \
    --dart-define=APP_FLAVOR=production \
    --dart-define=API_BASE_URL=https://api.example.com \
    --obfuscate --split-debug-info=build/symbols

  Release signing must be configured (key.properties) before this build
  is store-ready — see ../SETUP.md; it never silently falls back to
  debug signing.

iOS — per-flavor Xcode schemes aren't set up yet (see ../SETUP.md); run
against the default Runner scheme/configuration instead:

  flutter run \
    -t lib/main_production.dart \
    --dart-define=APP_FLAVOR=production \
    --dart-define=API_BASE_URL=https://api.example.com
*/
