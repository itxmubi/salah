# Salah

A Flutter application foundation for prayer times, Quran reading, Qibla, and related Islamic utilities.

## Getting started

Install the Flutter SDK, then run:

```sh
flutter pub get
flutter run
```

Run static analysis with `flutter analyze`. Run the project test suite with `flutter test`.

## Localization

English strings are in `lib/l10n/arb/app_en.arb`. After editing ARB files or adding a locale, regenerate the localization classes with `flutter gen-l10n`.

## Architecture

The app uses a feature-first Clean Architecture layout. Each feature can contain `data`, `domain`, and `presentation` layers under `lib/features/<feature>/`. Shared functionality belongs in `lib/core/`. Domain repository contracts and use cases should not depend on Flutter widgets, APIs, or storage packages.

Riverpod is used for state and dependency wiring. GoRouter owns application routes. App-wide dependencies should be exposed as providers and injected into feature providers; avoid a second service locator.

```text
lib/
  app/       app root and routing
  core/      shared error, theme, utilities, widgets, and services
  features/  independent feature-first modules
```

## Platform setup

Android and iOS are the initial mobile targets. Platform-specific permissions and minimum OS versions should be added alongside the feature that needs them and documented before release. Do not add external religious content until its source and licensing are confirmed; see [salah_docs.md](salah_docs.md).

## Project plan

See [salah_docs.md](salah_docs.md) for architecture, product scope, technical decisions, and phased delivery status.
For a concise snapshot of current decisions and the next steps, see [PROJECT_MEMORY.md](PROJECT_MEMORY.md).
