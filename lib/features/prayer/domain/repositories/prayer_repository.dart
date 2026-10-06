import '../../../../core/utils/result.dart';
import '../../../location/domain/entities/saved_location.dart';
import '../entities/prayer_schedule.dart';
import '../entities/prayer_settings.dart';

abstract interface class PrayerRepository {
  Future<Result<PrayerSettings>> loadSettings();

  Future<Result<void>> saveSettings(PrayerSettings settings);

  Future<Result<PrayerOverview>> loadToday(
    SavedLocation location,
    PrayerSettings settings,
  );

  Future<Result<List<PrayerSchedule>>> loadMonth(
    SavedLocation location,
    PrayerSettings settings,
    DateTime month,
  );
}
