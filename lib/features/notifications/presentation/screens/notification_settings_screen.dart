import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
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
  static const _prayers = <PrayerName>[
    PrayerName.fajr,
    PrayerName.dhuhr,
    PrayerName.asr,
    PrayerName.maghrib,
    PrayerName.isha,
  ];

  final _preferences = SharedPreferencesAsync();
  final Map<PrayerName, bool> _enabled = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    for (final prayer in _prayers) {
      _enabled[prayer] = await _preferences.getBool(_key(prayer)) ?? false;
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _setEnabled(PrayerName prayer, bool value) async {
    if (value) {
      final allowed = await ref
          .read(notificationServiceProvider)
          .requestPermission();
      if (!allowed) return;
    }
    await _preferences.setBool(_key(prayer), value);
    if (mounted) setState(() => _enabled[prayer] = value);
  }

  String _key(PrayerName prayer) => 'notifications.${prayer.name}';

  String _label(AppLocalizations strings, PrayerName prayer) =>
      switch (prayer) {
        PrayerName.fajr => strings.prayerFajr,
        PrayerName.dhuhr => strings.prayerDhuhr,
        PrayerName.asr => strings.prayerAsr,
        PrayerName.maghrib => strings.prayerMaghrib,
        PrayerName.isha => strings.prayerIsha,
        PrayerName.sunrise => strings.prayerSunrise,
        PrayerName.sunset => strings.prayerSunset,
      };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(strings.notificationSettingsTitle)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                AppCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        color: colors.primary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.prayerAlertsTitle,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              strings.notificationPermissionDescription,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  strings.prayerAlertsTitle,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppCard(
                  padding: AppSpacing.md,

                  child: Column(
                    children: [
                      for (var index = 0; index < _prayers.length; index++) ...[
                        if (index > 0) const Divider(height: 1),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_label(strings, _prayers[index])),
                          subtitle: Text(strings.prayerTimeNotification),
                          value: _enabled[_prayers[index]] ?? false,
                          onChanged: (value) =>
                              _setEnabled(_prayers[index], value),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
