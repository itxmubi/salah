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
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/prayer_issue.dart';
import '../../domain/entities/prayer_schedule.dart';
import '../../domain/entities/prayer_settings.dart';
import '../providers/prayer_controller.dart';

class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with WidgetsBindingObserver {
  Timer? _ticker;
  DateTime _now = DateTime.now().toUtc();
  bool _showMonth = true;
  bool _initialMonthRequested = false;
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
    final localization = AppLocalizations.of(context);
    final prayerAsync = ref.watch(prayerControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(localization.prayerTimesTitle),
        actions: [
          IconButton(
            tooltip: localization.openLocation,
            onPressed: () => context.push('/location'),
            icon: const Icon(AppIcons.location),
          ),
          IconButton(
            tooltip: localization.prayerSettings,
            onPressed: () => _openSettings(context, prayerAsync.asData?.value),
            icon: const Icon(AppIcons.tune),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: prayerAsync.when(
          loading: () => Center(
            child: AppLoadingState(label: localization.prayerTimesTitle),
          ),
          error: (error, stackTrace) => AppErrorState(
            title: localization.prayerTimesTitle,
            description: localization.prayerCalculationError,
            retryLabel: localization.retry,
            onRetry: _refresh,
          ),
          data: (state) {
            if (state.overview == null)
              return _noLocation(context, localization);
            if (_showMonth &&
                !_initialMonthRequested &&
                state.monthSchedules.isEmpty &&
                !state.isLoadingMonth) {
              _initialMonthRequested = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                ref
                    .read(prayerControllerProvider.notifier)
                    .loadMonth(
                      state.selectedMonth ?? state.overview!.today.localDate,
                    );
              });
            }
            return _buildPrayerContent(context, localization, state);
          },
        ),
      ),
    );
  }

  Widget _noLocation(BuildContext context, AppLocalizations localization) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppEmptyState(
            title: localization.prayerTimesTitle,
            description: localization.prayerNoLocation,
            actionLabel: localization.openLocation,
            onAction: () => context.push('/location'),
          ),
        ),
      );

  Widget _buildPrayerContent(
    BuildContext context,
    AppLocalizations localization,
    PrayerState state,
  ) {
    final overview = state.overview!;
    final schedule = overview.today;
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              _LocationHeading(schedule: schedule, localization: localization),
              const SizedBox(height: AppSpacing.md),
              if (state.issue case final issue?)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _PrayerIssueCard(
                    issue: issue,
                    localization: localization,
                  ),
                ),
              if (!_showMonth) ...[
                _NextPrayerCard(
                  overview: overview,
                  now: _now,
                  localization: localization,
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _ScheduleTabs(
                showMonth: _showMonth,
                localization: localization,
                onChanged: (showMonth) {
                  setState(() => _showMonth = showMonth);
                  if (showMonth) {
                    ref
                        .read(prayerControllerProvider.notifier)
                        .loadMonth(state.selectedMonth);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.md),
              if (_showMonth)
                _buildMonth(context, localization, state)
              else
                _buildToday(context, localization, state),
              const SizedBox(height: AppSpacing.md),
              Text(
                localization.prayerAccuracyNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToday(
    BuildContext context,
    AppLocalizations localization,
    PrayerState state,
  ) {
    final overview = state.overview!;
    final nextIsToday = overview.today.events.any(
      (event) => event.timeUtc == overview.nextPrayer.timeUtc,
    );
    final names = _PrayerLabels(localization);
    final dateLabel = DateFormat.yMMMMEEEEd(
      localization.localeName,
    ).format(overview.today.localDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                localization.todaySchedule,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Text(dateLabel, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: AppSpacing.xs,
          child: Column(
            children: [
              for (final event in overview.today.events)
                _PrayerTimeRow(
                  event: event,
                  label: names.of(event.prayer),
                  timeLabel: _formatTime(event, state.settings),
                  isCurrent:
                      overview.currentPrayer?.prayer == event.prayer &&
                      overview.currentPrayer?.timeUtc == event.timeUtc,
                  isNext:
                      nextIsToday && overview.nextPrayer.prayer == event.prayer,
                  localization: localization,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _SunlightCard(
          sunrise: overview.today.event(PrayerName.sunrise),
          sunset: overview.today.event(PrayerName.sunset),
          settings: state.settings,
          localization: localization,
        ),
      ],
    );
  }

  Widget _buildMonth(
    BuildContext context,
    AppLocalizations localization,
    PrayerState state,
  ) {
    final month = state.selectedMonth ?? state.overview!.today.localDate;
    final controller = ref.read(prayerControllerProvider.notifier);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              tooltip: localization.previousMonth,
              onPressed: () =>
                  controller.loadMonth(DateTime(month.year, month.month - 1)),
              icon: const Icon(AppIcons.chevronLeft),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMM(localization.localeName).format(month),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              tooltip: localization.nextMonth,
              onPressed: () =>
                  controller.loadMonth(DateTime(month.year, month.month + 1)),
              icon: const Icon(AppIcons.chevronRight),
            ),
          ],
        ),
        if (state.isLoadingMonth)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Center(child: CircularProgressIndicator()),
          )
        else
          for (final schedule in state.monthSchedules)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _MonthDayCard(
                schedule: schedule,
                currentDate: state.overview!.today.localDate,
                settings: state.settings,
                localization: localization,
              ),
            ),
      ],
    );
  }

  Future<void> _openSettings(BuildContext context, PrayerState? state) async {
    if (state == null) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _PrayerSettingsSheet(
        settings: state.settings,
        onChanged: (settings) => ref
            .read(prayerControllerProvider.notifier)
            .updateSettings(settings),
      ),
    );
  }

  String _formatTime(PrayerEvent event, PrayerSettings settings) {
    final dateTime = DateTime(2024, 1, 1, event.localHour, event.localMinute);
    return settings.use24HourFormat
        ? DateFormat.Hm().format(dateTime)
        : DateFormat.jm().format(dateTime);
  }
}

