import '../../domain/entities/prayer_settings.dart';

class PrayerSettingsModel {
  const PrayerSettingsModel._();

  static PrayerSettings fromJson(Map<String, Object?> json) {
    final offsets = <PrayerName, int>{};
    final rawAdjustments = json['adjustments'];
    if (rawAdjustments is Map<String, Object?>) {
      for (final prayer in PrayerName.values) {
        final value = rawAdjustments[prayer.name];
        if (value is num) offsets[prayer] = value.toInt().clamp(-30, 30);
      }
    }
    return PrayerSettings(
      method: PrayerCalculationMethod.values.firstWhere(
        (method) => method.name == json['method'],
        orElse: () => PrayerCalculationMethod.muslimWorldLeague,
      ),
      madhab: PrayerMadhab.values.firstWhere(
        (madhab) => madhab.name == json['madhab'],
        orElse: () => PrayerMadhab.standard,
      ),
      adjustments: offsets,
      use24HourFormat: json['use24HourFormat'] as bool? ?? false,
    );
  }

  static Map<String, Object?> toJson(PrayerSettings settings) => {
    'method': settings.method.name,
    'madhab': settings.madhab.name,
    'use24HourFormat': settings.use24HourFormat,
    'adjustments': {
      for (final entry in settings.adjustments.entries)
        entry.key.name: entry.value,
    },
  };
}
