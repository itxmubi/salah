import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quran_api_data_source.dart';
import '../../domain/entities/surah.dart';

final quranApiDataSourceProvider = Provider<QuranApiDataSource>((ref) {
  final dataSource = QuranApiDataSource();
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
