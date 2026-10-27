import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:salah/app/salah_app.dart';
import 'package:salah/features/quran/domain/entities/daily_ayah.dart';
import 'package:salah/features/quran/domain/entities/surah.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/notifications/presentation/providers/notification_providers.dart';

void main() {
  testWidgets('App starts with guided setup and accessible navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyAyahProvider.overrideWith(
            (ref, date) async => const DailyAyah(
              ayah: QuranAyah(
                numberInSurah: 5,
                text: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
                surahNumber: 94,
              ),
              surah: Surah(
                number: 94,
                name: 'الشرح',
                englishName: 'Ash-Sharh',
                translation: 'Relief',
                ayahCount: 8,
                revelationType: 'Meccan',
              ),
            ),
          ),
          dailyAyahTranslationProvider.overrideWith(
            (ref, number) async => 'For indeed, with hardship comes ease.',
          ),
          notificationSyncProvider.overrideWith(
            (ref) async => const AlertStatus(),
          ),
        ],
        child: const SalahApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Set up your prayer times'), findsOneWidget);
    expect(find.text('1. Choose your location'), findsOneWidget);
    expect(find.text('Quran'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
