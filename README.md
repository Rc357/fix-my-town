# Aninag Citizen

Project Aninag's Citizen app — report an incident, track it, confirm
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

Android flavors:

```sh
flutter run \
  --flavor development \
  -t lib/main_development.dart \
  --dart-define=APP_FLAVOR=development \
  --dart-define=API_BASE_URL=http://10.0.2.2:8080

flutter run \
  --flavor staging \
  -t lib/main_staging.dart \
  --dart-define=APP_FLAVOR=staging \
  --dart-define=API_BASE_URL=https://staging-api.example.com

flutter run \
  --flavor production \
  -t lib/main_production.dart \
  --dart-define=APP_FLAVOR=production \
  --dart-define=API_BASE_URL=https://api.example.com
```

For iOS, the Dart entry points and defines work immediately:

```sh
flutter run -t lib/main_development.dart \
  --dart-define=APP_FLAVOR=development
```

Create Xcode configurations and shared schemes before passing `--flavor` on
iOS. Keep platform signing and identifiers owned by Xcode rather than editing
opaque project IDs with a script.

For repeatable CI builds, commit non-secret define files such as
`config/development.json`, then use `--dart-define-from-file`. Never place
credentials in a define file: compile-time values can be extracted from an app
binary.

## Demo authentication

The starter uses `InMemoryAuthRepository`, so it runs without backend
credentials. Sign in with any syntactically valid email and a password of at
least eight characters.

For a real app:

1. Implement `AuthRepository` in the feature data layer.
2. Convert vendor-specific errors to domain exceptions.
3. Override `authRepositoryProvider` at the application composition root.
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
│   └── home/
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

Install only the Firebase products actually used, run `flutterfire configure`,
and initialize Firebase in a small adapter called from `bootstrap`. Do not
commit generated service credential files unless your organization explicitly
permits it. The `.gitignore` excludes them by default.

Crash reporting should be represented by an application-owned interface, with
the Firebase implementation receiving uncaught errors from `bootstrap.dart`.
This makes error reporting testable and avoids Firebase calls throughout the
UI.

## Release checklist

- [x] Bundle/application identifiers replaced (`com.aninag.citizen`) and app
      display name set (`Aninag Citizen` / `DEV`/`STG` variants).
- Configure Android release signing through local or CI secrets.
- Configure iOS schemes, bundle IDs, signing, and display names per flavor —
  the identifier above is set app-wide; per-flavor iOS schemes/configurations
  still need to be created in Xcode (see the iOS flavor note under Run).
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
