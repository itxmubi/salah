// Run: flutter test tool/screenshots/capture_test.dart
// This capture harness is outside test/ so normal flutter test does not run it.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:salah/app/app_router.dart';
import 'package:salah/core/theme/app_theme.dart';
import 'package:salah/l10n/generated/app_localizations.dart';
import 'package:salah/core/settings/app_settings.dart';
import 'package:salah/features/calendar/presentation/providers/hijri_calendar_providers.dart';
import 'package:salah/features/location/presentation/providers/location_controller.dart';
import 'package:salah/features/notifications/presentation/providers/notification_providers.dart';
import 'package:salah/features/prayer/presentation/providers/prayer_controller.dart';
import 'package:salah/features/qibla/presentation/providers/qibla_providers.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/quran/presentation/providers/quran_reader_preferences.dart';

import 'fixtures.dart';

Future<void> loadCaptureFonts() async {
  final configFile = File('.dart_tool/package_config.json').absolute;
  final config =
      jsonDecode(await configFile.readAsString()) as Map<String, dynamic>;
  final flutter = (config['packages'] as List)
      .cast<Map<String, dynamic>>()
      .singleWhere((p) => p['name'] == 'flutter');
  final flutterPackage = configFile.uri.resolve(flutter['rootUri'] as String);
  final sdk = Directory.fromUri(flutterPackage).parent.parent;
  for (final entry in {
    'Roboto': ['Roboto-Regular.ttf', 'Roboto-Bold.ttf'],
    'MaterialIcons': ['MaterialIcons-Regular.otf'],
  }.entries) {
    final loader = FontLoader(entry.key);
    for (final filename in entry.value) {
      final data = await File(
        '${sdk.path}/bin/cache/artifacts/material_fonts/$filename',
      ).readAsBytes();
      loader.addFont(Future.value(ByteData.sublistView(data)));
    }
    await loader.load();
  }
  await (FontLoader('AmiriQuran')..addFont(
        rootBundle.load('assets/fonts/amiri_quran/AmiriQuran-Regular.ttf'),
      ))
      .load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadCaptureFonts);
  testWidgets('Capture the README gallery from the real app screens', (
    tester,
  ) async {
    final oldBanner = WidgetsApp.debugAllowBannerOverride;
    WidgetsApp.debugAllowBannerOverride = false;
    addTearDown(() => WidgetsApp.debugAllowBannerOverride = oldBanner);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.runAsync(
      () => Directory('docs/screenshots').create(recursive: true),
    );

    const pages = {
      'home': '/',
      'prayer': '/prayer',
      'quran-library': '/quran',
      'quran-reader': '/quran/surah/1',
      'qibla': '/qibla',
      'settings': '/settings',
      'calculation-settings': '/settings/calculation',
      'hijri-calendar': '/calendar',
      'prayer-alerts': '/notifications',
    };
    for (final entry in pages.entries) {
      debugPrint('Capturing ${entry.key}.png');
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      final boundaryKey = GlobalKey();
      final router = createAppRouter();
      final container = ProviderContainer(
        overrides: [
          appSettingsProvider.overrideWith(ScreenshotSettings.new),
          prayerControllerProvider.overrideWith(ScreenshotPrayer.new),
          locationControllerProvider.overrideWith(ScreenshotLocation.new),
          calendarDateReaderProvider.overrideWithValue(() => sampleDate),
          calendarTodayProvider.overrideWith((ref) => Stream.value(sampleDate)),
          notificationSyncProvider.overrideWith(
            (ref) async =>
                AlertStatus(count: 60, until: DateTime.utc(2026, 11, 7, 15)),
          ),
          alertPreferencesProvider.overrideWith(ScreenshotAlerts.new),
          // A missing sensor shows the app's real north-bearing fallback.
          compassHeadingProvider.overrideWith((ref) => Stream.value(null)),
          dailyAyahProvider.overrideWith((ref, date) async => dailyVerse),
          dailyAyahTranslationProvider.overrideWith(
            (ref, number) async => 'For indeed, with hardship comes ease.',
          ),
          quranDownloadProvider.overrideWith(ScreenshotDownload.new),
          quranReaderPreferencesProvider.overrideWith(
            ScreenshotReaderSettings.new,
          ),
          surahListProvider.overrideWith((ref) async => directory),
          quranBismillahProvider.overrideWith((ref) async => bismillah),
          surahReadingProvider.overrideWith(
            (ref, number) async => fatihaReading,
          ),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: RepaintBoundary(
            key: boundaryKey,
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              // Headless Flutter has no platform Arabic fallback. Use the bundled
              // font to reproduce readable Arabic without changing app widgets.
              theme: AppTheme.light().copyWith(
                textTheme: AppTheme.light().textTheme.apply(
                  fontFamilyFallback: const ['AmiriQuran'],
                ),
              ),
              locale: const Locale('en'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      if (entry.key == 'hijri-calendar') {
        // Navigate like the actual Home calendar action, then browse Ramadan.
        await tester.tap(find.byTooltip('Islamic calendar'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Choose month and year'));
        await tester.pumpAndSettle();
        await tester.tap(find.byType(DropdownButtonFormField<int>).first);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Ramadan').last);
        await tester.tap(find.text('Ramadan').last);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Show month'));
        await tester.pumpAndSettle();
      } else if (entry.key == 'prayer-alerts') {
        await tester.tap(find.byTooltip('Prayer alerts'));
        await tester.pumpAndSettle();
      } else if (entry.value != '/') {
        router.go(entry.value);
        await tester.pumpAndSettle();
      }
      expect(
        tester.takeException(),
        isNull,
        reason: 'Layout failed for ${entry.key}',
      );
      await tester.runAsync(() async {
        final boundary =
            boundaryKey.currentContext!.findRenderObject()!
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          'docs/screenshots/${entry.key}.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      container.dispose();
      router.dispose();
    }
  });
}
