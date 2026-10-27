import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salah/core/settings/app_settings.dart';
import 'package:salah/features/calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:salah/features/prayer/presentation/screens/calculation_settings_screen.dart';
import 'package:salah/features/quran/domain/entities/daily_ayah.dart';
import 'package:salah/core/theme/app_theme.dart';
import 'package:salah/core/widgets/setup_guide.dart';
import 'package:salah/features/home/presentation/screens/home_screen.dart';
import 'package:salah/features/location/domain/entities/location_snapshot.dart';
import 'package:salah/features/location/domain/entities/saved_location.dart';
import 'package:salah/features/location/presentation/providers/location_controller.dart';
import 'package:salah/features/location/presentation/screens/location_screen.dart';
import 'package:salah/features/notifications/presentation/providers/notification_providers.dart';
import 'package:salah/features/notifications/presentation/screens/notification_settings_screen.dart';
import 'package:salah/features/prayer/data/datasources/prayer_calculation_data_source.dart';
import 'package:salah/features/prayer/domain/entities/prayer_schedule.dart';
import 'package:salah/features/prayer/domain/entities/prayer_settings.dart';
import 'package:salah/features/prayer/presentation/providers/prayer_controller.dart';
import 'package:salah/features/prayer/presentation/screens/prayer_times_screen.dart';
import 'package:salah/features/qibla/presentation/providers/qibla_providers.dart';
import 'package:salah/features/qibla/presentation/screens/qibla_screen.dart';
import 'package:salah/features/quran/domain/entities/surah.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/quran/presentation/screens/quran_library_screen.dart';
import 'package:salah/features/quran/presentation/screens/quran_page_reader_screen.dart';
import 'package:salah/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:salah/features/settings/presentation/screens/settings_screen.dart';
import 'package:salah/l10n/generated/app_localizations.dart';
import 'package:salah/features/calendar/presentation/providers/hijri_calendar_providers.dart';

const location = SavedLocation(
  id: 'dubai',
  city: 'Dubai',
  region: '',
  country: 'UAE',
  latitude: 25.2048,
  longitude: 55.2708,
);

class FixturePrayer extends PrayerController {
  @override
  Future<PrayerState> build() async {
    final calculation = PrayerCalculationDataSource();
    final date = calculation.currentLocalDate(location);
    final today = calculation.calculate(
      location,
      const PrayerSettings(),
      date: date,
    );
    return PrayerState(
      overview: PrayerOverview(
        today: today,
        currentPrayer: today.event(PrayerName.dhuhr),
        nextPrayer: today.event(PrayerName.asr),
      ),
      selectedMonth: date,
      monthSchedules: [today],
    );
  }
}

class FixtureLocation extends LocationController {
  @override
  Future<LocationState> build() async => const LocationState(
    snapshot: LocationSnapshot(
      activeLocation: location,
      savedLocations: [location],
    ),
  );
}

class FixtureAppSettings extends AppSettingsController {
  @override
  Future<AppSettings> build() async => const AppSettings(setupComplete: true);
}

class FixtureDownload extends QuranDownloadController {
  @override
  Future<bool> build() async => true;
}

class FixtureAlerts extends AlertPreferencesController {
  @override
  Future<Set<PrayerName>> build() async => {};
}

void main() {
  final screens = <String, Widget>{
    'home': const HomeScreen(),
    'hijri calendar': const HijriCalendarScreen(),
    'calculation screen': const CalculationSettingsScreen(),
    'prayer': const PrayerTimesScreen(),
    'location': const LocationScreen(),
    'qibla': const QiblaScreen(),
    'settings': const SettingsScreen(),
    'setup': const Scaffold(body: SetupGuide()),
    'alerts': const NotificationSettingsScreen(),
    'quran pages': const QuranPageReaderScreen(),
    'surah reader': const SurahReaderScreen(number: 1),
    'quran library': const QuranLibraryScreen(),
    'calculation settings': Scaffold(
      body: PrayerSettingsSheet(
        settings: const PrayerSettings(),
        onChanged: (_) {},
      ),
    ),
  };
  for (final language in ['en', 'ar']) {
    for (final size in [const Size(320, 700), const Size(700, 320)]) {
      for (final screen in screens.entries) {
        testWidgets('${screen.key}: $language $size supports large text', (
          tester,
        ) async {
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.view.resetPhysicalSize);
          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                prayerControllerProvider.overrideWith(FixturePrayer.new),
                locationControllerProvider.overrideWith(FixtureLocation.new),
                appSettingsProvider.overrideWith(FixtureAppSettings.new),
                quranDownloadProvider.overrideWith(FixtureDownload.new),
                alertPreferencesProvider.overrideWith(FixtureAlerts.new),
                notificationSyncProvider.overrideWith(
                  (ref) async => const AlertStatus(),
                ),
                compassHeadingProvider.overrideWith((ref) => Stream.value(0)),
                calendarDateReaderProvider.overrideWithValue(
                  () => DateTime.utc(2026, 10, 27),
                ),
                calendarTodayProvider.overrideWith(
                  (ref) => Stream.value(DateTime.utc(2026, 10, 27)),
                ),
                dailyAyahProvider.overrideWith(
                  (ref, date) async => const DailyAyah(
                    ayah: QuranAyah(
                      numberInSurah: 5,
                      text: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
                      surahNumber: 94,
                    ),
                    surah: Surah(
                      number: 94,
                      name: 'الشرح',
                      englishName: 'Ash-Sharh',
                      translation: 'Relief',
                      ayahCount: 8,
                      revelationType: 'Meccan',
                    ),
                  ),
                ),
                dailyAyahTranslationProvider.overrideWith(
                  (ref, number) async =>
                      'For indeed, with hardship comes ease.',
                ),
                hijriDateProvider.overrideWith((ref, date) async => null),
                surahListProvider.overrideWith(
                  (ref) async => [
                    const Surah(
                      number: 1,
                      name: 'سُورَةُ الْفَاتِحَةِ',
                      englishName: 'Al-Faatiha',
                      translation: 'The Opening',
                      ayahCount: 7,
                      revelationType: 'Meccan',
                    ),
                  ],
                ),
                surahReadingProvider.overrideWith(
                  (ref, number) async => const SurahReading(
                    surah: Surah(
                      number: 1,
                      name: 'الفاتحة',
                      englishName: 'Al-Faatiha',
                      translation: 'The Opening',
                      ayahCount: 1,
                      revelationType: 'Meccan',
                    ),
                    ayahs: [
                      QuranAyah(
                        numberInSurah: 1,
                        text: 'بسم الله الرحمن الرحيم',
                        page: 1,
                        surahNumber: 1,
                      ),
                    ],
                  ),
                ),
                pageReadingProvider.overrideWith(
                  (ref, number) async => const QuranReadingData(
                    surahs: [],
                    ayahs: [
                      QuranAyah(
                        numberInSurah: 1,
                        text: 'بسم الله الرحمن الرحيم',
                        page: 1,
                        surahNumber: 1,
                      ),
                    ],
                  ),
                ),
                quranBismillahProvider.overrideWith(
                  (ref) async => 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                ),
              ],
              child: MaterialApp(
                theme: AppTheme.light(),
                locale: Locale(language),
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(2)),
                  child: child!,
                ),
                home: screen.value,
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(
            Directionality.of(tester.element(find.byType(Scaffold).first)),
            language == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }
}
