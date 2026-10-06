enum PrayerIssue {
  noLocation,
  timezoneUnavailable,
  calculationFailed,
  storageFailed,
}

class PrayerCalculationIssue implements Exception {
  const PrayerCalculationIssue(this.issue);

  final PrayerIssue issue;
}
