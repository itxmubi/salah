import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../features/calendar/presentation/providers/hijri_calendar_providers.dart';
import '../../../../features/prayer/domain/entities/prayer_schedule.dart';
import '../../../../features/prayer/domain/entities/prayer_issue.dart';
import '../../../../features/prayer/domain/entities/prayer_settings.dart';
import '../../../../features/prayer/presentation/providers/prayer_controller.dart';
import '../../../../l10n/generated/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  DateTime _now = DateTime.now().toUtc();
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
  }

  void _tick() {
    final now = DateTime.now().toUtc();
    if (mounted) setState(() => _now = now);
    final next = ref
        .read(prayerControllerProvider)
        .asData
        ?.value
        .overview
        ?.nextPrayer;
    if (next != null && !now.isBefore(next.timeUtc) && !_refreshing) {
      _refresh();
    }
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      await ref.read(prayerControllerProvider.notifier).refreshOverview();
      if (mounted) setState(() => _now = DateTime.now().toUtc());
    } finally {
      _refreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final prayerState = ref.watch(prayerControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.appTitle),
        actions: [
          IconButton(
            tooltip: strings.notificationSettingsTitle,
            onPressed: () => context.push('/notifications'),
            icon: const Icon(AppIcons.notifications),
          ),
          IconButton(
            tooltip: strings.locationTitle,
            onPressed: () => context.push('/location'),
            icon: const Icon(AppIcons.location),
          ),
          IconButton(
            tooltip: strings.settingsTitle,
            onPressed: () => context.push('/settings'),
            icon: const Icon(AppIcons.settings),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: prayerState.when(
          loading: () =>
              Center(child: AppLoadingState(label: strings.prayerTimesTitle)),
          error: (error, stackTrace) => AppErrorState(
            title: strings.prayerTimesTitle,
            description: strings.prayerCalculationError,
            retryLabel: strings.retry,
            onRetry: _refresh,
          ),
          data: (state) {
            final overview = state.overview;
            if (overview == null) {
              if (state.issue != null) {
                return AppErrorState(
                  title: strings.prayerTimesTitle,
                  description: switch (state.issue!) {
                    PrayerIssue.noLocation => strings.prayerNoLocationError,
                    PrayerIssue.timezoneUnavailable =>
                      strings.prayerTimezoneError,
                    PrayerIssue.calculationFailed =>
                      strings.prayerCalculationError,
                    PrayerIssue.storageFailed => strings.prayerStorageError,
                  },
                  retryLabel: strings.retry,
                  onRetry: _refresh,
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppEmptyState(
                    title: strings.welcomeTitle,
                    description: strings.prayerNoLocation,
                    actionLabel: strings.openLocation,
                    onAction: () => context.push('/location'),
                  ),
                ),
              );
            }
            return _dashboard(context, strings, overview, state.settings);
          },
        ),
      ),
    );
  }

  Widget _dashboard(
    BuildContext context,
    AppLocalizations strings,
    PrayerOverview overview,
    PrayerSettings settings,
  ) {
    final today = overview.today;
    final labels = _PrayerLabels(strings);
    final date = DateFormat.yMMMMEEEEd(
      strings.localeName,
    ).format(today.localDate);
    final hijriDate = ref.watch(hijriDateProvider(today.localDate));
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(date, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.xxs),
                      hijriDate.when(
                        data: (value) => value == null
                            ? const SizedBox.shrink()
                            : Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xxs,
                                ),
                                child: Semantics(
                                  label:
                                      '${strings.hijriDate}: ${value.day} ${value.monthName} ${value.year}',
                                  child: Text(
                                    '${value.day} ${value.monthName} ${value.year} AH',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                        loading: () => const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        error: (error, stackTrace) => const SizedBox.shrink(),
                      ),
                      Text(
                        today.locationName.isEmpty
                            ? strings.currentLocation
                            : today.locationName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: strings.locationTitle,
                  onPressed: () => context.push('/location'),
                  icon: const Icon(AppIcons.location),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _NextPrayerHero(
              overview: overview,
              now: _now,
              labels: labels,
              strings: strings,
              settings: settings,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.todaySchedule,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/prayer'),
                  icon: const Icon(AppIcons.schedule),
                  label: Text(strings.viewAllPrayerTimes),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            AppCard(
              padding: AppSpacing.xs,
              child: Column(
                children: [
                  for (final event in today.events)
                    _DashboardPrayerRow(
                      event: event,
                      label: labels.of(event.prayer),
                      settings: settings,
                      isCurrent:
                          overview.currentPrayer?.timeUtc == event.timeUtc,
                      isNext: overview.nextPrayer.timeUtc == event.timeUtc,
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _SunlightSummary(
              sunrise: today.event(PrayerName.sunrise),
              sunset: today.event(PrayerName.sunset),
              settings: settings,
              strings: strings,
            ),
            if (today.timeZoneId.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                today.timeZoneId,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.prayerAccuracyNote,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextPrayerHero extends StatelessWidget {
  const _NextPrayerHero({
    required this.overview,
    required this.now,
    required this.labels,
    required this.strings,
    required this.settings,
  });

  final PrayerOverview overview;
  final DateTime now;
  final _PrayerLabels labels;
  final AppLocalizations strings;
  final PrayerSettings settings;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = overview.nextPrayer.timeUtc.difference(now);
    final interval = overview.currentPrayer == null
        ? const Duration(hours: 3)
        : overview.nextPrayer.timeUtc.difference(
            overview.currentPrayer!.timeUtc,
          );
    final progress = interval.inSeconds <= 0
        ? 0.0
        : (1 - remaining.inSeconds / interval.inSeconds).clamp(0.0, 1.0);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, AppColors.midnightForest],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              top: -56,
              right: -24,
              child: _GlowCircle(
                color: scheme.onPrimary.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.nextPrayer.toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.8),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    labels.of(overview.nextPrayer.prayer),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '${strings.timeRemaining} · ${_time(overview.nextPrayer, strings.localeName, settings)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.84),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _countdown(remaining),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scheme.onPrimary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: progress,
                      backgroundColor: scheme.onPrimary.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(scheme.tertiary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _countdown(Duration duration) {
    final seconds = duration.inSeconds.clamp(0, 99 * 3600 + 3599);
    final hours = (seconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final remainder = (seconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$remainder';
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 180,
    height: 180,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
  );
}

class _DashboardPrayerRow extends StatelessWidget {
  const _DashboardPrayerRow({
    required this.event,
    required this.label,
    required this.settings,
    required this.isCurrent,
    required this.isNext,
  });

  final PrayerEvent event;
  final String label;
  final PrayerSettings settings;
  final bool isCurrent;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final emphasized = isCurrent || isNext;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: emphasized ? scheme.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          event.prayer == PrayerName.sunrise ||
                  event.prayer == PrayerName.sunset
              ? AppIcons.sunrise
              : AppIcons.prayer,
          color: emphasized ? scheme.primary : scheme.onSurfaceVariant,
        ),
        title: Text(label),
        subtitle: isCurrent
            ? Text(AppLocalizations.of(context).currentPrayer)
            : isNext
            ? Text(AppLocalizations.of(context).nextPrayer)
            : null,
        trailing: Text(
          _time(event, AppLocalizations.of(context).localeName, settings),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: emphasized ? FontWeight.w700 : null,
          ),
        ),
      ),
    );
  }
}

class _SunlightSummary extends StatelessWidget {
  const _SunlightSummary({
    required this.sunrise,
    required this.sunset,
    required this.settings,
    required this.strings,
  });

  final PrayerEvent sunrise;
  final PrayerEvent sunset;
  final PrayerSettings settings;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      children: [
        Expanded(
          child: _SunTime(
            icon: AppIcons.sunrise,
            label: strings.prayerSunrise,
            event: sunrise,
            settings: settings,
            localeName: strings.localeName,
          ),
        ),
        Container(
          width: 1,
          height: 42,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
        Expanded(
          child: _SunTime(
            icon: AppIcons.sunset,
            label: strings.prayerSunset,
            event: sunset,
            settings: settings,
            localeName: strings.localeName,
          ),
        ),
      ],
    ),
  );
}

class _SunTime extends StatelessWidget {
  const _SunTime({
    required this.icon,
    required this.label,
    required this.event,
    required this.settings,
    required this.localeName,
  });

  final IconData icon;
  final String label;
  final PrayerEvent event;
  final PrayerSettings settings;
  final String localeName;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: Theme.of(context).colorScheme.tertiary),
      const SizedBox(width: AppSpacing.xs),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          Text(
            _time(event, localeName, settings),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    ],
  );
}

String _time(
  PrayerEvent event,
  String localeName, [
  PrayerSettings settings = const PrayerSettings(),
]) {
  final localTime = DateTime(2024, 1, 1, event.localHour, event.localMinute);
  return settings.use24HourFormat
      ? DateFormat.Hm(localeName).format(localTime)
      : DateFormat.jm(localeName).format(localTime);
}

class _PrayerLabels {
  const _PrayerLabels(this.strings);
  final AppLocalizations strings;

  String of(PrayerName prayer) => switch (prayer) {
    PrayerName.fajr => strings.prayerFajr,
    PrayerName.sunrise => strings.prayerSunrise,
    PrayerName.dhuhr => strings.prayerDhuhr,
    PrayerName.asr => strings.prayerAsr,
    PrayerName.maghrib => strings.prayerMaghrib,
    PrayerName.sunset => strings.prayerSunset,
    PrayerName.isha => strings.prayerIsha,
  };
}
