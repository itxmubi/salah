import '../../../../core/error/app_failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/hijri_date.dart';
import '../../domain/repositories/hijri_calendar_repository.dart';
import '../datasources/hijri_calendar_data_source.dart';

class HijriCalendarRepositoryImpl implements HijriCalendarRepository {
  const HijriCalendarRepositoryImpl(this._dataSource);

  final HijriCalendarDataSource _dataSource;

  @override
  Future<Result<HijriDate>> hijriDateFor(DateTime gregorianDate) async {
    try {
      return Success(await _dataSource.convertGregorianDate(gregorianDate));
    } catch (_) {
      return const Error(NetworkFailure());
    }
  }
}
