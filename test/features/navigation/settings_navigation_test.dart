import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salah/app/app_router.dart';
import 'package:salah/app/salah_app.dart';
import 'package:salah/core/settings/app_settings.dart';
import 'package:salah/features/calendar/presentation/providers/hijri_calendar_providers.dart';
import 'package:salah/features/calendar/presentation/screens/hijri_calendar_screen.dart';
import 'package:salah/features/notifications/presentation/providers/notification_providers.dart';
import 'package:salah/features/prayer/presentation/providers/prayer_controller.dart';
import 'package:salah/features/prayer/presentation/screens/calculation_settings_screen.dart';

class ReadySettings extends AppSettingsController {
  @override
  Future<AppSettings> build() async => const AppSettings(setupComplete: true);
}

class SettingsOnlyPrayer extends PrayerController {
  @override
  Future<PrayerState> build() async => const PrayerState();
}

void main() {
  testWidgets('Settings opens calculation controls and returns to Settings', (
    tester,
  ) async {
    final router = createAppRouter()..go('/settings');
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appRouterProvider.overrideWithValue(router),
          appSettingsProvider.overrideWith(ReadySettings.new),
          prayerControllerProvider.overrideWith(SettingsOnlyPrayer.new),
          notificationSyncProvider.overrideWith(
            (ref) async => const AlertStatus(),
          ),
        ],
        child: const SalahApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculation settings'));
    await tester.pumpAndSettle();
    expect(find.byType(CalculationSettingsScreen), findsOneWidget);
    expect(find.text('Asr calculation'), findsOneWidget);
    expect(find.text('Monthly timetable'), findsNothing);
    router.pop();
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/settings');
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'Home exposes the full calendar and omits repeated location toolbar actions',
    (tester) async {
      final router = createAppRouter();
      addTearDown(router.dispose);
      final date = DateTime.utc(2026, 10, 27);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appRouterProvider.overrideWithValue(router),
            appSettingsProvider.overrideWith(ReadySettings.new),
            prayerControllerProvider.overrideWith(SettingsOnlyPrayer.new),
            notificationSyncProvider.overrideWith(
              (ref) async => const AlertStatus(),
            ),
            calendarDateReaderProvider.overrideWithValue(() => date),
            calendarTodayProvider.overrideWith((ref) => Stream.value(date)),
          ],
          child: const SalahApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithIcon(IconButton, Icons.location_on_outlined),
        findsNothing,
      );
      expect(find.byTooltip('Your location'), findsNothing);
      await tester.tap(find.byTooltip('Islamic calendar'));
      await tester.pumpAndSettle();
      expect(find.byType(HijriCalendarScreen), findsOneWidget);
      router.pop();
      await tester.pumpAndSettle();
      router.go('/prayer');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Choose location'), findsNothing);
      await tester.tap(find.byTooltip('Calculation settings'));
      await tester.pumpAndSettle();
      expect(find.byType(CalculationSettingsScreen), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
