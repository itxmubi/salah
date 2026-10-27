// Synthetic presentation fixtures only. No network, GPS, or notifications run.
import 'package:salah/core/settings/app_settings.dart';
import 'package:salah/features/location/domain/entities/location_snapshot.dart';
import 'package:salah/features/location/domain/entities/saved_location.dart';
import 'package:salah/features/location/presentation/providers/location_controller.dart';
import 'package:salah/features/notifications/presentation/providers/notification_providers.dart';
import 'package:salah/features/prayer/data/datasources/prayer_calculation_data_source.dart';
import 'package:salah/features/prayer/domain/entities/prayer_schedule.dart';
import 'package:salah/features/prayer/domain/entities/prayer_settings.dart';
import 'package:salah/features/prayer/presentation/providers/prayer_controller.dart';
import 'package:salah/features/quran/domain/entities/daily_ayah.dart';
import 'package:salah/features/quran/domain/entities/surah.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/quran/presentation/providers/quran_reader_preferences.dart';

final sampleDate = DateTime.utc(2026, 10, 27);
const sampleLocation = SavedLocation(
  id: 'dubai',
  city: 'Dubai',
  region: 'Dubai',
  country: 'United Arab Emirates',
  latitude: 25.2048,
  longitude: 55.2708,
);
const sampleSettings = PrayerSettings(method: PrayerCalculationMethod.dubai);
const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
const fatiha = Surah(
  number: 1,
  name: 'سُورَةُ ٱلْفَاتِحَةِ',
  englishName: 'Al-Faatiha',
  translation: 'The Opening',
  ayahCount: 7,
  revelationType: 'Meccan',
);
const fatihaText = [
  bismillah,
  'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
  'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
  'مَٰلِكِ يَوْمِ ٱلدِّينِ',
  'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
  'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
  'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ',
];
final fatihaReading = SurahReading(
  surah: fatiha,
  ayahs: [
    for (var i = 0; i < fatihaText.length; i++)
      QuranAyah(
        numberInSurah: i + 1,
        globalNumber: i + 1,
        text: fatihaText[i],
        page: 1,
        juz: 1,
        surahNumber: 1,
        surahName: 'Al-Faatiha',
      ),
  ],
);
const dailyVerse = DailyAyah(
  ayah: QuranAyah(
    numberInSurah: 5,
    text: 'فَإِنَّ مَعَ ٱلْعُسْرِ يُسْرًا',
    surahNumber: 94,
    page: 596,
    juz: 30,
  ),
  surah: Surah(
    number: 94,
    name: 'سُورَةُ ٱلشَّرْحِ',
    englishName: 'Ash-Sharh',
    translation: 'Relief',
    ayahCount: 8,
    revelationType: 'Meccan',
  ),
);
// Only these real directory entries are visible in the library capture. Remaining
// rows preserve the directory count and are deliberately never scrolled into view.
final directory = <Surah>[
  fatiha,
  const Surah(
    number: 2,
    name: 'سُورَةُ ٱلْبَقَرَةِ',
    englishName: 'Al-Baqara',
    translation: 'The Cow',
    ayahCount: 286,
    revelationType: 'Medinan',
  ),
  const Surah(
    number: 3,
    name: 'سُورَةُ آلِ عِمْرَانَ',
    englishName: 'Aal-i-Imraan',
    translation: 'The Family of Imran',
    ayahCount: 200,
    revelationType: 'Medinan',
  ),
  for (var i = 4; i <= 114; i++)
    Surah(
      number: i,
      name: '',
      englishName: 'Surah $i',
      translation: '',
      ayahCount: 1,
      revelationType: '',
    ),
];

class ScreenshotPrayer extends PrayerController {
  @override
  Future<PrayerState> build() async {
    final calculation = PrayerCalculationDataSource();
    final days = [
      for (var day = 1; day <= 31; day++)
        calculation.calculate(
          sampleLocation,
          sampleSettings,
          date: DateTime.utc(2026, 10, day),
        ),
    ];
    final original = days[26];
    // Display the sample day at 14:30 Dubai time, with a running countdown.
    // This rebases only UTC instants, keeping the shown local timetable intact.
    final delta = DateTime.now().toUtc().difference(
      DateTime.utc(2026, 10, 27, 10, 30),
    );
    final today = PrayerSchedule(
      locationId: original.locationId,
      locationName: original.locationName,
      latitude: original.latitude,
      longitude: original.longitude,
      localDate: original.localDate,
      timeZoneId: original.timeZoneId,
      source: original.source,
      events: original.events
          .map(
            (event) => PrayerEvent(
              prayer: event.prayer,
              timeUtc: event.timeUtc.add(delta),
              localHour: event.localHour,
              localMinute: event.localMinute,
            ),
          )
          .toList(),
    );
    return PrayerState(
      settings: sampleSettings,
      selectedMonth: DateTime(2026, 10),
      monthSchedules: days,
      overview: PrayerOverview(
        today: today,
        currentPrayer: today.event(PrayerName.dhuhr),
        nextPrayer: today.event(PrayerName.asr),
      ),
    );
  }

  @override
  Future<void> refreshOverview() async {}
  @override
  Future<void> loadMonth([DateTime? month]) async {}
}

class ScreenshotLocation extends LocationController {
  @override
  Future<LocationState> build() async => const LocationState(
    snapshot: LocationSnapshot(
      activeLocation: sampleLocation,
      savedLocations: [sampleLocation],
    ),
  );
}

class ScreenshotSettings extends AppSettingsController {
  @override
  Future<AppSettings> build() async =>
      const AppSettings(language: 'en', setupComplete: true);
}

class ScreenshotDownload extends QuranDownloadController {
  @override
  Future<bool> build() async => true;
}

class ScreenshotReaderSettings extends QuranReaderPreferencesController {
  @override
  Future<QuranReaderPreferences> build() async => const QuranReaderPreferences(
    last: ReadingPosition(kind: 'page', number: 1),
    bookmarks: [ReadingPosition(kind: 'surah', number: 94, surah: 94, ayah: 5)],
  );
  @override
  Future<void> remember(
    ReadingPosition position, {
    bool makeCurrent = true,
  }) async {}
}

class ScreenshotAlerts extends AlertPreferencesController {
  @override
  Future<Set<PrayerName>> build() async => {
    PrayerName.fajr,
    PrayerName.dhuhr,
    PrayerName.asr,
    PrayerName.maghrib,
    PrayerName.isha,
  };
}
