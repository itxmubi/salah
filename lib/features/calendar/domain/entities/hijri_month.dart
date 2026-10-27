import 'hijri_date.dart';

class HijriMonthId {
  const HijriMonthId(this.year, this.month);
  final int year;
  final int month;
  HijriMonthId get previous =>
      month == 1 ? HijriMonthId(year - 1, 12) : HijriMonthId(year, month - 1);
  HijriMonthId get next =>
      month == 12 ? HijriMonthId(year + 1, 1) : HijriMonthId(year, month + 1);
  @override
  bool operator ==(Object other) =>
      other is HijriMonthId && year == other.year && month == other.month;
  @override
  int get hashCode => Object.hash(year, month);
}

enum IslamicOccasion {
  newYear,
  ashura,
  ramadan,
  eidFitr,
  arafah,
  eidAdha,
  tashriq,
}

class HijriCalendarDay {
  const HijriCalendarDay({
    required this.hijri,
    required this.gregorian,
    this.occasion,
  });
  final HijriDate hijri;
  final DateTime gregorian;
  final IslamicOccasion? occasion;
}

class HijriMonthData {
  const HijriMonthData({required this.id, required this.days});
  final HijriMonthId id;
  final List<HijriCalendarDay> days;
  int get leadingDays => days.first.gregorian.weekday % 7;
}
