import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:salah/features/quran/data/datasources/quran_api_data_source.dart';
import 'package:salah/features/quran/data/datasources/quran_cache.dart';
import 'package:salah/features/quran/presentation/providers/quran_reader_preferences.dart';

Map<String, dynamic> fullFixture() {
  var global = 0;
  return {
    'surahs': List.generate(
      114,
      (s) => {
        'number': s + 1,
        'name': 'سورة',
        'englishName': 'Surah ${s + 1}',
        'englishNameTranslation': '',
        'revelationType': 'Meccan',
        'numberOfAyahs': s < 80 ? 55 : 54,
        'ayahs': List.generate(
          s < 80 ? 55 : 54,
          (a) => {
            'number': ++global,
            'numberInSurah': a + 1,
            'text': 'آية',
            'page': (global - 1) * 604 ~/ 6236 + 1,
            'juz': (global - 1) * 30 ~/ 6236 + 1,
          },
        ),
      },
    ),
  };
}

void main() {
  test('Quran requests time out instead of loading forever', () async {
    final source = QuranApiDataSource(
      timeout: const Duration(milliseconds: 5),
      client: MockClient((_) => Completer<http.Response>().future),
    );
    await expectLater(
      source.getSurahs(),
      throwsA(
        isA<QuranNetworkException>().having(
          (e) => e.timedOut,
          'timed out',
          true,
        ),
      ),
    );
    source.close();
  });

  test(
    'Downloaded Quran survives restart and supplies surah, juz, page and directory offline',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'salah-quran-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final cache = FileQuranCache(directory: () async => directory);
      final source = QuranApiDataSource(
        cache: cache,
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'code': 200, 'status': 'OK', 'data': fullFixture()}),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      await source.downloadArabic();
      source.close();
      var networkCalls = 0;
      final offline = QuranApiDataSource(
        cache: FileQuranCache(directory: () async => directory),
        client: MockClient((_) async {
          networkCalls++;
          throw http.ClientException('Offline');
        }),
      );
      expect(await offline.hasDownload(), isTrue);
      expect(await offline.getSurahs(), hasLength(114));
      expect(
        (await offline.getSurah(2, edition: 'quran-uthmani')).ayahs,
        hasLength(55),
      );
      expect(
        (await offline.getPageReading(2)).ayahs.every((a) => a.page == 2),
        isTrue,
      );
      expect(
        (await offline.getJuzReading(2)).ayahs.every((a) => a.juz == 2),
        isTrue,
      );
      final ayah = await offline.getAyah(55, edition: 'quran-uthmani');
      expect((ayah.data as Map<String, dynamic>)['number'], 55);
      expect(
        ((ayah.data as Map<String, dynamic>)['surah']
            as Map<String, dynamic>)['number'],
        1,
      );
      expect(networkCalls, 0);
      offline.close();
    },
  );

  test(
    'Incomplete download is rejected without marking content ready',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'salah-quran-bad-test',
      );
      addTearDown(() => directory.delete(recursive: true));
      final source = QuranApiDataSource(
        cache: FileQuranCache(directory: () async => directory),
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'code': 200,
              'data': {'surahs': []},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      await expectLater(source.downloadArabic(), throwsFormatException);
      expect(await source.hasDownload(), isFalse);
      source.close();
    },
  );

  test(
    'Reading settings, progress and bookmarks persist across provider restarts',
    () async {
      final container = ProviderContainer();
      await container.read(quranReaderPreferencesProvider.future);
      final controller = container.read(
        quranReaderPreferencesProvider.notifier,
      );
      const position = ReadingPosition(
        kind: 'surah',
        number: 2,
        offset: 425,
        ayah: 20,
        surah: 2,
      );
      await controller.setFontSize(34);
      await controller.remember(position);
      await controller.toggleBookmark(position);
      container.dispose();
      final restored = ProviderContainer();
      addTearDown(restored.dispose);
      final settings = await restored.read(
        quranReaderPreferencesProvider.future,
      );
      expect(settings.fontSize, 34);
      expect(settings.last!.offset, 425);
      expect(settings.bookmarks.single.ayah, 20);
      await restored
          .read(quranReaderPreferencesProvider.notifier)
          .toggleBookmark(position);
      expect(
        restored.read(quranReaderPreferencesProvider).requireValue.bookmarks,
        isEmpty,
      );
    },
  );
  test(
    'Flushing a closed reader preserves the newer Continue reading entry',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(quranReaderPreferencesProvider.future);
      final controller = container.read(
        quranReaderPreferencesProvider.notifier,
      );
      await controller.remember(const ReadingPosition(kind: 'page', number: 1));
      await controller.remember(const ReadingPosition(kind: 'page', number: 2));
      await controller.remember(
        const ReadingPosition(kind: 'page', number: 1, offset: 250),
        makeCurrent: false,
      );
      final preferences = container
          .read(quranReaderPreferencesProvider)
          .requireValue;
      expect(preferences.last!.number, 2);
      expect(preferences.positions['page:1']!.offset, 250);
    },
  );
}
