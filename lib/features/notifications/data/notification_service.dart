import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../prayer/domain/entities/prayer_schedule.dart';
import '../../prayer/domain/entities/prayer_settings.dart';

class PrayerReminder {
  const PrayerReminder({
    required this.id,
    required this.event,
    required this.title,
    required this.body,
  });
  final int id;
  final PrayerEvent event;
  final String title;
  final String body;
}

/// Stable UTC ids let an unchanged reminder replace itself after app resume.
List<PrayerReminder> buildPrayerReminders({
  required List<PrayerSchedule> schedules,
  required Set<PrayerName> enabled,
  required DateTime now,
  required String Function(PrayerName) title,
  required String body,
}) {
  final events =
      schedules
          .expand((day) => day.events)
          .where(
            (event) =>
                event.isObligatoryPrayer &&
                enabled.contains(event.prayer) &&
                event.timeUtc.isAfter(now),
          )
          .toList()
        ..sort((a, b) => a.timeUtc.compareTo(b.timeUtc));
  return events
      .take(60)
      .map(
        (event) => PrayerReminder(
          id:
              (event.timeUtc.millisecondsSinceEpoch ~/ 60000) * 8 +
              event.prayer.index,
          event: event,
          title: title(event.prayer),
          body: body,
        ),
      )
      .toList(growable: false);
}

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initializing;
  Future<void> _queue = Future.value();
  int _revision = 0;

  // Reserved before loading schedules; stale requests cannot re-enable old alerts.
  int reserve() => ++_revision;

  Future<void> initialize() => _initializing ??= _initialize();
  Future<void> _initialize() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings(
            '@drawable/ic_prayer_notification',
          ),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  Future<void> openSettings() async {
    await Geolocator.openAppSettings();
  }

  Future<bool> requestPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  Future<bool> permissionGranted() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return (await ios?.checkPermissions())?.isEnabled ?? false;
  }

  Future<bool> requestExactPermission() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestExactAlarmsPermission() ?? true;
  }

  Future<bool> exactPermissionGranted() async {
    await initialize();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.canScheduleExactNotifications() ?? true;
  }

  Future<void> replace(
    List<PrayerReminder> reminders,
    int revision, {
    required bool exact,
  }) {
    final operation = _queue.catchError((Object _) {}).then((_) async {
      if (revision != _revision) return;
      await initialize();
      final desired = {for (final reminder in reminders) reminder.id};
      // Remove disabled/obsolete reminders before adding the new plan.
      for (final pending in await _plugin.pendingNotificationRequests()) {
        if (revision != _revision) return;
        if (!desired.contains(pending.id)) await _plugin.cancel(id: pending.id);
      }
      for (final reminder in reminders) {
        if (revision != _revision) return;
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime.from(reminder.event.timeUtc, tz.UTC),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_reminders_v1',
              'Prayer reminders',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    });
    _queue = operation;
    return operation;
  }
}