class _LocationHeading extends StatelessWidget {
  const _LocationHeading({required this.schedule, required this.localization});

  final PrayerSchedule schedule;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: const Icon(AppIcons.location),
      ),
      const SizedBox(width: AppSpacing.sm),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              schedule.locationName.isEmpty
                  ? localization.currentLocation
                  : schedule.locationName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              schedule.timeZoneId,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({
    required this.overview,
    required this.now,
    required this.localization,
  });

  final PrayerOverview overview;
  final DateTime now;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = overview.nextPrayer.timeUtc.difference(now);
    final names = _PrayerLabels(localization);
    final prayerDuration = overview.currentPrayer == null
        ? const Duration(hours: 3)
        : overview.nextPrayer.timeUtc.difference(
            overview.currentPrayer!.timeUtc,
          );
    final progress = prayerDuration.inSeconds <= 0
        ? 0.0
        : (1 - remaining.inSeconds / prayerDuration.inSeconds).clamp(0.0, 1.0);
    final localDateTime = DateTime(
      2024,
      1,
      1,
      overview.nextPrayer.localHour,
      overview.nextPrayer.localMinute,
    );

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
            color: scheme.primary.withValues(alpha: 0.22),
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
              top: -58,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.onPrimary.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -88,
              right: 76,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.tertiary.withValues(alpha: 0.12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(AppIcons.schedule, color: scheme.onPrimary),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        localization.nextPrayer.toUpperCase(),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: scheme.onPrimary.withValues(alpha: 0.84),
                          letterSpacing: 1.1,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat.jm(
                          localization.localeName,
                        ).format(localDateTime),
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: scheme.onPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    names.of(overview.nextPrayer.prayer),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: scheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    remaining.isNegative
                        ? '${localization.prayerStarted} ${names.of(overview.nextPrayer.prayer)}'
                        : localization.timeRemaining,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.84),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _countdown(remaining),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scheme.onPrimary,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: progress,
                      backgroundColor: scheme.onPrimary.withValues(alpha: 0.20),
                      valueColor: AlwaysStoppedAnimation(scheme.tertiary),
                    ),
                  ),
                  if (overview.currentPrayer != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      '${localization.currentPrayer} · ${names.of(overview.currentPrayer!.prayer)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onPrimary.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _countdown(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 99 * 3600 + 3599);
    final hours = (totalSeconds ~/ 3600).toString().padLeft(2, '0');
    final minutes = ((totalSeconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

class _ScheduleTabs extends StatelessWidget {
  const _ScheduleTabs({
    required this.showMonth,
    required this.localization,
    required this.onChanged,
  });

  final bool showMonth;
  final AppLocalizations localization;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SegmentedButton<bool>(
    segments: [
      ButtonSegment(
        value: false,
        icon: const Icon(AppIcons.schedule),
        label: Text(localization.todaySchedule),
      ),
      ButtonSegment(
        value: true,
        icon: const Icon(AppIcons.month),
        label: Text(localization.monthlySchedule),
      ),
    ],
    selected: {showMonth},
    onSelectionChanged: (selection) => onChanged(selection.first),
  );
}

class _PrayerTimeRow extends StatelessWidget {
  const _PrayerTimeRow({
    required this.event,
    required this.label,
    required this.timeLabel,
    required this.isCurrent,
    required this.isNext,
    required this.localization,
  });

  final PrayerEvent event;
  final String label;
  final String timeLabel;
  final bool isCurrent;
  final bool isNext;
  final AppLocalizations localization;

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
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: emphasized
              ? scheme.primary
              : scheme.surfaceContainerHighest,
          foregroundColor: emphasized
              ? scheme.onPrimary
              : scheme.onSurfaceVariant,
          child: Icon(
            event.prayer == PrayerName.sunrise ||
                    event.prayer == PrayerName.sunset
                ? AppIcons.sunrise
                : AppIcons.schedule,
            size: 18,
          ),
        ),
        title: Text(label, style: Theme.of(context).textTheme.titleMedium),
        subtitle: isCurrent
            ? Text(localization.currentPrayer)
            : isNext
            ? Text(localization.nextPrayer)
            : null,
        trailing: Text(
          timeLabel,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

class _SunlightCard extends StatelessWidget {
  const _SunlightCard({
    required this.sunrise,
    required this.sunset,
    required this.settings,
    required this.localization,
  });

  final PrayerEvent sunrise;
  final PrayerEvent sunset;
  final PrayerSettings settings;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localization.sunriseSunset,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _SunTime(
                icon: AppIcons.sunrise,
                label: localization.prayerSunrise,
                event: sunrise,
                settings: settings,
              ),
            ),
            Container(
              width: 1,
              height: 44,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            Expanded(
              child: _SunTime(
                icon: AppIcons.sunset,
                label: localization.prayerSunset,
                event: sunset,
                settings: settings,
              ),
            ),
          ],
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
  });

  final IconData icon;
  final String label;
  final PrayerEvent event;
  final PrayerSettings settings;

  @override
  Widget build(BuildContext context) {
    final localTime = DateTime(2024, 1, 1, event.localHour, event.localMinute);
    final formatted = settings.use24HourFormat
        ? DateFormat.Hm().format(localTime)
        : DateFormat.jm().format(localTime);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.tertiary),
          const SizedBox(width: AppSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(formatted, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthDayCard extends StatelessWidget {
  const _MonthDayCard({
    required this.schedule,
    required this.currentDate,
    required this.settings,
    required this.localization,
  });

  final PrayerSchedule schedule;
  final DateTime currentDate;
  final PrayerSettings settings;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) {
    final isToday =
        schedule.localDate.year == currentDate.year &&
        schedule.localDate.month == currentDate.month &&
        schedule.localDate.day == currentDate.day;
    final colors = Theme.of(context).colorScheme;
    final date = DateFormat(
      'EEE, d',
      localization.localeName,
    ).format(schedule.localDate);
    final names = _PrayerLabels(localization);
    return Card(
      color: isToday ? colors.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isToday
            ? BorderSide(color: colors.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sm,
              AppSpacing.sm,
              AppSpacing.sm,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isToday ? colors.primary : null,
                      fontWeight: isToday ? FontWeight.bold : null,
                    ),
                  ),
                ),
                if (isToday)
                  Text(
                    localization.todayLabel,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final event in schedule.events)
                  _MonthTimeChip(
                    label: names.of(event.prayer),
                    event: event,
                    settings: settings,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthTimeChip extends StatelessWidget {
  const _MonthTimeChip({
    required this.label,
    required this.event,
    required this.settings,
  });

  final String label;
  final PrayerEvent event;
  final PrayerSettings settings;

  @override
  Widget build(BuildContext context) {
    final clock = DateTime(2024, 1, 1, event.localHour, event.localMinute);
    final time = settings.use24HourFormat
        ? DateFormat.Hm().format(clock)
        : DateFormat.jm().format(clock);
    return Container(
      constraints: const BoxConstraints(minWidth: 68),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 2),
          Text(time, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _PrayerSettingsSheet extends StatelessWidget {
  const _PrayerSettingsSheet({required this.settings, required this.onChanged});

  final PrayerSettings settings;
  final ValueChanged<PrayerSettings> onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final labels = _PrayerLabels(localization);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              localization.prayerSettings,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              localization.calculationMethod,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            DropdownButtonFormField<PrayerCalculationMethod>(
              initialValue: settings.method,
              isExpanded: true,
              items: [
                for (final method in PrayerCalculationMethod.values)
                  DropdownMenuItem(
                    value: method,
                    child: Text(_methodName(localization, method)),
                  ),
              ],
              onChanged: (method) {
                if (method != null) {
                  onChanged(settings.copyWith(method: method));
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              localization.madhab,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            SegmentedButton<PrayerMadhab>(
              segments: [
                ButtonSegment(
                  value: PrayerMadhab.standard,
                  label: Text(localization.madhabStandard),
                ),
                ButtonSegment(
                  value: PrayerMadhab.hanafi,
                  label: Text(localization.madhabHanafi),
                ),
              ],
              selected: {settings.madhab},
              onSelectionChanged: (value) =>
                  onChanged(settings.copyWith(madhab: value.first)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              localization.highLatitudeNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              localization.manualAdjustments,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            for (final prayer in const [
              PrayerName.fajr,
              PrayerName.sunrise,
              PrayerName.dhuhr,
              PrayerName.asr,
              PrayerName.maghrib,
              PrayerName.isha,
            ])
              _AdjustmentRow(
                prayer: prayer,
                label: labels.of(prayer),
                minutes: settings.adjustments[prayer] ?? 0,
                onChanged: (minutes) => onChanged(
                  settings.copyWith(
                    adjustments: {...settings.adjustments, prayer: minutes},
                  ),
                ),
              ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(localization.timeFormat),
              value: settings.use24HourFormat,
              onChanged: (value) =>
                  onChanged(settings.copyWith(use24HourFormat: value)),
            ),
          ],
        ),
      ),
    );
  }

  String _methodName(
    AppLocalizations localization,
    PrayerCalculationMethod method,
  ) => switch (method) {
    PrayerCalculationMethod.muslimWorldLeague =>
      localization.methodMuslimWorldLeague,
    PrayerCalculationMethod.egyptian => localization.methodEgyptian,
    PrayerCalculationMethod.karachi => localization.methodKarachi,
    PrayerCalculationMethod.ummAlQura => localization.methodUmmAlQura,
    PrayerCalculationMethod.dubai => localization.methodDubai,
    PrayerCalculationMethod.qatar => localization.methodQatar,
    PrayerCalculationMethod.kuwait => localization.methodKuwait,
    PrayerCalculationMethod.moonsightingCommittee =>
      localization.methodMoonsightingCommittee,
    PrayerCalculationMethod.singapore => localization.methodSingapore,
    PrayerCalculationMethod.turkiye => localization.methodTurkiye,
    PrayerCalculationMethod.tehran => localization.methodTehran,
    PrayerCalculationMethod.northAmerica => localization.methodNorthAmerica,
    PrayerCalculationMethod.morocco => localization.methodMorocco,
  };
}

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({
    required this.prayer,
    required this.label,
    required this.minutes,
    required this.onChanged,
  });

  final PrayerName prayer;
  final String label;
  final int minutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        IconButton(
          tooltip: localization.decreaseAdjustment(label),
          onPressed: minutes <= -30 ? null : () => onChanged(minutes - 1),
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 64,
          child: Text(
            localization.adjustmentMinutes(minutes),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        IconButton(
          tooltip: localization.increaseAdjustment(label),
          onPressed: minutes >= 30 ? null : () => onChanged(minutes + 1),
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _PrayerIssueCard extends StatelessWidget {
  const _PrayerIssueCard({required this.issue, required this.localization});

  final PrayerIssue issue;
  final AppLocalizations localization;

  @override
  Widget build(BuildContext context) => AppErrorState(
    title: localization.prayerTimesTitle,
    description: switch (issue) {
      PrayerIssue.noLocation => localization.prayerNoLocationError,
      PrayerIssue.timezoneUnavailable => localization.prayerTimezoneError,
      PrayerIssue.calculationFailed => localization.prayerCalculationError,
      PrayerIssue.storageFailed => localization.prayerStorageError,
    },
  );
}

class _PrayerLabels {
  const _PrayerLabels(this.localization);
  final AppLocalizations localization;

  String of(PrayerName prayer) => switch (prayer) {
    PrayerName.fajr => localization.prayerFajr,
    PrayerName.sunrise => localization.prayerSunrise,
    PrayerName.dhuhr => localization.prayerDhuhr,
    PrayerName.asr => localization.prayerAsr,
    PrayerName.maghrib => localization.prayerMaghrib,
    PrayerName.sunset => localization.prayerSunset,
    PrayerName.isha => localization.prayerIsha,
  };
}
