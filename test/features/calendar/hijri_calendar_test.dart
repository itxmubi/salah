import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salah/features/calendar/domain/entities/hijri_month.dart';
import 'package:salah/features/calendar/domain/services/hijri_calendar_engine.dart';
import 'package:salah/features/calendar/presentation/providers/hijri_calendar_providers.dart';
import 'package:salah/features/calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:salah/l10n/generated/app_localizations.dart';

void main() {
  const engine = HijriCalendarEngine();
  test('Umm al-Qura conversion matches documented dates', () {
    final date = engine.fromGregorian(DateTime.utc(2018, 11, 12));
    expect(date.year, '1440');
    expect(date.monthNumber, 3);
    expect(date.day, '4');
    expect(
      engine.month(const HijriMonthId(1415, 7)).days[26].gregorian,
      DateTime.utc(1994, 12, 29),
    );
    expect(engine.fromGregorian(DateTime.utc(2024, 4, 10)).day, '1');
    expect(engine.fromGregorian(DateTime.utc(2024, 4, 10)).monthNumber, 10);
  });
  test(
    'All supported month boundaries round-trip and retain historical table data',
    () {
      for (
        var year = HijriCalendarEngine.minYear;
        year <= HijriCalendarEngine.maxYear;
        year++
      ) {
        for (var month = 1; month <= 12; month++) {
          final data = engine.month(HijriMonthId(year, month));
          // The package's historical table preserves the 28-day Shaban 1364
          // entry; do not invent a day or shift all subsequent conversions.
          // See R. H. van Gent's Umm al-Qura calendar table at Utrecht University.
          if (year == 1364 && month == 8) {
            expect(data.days.length, 28);
          } else {
            expect([29, 30], contains(data.days.length));
          }
          for (final day in [data.days.first, data.days.last]) {
            final roundTrip = engine.fromGregorian(day.gregorian);
            expect(roundTrip.year, '$year');
            expect(roundTrip.monthNumber, month);
            expect(roundTrip.day, day.hijri.day);
          }
          for (var i = 1; i < data.days.length; i++) {
            expect(
              data.days[i].gregorian.difference(data.days[i - 1].gregorian),
              const Duration(days: 1),
            );
          }
        }
      }
    },
  );
  test('Month navigation crosses years and refuses unsupported years', () {
    expect(const HijriMonthId(1448, 1).previous, const HijriMonthId(1447, 12));
    expect(const HijriMonthId(1448, 12).next, const HijriMonthId(1449, 1));
    expect(engine.supports(const HijriMonthId(1356, 1).previous), isFalse);
    expect(engine.supports(const HijriMonthId(1500, 12).next), isFalse);
    expect(() => engine.month(const HijriMonthId(1501, 1)), throwsRangeError);
  });
  test('Occasions belong to their correct Hijri dates', () {
    expect(
      engine.month(const HijriMonthId(1448, 9)).days.first.occasion,
      IslamicOccasion.ramadan,
    );
    expect(
      engine.month(const HijriMonthId(1448, 10)).days.first.occasion,
      IslamicOccasion.eidFitr,
    );
    expect(
      engine.month(const HijriMonthId(1448, 12)).days[8].occasion,
      IslamicOccasion.arafah,
    );
    expect(
      engine.month(const HijriMonthId(1448, 12)).days[9].occasion,
      IslamicOccasion.eidAdha,
    );
    expect(
      engine
          .month(const HijriMonthId(1448, 2))
          .days
          .every((d) => d.occasion == null),
      isTrue,
    );
  });
  testWidgets(
    'Calendar browses across years, selects a day and returns to today',
    (tester) async {
      final date = DateTime.utc(2026, 10, 27);
      final hijri = engine.fromGregorian(date);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            calendarDateReaderProvider.overrideWithValue(() => date),
            calendarTodayProvider.overrideWith((ref) => Stream.value(date)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HijriCalendarScreen(
              initialMonth: HijriMonthId(1448, 12),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('Muharram 1449'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('hijri-day-1449-1-10')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('10 Muharram 1449'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('10 Muharram 1449'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.widgetWithText(TextButton, 'Today'),
        -240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(TextButton, 'Today'));
      await tester.pumpAndSettle();
      expect(find.text('${hijri.monthName} ${hijri.year}'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
