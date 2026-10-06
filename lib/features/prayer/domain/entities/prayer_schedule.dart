import 'prayer_settings.dart';

class PrayerEvent {
  const PrayerEvent({
    required this.prayer,
    required this.timeUtc,
    required this.localHour,
    required this.localMinute,
  });

  final PrayerName prayer;
  final DateTime timeUtc;
  final int localHour;
  final int localMinute;

  bool get isObligatoryPrayer =>
      prayer != PrayerName.sunrise && prayer != PrayerName.sunset;
}

class PrayerSchedule {
  const PrayerSchedule({
    required this.locationId,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.localDate,
    required this.timeZoneId,
    required this.events,
  });

  final String locationId;
  final String locationName;
  final double latitude;
  final double longitude;
  final DateTime localDate;
  final String timeZoneId;
  final List<PrayerEvent> events;

  PrayerEvent event(PrayerName prayer) =>
      events.firstWhere((event) => event.prayer == prayer);
}

class PrayerOverview {
  const PrayerOverview({
    required this.today,
    required this.currentPrayer,
    required this.nextPrayer,
  });

  final PrayerSchedule today;
  final PrayerEvent? currentPrayer;
  final PrayerEvent nextPrayer;
}
