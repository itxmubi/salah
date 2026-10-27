import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:salah/features/quran/domain/entities/surah.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/quran/presentation/providers/quran_reader_preferences.dart';
import 'package:salah/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:salah/features/quran/presentation/widgets/ayah_end_marker.dart';
import 'package:salah/features/quran/presentation/widgets/quran_page_jump_dialog.dart';
import 'package:salah/l10n/generated/app_localizations.dart';

const surah = Surah(
  number: 2,
  name: 'البقرة',
  englishName: 'Al-Baqara',
  translation: 'The Cow',
  ayahCount: 100,
  revelationType: 'Medinan',
);
final ayahs = List.generate(
  100,
  (i) => QuranAyah(
    numberInSurah: i + 1,
    text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
    surahNumber: 2,
    page: i ~/ 3 + 2,
    juz: 1,
  ),
);
Widget app(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  test(
    'Page navigation accepts Western, Arabic and Persian digits and rejects invalid ranges',
    () {
      expect(parseQuranPage('604'), 604);
      expect(parseQuranPage('٦٠٤'), 604);
      expect(parseQuranPage('۶۰۴'), 604);
      for (final value in ['0', '605', '-1', 'abc', '']) {
        expect(parseQuranPage(value), isNull);
      }
    },
  );

  testWidgets(
    'Invalid page input displays validation; Arabic page input opens a page',
    (tester) async {
      int? chosen;
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  chosen = await showDialog<int>(
                    context: context,
                    builder: (_) => const QuranPageJumpDialog(currentPage: 1),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '605');
      await tester.tap(find.text('Open page'));
      await tester.pumpAndSettle();
      expect(find.text('Page (1–604)'), findsNWidgets(2));
      expect(chosen, isNull);
      await tester.enterText(find.byType(TextFormField), '٦٠٤');
      await tester.tap(find.text('Open page'));
      await tester.pumpAndSettle();
      expect(chosen, 604);
    },
  );

  testWidgets(
    'Reader restores an ayah, bookmarks it and keeps earlier folios reachable',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          surahReadingProvider.overrideWith(
            (ref, number) async => SurahReading(surah: surah, ayahs: ayahs),
          ),
          quranBismillahProvider.overrideWith(
            (ref) async => 'بسم الله الرحمن الرحيم',
          ),
        ],
      );
      addTearDown(container.dispose);
      await container.read(quranReaderPreferencesProvider.future);
      await container
          .read(quranReaderPreferencesProvider.notifier)
          .remember(
            const ReadingPosition(kind: 'surah', number: 2, surah: 2, ayah: 60),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: app(const SurahReaderScreen(number: 2)),
        ),
      );
      await tester.pumpAndSettle();
      final marker = find.byWidgetPredicate(
        (w) => w is AyahEndMarker && w.number == 60,
      );
      expect(marker, findsOneWidget);
      await tester.tap(marker);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bookmark ayah'));
      await tester.pumpAndSettle();
      expect(
        container
            .read(quranReaderPreferencesProvider)
            .requireValue
            .bookmarks
            .single
            .ayah,
        60,
      );
      expect(find.text('Remove bookmark'), findsOneWidget);
      Navigator.of(tester.element(find.text('Remove bookmark'))).pop();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pumpAndSettle();
      final scrollable = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      expect(scrollable.position.pixels, lessThan(0));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
