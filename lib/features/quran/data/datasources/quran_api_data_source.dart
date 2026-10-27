import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;

import '../../domain/entities/surah.dart';
import 'quran_cache.dart';

class QuranApiDataSource {
  QuranApiDataSource({
    http.Client? client,
    QuranCache? cache,
    this.timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _cache = cache;
  final QuranCache? _cache;
  final Duration timeout;
  Map<String, dynamic>? _download;

  Future<bool> hasDownload() async {
    final data = await _complete();
    return data != null;
  }

  Future<Map<String, dynamic>?> _complete() async {
    if (_download != null) return _download;
    final payload = await _cache?.read('complete-quran-uthmani');
    final data = payload?['data'];
    if (data is Map<String, dynamic> && _validComplete(data)) _download = data;
    return _download;
  }

  bool _validComplete(Map<String, dynamic> data) {
    final surahs = data['surahs'];
    if (surahs is! List || surahs.length != 114) return false;
    var count = 0;
    final pages = <int>{};
    final juzs = <int>{};
    for (var i = 0; i < surahs.length; i++) {
      final surah = surahs[i];
      if (surah is! Map<String, dynamic> ||
          surah['number'] != i + 1 ||
          surah['ayahs'] is! List ||
          (surah['ayahs'] as List).isEmpty ||
          surah['name'] is! String ||
          surah['englishName'] is! String ||
          surah['englishNameTranslation'] is! String ||
          surah['revelationType'] is! String ||
          surah['numberOfAyahs'] != (surah['ayahs'] as List).length) {
        return false;
      }
      var numberInSurah = 0;
      for (final ayah in surah['ayahs'] as List) {
        numberInSurah++;
        if (ayah is! Map ||
            ayah['text'] is! String ||
            (ayah['text'] as String).isEmpty ||
            ayah['numberInSurah'] != numberInSurah ||
            ayah['number'] != count + 1 ||
            ayah['page'] is! int ||
            ayah['juz'] is! int) {
          return false;
        }
        final page = ayah['page'] as int;
        final juz = ayah['juz'] as int;
        if (page < 1 || page > 604 || juz < 1 || juz > 30) return false;
        pages.add(page);
        juzs.add(juz);
        count++;
      }
    }
    return count == 6236 && pages.length == 604 && juzs.length == 30;
  }

  Future<void> downloadArabic() async {
    final result = await _get('/quran/quran-uthmani', bypassCache: true);
    final data = result.data;
    if (data is! Map<String, dynamic> || !_validComplete(data)) {
      throw const FormatException('The Quran download is incomplete.');
    }
    if (_cache == null) throw StateError('Offline storage unavailable');
    await _cache.write('complete-quran-uthmani', {'data': data});
    _download = data;
  }

  QuranApiResult? _fromDownload(Map<String, dynamic> complete, String path) {
    final surahs = (complete['surahs'] as List).cast<Map<String, dynamic>>();
    if (path == '/surah') return QuranApiResult(data: surahs, status: 'OK');
    if (path == '/quran/quran-uthmani' || path == '/quran') {
      return QuranApiResult(data: complete, status: 'OK');
    }
    final parts = path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2 || (parts.length > 2 && parts[2] != 'quran-uthmani')) {
      return null;
    }
    final number = int.tryParse(parts[1]);
    if (parts[0] == 'ayah' && number != null) {
      for (final surah in surahs) {
        for (final raw in surah['ayahs'] as List) {
          final ayah = raw as Map<String, dynamic>;
          if (ayah['number'] == number) {
            return QuranApiResult(
              data: {
                ...ayah,
                'surah': {...surah}..remove('ayahs'),
              },
              status: 'OK',
            );
          }
        }
      }
    }
    if (parts[0] == 'surah' && number != null && number >= 1 && number <= 114) {
      return QuranApiResult(data: surahs[number - 1], status: 'OK');
    }
    if (!['page', 'juz'].contains(parts[0]) || number == null) return null;
    final ayahs = <Map<String, dynamic>>[];
    for (final surah in surahs) {
      for (final raw in surah['ayahs'] as List) {
        final ayah = raw as Map<String, dynamic>;
        if (ayah[parts[0]] == number) {
          ayahs.add({
            ...ayah,
            'surah': {...surah}..remove('ayahs'),
          });
        }
      }
    }
    return QuranApiResult(data: {'ayahs': ayahs}, status: 'OK');
  }

  static const _host = 'api.alquran.cloud';
  static const _basePath = '/v1';
  final http.Client _client;

  void close() => _client.close();

  Future<List<Surah>> getSurahs() async {
    final data = await _getData('/surah') as List<dynamic>;
    return data
        .map((item) => Surah.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<SurahReading> getSurah(
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) async {
    _checkRange('surah', number, 1, 114);
    final editionPath = edition == null ? '' : '/${_segment(edition)}';
    final data = await _getData(
      '/surah/$number$editionPath',
      query: {
        if (offset != null) 'offset': '$offset',
        if (limit != null) 'limit': '$limit',
      },
    );
    return SurahReading.fromJson(data as Map<String, dynamic>);
  }

  Future<QuranReadingData> getJuzReading(int number) async {
    final data = await getJuz(number, edition: 'quran-uthmani');
    return QuranReadingData.fromPartition(data.data as Map<String, dynamic>);
  }

  Future<QuranReadingData> getPageReading(int number) async {
    final result = await getPage(number, edition: 'quran-uthmani');
    return QuranReadingData.fromPartition(result.data as Map<String, dynamic>);
  }

  Future<QuranReadingData> getFullQuran({String? edition}) async {
    final result = await getCompleteQuran(edition: edition ?? 'quran-uthmani');
    return QuranReadingData.fromCompleteQuran(
      result.data as Map<String, dynamic>,
    );
  }

  Future<QuranApiResult> getSurahEditions(
    int number,
    List<String> editions, {
    int? offset,
    int? limit,
  }) {
    _checkRange('surah', number, 1, 114);
    _requireEditions(editions);
    return _get(
      '/surah/$number/editions/${_segment(editions.join(','))}',
      query: {
        if (offset != null) 'offset': '$offset',
        if (limit != null) 'limit': '$limit',
      },
    );
  }

  /// Fetches one Ayah in the default edition or a requested edition.
  Future<QuranApiResult> getAyah(int number, {String? edition}) {
    _checkRange('ayah', number, 1, 6236);
    return _get(
      edition == null ? '/ayah/$number' : '/ayah/$number/${_segment(edition)}',
    );
  }

  Future<QuranApiResult> getAyahReference(
    String reference, {
    required String edition,
  }) {
    if (!RegExp(r'^\d{1,3}:\d{1,3}$').hasMatch(reference)) {
      throw ArgumentError('Invalid ayah reference');
    }
    return _get('/ayah/$reference/${_segment(edition)}');
  }

  Future<QuranApiResult> getRandomAyah({String? edition}) => _get(
    edition == null ? '/ayah/random' : '/ayah/random/${_segment(edition)}',
  );

  Future<QuranApiResult> getRandomAyahEditions(List<String> editions) {
    _requireEditions(editions);
    return _get('/ayah/random/editions/${_segment(editions.join(','))}');
  }

  Future<QuranApiResult> getAyahEditions(int number, List<String> editions) {
    _checkRange('ayah', number, 1, 6236);
    _requireEditions(editions);
    return _get('/ayah/$number/editions/${_segment(editions.join(','))}');
  }

  Future<QuranApiResult> getEditions({
    String? type,
    String? format,
    String? language,
  }) => _get(
    '/edition',
    query: {'type': ?type, 'format': ?format, 'language': ?language},
  );

  Future<QuranApiResult> getEditionTypes() => _get('/edition/type');
  Future<QuranApiResult> getEditionsByType(String type) =>
      _get('/edition/type/${_segment(type)}');
  Future<QuranApiResult> getEditionFormats() => _get('/edition/format');
  Future<QuranApiResult> getEditionsByFormat(String format) =>
      _get('/edition/format/${_segment(format)}');
  Future<QuranApiResult> getEditionLanguages() => _get('/edition/language');
  Future<QuranApiResult> getEditionsByLanguage(String language) =>
      _get('/edition/language/${_segment(language)}');

  Future<QuranApiResult> getJuz(
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) => _getPartition(
    'juz',
    number,
    edition: edition,
    offset: offset,
    limit: limit,
  );

  Future<QuranApiResult> getPage(
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) => _getPartition(
    'page',
    number,
    edition: edition,
    offset: offset,
    limit: limit,
  );

  Future<QuranApiResult> getHizbQuarter(
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) => _getPartition(
    'hizbQuarter',
    number,
    edition: edition,
    offset: offset,
    limit: limit,
  );

  Future<QuranApiResult> getManzil(
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) => _getPartition(
    'manzil',
    number,
    edition: edition,
    offset: offset,
    limit: limit,
  );

  Future<QuranApiResult> getRuku(
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) => _getPartition(
    'ruku',
    number,
    edition: edition,
    offset: offset,
    limit: limit,
  );

  Future<QuranApiResult> _getPartition(
    String partition,
    int number, {
    String? edition,
    int? offset,
    int? limit,
  }) {
    final (minimum, maximum) = switch (partition) {
      'juz' => (1, 30),
      'page' => (1, 604),
      'hizbQuarter' => (1, 240),
      'manzil' => (1, 7),
      'ruku' => (1, 556),
      _ => throw ArgumentError.value(partition, 'partition'),
    };
    _checkRange(partition, number, minimum, maximum);
    return _get(
      '/$partition/$number${edition == null ? '' : '/${_segment(edition)}'}',
      query: {
        if (offset != null) 'offset': '$offset',
        if (limit != null) 'limit': '$limit',
      },
    );
  }

  Future<QuranApiResult> getMeta() => _get('/meta');

  Future<QuranApiResult> getCompleteQuran({String? edition}) =>
      _get(edition == null ? '/quran' : '/quran/${_segment(edition)}');

  Future<QuranApiResult> getSajda({String? edition}) =>
      _get(edition == null ? '/sajda' : '/sajda/${_segment(edition)}');

  Future<QuranApiResult> search({
    required String word,
    int? surah,
    String? languageOrEdition,
    int? offset,
    int? limit,
  }) {
    if (word.trim().isEmpty) {
      throw ArgumentError.value(word, 'word', 'Must not be empty.');
    }
    if (surah != null) _checkRange('surah', surah, 1, 114);
    if (languageOrEdition != null && surah == null) {
      throw ArgumentError(
        'The API requires a surah number when a language/edition is supplied.',
      );
    }
    final path = StringBuffer('/search/${_segment(word.trim())}');
    if (surah != null) path.write('/$surah');
    if (languageOrEdition != null) {
      path.write('/${_segment(languageOrEdition)}');
    }
    return _get(
      path.toString(),
      query: {
        if (offset != null) 'offset': '$offset',
        if (limit != null) 'limit': '$limit',
      },
    );
  }

  Future<QuranApiResult> _get(
    String path, {
    Map<String, String> query = const {},
    bool bypassCache = false,
  }) async {
    final key = '$path?${Uri(queryParameters: query).query}';
    if (!bypassCache && query.isEmpty) {
      final complete = await _complete();
      if (complete != null) {
        final result = _fromDownload(complete, path);
        if (result != null) return result;
      }
    }
    if (!bypassCache) {
      final cached = await _cache?.read(key);
      if (cached?['code'] == 200 && cached?['data'] != null) {
        return QuranApiResult(data: cached!['data'], status: 'OK');
      }
    }
    final uri = Uri.parse(
      'https://$_host$_basePath$path',
    ).replace(queryParameters: query.isEmpty ? null : query);
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(timeout);
    } on TimeoutException {
      throw const QuranNetworkException(timedOut: true);
    } on http.ClientException {
      throw const QuranNetworkException();
    }
    final payload = _decodePayload(response);
    final code = payload['code'];
    if (code != 200 ||
        response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw QuranApiException(
        message:
            payload['data']?.toString() ??
            'Quran service returned ${response.statusCode}.',
        statusCode: code is int ? code : response.statusCode,
      );
    }
    if (!bypassCache) {
      try {
        await _cache?.write(key, payload);
      } catch (_) {
        /* Reading remains available if storage is full. */
      }
    }
    return QuranApiResult(
      data: payload['data'],
      status: payload['status'] as String? ?? 'OK',
    );
  }

  Future<Object?> _getData(
    String path, {
    Map<String, String> query = const {},
  }) async => (await _get(path, query: query)).data;

  Map<String, dynamic> _decodePayload(http.Response response) {
    try {
      final payload = jsonDecode(utf8.decode(response.bodyBytes));
      if (payload is Map<String, dynamic>) return payload;
    } on FormatException {
      rethrow;
    }
    throw const FormatException('Unexpected response from Quran service.');
  }

  static String _segment(String value) => Uri.encodeComponent(value);

  static void _requireEditions(List<String> editions) {
    if (editions.isEmpty || editions.any((edition) => edition.trim().isEmpty)) {
      throw ArgumentError.value(
        editions,
        'editions',
        'At least one edition is required.',
      );
    }
  }

  static void _checkRange(String label, int value, int minimum, int maximum) {
    if (value < minimum || value > maximum) {
      throw RangeError.range(value, minimum, maximum, label);
    }
  }
}

class QuranApiResult {
  const QuranApiResult({required this.data, required this.status});

  final Object? data;
  final String status;
}

class QuranApiException implements Exception {
  const QuranApiException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => 'QuranApiException($statusCode): $message';
}

class QuranNetworkException implements Exception {
  const QuranNetworkException({this.timedOut = false});
  final bool timedOut;
}
