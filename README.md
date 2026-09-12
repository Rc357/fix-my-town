# Obserba Citizen

Obserba's Citizen app — report an incident, track it, confirm
resolution (see [`../docs-mobile/`](../docs-mobile/README.md) for the full
mobile documentation set this implements).

Built from `mobile-boilerplate-riverpod-v2`: Riverpod for state and
dependency injection, `go_router` for declarative navigation, feature-first
folders, compile-time configuration, automated tests, and CI quality gates.
The template itself is unchanged at its own location; everything below
describes this app's copy of it.

## What is improved

- The default `main.dart` launches the real application.
- Riverpod 3 and the current `go_router` major version are used.
- Authentication depends on a domain interface, not a Firebase global.
- Router and stream resources are disposed with their provider lifecycle.
- Runtime configuration uses `--dart-define`; `.env` files are not bundled.
- Android flavors have distinct application IDs and labels.
- Release builds never silently fall back to debug signing.
- Unit and end-to-end widget tests cover configuration and sign-in.
- GitHub Actions enforces formatting, analysis, and test coverage.
- Firebase is optional. The app runs before credentials are configured.

## Requirements

- Flutter stable with Dart 3.12 or newer
- Android Studio and/or Xcode for device builds

```sh
flutter pub get
flutter analyze
flutter test
```

## Run

The default entry point runs the development configuration:

```sh
flutter run
```

Flavors — same commands on both Android and iOS now (each gets its own
bundle/application ID and display name: `Obserba`/`DEV Obserba`/`STG Obserba`, so all
three install side-by-side on one device):

```sh
flutter run --flavor development -t lib/main_development.dart --dart-define=APP_FLAVOR=development --dart-define=API_BASE_URL=http://10.0.2.2:8080

flutter run --flavor staging -t lib/main_staging.dart --dart-define=APP_FLAVOR=staging --dart-define=API_BASE_URL=https://staging-api.example.com

flutter run --flavor production -t lib/main_production.dart --dart-define=APP_FLAVOR=production --dart-define=API_BASE_URL=https://api.example.com
```

iOS flavors are wired via three shared Xcode schemes
(`ios/Runner.xcodeproj/xcshareddata/xcschemes/{development,staging,production}.xcscheme`),
each pointing at a `Debug-<flavor>`/`Release-<flavor>`/`Profile-<flavor>`
build configuration with its own `PRODUCT_BUNDLE_IDENTIFIER` and
`APP_DISPLAY_NAME` (the latter feeds `Info.plist`'s `CFBundleDisplayName` via
Xcode's `$(VAR)` substitution — same mechanism already used for
`PRODUCT_BUNDLE_IDENTIFIER`/`FLUTTER_BUILD_NAME` there). Built with the
`xcodeproj` Ruby gem rather than hand-edited, since duplicating build
configurations and constructing scheme XML by hand is easy to get subtly
wrong. The original unflavored `Runner` scheme is untouched and still builds
(`flutter run -t lib/main.dart`, no `--flavor`) — useful for the simplest
possible signing sanity-check when only one install slot is needed.

For repeatable CI builds, commit non-secret define files such as
`config/development.json`, then use `--dart-define-from-file`. Never place
credentials in a define file: compile-time values can be extracted from an app
binary.

`config/development.json` is committed directly and safe to fill in in place
— dev credentials point at local/throwaway backends. `config/staging.json`
and `config/production.json` are gitignored instead: copy the matching
`.example` file (drop the `.example` suffix) and fill in real values there,
kept local-only even though the values themselves aren't secret — belt and
suspenders against an accidental commit. (There are also empty
`.env.{development,staging,production}` files in the repo root — those aren't
read by anything here; this app is `--dart-define`-only, not dotenv. Safe to
delete, or ignore.)

```sh
flutter run --dart-define-from-file=config/development.json
```

