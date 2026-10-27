import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salah/features/notifications/presentation/providers/notification_providers.dart';
import 'package:salah/features/notifications/data/notification_service.dart';
import 'package:salah/features/prayer/domain/entities/prayer_schedule.dart';
import 'package:salah/features/prayer/domain/entities/prayer_settings.dart';
import 'package:timezone/timezone.dart' as tz;

class RecordingNotifications implements FlutterLocalNotificationsPlugin {
  final scheduled = <int>[];
  final cancelled = <int>[];
  List<PendingNotificationRequest> pending = [];
  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async => true;
  @override
  Future<List<PendingNotificationRequest>>
  pendingNotificationRequests() async => pending;
  @override
  Future<void> cancel({required int id, String? tag}) async {
    cancelled.add(id);
  }

  @override
  Future<void> zonedSchedule({
    required int id,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails notificationDetails,
    required AndroidScheduleMode androidScheduleMode,
    String? title,
    String? body,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    scheduled.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

PrayerReminder reminder(int id) => PrayerReminder(
  id: id,
  event: PrayerEvent(
    prayer: PrayerName.fajr,
    timeUtc: DateTime.utc(2026, 10, 28),
    localHour: 5,
    localMinute: 0,
  ),
  title: 'Fajr',
  body: 'Prayer time',
);

void main() {
  test(
    'Reminder plan omits past, disabled and non-prayer events and stays below iOS limit',
    () {
      final now = DateTime.utc(2026, 10, 27);
      final schedules = List.generate(
        20,
        (day) => PrayerSchedule(
          locationId: 'dubai',
          locationName: 'Dubai',
          latitude: 25,
          longitude: 55,
          localDate: now.add(Duration(days: day)),
          timeZoneId: 'Asia/Dubai',
          events: [
            for (final p in PrayerName.values)
              PrayerEvent(
                prayer: p,
                timeUtc: now.add(Duration(days: day, hours: p.index)),
                localHour: p.index,
                localMinute: 0,
              ),
          ],
        ),
      );
      final plan = buildPrayerReminders(
        schedules: schedules,
        enabled: PrayerName.values.toSet(),
        now: now,
        title: (p) => p.name,
        body: 'Prayer time',
      );
      expect(plan, hasLength(60));
      expect(
        plan.every(
          (p) => p.event.timeUtc.isAfter(now) && p.event.isObligatoryPrayer,
        ),
        isTrue,
      );
      expect(plan.map((p) => p.id).toSet(), hasLength(60));
      expect(
        buildPrayerReminders(
          schedules: schedules,
          enabled: {PrayerName.isha},
          now: now,
          title: (p) => p.name,
          body: '',
        ),
        hasLength(20),
      );
    },
  );

  test(
    'Replacement cancels obsolete reminders and disabling cancels all',
    () async {
      final plugin = RecordingNotifications()
        ..pending = [const PendingNotificationRequest(1, 'Old', '', null)];
      final service = NotificationService(plugin: plugin);
      await service.replace([reminder(2)], service.reserve(), exact: false);
      expect(plugin.cancelled, [1]);
      expect(plugin.scheduled, [2]);
      plugin.pending = [const PendingNotificationRequest(2, 'New', '', null)];
      await service.replace([], service.reserve(), exact: false);
      expect(plugin.cancelled, [1, 2]);
    },
  );

  test('A stale scheduling request cannot restore disabled alerts', () async {
    final plugin = RecordingNotifications();
    final service = NotificationService(plugin: plugin);
    final stale = service.reserve();
    final current = service.reserve();
    await service.replace([reminder(1)], stale, exact: false);
    await service.replace([], current, exact: false);
    expect(plugin.scheduled, isEmpty);
  });
  test(
    'Denied alerts stay disabled; granted preferences persist and can be disabled',
    () async {
      final prefs = SharedPreferencesAsync();
      await prefs.remove('notifications.fajr');
      final service = PermissionService();
      final container = ProviderContainer(
        overrides: [notificationServiceProvider.overrideWithValue(service)],
      );
      await container.read(alertPreferencesProvider.future);
      expect(
        await container
            .read(alertPreferencesProvider.notifier)
            .setEnabled(PrayerName.fajr, true),
        isFalse,
      );
      expect(await prefs.getBool('notifications.fajr'), isNull);
      service.allowed = true;
      expect(
        await container
            .read(alertPreferencesProvider.notifier)
            .setEnabled(PrayerName.fajr, true),
        isTrue,
      );
      container.dispose();
      final restored = ProviderContainer(
        overrides: [notificationServiceProvider.overrideWithValue(service)],
      );
      addTearDown(restored.dispose);
      expect(
        await restored.read(alertPreferencesProvider.future),
        contains(PrayerName.fajr),
      );
      await restored
          .read(alertPreferencesProvider.notifier)
          .setEnabled(PrayerName.fajr, false);
      expect(await prefs.getBool('notifications.fajr'), isFalse);
    },
  );
}

class PermissionService extends NotificationService {
  bool allowed = false;
  @override
  Future<bool> requestPermission() async => allowed;
}
