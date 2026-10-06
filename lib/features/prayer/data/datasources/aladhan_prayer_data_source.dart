import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as timezone;

import '../../../../core/network/api_constants.dart';
import '../../../location/domain/entities/saved_location.dart';
import '../../domain/entities/prayer_issue.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';

class AladhanPrayerDataSource {
  AladhanPrayerDataSource({
    http.Client? client,
    this.baseUrl = ApiConstants.aladhanBaseUrl,
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  void close() => _client.close();

  static const _methodIds = <PrayerCalculationMethod, int>{
    PrayerCalculationMethod.muslimWorldLeague: 3,
    PrayerCalculationMethod.egyptian: 5,
    PrayerCalculationMethod.karachi: 1,
    PrayerCalculationMethod.ummAlQura: 4,
    PrayerCalculationMethod.dubai: 16,
    PrayerCalculationMethod.qatar: 10,
    PrayerCalculationMethod.kuwait: 9,
    PrayerCalculationMethod.moonsightingCommittee: 15,
    PrayerCalculationMethod.singapore: 11,
    PrayerCalculationMethod.turkiye: 13,
    PrayerCalculationMethod.tehran: 7,
    PrayerCalculationMethod.northAmerica: 2,
    PrayerCalculationMethod.morocco: 21,
  };

  Future<PrayerSchedule> fetchTimings(
    SavedLocation location,
    PrayerSettings settings,
    DateTime date,
    String fallbackTimezone,
  ) async {
    final path = _timingsPath(location, date);
    final query = _query(location, settings, fallbackTimezone);
    final response = await _get(path, query);
    return _scheduleFromData(
      response,
      location,
      settings,
      date,
      fallbackTimezone,
    );
  }

  Future<List<PrayerSchedule>> fetchCalendar(
    SavedLocation location,
    PrayerSettings settings,
    DateTime month,
    String fallbackTimezone,
  ) async {
    final date = DateTime(month.year, month.month, 1);
    final path = _calendarPath(location, date);
    final query = _query(location, settings, fallbackTimezone);
    final response = await _get(path, query);
    final rawDays = response['data'];
    if (rawDays is! List) throw const _AladhanException();
    final schedules = <PrayerSchedule>[];
    for (var index = 0; index < rawDays.length; index++) {
      final item = rawDays[index];
      if (item is! Map<String, dynamic>) throw const _AladhanException();
      final itemDate = DateTime(month.year, month.month, index + 1);
      schedules.add(
        _scheduleFromData(item, location, settings, itemDate, fallbackTimezone),
      );
    }
    if (schedules.isEmpty) throw const _AladhanException();
    return schedules;
  }

  String _timingsPath(SavedLocation location, DateTime date) {
    final formatted = DateFormat('dd-MM-yyyy').format(date);
    if (location.isDeviceLocation) {
      return '/timings/$formatted';
    }
    if (location.city.trim().isNotEmpty && location.country.trim().isNotEmpty) {
      return '/timingsByCity/$formatted';
    }
    return '/timingsByAddress/$formatted';
  }

  String _calendarPath(SavedLocation location, DateTime date) {
    final year = date.year;
    final month = date.month;
    if (location.isDeviceLocation) {
      return '/calendar/$year/$month';
    }
    if (location.city.trim().isNotEmpty && location.country.trim().isNotEmpty) {
      return '/calendarByCity/$year/$month';
    }
    return '/calendarByAddress/$year/$month';
  }

  Map<String, String> _query(
    SavedLocation location,
    PrayerSettings settings,
    String timeZoneId,
  ) => {
    if (location.isDeviceLocation ||
        (location.city.trim().isEmpty &&
            location.country.trim().isEmpty &&
            location.region.trim().isEmpty))
      'latitude': location.latitude.toString(),
    if (location.isDeviceLocation ||
        (location.city.trim().isEmpty &&
            location.country.trim().isEmpty &&
            location.region.trim().isEmpty))
      'longitude': location.longitude.toString(),
    if (!location.isDeviceLocation &&
        location.city.trim().isNotEmpty &&
        location.country.trim().isNotEmpty)
      'city': location.city,
    if (!location.isDeviceLocation &&
        location.city.trim().isNotEmpty &&
        location.country.trim().isNotEmpty)
      'country': location.country,
    if (!location.isDeviceLocation &&
        location.city.trim().isNotEmpty &&
        location.country.trim().isNotEmpty &&
        location.region.trim().isNotEmpty)
      'state': location.region,
    if (!location.isDeviceLocation &&
        (location.city.trim().isEmpty || location.country.trim().isEmpty))
      'address': [
        location.city,
        location.region,
        location.country,
      ].where((part) => part.trim().isNotEmpty).join(', '),
    'method': '${_methodIds[settings.method] ?? 3}',
    'school': settings.madhab == PrayerMadhab.hanafi ? '1' : '0',
    'timezonestring': timeZoneId,
    if (location.latitude.abs() >= 48) 'latitudeAdjustmentMethod': '3',
  };

  Future<Map<String, dynamic>> _get(
    String path,
    Map<String, String> query,
  ) async {
    final base = Uri.parse(baseUrl);
    final uri = Uri.https(base.authority, '${base.path}$path', query);
    try {
      final response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const _AladhanException();
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['code'] != 200) {
        throw const _AladhanException();
      }
      final data = decoded['data'];
      if (data is! Map<String, dynamic>) throw const _AladhanException();
      return data;
    } on _AladhanException {
      rethrow;
    } catch (_) {
      throw const _AladhanException();
    }
  }

  PrayerSchedule _scheduleFromData(
    Map<String, dynamic> data,
    SavedLocation location,
    PrayerSettings settings,
    DateTime date,
    String fallbackTimezone,
  ) {
    final rawTimings = data['timings'];
    final rawMeta = data['meta'];
    if (rawTimings is! Map<String, dynamic>) {
      throw const _AladhanException();
    }
    final meta = rawMeta is Map<String, dynamic> ? rawMeta : const {};
    final zoneName =
        meta['timezone'] is String && (meta['timezone'] as String).isNotEmpty
        ? meta['timezone'] as String
        : fallbackTimezone;
    final zone = timezone.timeZoneDatabase.locations[zoneName];
    if (zone == null) {
      throw const PrayerCalculationIssue(PrayerIssue.timezoneUnavailable);
    }
    final localDate = timezone.TZDateTime(
      zone,
      date.year,
      date.month,
      date.day,
    );
    final rawNames = <PrayerName, String>{
      PrayerName.fajr: 'Fajr',
      PrayerName.sunrise: 'Sunrise',
      PrayerName.dhuhr: 'Dhuhr',
      PrayerName.asr: 'Asr',
      PrayerName.maghrib: 'Maghrib',
      PrayerName.sunset: 'Sunset',
      PrayerName.isha: 'Isha',
    };
    final events = <PrayerEvent>[];
    for (final entry in rawNames.entries) {
      final value = rawTimings[entry.value];
      if (value is! String) throw const _AladhanException();
      final time = value.split(RegExp(r'\s+')).first;
      final pieces = time.split(':');
      if (pieces.length < 2) throw const _AladhanException();
      final adjustment = settings.adjustments[entry.key] ?? 0;
      final localTime = timezone.TZDateTime(
        zone,
        localDate.year,
        localDate.month,
        localDate.day,
        int.parse(pieces[0]),
        int.parse(pieces[1]),
      ).add(Duration(minutes: adjustment));
      events.add(
        PrayerEvent(
          prayer: entry.key,
          timeUtc: localTime.toUtc(),
          localHour: localTime.hour,
          localMinute: localTime.minute,
        ),
      );
    }
    return PrayerSchedule(
      locationId: location.id,
      locationName: location.city,
      latitude: location.latitude,
      longitude: location.longitude,
      localDate: DateTime.utc(date.year, date.month, date.day),
      timeZoneId: zoneName,
      events: events,
    );
  }
}

class _AladhanException implements Exception {
  const _AladhanException();
}
