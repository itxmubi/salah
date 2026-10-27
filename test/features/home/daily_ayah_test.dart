import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:salah/features/home/presentation/widgets/daily_ayah_card.dart';
import 'package:salah/features/quran/data/datasources/quran_api_data_source.dart';
import 'package:salah/features/quran/domain/entities/daily_ayah.dart';
import 'package:salah/features/quran/domain/entities/surah.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:salah/features/quran/presentation/widgets/ayah_end_marker.dart';
import 'package:salah/l10n/generated/app_localizations.dart';

const verse = QuranAyah(
  numberInSurah: 5,
  text: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
  surahNumber: 94,
  globalNumber: 1,
  page: 596,
);
const surah = Surah(
  number: 94,
  name: 'الشرح',
  englishName: 'Ash-Sharh',
  translation: 'Relief',
  ayahCount: 8,
  revelationType: 'Meccan',
);

void main() {
  test('Daily verse is stable within a civil day and changes at midnight', () {
    expect(
      dailyAyahNumber(DateTime(2026, 10, 27, 1)),
      dailyAyahNumber(DateTime(2026, 10, 27, 23, 59)),
    );
    expect(
      dailyAyahNumber(DateTime(2026, 10, 28)),
      isNot(dailyAyahNumber(DateTime(2026, 10, 27))),
    );
    for (final date in [DateTime(1900), DateTime(2000), DateTime(2100)]) {
      expect(dailyAyahNumber(date), inInclusiveRange(1, 6236));
    }
  });
  test(
    'Daily provider uses a deterministic Arabic endpoint and reuses the daily result',
    () async {
      final requests = <String>[];
      final source = QuranApiDataSource(
        client: MockClient((request) async {
          requests.add(request.url.path);
          return http.Response(
            jsonEncode({
              'code': 200,
              'data': {
                'number': 1,
                'numberInSurah': 5,
                'text': verse.text,
                'surah': {
                  'number': 94,
                  'name': surah.name,
                  'englishName': surah.englishName,
                  'englishNameTranslation': surah.translation,
                  'numberOfAyahs': 8,
                  'revelationType': 'Meccan',
                },
              },
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final container = ProviderContainer(
        overrides: [quranApiDataSourceProvider.overrideWithValue(source)],
      );
      addTearDown(container.dispose);
      addTearDown(source.close);
      final date = DateTime.utc(2026, 10, 27);
      final subscription = container.listen(dailyAyahProvider(date), (_, _) {});
      addTearDown(subscription.close);
      expect(
        (await container.read(dailyAyahProvider(date).future)).surah.number,
        94,
      );
      await container.read(dailyAyahProvider(date).future);
      expect(requests, ['/v1/ayah/${dailyAyahNumber(date)}/quran-uthmani']);
    },
  );
  testWidgets(
    'Daily card displays text and translation and opens the selected ayah',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            dailyAyahProvider.overrideWith(
              (ref, date) async => const DailyAyah(ayah: verse, surah: surah),
            ),
            dailyAyahTranslationProvider.overrideWith(
              (ref, number) async => 'For indeed, with hardship comes ease.',
            ),
            surahReadingProvider.overrideWith(
              (ref, number) async =>
                  const SurahReading(surah: surah, ayahs: [verse]),
            ),
            quranBismillahProvider.overrideWith(
              (ref) async => 'بسم الله الرحمن الرحيم',
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: ListView(
                children: [DailyAyahCard(date: DateTime.utc(2026, 10, 27))],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ayah of the Day'), findsOneWidget);
      expect(find.text(verse.text), findsOneWidget);
      expect(
        find.text('For indeed, with hardship comes ease.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Read this Surah'));
      await tester.pumpAndSettle();
      expect(find.byType(SurahReaderScreen), findsOneWidget);
      expect(
        tester.widget<AyahEndMarker>(find.byType(AyahEndMarker)).isHighlighted,
        isTrue,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Daily card failure can be retried without failing Home', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyAyahProvider.overrideWith((ref, date) async {
            attempts++;
            if (attempts == 1) throw StateError('Offline');
            return const DailyAyah(ayah: verse, surah: surah);
          }),
          dailyAyahTranslationProvider.overrideWith(
            (ref, number) async => 'Translation',
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: ListView(
              children: [DailyAyahCard(date: DateTime.utc(2026, 10, 27))],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(attempts, 2);
    expect(find.text(verse.text), findsOneWidget);
  });
}
