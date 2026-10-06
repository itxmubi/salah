enum PrayerCalculationMethod {
  muslimWorldLeague,
  egyptian,
  karachi,
  ummAlQura,
  dubai,
  qatar,
  kuwait,
  moonsightingCommittee,
  singapore,
  turkiye,
  tehran,
  northAmerica,
  morocco,
}

enum PrayerMadhab { standard, hanafi }

enum PrayerName { fajr, sunrise, dhuhr, asr, maghrib, sunset, isha }

class PrayerSettings {
  const PrayerSettings({
    this.method = PrayerCalculationMethod.muslimWorldLeague,
    this.madhab = PrayerMadhab.standard,
    this.adjustments = const {},
    this.use24HourFormat = false,
  });

  final PrayerCalculationMethod method;
  final PrayerMadhab madhab;
  final Map<PrayerName, int> adjustments;
  final bool use24HourFormat;

  PrayerSettings copyWith({
    PrayerCalculationMethod? method,
    PrayerMadhab? madhab,
    Map<PrayerName, int>? adjustments,
    bool? use24HourFormat,
  }) => PrayerSettings(
    method: method ?? this.method,
    madhab: madhab ?? this.madhab,
    adjustments: adjustments ?? this.adjustments,
    use24HourFormat: use24HourFormat ?? this.use24HourFormat,
  );

  String get cacheKey {
    final offsets = PrayerName.values
        .map((prayer) => '${prayer.name}:${adjustments[prayer] ?? 0}')
        .join(',');
    return '${method.name}-${madhab.name}-$offsets';
  }
}
