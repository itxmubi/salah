import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../prayer/domain/entities/prayer_settings.dart';
import '../providers/notification_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _busy = false;
  String? _message;
  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(() => _message = AppLocalizations.of(context).alertsFailed);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final preferences = ref.watch(alertPreferencesProvider);
    final sync = ref.watch(notificationSyncProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.notificationSettingsTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(strings.notificationPermissionDescription),
                const SizedBox(height: 12),
                Text(strings.alertsRollingNote),
                const SizedBox(height: 16),
                if (_message != null)
                  Semantics(liveRegion: true, child: Text(_message!)),
                sync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(strings.alertsFailed),
                  data: (status) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          status.permissionDenied
                              ? strings.alertsDenied
                              : status.needsLocation
                              ? strings.alertsLocation
                              : status.count == 0
                              ? strings.alertsOff
                              : strings.alertsSchedule(status.count),
                        ),
                      ),
                      if (status.permissionDenied)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _run(
                                  () => ref
                                      .read(notificationServiceProvider)
                                      .openSettings(),
                                ),
                          child: Text(strings.openSettings),
                        ),
                      if (status.until != null)
                        Text(
                          DateFormat.yMMMd(
                            strings.localeName,
                          ).add_jm().format(status.until!.toLocal()),
                        ),
                      if (!status.exact && status.count > 0) ...[
                        Text(strings.alertsApproximate),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _run(() async {
                                  await ref
                                      .read(notificationServiceProvider)
                                      .requestExactPermission();
                                  ref.invalidate(notificationSyncProvider);
                                }),
                          child: Text(strings.allowExactAlerts),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: _busy
                      ? null
                      : () {
                          ref.invalidate(alertPreferencesProvider);
                          ref.invalidate(notificationSyncProvider);
                        },
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.retry),
                ),
                preferences.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Text(strings.alertsFailed),
                  data: (enabled) => Column(
                    children: [
                      for (final entry in <PrayerName, String>{
                        PrayerName.fajr: strings.prayerFajr,
                        PrayerName.dhuhr: strings.prayerDhuhr,
                        PrayerName.asr: strings.prayerAsr,
                        PrayerName.maghrib: strings.prayerMaghrib,
                        PrayerName.isha: strings.prayerIsha,
                      }.entries)
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(entry.value),
                          subtitle: Text(strings.prayerTimeNotification),
                          value: enabled.contains(entry.key),
                          onChanged: _busy
                              ? null
                              : (value) => _run(() async {
                                  final allowed = await ref
                                      .read(alertPreferencesProvider.notifier)
                                      .setEnabled(entry.key, value);
                                  if (!allowed && mounted) {
                                    setState(
                                      () => _message =
                                          strings.alertsPermissionDenied,
                                    );
                                  }
                                }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
