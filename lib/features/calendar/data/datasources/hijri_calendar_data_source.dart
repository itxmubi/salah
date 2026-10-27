import '../../domain/entities/hijri_date.dart';
import '../../domain/services/hijri_calendar_engine.dart';

class HijriCalendarDataSource {
  const HijriCalendarDataSource({
    HijriCalendarEngine engine = const HijriCalendarEngine(),
  }) : _engine = engine;
  final HijriCalendarEngine _engine;
  Future<HijriDate> convertGregorianDate(DateTime date) async =>
      _engine.fromGregorian(date);
}
