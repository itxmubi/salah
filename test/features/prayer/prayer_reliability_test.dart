import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salah/core/utils/result.dart';
import 'package:salah/features/location/domain/entities/saved_location.dart';
import 'package:salah/features/location/presentation/providers/location_controller.dart';
import 'package:salah/features/prayer/data/datasources/aladhan_prayer_data_source.dart';
import 'package:salah/features/prayer/data/datasources/prayer_calculation_data_source.dart';
import 'package:salah/features/prayer/data/datasources/prayer_local_data_source.dart';
import 'package:salah/features/prayer/data/repositories/prayer_repository_impl.dart';
import 'package:salah/features/prayer/domain/entities/prayer_issue.dart';
import 'package:salah/features/prayer/domain/entities/prayer_schedule.dart';
import 'package:salah/features/prayer/domain/entities/prayer_settings.dart';
import 'package:salah/features/prayer/domain/repositories/prayer_repository.dart';
import 'package:salah/features/prayer/presentation/providers/prayer_controller.dart';
import 'package:salah/features/prayer/presentation/providers/prayer_providers.dart';

const dubai = SavedLocation(
  id: 'dubai',
  city: 'Dubai',
  region: '',
  country: 'UAE',
  latitude: 25.2048,
  longitude: 55.2708,
);
final now = DateTime.utc(2026, 10, 27, 12);
final calculation = PrayerCalculationDataSource(now: () => now);
PrayerSchedule day(DateTime date) =>
    calculation.calculate(dubai, const PrayerSettings(), date: date);
final overview = PrayerOverview(
  today: day(now),
  currentPrayer: null,
  nextPrayer: day(now).event(PrayerName.isha),
);
Map<String, dynamic> apiDay() => {
  'timings': {
    'Fajr': '05:01',
    'Sunrise': '06:02',
    'Dhuhr': '12:03',
    'Asr': '15:04',
    'Sunset': '17:05',
    'Maghrib': '17:05',
    'Isha': '18:06',
  },
  'meta': {'timezone': 'Asia/Dubai'},
};

class BrokenCache extends PrayerLocalDataSource {
  BrokenCache() : super(SharedPreferencesAsync());
  bool brokenRead = true;
  @override
  Future<PrayerSchedule?> readSchedule(String key) async {
    if (brokenRead) throw const FormatException('Damaged JSON');
    return null;
  }

  @override
  Future<void> writeSchedule(String key, PrayerSchedule schedule) async =>
      throw StateError('Disk full');
}

class ControlledRepository implements PrayerRepository {
  final requests = <int, Completer<Result<List<PrayerSchedule>>>>{};
  bool failSave = false;
  bool throwToday = false;
  int todayLoads = 0;
  @override
  Future<Result<PrayerSettings>> loadSettings() async =>
      const Success(PrayerSettings());
  @override
  Future<Result<void>> saveSettings(PrayerSettings settings) async =>
      failSave ? const Error(PrayerIssue.storageFailed) : const Success(null);
  @override
  Future<Result<PrayerOverview>> loadToday(
    SavedLocation location,
    PrayerSettings settings,
  ) async {
    todayLoads++;
    if (throwToday) throw StateError('Transient startup failure');
    return Success(overview);
  }

  @override
  Future<Result<List<PrayerSchedule>>> loadMonth(
    SavedLocation location,
    PrayerSettings settings,
    DateTime month,
  ) {
    final completer = Completer<Result<List<PrayerSchedule>>>();
    requests[month.month] = completer;
    return completer.future;
  }
}

