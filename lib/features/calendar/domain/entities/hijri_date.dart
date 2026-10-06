class HijriDate {
  const HijriDate({
    required this.day,
    required this.monthName,
    required this.year,
    this.holiday,
  });

  final String day;
  final String monthName;
  final String year;
  final String? holiday;
}
