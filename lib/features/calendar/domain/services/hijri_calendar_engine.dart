import 'package:hijri/hijri_calendar.dart' as umm;

import '../entities/hijri_date.dart';
import '../entities/hijri_month.dart';

/// Umm al-Qura table conversion, with civil dates normalized to UTC midnight.
/// No network or location permissions are needed for calendar browsing.
class HijriCalendarEngine {
  const HijriCalendarEngine();
  static const minYear = 1356;
  static const maxYear = 1500;
  static const englishMonths = [
    'Muharram',
    'Safar',
    'Rabi al-Awwal',
    'Rabi al-Thani',
    'Jumada al-Ula',
    'Jumada al-Akhirah',
    'Rajab',
    'Shaban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qadah',
    'Dhu al-Hijjah',
  ];
  static const arabicMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الآخر',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  bool supports(HijriMonthId id) =>
      id.year >= minYear &&
      id.year <= maxYear &&
      id.month >= 1 &&
      id.month <= 12;
  String monthName(int month, String language) =>
      (language == 'ar' ? arabicMonths : englishMonths)[month - 1];

  HijriDate fromGregorian(DateTime date) {
    final converted = umm.HijriCalendar.fromDate(date);
    if (!supports(HijriMonthId(converted.hYear, converted.hMonth))) {
      throw RangeError('Date outside Umm al-Qura table');
    }
    return _date(converted.hYear, converted.hMonth, converted.hDay);
  }

  HijriMonthData month(HijriMonthId id) {
    if (!supports(id)) throw RangeError('Hijri year must be $minYear–$maxYear');
    final calendar = umm.HijriCalendar();
    final length = calendar.getDaysInMonth(id.year, id.month);
    return HijriMonthData(
      id: id,
      days: List.generate(length, (index) {
        final day = index + 1;
        final converted = calendar.hijriToGregorian(id.year, id.month, day);
        return HijriCalendarDay(
          hijri: _date(id.year, id.month, day),
          gregorian: DateTime.utc(
            converted.year,
            converted.month,
            converted.day,
          ),
          occasion: occasionFor(id.month, day),
        );
      }, growable: false),
    );
  }

  HijriDate _date(int year, int month, int day) => HijriDate(
    day: '$day',
    monthName: englishMonths[month - 1],
    arabicMonthName: arabicMonths[month - 1],
    monthNumber: month,
    year: '$year',
  );

  IslamicOccasion? occasionFor(int month, int day) => switch ((month, day)) {
    (1, 1) => IslamicOccasion.newYear,
    (1, 10) => IslamicOccasion.ashura,
    (9, 1) => IslamicOccasion.ramadan,
    (10, 1) => IslamicOccasion.eidFitr,
    (12, 9) => IslamicOccasion.arafah,
    (12, 10) => IslamicOccasion.eidAdha,
    (12, >= 11 && <= 13) => IslamicOccasion.tashriq,
    _ => null,
  };
}
