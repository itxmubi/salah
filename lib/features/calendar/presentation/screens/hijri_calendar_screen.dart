import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/hijri_month.dart';
import '../../domain/services/hijri_calendar_engine.dart';
import '../providers/hijri_calendar_providers.dart';

String occasionLabel(AppLocalizations strings, IslamicOccasion occasion) =>
    switch (occasion) {
      IslamicOccasion.newYear => strings.islamicNewYear,
      IslamicOccasion.ashura => strings.dayOfAshura,
      IslamicOccasion.ramadan => strings.ramadanBegins,
      IslamicOccasion.eidFitr => strings.eidAlFitr,
      IslamicOccasion.arafah => strings.dayOfArafah,
      IslamicOccasion.eidAdha => strings.eidAlAdha,
      IslamicOccasion.tashriq => strings.daysOfTashriq,
    };

class HijriCalendarScreen extends ConsumerStatefulWidget {
  const HijriCalendarScreen({this.initialMonth, super.key});
  final HijriMonthId? initialMonth;
  @override
  ConsumerState<HijriCalendarScreen> createState() =>
      _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends ConsumerState<HijriCalendarScreen>
    with WidgetsBindingObserver {
  HijriMonthId? _month;
  int _selected = 1;
  final _scroll = ScrollController();
  @override
  void initState() {
    super.initState();
    _month = widget.initialMonth;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(calendarTodayProvider);
    }
  }

