import '../../../../core/utils/result.dart';
import '../../../location/domain/entities/saved_location.dart';
import '../entities/prayer_schedule.dart';
import '../entities/prayer_settings.dart';
import '../repositories/prayer_repository.dart';

class LoadPrayerSettings {
  const LoadPrayerSettings(this._repository);
  final PrayerRepository _repository;

  Future<Result<PrayerSettings>> call() => _repository.loadSettings();
}

class SavePrayerSettings {
  const SavePrayerSettings(this._repository);
  final PrayerRepository _repository;

  Future<Result<void>> call(PrayerSettings settings) =>
      _repository.saveSettings(settings);
}

class LoadTodayPrayerTimes {
  const LoadTodayPrayerTimes(this._repository);
  final PrayerRepository _repository;

  Future<Result<PrayerOverview>> call(
    SavedLocation location,
    PrayerSettings settings,
  ) => _repository.loadToday(location, settings);
}

class LoadMonthlyPrayerTimes {
  const LoadMonthlyPrayerTimes(this._repository);
  final PrayerRepository _repository;

  Future<Result<List<PrayerSchedule>>> call(
    SavedLocation location,
    PrayerSettings settings,
    DateTime month,
  ) => _repository.loadMonth(location, settings, month);
}
