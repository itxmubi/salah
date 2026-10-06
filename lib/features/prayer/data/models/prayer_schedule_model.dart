import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';

class PrayerScheduleModel {
  const PrayerScheduleModel._();

  static PrayerSchedule fromJson(Map<String, Object?> json) => PrayerSchedule(
    locationId: json['locationId']! as String,
    locationName: json['locationName']! as String,
    latitude: (json['latitude']! as num).toDouble(),
    longitude: (json['longitude']! as num).toDouble(),
    localDate: DateTime.parse(json['localDate']! as String),
    timeZoneId: json['timeZoneId']! as String,
    events: (json['events']! as List<Object?>)
        .map((item) {
          final event = item! as Map<String, Object?>;
          return PrayerEvent(
            prayer: PrayerName.values.byName(event['prayer']! as String),
            timeUtc: DateTime.fromMillisecondsSinceEpoch(
              event['timeUtc']! as int,
              isUtc: true,
            ),
            localHour: event['localHour']! as int,
            localMinute: event['localMinute']! as int,
          );
        })
        .toList(growable: false),
  );

  static Map<String, Object?> toJson(PrayerSchedule schedule) => {
    'locationId': schedule.locationId,
    'locationName': schedule.locationName,
    'latitude': schedule.latitude,
    'longitude': schedule.longitude,
    'localDate': _dateKey(schedule.localDate),
    'timeZoneId': schedule.timeZoneId,
    'events': [
      for (final event in schedule.events)
        {
          'prayer': event.prayer.name,
          'timeUtc': event.timeUtc.millisecondsSinceEpoch,
          'localHour': event.localHour,
          'localMinute': event.localMinute,
        },
    ],
  };

  static String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }
}
