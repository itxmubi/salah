import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';
import '../models/prayer_schedule_model.dart';
import '../models/prayer_settings_model.dart';

class PrayerLocalDataSource {
  PrayerLocalDataSource(this._preferences);

  static const _settingsKey = 'salah.prayer.settings.v1';
  static const _cachePrefix = 'salah.prayer.schedule.v1';

  final SharedPreferencesAsync _preferences;

  Future<PrayerSettings?> readSettings() async {
    final encoded = await _preferences.getString(_settingsKey);
    if (encoded == null) return null;
    return PrayerSettingsModel.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );
  }

  Future<void> writeSettings(PrayerSettings settings) => _preferences.setString(
    _settingsKey,
    jsonEncode(PrayerSettingsModel.toJson(settings)),
  );

  Future<PrayerSchedule?> readSchedule(String key) async {
    final encoded = await _preferences.getString('$_cachePrefix.$key');
    if (encoded == null) return null;
    return PrayerScheduleModel.fromJson(
      jsonDecode(encoded) as Map<String, Object?>,
    );
  }

  Future<void> writeSchedule(String key, PrayerSchedule schedule) =>
      _preferences.setString(
        '$_cachePrefix.$key',
        jsonEncode(PrayerScheduleModel.toJson(schedule)),
      );
}
