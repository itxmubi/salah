import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/result.dart' as core;
import '../../../location/presentation/providers/location_controller.dart';
import '../../domain/entities/prayer_issue.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';
import 'prayer_providers.dart';

class PrayerState {
  const PrayerState({
    this.settings = const PrayerSettings(),
    this.overview,
    this.monthSchedules = const [],
    this.selectedMonth,
    this.issue,
    this.isLoadingMonth = false,
  });

  final PrayerSettings settings;
  final PrayerOverview? overview;
  final List<PrayerSchedule> monthSchedules;
  final DateTime? selectedMonth;
  final PrayerIssue? issue;
  final bool isLoadingMonth;

  PrayerState copyWith({
    PrayerSettings? settings,
    PrayerOverview? overview,
    List<PrayerSchedule>? monthSchedules,
    DateTime? selectedMonth,
    PrayerIssue? issue,
    bool clearIssue = false,
    bool? isLoadingMonth,
  }) => PrayerState(
    settings: settings ?? this.settings,
    overview: overview ?? this.overview,
    monthSchedules: monthSchedules ?? this.monthSchedules,
    selectedMonth: selectedMonth ?? this.selectedMonth,
    issue: clearIssue ? null : issue ?? this.issue,
    isLoadingMonth: isLoadingMonth ?? this.isLoadingMonth,
  );
}

class PrayerController extends AsyncNotifier<PrayerState> {
  int _monthRequest = 0;
  int _overviewRequest = 0;
  int _generation = 0;
  int _settingsRequest = 0;
  PrayerSettings _persistedSettings = const PrayerSettings();
  Future<void> _settingsQueue = Future.value();

  @override
  Future<PrayerState> build() async {
    _generation++;
    _monthRequest++;
    _overviewRequest++;
    final location = ref.watch(activeLocationProvider);
    final loadSettings = ref.watch(loadPrayerSettingsProvider);
    final loadToday = ref.watch(loadTodayPrayerTimesProvider);
    final settingsResult = await loadSettings();
    final settings = settingsResult is core.Success<PrayerSettings>
        ? settingsResult.value
        : const PrayerSettings();
    _persistedSettings = settings;
    if (location == null) return PrayerState(settings: settings);

    final overviewResult = await loadToday(location, settings);
    if (overviewResult is core.Success<PrayerOverview>) {
      final overview = overviewResult.value;
      return PrayerState(
        settings: settings,
        overview: overview,
        selectedMonth: DateTime(
          overview.today.localDate.year,
          overview.today.localDate.month,
        ),
      );
    }
    return PrayerState(
      settings: settings,
      issue: _toIssue((overviewResult as core.Error<PrayerOverview>).error),
    );
  }

  Future<void> loadMonth([DateTime? month]) async {
    final current = state.asData?.value;
    final overview = current?.overview;
    final location = ref.read(activeLocationProvider);
    if (current == null || location == null || overview == null) return;
    final request = ++_monthRequest;
    final generation = _generation;
    final selected = month ?? current.selectedMonth ?? overview.today.localDate;
    final normalized = DateTime(selected.year, selected.month);
    _update(
      selectedMonth: normalized,
      isLoadingMonth: true,
      clearIssue: true,
      monthSchedules:
          current.selectedMonth?.year == normalized.year &&
              current.selectedMonth?.month == normalized.month
          ? current.monthSchedules
          : const [],
    );
    final result = await ref.read(loadMonthlyPrayerTimesProvider)(
      location,
      current.settings,
      normalized,
    );
    if (!ref.mounted || request != _monthRequest || generation != _generation) {
      return;
    }
    if (result is core.Success<List<PrayerSchedule>>) {
      _update(monthSchedules: result.value, isLoadingMonth: false);
    } else {
      _update(
        issue: _toIssue((result as core.Error<List<PrayerSchedule>>).error),
        isLoadingMonth: false,
      );
    }
  }

  Future<void> refreshOverview() async {
    final current = state.asData?.value;
    final location = ref.read(activeLocationProvider);
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    if (location == null) return;
    final request = ++_overviewRequest;
    final generation = _generation;
    final result = await ref.read(loadTodayPrayerTimesProvider)(
      location,
      current.settings,
    );
    if (!ref.mounted ||
        request != _overviewRequest ||
        generation != _generation) {
      return;
    }
    if (result is core.Success<PrayerOverview>) {
      final overview = result.value;
      _update(overview: overview, clearIssue: true);
    } else {
      _update(issue: _toIssue((result as core.Error<PrayerOverview>).error));
    }
  }

  Future<void> updateSettings(PrayerSettings settings) async {
    final current = state.asData?.value;
    if (current == null) return;
    final generation = _generation;
    final request = ++_settingsRequest;
    _monthRequest++;
    _overviewRequest++;
    final reloadMonth =
        current.monthSchedules.isNotEmpty || current.isLoadingMonth;
    _update(
      settings: settings,
      monthSchedules: const [],
      isLoadingMonth: reloadMonth,
      clearIssue: true,
    );
    // Keep disk writes in the same order as user edits.
    final saveSettings = ref.read(savePrayerSettingsProvider);
    final save = _settingsQueue
        .catchError((Object _) {})
        .then((_) => saveSettings(settings));
    _settingsQueue = save.then((_) {});
    final saved = await save;
    if (!ref.mounted) return;
    if (saved is core.Success<void>) _persistedSettings = settings;
    if (request != _settingsRequest) return;
    if (generation != _generation) {
      ref.invalidateSelf();
      return;
    }
    if (saved is core.Error<void>) {
      _update(
        settings: _persistedSettings,
        monthSchedules: current.monthSchedules,
        isLoadingMonth: false,
        issue: PrayerIssue.storageFailed,
      );
      return;
    }
    await refreshOverview();
    if (!ref.mounted ||
        request != _settingsRequest ||
        generation != _generation) {
      return;
    }
    if (reloadMonth) await loadMonth(current.selectedMonth);
  }

  Future<void> changeAdjustment(PrayerName prayer, int minutes) async {
    final current = state.asData?.value;
    if (current == null) return;
    final adjustments = Map<PrayerName, int>.of(current.settings.adjustments)
      ..[prayer] = minutes.clamp(-30, 30);
    await updateSettings(current.settings.copyWith(adjustments: adjustments));
  }

  void _update({
    PrayerSettings? settings,
    PrayerOverview? overview,
    List<PrayerSchedule>? monthSchedules,
    DateTime? selectedMonth,
    PrayerIssue? issue,
    bool clearIssue = false,
    bool? isLoadingMonth,
  }) {
    if (!ref.mounted) return;
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncData(
      current.copyWith(
        settings: settings,
        overview: overview,
        monthSchedules: monthSchedules,
        selectedMonth: selectedMonth,
        issue: issue,
        clearIssue: clearIssue,
        isLoadingMonth: isLoadingMonth,
      ),
    );
  }

  PrayerIssue _toIssue(Object error) =>
      error is PrayerIssue ? error : PrayerIssue.calculationFailed;
}

final prayerControllerProvider =
    AsyncNotifierProvider<PrayerController, PrayerState>(PrayerController.new);
