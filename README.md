# Salah

Salah is a Flutter app for local prayer times, Qibla direction, and related Islamic utilities. It currently targets Android and iOS.

## Features

- **Home:** Daily prayer overview, next-prayer countdown, sunrise and sunset, and Hijri date when the calendar service is available.
- **Prayer:** Daily and monthly timetables, with the current local date highlighted. Prayer calculations support multiple methods, Standard or Hanafi Asr, event time adjustments, and 12- or 24-hour display.
- **Location:** Use the device location or search for a city; save places locally to switch between them.
- **Qibla:** Kaaba bearing and distance, with a live compass when the device has a heading sensor and a bearing-only fallback otherwise.
- **Settings:** Shortcuts to prayer, location, prayer alert, and appearance controls. Theme mode and accent color are saved on the device.
- **Prayer alerts:** Choose which prayers may send alerts. Alert scheduling and Azan audio are not implemented yet.

The Quran tab and Quran reading features are not currently included. Quran, translation, and recitation content will require an appropriate source and license before integration.

## Getting started

Install the Flutter SDK, then run:

```sh
flutter pub get
flutter run
```

Run static analysis with `flutter analyze` and the project tests with `flutter test`.

## Localization

English strings are in `lib/l10n/arb/app_en.arb`. After editing ARB files or adding a locale, regenerate the localization classes with `flutter gen-l10n`.

## Architecture

The app uses a feature-first Clean Architecture layout. Features live under `lib/features/<feature>/` and can contain `data`, `domain`, and `presentation` layers. Shared functionality belongs in `lib/core/`.

Riverpod handles state and dependency wiring. GoRouter owns the four-tab navigation shell (Home, Prayer, Qibla, Settings) and the supporting Location and Prayer Alerts routes.

```text
lib/
  app/       app root and routing
  core/      shared errors, theme, utilities, widgets, and services
  features/  calendar, home, location, notifications, prayer, qibla, settings
  l10n/      English source strings and generated localization classes
```
