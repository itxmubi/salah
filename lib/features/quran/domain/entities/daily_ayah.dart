import 'surah.dart';

class DailyAyah {
  const DailyAyah({required this.ayah, required this.surah});
  final QuranAyah ayah;
  final Surah surah;
}

/// A civil date determines the verse, independent of rebuilds and restarts.
int dailyAyahNumber(DateTime date) =>
    DateTime.utc(
          date.year,
          date.month,
          date.day,
        ).difference(DateTime.utc(2000, 1, 1)).inDays %
        6236 +
    1;
