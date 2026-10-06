import '../../../../core/utils/result.dart';
import '../entities/hijri_date.dart';

abstract interface class HijriCalendarRepository {
  Future<Result<HijriDate>> hijriDateFor(DateTime gregorianDate);
}