void main() {
  test('Monthly API accepts array data and preserves remote timings', () async {
    final source = AladhanPrayerDataSource(
      client: MockClient((request) async {
        expect(request.url.path, contains('calendarByCity/2026/10'));
        return http.Response(
          jsonEncode({'code': 200, 'data': List.generate(31, (_) => apiDay())}),
          200,
        );
      }),
    );
    final result = await source.fetchCalendar(
      dubai,
      const PrayerSettings(),
      DateTime(2026, 10),
      calculation.timezoneId(dubai),
    );
    expect(result, hasLength(31));
    expect(result.first.event(PrayerName.fajr).localHour, 5);
    expect(result.first.source, PrayerScheduleSource.aladhan);
    source.close();
  });

  test('Damaged cache and no network still allow local prayer times', () async {
    final remote = AladhanPrayerDataSource(
      client: MockClient((_) async => http.Response('Offline', 503)),
    );
    final repository = PrayerRepositoryImpl(
      calculation: calculation,
      aladhan: remote,
      local: BrokenCache(),
      now: () => now,
    );
    final result = await repository.loadToday(dubai, const PrayerSettings());
    expect(result, isA<Success<PrayerOverview>>());
    expect(
      (result as Success<PrayerOverview>).value.today.source,
      PrayerScheduleSource.local,
    );
    remote.close();
  });

  test('Storage write failures preserve successful remote timings', () async {
    final cache = BrokenCache()..brokenRead = false;
    final remote = AladhanPrayerDataSource(
      client: MockClient(
        (_) async =>
            http.Response(jsonEncode({'code': 200, 'data': apiDay()}), 200),
      ),
    );
    final repository = PrayerRepositoryImpl(
      calculation: calculation,
      aladhan: remote,
      local: cache,
      now: () => now,
    );
    final result = await repository.loadToday(dubai, const PrayerSettings());
    expect(
      (result as Success<PrayerOverview>).value.today.source,
      PrayerScheduleSource.aladhan,
    );
    remote.close();
  });

  test(
    'After Isha next prayer belongs to tomorrow; before Fajr current is yesterday Isha',
    () async {
      final remote = AladhanPrayerDataSource(
        client: MockClient((_) async => http.Response('offline', 503)),
      );
      for (final time in [
        DateTime.utc(2026, 10, 27, 20),
        DateTime.utc(2026, 10, 27, 0),
      ]) {
        final source = PrayerCalculationDataSource(now: () => time);
        final repository = PrayerRepositoryImpl(
          calculation: source,
          aladhan: remote,
          local: BrokenCache(),
          now: () => time,
        );
        final result =
            (await repository.loadToday(dubai, const PrayerSettings())
                    as Success<PrayerOverview>)
                .value;
        expect(result.nextPrayer.prayer, PrayerName.fajr);
        expect(result.nextPrayer.timeUtc.isAfter(time), isTrue);
        expect(result.currentPrayer!.prayer, PrayerName.isha);
        expect(result.currentPrayer!.timeUtc.isBefore(time), isTrue);
      }
      remote.close();
    },
  );

  test('Local date follows selected timezone rather than device date', () {
    final source = PrayerCalculationDataSource(
      now: () => DateTime.utc(2026, 12, 31, 21),
    );
    expect(source.currentLocalDate(dubai), DateTime.utc(2027, 1, 1));
    const newYork = SavedLocation(
      id: 'ny',
      city: 'NY',
      region: '',
      country: 'US',
      latitude: 40.7128,
      longitude: -74.006,
    );
    expect(source.currentLocalDate(newYork), DateTime.utc(2026, 12, 31));
    final adjusted = source.calculate(
      dubai,
      const PrayerSettings(adjustments: {PrayerName.fajr: 7}),
      date: now,
    );
    expect(
      adjusted
          .event(PrayerName.fajr)
          .timeUtc
          .difference(day(now).event(PrayerName.fajr).timeUtc),
      const Duration(minutes: 7),
    );
  });

  late ControlledRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = ControlledRepository();
    container = ProviderContainer(
      overrides: [
        activeLocationProvider.overrideWith((ref) => dubai),
        prayerRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });
  tearDown(() => container.dispose());

  test('Older month response cannot overwrite latest selection', () async {
    await container.read(prayerControllerProvider.future);
    final controller = container.read(prayerControllerProvider.notifier);
    final october = controller.loadMonth(DateTime(2026, 10));
    final november = controller.loadMonth(DateTime(2026, 11));
    repository.requests[11]!.complete(Success([day(DateTime(2026, 11, 1))]));
    await november;
    repository.requests[10]!.complete(Success([day(DateTime(2026, 10, 1))]));
    await october;
    final state = container.read(prayerControllerProvider).requireValue;
    expect(state.selectedMonth!.month, 11);
    expect(state.monthSchedules.single.localDate.month, 11);
    await controller.refreshOverview();
    expect(
      container
          .read(prayerControllerProvider)
          .requireValue
          .selectedMonth!
          .month,
      11,
    );
  });

  test('Retry rebuilds a provider after startup exception', () async {
    repository.throwToday = true;
    await expectLater(
      container.read(prayerControllerProvider.future),
      throwsStateError,
    );
    repository.throwToday = false;
    await container.read(prayerControllerProvider.notifier).refreshOverview();
    expect(
      (await container.read(prayerControllerProvider.future)).overview,
      isNotNull,
    );
  });

  test('Failed preference write rolls back calculation settings', () async {
    await container.read(prayerControllerProvider.future);
    repository.failSave = true;
    await container
        .read(prayerControllerProvider.notifier)
        .updateSettings(
          const PrayerSettings(method: PrayerCalculationMethod.dubai),
        );
    final state = container.read(prayerControllerProvider).requireValue;
    expect(state.settings.method, PrayerCalculationMethod.muslimWorldLeague);
    expect(state.issue, PrayerIssue.storageFailed);
  });
}
