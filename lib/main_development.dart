import 'package:aninag_citizen/app/config/app_config.dart';
import 'package:aninag_citizen/bootstrap.dart';

Future<void> main() =>
    bootstrap(AppConfig.fromEnvironment(fallbackFlavor: AppFlavor.development));

/*
Android — uses the "development" product flavor (distinct app ID suffix
".dev", see android/app/build.gradle.kts), installable side-by-side with
staging/production:

  flutter run \
    --flavor development \
    -t lib/main_development.dart \
    --dart-define=APP_FLAVOR=development \
    --dart-define=API_BASE_URL=http://10.0.2.2:8080

  flutter build apk \
    --flavor development \
    -t lib/main_development.dart \
    --dart-define=APP_FLAVOR=development \
    --dart-define=API_BASE_URL=http://10.0.2.2:8080

  flutter build appbundle \
    --flavor development \
    -t lib/main_development.dart \
    --dart-define=APP_FLAVOR=development \
    --dart-define=API_BASE_URL=http://10.0.2.2:8080

  (10.0.2.2 is the Android emulator's alias for the host machine's
  localhost — swap for your machine's LAN IP on a physical device.)

iOS — per-flavor Xcode schemes aren't set up yet (see ../SETUP.md), so
--flavor isn't available here. Run against the default Runner
scheme/configuration instead — on an iOS Simulator, "localhost" reaches
the host machine directly (no 10.0.2.2 alias needed):

  flutter run \
    -t lib/main_development.dart \
    --dart-define=APP_FLAVOR=development \
    --dart-define=API_BASE_URL=http://localhost:8080
*/
