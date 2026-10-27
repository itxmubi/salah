class HijriDate {
  const HijriDate({
    required this.day,
    required this.monthName,
    required this.year,
    this.holiday,
    this.monthNumber,
    this.arabicMonthName,
  });

  final String day;
  final String monthName;
  final String year;
  final String? holiday;
  final int? monthNumber;
  final String? arabicMonthName;

  String localizedMonth(String language) =>
      language == 'ar' ? arabicMonthName ?? monthName : monthName;
}
