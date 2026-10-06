import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../data/datasources/hijri_calendar_data_source.dart';
import '../../data/repositories/hijri_calendar_repository_impl.dart';
import '../../domain/entities/hijri_date.dart';
import '../../domain/repositories/hijri_calendar_repository.dart';
import '../../domain/usecases/load_hijri_date.dart';

final hijriHttpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final hijriCalendarDataSourceProvider = Provider<HijriCalendarDataSource>(
  (ref) => HijriCalendarDataSource(client: ref.watch(hijriHttpClientProvider)),
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
