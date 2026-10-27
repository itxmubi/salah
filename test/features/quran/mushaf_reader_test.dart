import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:salah/features/quran/domain/entities/surah.dart';
import 'package:salah/features/quran/presentation/providers/quran_providers.dart';
import 'package:salah/features/quran/presentation/screens/quran_page_reader_screen.dart';
import 'package:salah/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:salah/features/quran/presentation/widgets/ayah_end_marker.dart';
import 'package:salah/features/quran/presentation/widgets/mushaf_page_border.dart';
import 'package:salah/features/quran/presentation/widgets/mushaf_reader.dart';
import 'package:salah/features/quran/presentation/widgets/mushaf_theme.dart';
import 'package:salah/features/quran/presentation/widgets/quran_text_view.dart';
import 'package:salah/features/quran/presentation/widgets/surah_header_banner.dart';
import 'package:salah/l10n/generated/app_localizations.dart';

const _bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
const _verse = 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ';
const _ibrahim = Surah(
  number: 14,
  name: 'سُورَةُ إِبْرَاهِيمَ',
  englishName: 'Ibrahim',
  translation: 'Abraham',
  ayahCount: 52,
  revelationType: 'Meccan',
);

Surah _surah(int number) => Surah(
  number: number,
  name: 'سورة',
  englishName: 'Surah $number',
  translation: '',
  ayahCount: 2,
  revelationType: 'Meccan',
);

QuranAyah _ayah(
  int number, {
  int? surah = 14,
  int? page = 255,
  String text = _verse,
}) => QuranAyah(
  numberInSurah: number,
  text: text,
  surahNumber: surah,
  page: page,
  juz: 13,
);

Widget _app(Widget child, {bool dark = false, double textScale = 1}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Scaffold(body: child),
    );

Future<void> _viewport(WidgetTester tester, Size size) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
}

