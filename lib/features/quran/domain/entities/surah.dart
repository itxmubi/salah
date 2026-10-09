class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.translation,
    required this.ayahCount,
    required this.revelationType,
  });

  final int number;
  final String name;
  final String englishName;
  final String translation;
  final int ayahCount;
  final String revelationType;

  factory Surah.fromJson(Map<String, dynamic> json) => Surah(
    number: json['number'] as int,
    name: json['name'] as String,
    englishName: json['englishName'] as String,
    translation: json['englishNameTranslation'] as String,
    ayahCount:
        json['numberOfAyahs'] as int? ??
        (json['ayahs'] as List<dynamic>?)?.length ??
        0,
    revelationType: json['revelationType'] as String,
  );
}

class QuranAyah {
  const QuranAyah({
    required this.numberInSurah,
    required this.text,
    this.page,
    this.globalNumber,
    this.juz,
    this.surahNumber,
    this.surahName,
  });

  final int numberInSurah;
  final String text;
  final int? page;

  factory QuranAyah.fromJson(Map<String, dynamic> json) => QuranAyah(
    numberInSurah: json['numberInSurah'] as int,
    text: json['text'] as String,
    page: json['page'] as int?,
    globalNumber: json['number'] as int?,
    juz: json['juz'] as int?,
    surahNumber: (json['surah'] as Map<String, dynamic>?)?['number'] as int?,
    surahName:
        (json['surah'] as Map<String, dynamic>?)?['englishName'] as String?,
  );

  final int? globalNumber;
  final int? juz;
  final int? surahNumber;
  final String? surahName;
}

class SurahReading {
  const SurahReading({required this.surah, required this.ayahs});

  final Surah surah;
  final List<QuranAyah> ayahs;

  factory SurahReading.fromJson(Map<String, dynamic> json) => SurahReading(
    surah: Surah.fromJson(json),
    ayahs: (json['ayahs'] as List<dynamic>)
        .map((ayah) => QuranAyah.fromJson(ayah as Map<String, dynamic>))
        .toList(growable: false),
  );
}

class QuranReadingData {
  const QuranReadingData({required this.ayahs, required this.surahs});

  final List<QuranAyah> ayahs;
  final List<Surah> surahs;

  factory QuranReadingData.fromPartition(Map<String, dynamic> json) {
    final rawAyahs = json['ayahs'] as List<dynamic>;
    final ayahs = rawAyahs
        .map((ayah) => QuranAyah.fromJson(ayah as Map<String, dynamic>))
        .toList(growable: false);
    final surahsByNumber = <int, Surah>{};
    for (final item in rawAyahs.cast<Map<String, dynamic>>()) {
      final surahJson = item['surah'];
      if (surahJson is Map<String, dynamic>) {
        final surah = Surah.fromJson(surahJson);
        surahsByNumber[surah.number] = surah;
      }
    }
    return QuranReadingData(
      ayahs: ayahs,
      surahs: surahsByNumber.values.toList(growable: false),
    );
  }

  factory QuranReadingData.fromCompleteQuran(Map<String, dynamic> json) {
    final surahReadings = (json['surahs'] as List<dynamic>)
        .map((item) => SurahReading.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
    return QuranReadingData(
      ayahs: [
        for (final reading in surahReadings)
          for (final ayah in reading.ayahs)
            QuranAyah(
              numberInSurah: ayah.numberInSurah,
              text: ayah.text,
              page: ayah.page,
              globalNumber: ayah.globalNumber,
              juz: ayah.juz,
              surahNumber: reading.surah.number,
              surahName: reading.surah.englishName,
            ),
      ],
      surahs: [for (final surah in surahReadings) surah.surah],
    );
  }
}
