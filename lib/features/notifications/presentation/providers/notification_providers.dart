import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/app_settings.dart';
import '../../../../core/utils/result.dart' as core;
import '../../../../l10n/generated/app_localizations.dart';
import '../../../location/presentation/providers/location_controller.dart';
import '../../../prayer/domain/entities/prayer_schedule.dart';
import '../../../prayer/domain/entities/prayer_settings.dart';
import '../../../prayer/presentation/providers/prayer_controller.dart';
import '../../../prayer/presentation/providers/prayer_providers.dart';
import '../../data/notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);
final alertPreferencesProvider =
    AsyncNotifierProvider<AlertPreferencesController, Set<PrayerName>>(
      AlertPreferencesController.new,
    );

class AlertPreferencesController extends AsyncNotifier<Set<PrayerName>> {
  @override
  Future<Set<PrayerName>> build() async {
    final prefs = ref.watch(appPreferencesProvider);
    final enabled = <PrayerName>{};
    for (final prayer in PrayerName.values.where(
      (p) => p != PrayerName.sunrise && p != PrayerName.sunset,
    )) {
      if (await prefs.getBool('notifications.${prayer.name}') ?? false) {
        enabled.add(prayer);
      }
    }
    return enabled;
  }

  Future<bool> setEnabled(PrayerName prayer, bool value) async {
    if (value &&
        !await ref.read(notificationServiceProvider).requestPermission()) {
      return false;
    }
    await ref
        .read(appPreferencesProvider)
        .setBool('notifications.${prayer.name}', value);
    if (!ref.mounted) return false;
    final next = {...?state.asData?.value};
    value ? next.add(prayer) : next.remove(prayer);
    state = AsyncData(next);
    return true;
  }
}

class AlertStatus {
  const AlertStatus({
    this.count = 0,
    this.until,
    this.permissionDenied = false,
    this.needsLocation = false,
    this.exact = true,
  });
  final int count;
  final DateTime? until;
  final bool permissionDenied;
  final bool needsLocation;
  final bool exact;
}

final notificationSyncProvider = FutureProvider<AlertStatus>((ref) async {
  final preferences = ref.watch(alertPreferencesProvider);
  final location = ref.watch(activeLocationProvider);
  final settings = ref.watch(
    prayerControllerProvider.select((state) => state.asData?.value.settings),
  );
  final app = ref.watch(appSettingsProvider);
  final service = ref.watch(notificationServiceProvider);
  final revision = service.reserve();
  // Invalidate the reservation as soon as inputs change, even while awaiting IO.
  ref.onDispose(service.reserve);
  if (preferences.isLoading || app.isLoading) {
    return const AlertStatus();
  }
  final enabled = preferences.requireValue;
  if (enabled.isEmpty || location == null) {
    await service.replace([], revision, exact: false);
    return AlertStatus(needsLocation: enabled.isNotEmpty && location == null);
  }
  if (settings == null) return const AlertStatus();
  if (!await service.permissionGranted()) {
    await service.replace([], revision, exact: false);
    return const AlertStatus(permissionDenied: true);
  }
  final language =
      app.asData?.value.language ??
      PlatformDispatcher.instance.locale.languageCode;
  final strings = await AppLocalizations.delegate.load(
    Locale(language == 'ar' ? 'ar' : 'en'),
  );
  await service.replace([], revision, exact: false);
  final source = ref.read(prayerCalculationDataSourceProvider);
  final today = source.currentLocalDate(location);
  final repository = ref.read(prayerRepositoryProvider);
  final schedules = <PrayerSchedule>[];
  // Twelve calendar days fit the iOS pending-notification limit (60 <= 64).
  final end = today.add(const Duration(days: 12));
  for (
    var month = DateTime(today.year, today.month);
    month.isBefore(end);
    month = DateTime(month.year, month.month + 1)
  ) {
    final result = await repository.loadMonth(location, settings, month);
    if (!ref.mounted) return const AlertStatus();
    if (result is! core.Success<List<PrayerSchedule>>) {
      throw StateError('Prayer schedule unavailable');
    }
    schedules.addAll(
      result.value.where(
        (s) => !s.localDate.isBefore(today) && s.localDate.isBefore(end),
      ),
    );
  }
  final reminders = buildPrayerReminders(
    schedules: schedules,
    enabled: enabled,
    now: DateTime.now().toUtc(),
    title: (p) => switch (p) {
      PrayerName.fajr => strings.prayerFajr,
      PrayerName.dhuhr => strings.prayerDhuhr,
      PrayerName.asr => strings.prayerAsr,
      PrayerName.maghrib => strings.prayerMaghrib,
      PrayerName.isha => strings.prayerIsha,
      _ => '',
    },
    body: '${strings.prayerTimeNotification} · ${location.city}',
  );
  final exact = await service.exactPermissionGranted();
  if (!ref.mounted) return const AlertStatus();
  await service.replace(reminders, revision, exact: exact);
  return AlertStatus(
    count: reminders.length,
    until: reminders.lastOrNull?.event.timeUtc,
    exact: exact,
  );
});
