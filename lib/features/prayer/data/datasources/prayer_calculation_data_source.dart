import 'package:adhan_dart/adhan_dart.dart' as adhan;
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as timezone_map;
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import '../../../location/domain/entities/saved_location.dart';
import '../../domain/entities/prayer_issue.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';
import '../models/prayer_schedule_model.dart';

class PrayerCalculationDataSource {
  static bool _timeZonesInitialized = false;

  String timezoneId(SavedLocation location) {
    _ensureTimeZones();
    return timezone_map.latLngToTimezoneString(
      location.latitude,
      location.longitude,
    );
  }

  DateTime currentLocalDate(SavedLocation location) {
    final zone = _zone(location);
    final now = timezone.TZDateTime.from(DateTime.now().toUtc(), zone);
    return DateTime.utc(now.year, now.month, now.day);
  }

  PrayerSchedule calculate(
    SavedLocation location,
    PrayerSettings settings, {
    DateTime? date,
  }) {
    final timezoneId = this.timezoneId(location);
    final zone = _zone(location);

    final requestedDate = date == null
        ? timezone.TZDateTime.now(zone)
        : timezone.TZDateTime(zone, date.year, date.month, date.day);
    final localDate = timezone.TZDateTime(
      zone,
      requestedDate.year,
      requestedDate.month,
      requestedDate.day,
    );
    final coordinates = adhan.Coordinates(
      location.latitude,
      location.longitude,
    );
    final parameters = _parameters(settings, coordinates);
    final calculated = adhan.PrayerTimes(
      coordinates: coordinates,
      date: localDate,
      calculationParameters: parameters,
      precision: true,
    );
    final entries = <(PrayerName, DateTime)>[
      (PrayerName.fajr, calculated.fajr),
      (PrayerName.sunrise, calculated.sunrise),
      (PrayerName.dhuhr, calculated.dhuhr),
      (PrayerName.asr, calculated.asr),
      (PrayerName.sunset, calculated.sunset),
      (PrayerName.maghrib, calculated.maghrib),
      (PrayerName.isha, calculated.isha),
    ];
    final events = entries
        .map((entry) {
          final localTime = timezone.TZDateTime.from(entry.$2, zone);
          return PrayerEvent(
            prayer: entry.$1,
            timeUtc: entry.$2.toUtc(),
            localHour: localTime.hour,
            localMinute: localTime.minute,
          );
        })
        .toList(growable: false);

    return PrayerScheduleModel.fromJson({
      'locationId': location.id,
      'locationName': location.city,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'localDate': _dateKey(localDate),
      'timeZoneId': timezoneId,
      'events': [
        for (final event in events)
          {
            'prayer': event.prayer.name,
            'timeUtc': event.timeUtc.millisecondsSinceEpoch,
            'localHour': event.localHour,
            'localMinute': event.localMinute,
          },
      ],
    });
  }

  timezone.Location _zone(SavedLocation location) {
    _ensureTimeZones();
    final id = timezone_map.latLngToTimezoneString(
      location.latitude,
      location.longitude,
    );
    final zone = timezone.timeZoneDatabase.locations[id];
    if (zone == null) {
      throw const PrayerCalculationIssue(PrayerIssue.timezoneUnavailable);
    }
    return zone;
  }

  void _ensureTimeZones() {
    if (_timeZonesInitialized) return;
    timezone_data.initializeTimeZones();
    _timeZonesInitialized = true;
  }

  adhan.CalculationParameters _parameters(
    PrayerSettings settings,
    adhan.Coordinates coordinates,
  ) {
    final parameters = switch (settings.method) {
      PrayerCalculationMethod.muslimWorldLeague =>
        adhan.CalculationMethodParameters.muslimWorldLeague(),
      PrayerCalculationMethod.egyptian =>
        adhan.CalculationMethodParameters.egyptian(),
      PrayerCalculationMethod.karachi =>
        adhan.CalculationMethodParameters.karachi(),
      PrayerCalculationMethod.ummAlQura =>
        adhan.CalculationMethodParameters.ummAlQura(),
      PrayerCalculationMethod.dubai =>
        adhan.CalculationMethodParameters.dubai(),
      PrayerCalculationMethod.qatar =>
        adhan.CalculationMethodParameters.qatar(),
      PrayerCalculationMethod.kuwait =>
        adhan.CalculationMethodParameters.kuwait(),
      PrayerCalculationMethod.moonsightingCommittee =>
        adhan.CalculationMethodParameters.moonsightingCommittee(),
      PrayerCalculationMethod.singapore =>
        adhan.CalculationMethodParameters.singapore(),
      PrayerCalculationMethod.turkiye =>
        adhan.CalculationMethodParameters.turkiye(),
      PrayerCalculationMethod.tehran =>
        adhan.CalculationMethodParameters.tehran(),
      PrayerCalculationMethod.northAmerica =>
        adhan.CalculationMethodParameters.northAmerica(),
      PrayerCalculationMethod.morocco =>
        adhan.CalculationMethodParameters.morocco(),
    };
    parameters.madhab = settings.madhab == PrayerMadhab.hanafi
        ? adhan.Madhab.hanafi
        : adhan.Madhab.shafi;
    parameters.highLatitudeRule = adhan.HighLatitudeRule.recommended(
      coordinates,
    );
    final adjustments = <adhan.Prayer, int>{};
    for (final entry in settings.adjustments.entries) {
      final prayer = _adhanPrayer(entry.key);
      if (prayer != null) adjustments[prayer] = entry.value;
    }
    parameters.adjustments = adjustments;
    return parameters;
  }

  adhan.Prayer? _adhanPrayer(PrayerName prayer) => switch (prayer) {
    PrayerName.fajr => adhan.Prayer.fajr,
    PrayerName.sunrise => adhan.Prayer.sunrise,
    PrayerName.dhuhr => adhan.Prayer.dhuhr,
    PrayerName.asr => adhan.Prayer.asr,
    PrayerName.maghrib => adhan.Prayer.maghrib,
    PrayerName.isha => adhan.Prayer.isha,
    PrayerName.sunset => null,
  };

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
