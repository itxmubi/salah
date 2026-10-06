import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/aladhan_prayer_data_source.dart';
import '../../data/datasources/prayer_calculation_data_source.dart';
import '../../data/datasources/prayer_local_data_source.dart';
import '../../data/repositories/prayer_repository_impl.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../../domain/usecases/prayer_use_cases.dart';

final prayerPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final prayerCalculationDataSourceProvider =
    Provider<PrayerCalculationDataSource>(
      (ref) => PrayerCalculationDataSource(),
    );

final aladhanPrayerDataSourceProvider = Provider<AladhanPrayerDataSource>((
  ref,
) {
  final source = AladhanPrayerDataSource();
  ref.onDispose(source.close);
  return source;
});

final prayerLocalDataSourceProvider = Provider<PrayerLocalDataSource>(
  (ref) => PrayerLocalDataSource(ref.watch(prayerPreferencesProvider)),
);

final prayerRepositoryProvider = Provider<PrayerRepository>(
  (ref) => PrayerRepositoryImpl(
    calculation: ref.watch(prayerCalculationDataSourceProvider),
    aladhan: ref.watch(aladhanPrayerDataSourceProvider),
    local: ref.watch(prayerLocalDataSourceProvider),
  ),
);

final loadPrayerSettingsProvider = Provider<LoadPrayerSettings>(
  (ref) => LoadPrayerSettings(ref.watch(prayerRepositoryProvider)),
);

final savePrayerSettingsProvider = Provider<SavePrayerSettings>(
  (ref) => SavePrayerSettings(ref.watch(prayerRepositoryProvider)),
);

final loadTodayPrayerTimesProvider = Provider<LoadTodayPrayerTimes>(
  (ref) => LoadTodayPrayerTimes(ref.watch(prayerRepositoryProvider)),
);

final loadMonthlyPrayerTimesProvider = Provider<LoadMonthlyPrayerTimes>(
  (ref) => LoadMonthlyPrayerTimes(ref.watch(prayerRepositoryProvider)),
);
