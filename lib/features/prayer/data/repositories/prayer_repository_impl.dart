import 'dart:convert';

import '../../../../core/utils/result.dart' as core;
import '../../../location/domain/entities/saved_location.dart';
import '../../domain/entities/prayer_issue.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/aladhan_prayer_data_source.dart';
import '../datasources/prayer_calculation_data_source.dart';
import '../datasources/prayer_local_data_source.dart';

class PrayerRepositoryImpl implements PrayerRepository {
  const PrayerRepositoryImpl({
    required PrayerCalculationDataSource calculation,
    required AladhanPrayerDataSource aladhan,
    required PrayerLocalDataSource local,
  }) : _calculation = calculation,
       _aladhan = aladhan,
       _local = local;

  final PrayerCalculationDataSource _calculation;
  final AladhanPrayerDataSource _aladhan;
  final PrayerLocalDataSource _local;

  @override
  Future<core.Result<PrayerSettings>> loadSettings() async {
    try {
      return core.Success(
        await _local.readSettings() ?? const PrayerSettings(),
      );
    } on FormatException {
      return const core.Error(PrayerIssue.storageFailed);
    } catch (_) {
      return const core.Error(PrayerIssue.storageFailed);
    }
  }

  @override
  Future<core.Result<void>> saveSettings(PrayerSettings settings) async {
    try {
      await _local.writeSettings(settings);
      return const core.Success(null);
    } catch (_) {
      return const core.Error(PrayerIssue.storageFailed);
    }
  }

  @override
  Future<core.Result<PrayerOverview>> loadToday(
    SavedLocation location,
    PrayerSettings settings,
  ) async {
    try {
      final today = await _schedule(location, settings);
      final now = DateTime.now().toUtc();
      final prayers = today.events.where((event) => event.isObligatoryPrayer);
      PrayerEvent? nextPrayer;
      PrayerEvent? currentPrayer;
      for (final event in prayers) {
        if (event.timeUtc.isAfter(now)) {
          nextPrayer = event;
          break;
        }
        currentPrayer = event;
      }

      if (nextPrayer == null) {
        final tomorrow = await _schedule(
          location,
          settings,
          today.localDate.add(const Duration(days: 1)),
        );
        nextPrayer = tomorrow.event(PrayerName.fajr);
      }
      if (currentPrayer == null) {
        final yesterday = await _schedule(
          location,
          settings,
          today.localDate.subtract(const Duration(days: 1)),
        );
        currentPrayer = yesterday.event(PrayerName.isha);
      }
      return core.Success(
        PrayerOverview(
          today: today,
          currentPrayer: currentPrayer,
          nextPrayer: nextPrayer,
        ),
      );
    } on PrayerCalculationIssue catch (error) {
      return core.Error(error.issue);
    } catch (_) {
      return const core.Error(PrayerIssue.calculationFailed);
    }
  }

  @override
  Future<core.Result<List<PrayerSchedule>>> loadMonth(
    SavedLocation location,
    PrayerSettings settings,
    DateTime month,
  ) async {
    try {
      final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
      final cachedSchedules = <PrayerSchedule?>[];
      for (var day = 1; day <= daysInMonth; day++) {
        cachedSchedules.add(
          await _readCached(
            location,
            settings,
            DateTime(month.year, month.month, day),
          ),
        );
      }
      if (cachedSchedules.every((schedule) => schedule != null)) {
        return core.Success(cachedSchedules.cast<PrayerSchedule>());
      }

      try {
        final remoteSchedules = await _aladhan.fetchCalendar(
          location,
          settings,
          month,
          _calculation.timezoneId(location),
        );
        for (final schedule in remoteSchedules) {
          await _writeCached(location, settings, schedule.localDate, schedule);
        }
        return core.Success(remoteSchedules);
      } catch (_) {
        // Retain locally calculated timings when the service is unavailable.
      }

      final schedules = <PrayerSchedule>[];
      for (var day = 1; day <= daysInMonth; day++) {
        final date = DateTime(month.year, month.month, day);
        schedules.add(
          cachedSchedules[day - 1] ??
              _calculation.calculate(location, settings, date: date),
        );
      }
      return core.Success(schedules);
    } on PrayerCalculationIssue catch (error) {
      return core.Error(error.issue);
    } catch (_) {
      return const core.Error(PrayerIssue.calculationFailed);
    }
  }

  Future<PrayerSchedule> _schedule(
    SavedLocation location,
    PrayerSettings settings, [
    DateTime? date,
  ]) async {
    final localDate = date ?? _calculation.currentLocalDate(location);
    final cached = await _readCached(location, settings, localDate);
    if (cached != null) return cached;

    try {
      final schedule = await _aladhan.fetchTimings(
        location,
        settings,
        localDate,
        _calculation.timezoneId(location),
      );
      await _writeCached(location, settings, localDate, schedule);
      return schedule;
    } catch (_) {
      return _calculation.calculate(location, settings, date: localDate);
    }
  }

  Future<PrayerSchedule?> _readCached(
    SavedLocation location,
    PrayerSettings settings,
    DateTime date,
  ) => _local.readSchedule(_cacheKey(location, settings, date));

  Future<void> _writeCached(
    SavedLocation location,
    PrayerSettings settings,
    DateTime date,
    PrayerSchedule schedule,
  ) => _local.writeSchedule(_cacheKey(location, settings, date), schedule);

  String _cacheKey(
    SavedLocation location,
    PrayerSettings settings,
    DateTime date,
  ) {
    final day =
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final cacheIdentity = [
      'aladhan-v1',
      location.id,
      location.latitude.toStringAsFixed(5),
      location.longitude.toStringAsFixed(5),
      _calculation.timezoneId(location),
      settings.cacheKey,
      day,
    ].join('|');
    return base64Url.encode(utf8.encode(cacheIdentity));
  }
}
