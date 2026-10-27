# Screenshot gallery

The PNGs in this directory are captured from the actual Flutter widgets and router. They use local presentation fixtures, rather than live APIs or device sensors.

- All images use a 430 × 932 logical viewport at 2× resolution (860 × 1864 PNGs), English, the light theme, and the forest accent.
- The sample city is Dubai and the example date is 27 October 2026. The calendar browses Ramadan 1448 to show its dates and occasion marker.
- Prayer times are calculated by the app's local calculation source. The Home countdown represents an illustrative 14:30 Dubai snapshot, with UTC instants rebased during capture.
- The daily ayah fixture is Ash-Sharh 94:5. The reader shows Al-Fatiha, and the library uses a presentation directory fixture.
- Download readiness, bookmarks, and scheduled reminder counts are illustrative states. The capture creates no real downloads or notifications.
- Qibla uses the real bearing calculation with no compass sensor, so it displays the north-bearing fallback and Kaaba marker.
- The debug banner is hidden. Operating-system status bars and permission prompts are not part of the widget captures.

From the repository root, with the Flutter SDK installed:

```sh
flutter pub get
flutter test --no-pub tool/screenshots/capture_test.dart
```

The harness loads Roboto and Material Icons from the installed Flutter SDK and the bundled Amiri Quran font from the app. It adds Amiri Quran as a text fallback in the capture theme because the headless renderer does not have the phone’s system Arabic fonts. The screens, layout, and router come from the app. It overwrites the nine gallery PNGs. Its fixtures live in [fixtures.dart](../../tool/screenshots/fixtures.dart), and the capture code is [capture_test.dart](../../tool/screenshots/capture_test.dart).

| File | Content |
| --- | --- |
| `home.png` | Next prayer, Hijri date, and Ayah of the Day |
| `hijri-calendar.png` | Month grid, Gregorian dates, and Islamic occasion |
| `prayer.png` | Monthly prayer timetable |
| `qibla.png` | Kaaba marker and bearing fallback |
| `quran-library.png` | Offline status, progress, bookmarks, and reading modes |
| `quran-reader.png` | Arabic reader and reading controls |
| `settings.png` | Language, location, calendar, and appearance controls |
| `calculation-settings.png` | Dedicated prayer calculation controls |
| `prayer-alerts.png` | Illustrative reminder status and prayer switches |