TextSpan _paragraph(WidgetTester tester) {
  var span =
      tester
              .widget<RichText>(
                find
                    .descendant(
                      of: find.byType(QuranTextView).first,
                      matching: find.byType(RichText),
                    )
                    .first,
              )
              .text
          as TextSpan;
  // Text.rich adds a style-inheriting parent around the supplied paragraph.
  while (span.children?.length == 1 && span.children!.first is TextSpan) {
    span = span.children!.first as TextSpan;
  }
  return span;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Use the shipped font so layout tests also exercise real Quranic metrics.
    final font = FontLoader(MushafTheme.fontFamily)
      ..addFont(
        rootBundle.load('assets/fonts/amiri_quran/AmiriQuran-Regular.ttf'),
      );
    await font.load();
  });

  for (final number in [1, 9, 14]) {
    testWidgets('opening Bismillah rules for surah $number', (tester) async {
      await tester.pumpWidget(
        _app(
          MushafReader(
            ayahs: [_ayah(1, surah: number)],
            surahs: [_surah(number)],
            bismillah: _bismillah,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SurahHeaderBanner), findsOneWidget);
      expect(
        find.byKey(const ValueKey('mushaf-bismillah')),
        number == 14 ? findsOneWidget : findsNothing,
      );
    });
  }

  testWidgets('continuation pages have no title or extra Bismillah', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(MushafReader(ayahs: [_ayah(10)], surahs: const [_ibrahim])),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ibrahim'), findsOneWidget);
    expect(find.text('Part 13'), findsOneWidget);
    expect(find.byType(SurahHeaderBanner), findsNothing);
    expect(find.byKey(const ValueKey('mushaf-bismillah')), findsNothing);
  });

  testWidgets('a new surah within a page gets its own headpiece', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        MushafReader(
          ayahs: [_ayah(43, surah: 13), _ayah(1)],
          surahs: [_surah(13), _ibrahim],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SurahHeaderBanner), findsOneWidget);
    expect(
      tester
          .widget<SurahHeaderBanner>(find.byType(SurahHeaderBanner))
          .surahNameArabic,
      _ibrahim.name,
    );
    expect(find.byKey(const ValueKey('mushaf-bismillah')), findsOneWidget);
    expect(find.byType(QuranTextView), findsNWidgets(2));
  });

  testWidgets('separate Bismillah never duplicates a prepended API prefix', (
    tester,
  ) async {
    const source = 'بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ $_verse';
    final ayah = _ayah(1, text: source);
    await tester.pumpWidget(
      _app(
        MushafReader(
          ayahs: [ayah],
          surahs: const [_ibrahim],
          bismillah: _bismillah,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_paragraph(tester).toPlainText(), startsWith(_verse));
    expect(find.text(_bismillah), findsOneWidget);
    expect(
      ayah.text,
      source,
      reason: 'Presentation must not mutate API models.',
    );
  });

  testWidgets('tapping flowing text and its marker selects the correct ayah', (
    tester,
  ) async {
    final ayahs = [_ayah(2), _ayah(3)];
    final selected = <QuranAyah>[];
    await tester.pumpWidget(
      _app(
        MushafReader(
          ayahs: ayahs,
          surahs: const [_ibrahim],
          onAyahTap: selected.add,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final richText = find
        .descendant(
          of: find.byType(QuranTextView),
          matching: find.byType(RichText),
        )
        .first;
    final paragraph = tester.renderObject<RenderParagraph>(richText);
    final firstGlyph = paragraph
        .getBoxesForSelection(
          const TextSelection(baseOffset: 0, extentOffset: 1),
        )
        .first
        .toRect();
    await tester.tapAt(paragraph.localToGlobal(firstGlyph.center));
    await tester.pump();

    expect(selected, [ayahs.first]);
    expect(
      (_paragraph(tester).children!.first as TextSpan).style!.backgroundColor,
      MushafTheme.light.highlight,
    );
    await tester.tap(find.byType(AyahEndMarker).last);
    await tester.pump();
    expect(selected.last, same(ayahs.last));
    final markers = tester.widgetList<AyahEndMarker>(
      find.byType(AyahEndMarker),
    );
    expect(markers.first.isHighlighted, isFalse);
    expect(markers.last.isHighlighted, isTrue);
    expect(find.text('٢'), findsOneWidget);
    expect(find.text('٣'), findsOneWidget);
  });

  testWidgets('an externally supplied playing ayah is highlighted', (
    tester,
  ) async {
    final ayah = _ayah(2);
    await tester.pumpWidget(
      _app(
        MushafReader(
          ayahs: [ayah],
          surahs: const [_ibrahim],
          playingAyah: _ayah(2),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<AyahEndMarker>(find.byType(AyahEndMarker)).isHighlighted,
      isTrue,
    );
  });

  testWidgets(
    'long readings build folios lazily and keep unknown-metadata text',
    (tester) async {
      await _viewport(tester, const Size(390, 800));
      final ayahs = List.generate(
        286,
        (index) => _ayah(index + 1, surah: 2, page: index ~/ 8 + 2),
      );
      await tester.pumpWidget(
        _app(MushafReader(ayahs: ayahs, surahs: [_surah(2)])),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MushafPageBorder).evaluate().length, lessThan(5));
      expect(find.text('٢٨٦'), findsNothing);
      await tester.scrollUntilVisible(
        find.text('٢٨٦'),
        600,
        maxScrolls: 100,
        scrollable: find.byType(Scrollable),
      );
      expect(find.text('٢٨٦'), findsOneWidget);

      // Missing chapter metadata must not cause verses to disappear.
      await tester.pumpWidget(
        _app(MushafReader(ayahs: [_ayah(12, surah: null)], surahs: const [])),
      );
      await tester.pumpAndSettle();
      expect(_paragraph(tester).toPlainText(), contains(_verse));
    },
  );

  testWidgets('full-page navigation keeps the existing provider contract', (
    tester,
  ) async {
    final requested = <int>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pageReadingProvider.overrideWith((ref, page) async {
            requested.add(page);
            return QuranReadingData(
              ayahs: [_ayah(2, page: page)],
              surahs: const [_ibrahim],
            );
          }),
          quranBismillahProvider.overrideWith((ref) async => _bismillah),
        ],
        child: _app(const QuranPageReaderScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(requested, [1]);
    expect(find.text('Page 1 of 604'), findsOneWidget);
    final previous = find.widgetWithText(OutlinedButton, 'Previous page');
    expect(tester.widget<OutlinedButton>(previous).onPressed, isNull);

    await tester.tap(find.text('Next page'));
    await tester.pumpAndSettle();
    expect(requested, [1, 2]);
    expect(find.text('Page 2 of 604'), findsOneWidget);
    expect(tester.widget<OutlinedButton>(previous).onPressed, isNotNull);
    await tester.tap(find.text('Previous page'));
    await tester.pumpAndSettle();
    expect(find.text('Page 1 of 604'), findsOneWidget);
  });

  testWidgets('surah reader accepts existing ayahs without surahNumber', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          surahReadingProvider.overrideWith(
            (ref, number) async =>
                SurahReading(surah: _ibrahim, ayahs: [_ayah(1, surah: null)]),
          ),
          quranBismillahProvider.overrideWith((ref) async => _bismillah),
        ],
        child: _app(const SurahReaderScreen(number: 14)),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ibrahim'), findsOneWidget);
    expect(find.byType(SurahHeaderBanner), findsOneWidget);
    expect(find.byType(QuranTextView), findsOneWidget);
  });

  for (final size in [const Size(320, 700), const Size(1024, 1366)]) {
    testWidgets('paper layout supports $size and large text in both themes', (
      tester,
    ) async {
      await _viewport(tester, size);
      for (final dark in [false, true]) {
        await tester.pumpWidget(
          _app(
            MushafReader(ayahs: [_ayah(1), _ayah(2)], surahs: const [_ibrahim]),
            dark: dark,
            textScale: 1.8,
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final frame = tester.widget<MushafPageBorder>(
          find.byType(MushafPageBorder),
        );
        expect(frame.palette, dark ? MushafTheme.dark : MushafTheme.light);
        expect(
          tester.getSize(find.byType(MushafPageBorder)).width,
          lessThanOrEqualTo(820),
        );
      }
    });
  }
}
