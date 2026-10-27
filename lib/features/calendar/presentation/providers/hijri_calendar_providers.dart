import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../location/presentation/providers/location_controller.dart';
import '../../../prayer/presentation/providers/prayer_providers.dart';
import '../../data/datasources/hijri_calendar_data_source.dart';
import '../../data/repositories/hijri_calendar_repository_impl.dart';
import '../../domain/entities/hijri_date.dart';
import '../../domain/entities/hijri_month.dart';
import '../../domain/repositories/hijri_calendar_repository.dart';
import '../../domain/services/hijri_calendar_engine.dart';
import '../../domain/usecases/load_hijri_date.dart';

final hijriCalendarEngineProvider = Provider<HijriCalendarEngine>(
  (ref) => const HijriCalendarEngine(),
);
final hijriCalendarDataSourceProvider = Provider<HijriCalendarDataSource>(
  (ref) =>
      HijriCalendarDataSource(engine: ref.watch(hijriCalendarEngineProvider)),
);
final hijriCalendarRepositoryProvider = Provider<HijriCalendarRepository>(
  (ref) =>
      HijriCalendarRepositoryImpl(ref.watch(hijriCalendarDataSourceProvider)),
);
final loadHijriDateProvider = Provider<LoadHijriDate>(
  (ref) => LoadHijriDate(ref.watch(hijriCalendarRepositoryProvider)),
);
final hijriDateProvider = FutureProvider.autoDispose
    .family<HijriDate?, DateTime>((ref, date) async {
      final result = await ref.watch(loadHijriDateProvider)(date);
      return result.fold(success: (value) => value, failure: (_) => null);
    });
final hijriMonthProvider = Provider.autoDispose
    .family<HijriMonthData, HijriMonthId>(
      (ref, id) => ref.watch(hijriCalendarEngineProvider).month(id),
    );

/// Refresh on resume and each minute so Home's daily content rolls over even
/// before Fajr. A selected city uses its timezone; otherwise use the device date.
final calendarDateReaderProvider = Provider<DateTime Function()>((ref) {
  final location = ref.watch(activeLocationProvider);
  final calculation = ref.watch(prayerCalculationDataSourceProvider);
  return () {
    if (location != null) return calculation.currentLocalDate(location);
    final now = DateTime.now();
    return DateTime.utc(now.year, now.month, now.day);
  };
});

final calendarTodayProvider = StreamProvider.autoDispose<DateTime>((ref) {
  final today = ref.watch(calendarDateReaderProvider);
  final stream = StreamController<DateTime>();
  DateTime? previous;
  void emit() {
    final value = today();
    if (value != previous) {
      previous = value;
      stream.add(value);
    }
  }

  emit();
  final timer = Timer.periodic(const Duration(minutes: 1), (_) => emit());
  ref.onDispose(() {
    timer.cancel();
    stream.close();
  });
  return stream.stream;
});
