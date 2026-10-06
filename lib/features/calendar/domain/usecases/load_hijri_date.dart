import '../../../../core/utils/result.dart';
import '../entities/hijri_date.dart';
import '../repositories/hijri_calendar_repository.dart';

class LoadHijriDate {
  const LoadHijriDate(this._repository);

  final HijriCalendarRepository _repository;

  Future<Result<HijriDate>> call(DateTime gregorianDate) =>
      _repository.hijriDateFor(gregorianDate);
}
