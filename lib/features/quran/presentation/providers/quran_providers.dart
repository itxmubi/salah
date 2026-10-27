import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quran_api_data_source.dart';
import '../../data/datasources/quran_cache.dart';
import '../../domain/entities/surah.dart';
import '../../domain/entities/daily_ayah.dart';

final quranApiDataSourceProvider = Provider<QuranApiDataSource>((ref) {
  final dataSource = QuranApiDataSource(cache: FileQuranCache());
  ref.onDispose(dataSource.close);
  return dataSource;
});

final surahListProvider = FutureProvider<List<Surah>>(
  (ref) => ref.watch(quranApiDataSourceProvider).getSurahs(),
);

final surahReadingProvider = FutureProvider.family<SurahReading, int>(
  (ref, number) => ref
      .watch(quranApiDataSourceProvider)
      .getSurah(number, edition: 'quran-uthmani'),
);

final juzReadingProvider = FutureProvider.family<QuranReadingData, int>(
  (ref, number) => ref.watch(quranApiDataSourceProvider).getJuzReading(number),
);

final pageReadingProvider = FutureProvider.family<QuranReadingData, int>(
  (ref, number) => ref.watch(quranApiDataSourceProvider).getPageReading(number),
);

final fullQuranProvider = FutureProvider<QuranReadingData>(
  (ref) => ref.watch(quranApiDataSourceProvider).getFullQuran(),
);

final quranBismillahProvider = FutureProvider<String>((ref) async {
  final fatiha = await ref
      .watch(quranApiDataSourceProvider)
      .getSurah(1, edition: 'quran-uthmani');
  return fatiha.ayahs.first.text;
});

final quranDownloadProvider =
    AsyncNotifierProvider<QuranDownloadController, bool>(
      QuranDownloadController.new,
    );

class QuranDownloadController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() => ref.watch(quranApiDataSourceProvider).hasDownload();

  Future<void> download() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(quranApiDataSourceProvider).downloadArabic();
      ref.invalidate(surahListProvider);
      ref.invalidate(surahReadingProvider);
      ref.invalidate(juzReadingProvider);
      ref.invalidate(pageReadingProvider);
      return true;
    });
  }
}

final dailyAyahProvider = FutureProvider.autoDispose
    .family<DailyAyah, DateTime>((ref, date) async {
      final result = await ref
          .watch(quranApiDataSourceProvider)
          .getAyah(dailyAyahNumber(date), edition: 'quran-uthmani');
      final data = result.data;
      if (data is! Map<String, dynamic> ||
          data['surah'] is! Map<String, dynamic>) {
        throw const FormatException('Ayah metadata is missing');
      }
      return DailyAyah(
        ayah: QuranAyah.fromJson(data),
        surah: Surah.fromJson(data['surah'] as Map<String, dynamic>),
      );
    });

final dailyAyahTranslationProvider = FutureProvider.autoDispose
    .family<String, int>((ref, number) async {
      final result = await ref
          .watch(quranApiDataSourceProvider)
          .getAyah(number, edition: 'en.sahih');
      final data = result.data;
      if (data is! Map<String, dynamic> || data['text'] is! String) {
        throw const FormatException('Translation is missing');
      }
      return data['text'] as String;
    });