| Key | Required for | Safe to commit once filled in? |
|---|---|---|
| `SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY` | Real auth/data instead of the in-memory demo (see [Demo authentication](#demo-authentication)) | Yes — the publishable key (formerly "anon key") is meant to be client-exposed |
| `FIREBASE_API_KEY_ANDROID`/`_IOS`, `FIREBASE_APP_ID_ANDROID`/`_IOS`, `FIREBASE_MESSAGING_SENDER_ID`, `FIREBASE_PROJECT_ID` | Push notifications (see [Adding Firebase](#adding-firebase)) | Yes — same as `google-services.json`/`GoogleService-Info.plist`, not secret |

`apiKey`/`appId` are split by platform because Firebase issues different values for the Android app registration vs. the iOS one under the same project — `messagingSenderId`/`projectId` are shared, so those stay single keys. `AppConfig.firebaseApiKey`/`firebaseAppId` pick the right one for the running platform automatically.

Both are optional — the app runs fine with either or both left empty, falling back to in-memory data and no push respectively. See `.test_folder/supabase-setup-guide.md` for actually standing up the Supabase project these keys point to.

## Demo authentication

Without `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY` set, `authRepositoryProvider`
and `reportRepositoryProvider` fall back to `InMemoryAuthRepository`/
`InMemoryReportRepository`, so the app runs without backend credentials. Sign
in with any syntactically valid email and a password of at least eight
characters.

With both Supabase keys set, the same providers switch to
`SupabaseAuthRepository`/`SupabaseReportRepository` (real email/password
auth, real Postgres-backed reports) automatically — see
`.test_folder/supabase-setup-guide.md` for standing up the project schema
these expect. A few things that real path doesn't do yet: guest report
submission (FR-1.1 — see the repository's class doc), sign-up (only sign-in
is wired), and role-based access beyond tenant isolation.

To point at a different backend entirely:

1. Implement `AuthRepository`/`ReportRepository` in the feature data layer.
2. Convert vendor-specific errors to domain exceptions.
3. Add the switch to `authRepositoryProvider`/`reportRepositoryProvider`
   (same pattern the Supabase branch already follows).
4. Test the adapter separately against an emulator or test environment.

This keeps screens, controllers, and routing independent of Firebase,
Supabase, or a custom API.

## Structure

```text
lib/
├── app/
│   ├── config/       # Typed compile-time configuration
│   ├── router/       # Routes, redirects, lifecycle
│   ├── theme/        # Material themes
│   └── app.dart
├── features/
│   ├── auth/
│   │   ├── data/     # Repository implementations and providers
│   │   ├── domain/   # Vendor-independent entities/contracts
│   │   └── presentation/
│   ├── home/
│   ├── incident_reporting/
│   └── notifications/
│       └── data/     # Firebase Cloud Messaging + local-notification display
├── bootstrap.dart    # Process initialization and top-level errors
└── main_*.dart       # Environment entry points
```

Feature rules:

- Presentation may depend on domain and providers.
- Data implements domain contracts.
- Domain does not import Flutter, Riverpod, Firebase, or UI packages.
- Cross-feature dependencies go through an explicit contract or provider.
- Keep local widget state in widgets; use Riverpod for shared or asynchronous
  application state.

## Adding Firebase

Wired for push notifications only (Firebase Cloud Messaging), deliberately
configured via `FirebaseOptions`/`--dart-define` rather than
`flutterfire configure` + `google-services.json`/`GoogleService-Info.plist` —
keeps Firebase in the same typed, compile-time-config pattern as the rest of
`AppConfig` instead of adding a second, file-based configuration mechanism.
See `lib/app/config/app_config.dart` (`hasFirebase`), `lib/bootstrap.dart`
(guarded `Firebase.initializeApp`), and
`lib/features/notifications/data/push_notification_service.dart` (permission
request, foreground display, notification-tap → go_router deep link).

Both Android (`POST_NOTIFICATIONS` permission) and iOS (`UIBackgroundModes`,
`Runner.entitlements` with `aps-environment`) are wired for this. iOS push
still needs an APNs Authentication Key uploaded to the Firebase console
(requires an Apple Developer account) before delivery actually works — that's
a console-side step, not something a `--dart-define` value can supply.

If you add other Firebase products (Crashlytics, Analytics, Firestore), the
`flutterfire configure` + generated-file approach the Flutter docs describe
is reasonable for those — this project just didn't need it for FCM alone.
Crash reporting should be represented by an application-owned interface, with
the Firebase implementation receiving uncaught errors from `bootstrap.dart`.
This makes error reporting testable and avoids Firebase calls throughout the
UI.

## Release checklist

- [x] Bundle/application identifiers replaced (`com.obserba`) and app display
      name set (`Obserba` / `DEV Obserba`/`STG Obserba` variants).
- Configure Android release signing through local or CI secrets.
- [x] iOS per-flavor schemes/bundle IDs/display names configured (see the iOS
      flavor note under Run) — still needs release-mode code signing set up
      through Xcode/Fastlane before an actual Archive/App Store build.
- Replace the in-memory authentication adapter.
- Set real API URLs and enforce HTTPS for staging and production.
- Add privacy manifests, permissions, and store disclosures for chosen SDKs.
- Run `flutter test --coverage` and platform release builds in CI.
- Enable obfuscation and retain symbols if required by your threat model.

## Deliberate omissions

This starter does not preinstall analytics, notifications, storage,
connectivity banners, HTTP clients, localization, or code generation. Those
choices affect privacy, architecture, and maintenance, and should be added when
a real feature needs them. In particular, network-interface status is not
treated as proof that an API is reachable.