  void _showMonth(HijriMonthId id, {int day = 1}) {
    setState(() {
      _month = id;
      _selected = day;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _pickMonth(HijriMonthId current) async {
    final strings = AppLocalizations.of(context);
    var year = current.year;
    var month = current.month;
    final selected = await showDialog<HijriMonthId>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, update) => AlertDialog(
          title: Text(strings.chooseHijriMonth),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: month,
                  isExpanded: true,
                  decoration: InputDecoration(labelText: strings.calendarMonth),
                  items: [
                    for (var i = 1; i <= 12; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          ref
                              .read(hijriCalendarEngineProvider)
                              .monthName(i, strings.localeName),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) update(() => month = value);
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: year,
                  isExpanded: true,
                  menuMaxHeight: 280,
                  decoration: InputDecoration(labelText: strings.calendarYear),
                  items: [
                    for (
                      var i = HijriCalendarEngine.minYear;
                      i <= HijriCalendarEngine.maxYear;
                      i++
                    )
                      DropdownMenuItem(
                        value: i,
                        child: Text(
                          NumberFormat('0', strings.localeName).format(i),
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) update(() => year = value);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.close),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, HijriMonthId(year, month)),
              child: Text(strings.showCalendar),
            ),
          ],
        ),
      ),
    );
    if (mounted && selected != null) _showMonth(selected);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final today =
        ref.watch(calendarTodayProvider).asData?.value ??
        ref.watch(calendarDateReaderProvider)();
    final engine = ref.watch(hijriCalendarEngineProvider);
    final colors = Theme.of(context).colorScheme;
    final number = NumberFormat('0', strings.localeName);
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final currentDate = DateTime.utc(today.year, today.month, today.day);
    HijriMonthId currentMonth;
    int currentDay;
    try {
      final hijri = engine.fromGregorian(currentDate);
      currentMonth = HijriMonthId(int.parse(hijri.year), hijri.monthNumber!);
      currentDay = int.parse(hijri.day);
    } catch (_) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.hijriCalendarTitle)),
        body: AppErrorState(
          title: strings.hijriCalendarTitle,
          description: strings.calendarRange,
        ),
      );
    }
    if (_month == null) {
      _month = currentMonth;
      _selected = currentDay;
    }
    final id = _month!;
    final data = ref.watch(hijriMonthProvider(id));
    final selected = data.days[_selected.clamp(1, data.days.length) - 1];
    final monthName = engine.monthName(id.month, strings.localeName);
    final title = '$monthName ${number.format(id.year)}';
    final weekdays = strings.localeName == 'ar'
        ? ['أحد', 'إثن', 'ثلا', 'أرب', 'خمي', 'جمع', 'سبت']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final cellHeight =
        (MediaQuery.textScalerOf(context).scale(16) +
                MediaQuery.textScalerOf(context).scale(10) +
                28)
            .clamp(64.0, 180.0);
    final rows = (data.leadingDays + data.days.length + 6) ~/ 7;
    final events = data.days.where((day) => day.occasion != null).toList();
    return Scaffold(
      appBar: AppBar(title: Text(strings.hijriCalendarTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  strings.calendarMethodNote,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      tooltip: strings.previousMonth,
                      onPressed: engine.supports(id.previous)
                          ? () => _showMonth(id.previous)
                          : null,
                      icon: Icon(
                        rtl ? Icons.chevron_right : Icons.chevron_left,
                      ),
                    ),
                    Expanded(
                      child: Tooltip(
                        message: strings.chooseHijriMonth,
                        child: TextButton(
                          onPressed: () => _pickMonth(id),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: strings.nextMonth,
                      onPressed: engine.supports(id.next)
                          ? () => _showMonth(id.next)
                          : null,
                      icon: Icon(
                        rtl ? Icons.chevron_left : Icons.chevron_right,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: TextButton.icon(
                    onPressed: () => _showMonth(currentMonth, day: currentDay),
                    icon: const Icon(Icons.today),
                    label: Text(strings.calendarToday),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < 7; i++)
                      Expanded(
                        child: Semantics(
                          label: DateFormat.EEEE(
                            strings.localeName,
                          ).format(DateTime.utc(2026, 1, 4 + i)),
                          child: ExcludeSemantics(
                            child: Text(
                              weekdays[i],
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: Theme.of(
                                context,
                              ).textTheme.labelSmall?.copyWith(fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Table(
                  children: [
                    for (var row = 0; row < rows; row++)
                      TableRow(
                        children: [
                          for (var column = 0; column < 7; column++)
                            Builder(
                              builder: (context) {
                                final index =
                                    row * 7 + column - data.leadingDays;
                                if (index < 0 || index >= data.days.length) {
                                  return SizedBox(height: cellHeight);
                                }
                                final day = data.days[index];
                                final dayNumber = index + 1;
                                final isToday = day.gregorian == currentDate;
                                final isSelected = dayNumber == _selected;
                                final event = day.occasion;
                                final label =
                                    '${number.format(dayNumber)} $title, ${DateFormat.yMMMMEEEEd(strings.localeName).format(day.gregorian)}'
                                    '${isToday ? ', ${strings.calendarToday}' : ''}${event == null ? '' : ', ${occasionLabel(strings, event)}'}';
                                return Semantics(
                                  label: label,
                                  selected: isSelected,
                                  button: true,
                                  child: ExcludeSemantics(
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Material(
                                        color: isSelected
                                            ? colors.primaryContainer
                                            : isToday
                                            ? colors.secondaryContainer
                                            : colors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                        child: InkWell(
                                          key: ValueKey(
                                            'hijri-day-${id.year}-${id.month}-$dayNumber',
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          onTap: () => setState(
                                            () => _selected = dayNumber,
                                          ),
                                          child: Container(
                                            height: cellHeight,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: isToday
                                                  ? Border.all(
                                                      color: colors.primary,
                                                      width: 2,
                                                    )
                                                  : null,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  number.format(dayNumber),
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w700,
                                                    color: isSelected
                                                        ? colors
                                                              .onPrimaryContainer
                                                        : colors.onSurface,
                                                  ),
                                                ),
                                                Text(
                                                  number.format(
                                                    day.gregorian.day,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isSelected
                                                        ? colors
                                                              .onPrimaryContainer
                                                        : colors
                                                              .onSurfaceVariant,
                                                  ),
                                                ),
                                                if (event != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 3,
                                                        ),
                                                    child: Icon(
                                                      Icons.circle,
                                                      size: 5,
                                                      color: colors.primary,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  strings.calendarNumberLegend,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${number.format(int.parse(selected.hijri.day))} $title',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        DateFormat.yMMMMEEEEd(
                          strings.localeName,
                        ).format(selected.gregorian),
                      ),
                      if (selected.occasion case final occasion?)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            occasionLabel(strings, occasion),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.monthOccasions,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(strings.noMonthOccasions),
                  ),
                for (final day in events)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_outlined),
                    title: Text(occasionLabel(strings, day.occasion!)),
                    subtitle: Text(
                      '${number.format(int.parse(day.hijri.day))} $monthName · ${DateFormat.yMMMd(strings.localeName).format(day.gregorian)}',
                    ),
                    onTap: () =>
                        setState(() => _selected = int.parse(day.hijri.day)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
