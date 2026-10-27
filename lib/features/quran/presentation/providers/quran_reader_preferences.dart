import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/settings/app_settings.dart';

class ReadingPosition {
  const ReadingPosition({
    required this.kind,
    required this.number,
    this.offset = 0,
    this.ayah,
    this.surah,
  });
  final String kind;
  final int number;
  final double offset;
  final int? ayah;
  final int? surah;
  String get key => '$kind:$number';
  String get bookmarkKey => '$key:${surah ?? 0}:${ayah ?? 0}';
  Map<String, dynamic> toJson() => {
    'kind': kind,
    'number': number,
    'offset': offset,
    'ayah': ayah,
    'surah': surah,
  };
  factory ReadingPosition.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String;
    final number = json['number'] as int;
    final maximum = switch (kind) {
      'page' => 604,
      'surah' => 114,
      'juz' => 30,
      _ => 0,
    };
    if (number < 1 || number > maximum) {
      throw const FormatException('Invalid reading position');
    }
    final offset = (json['offset'] as num?)?.toDouble() ?? 0;
    return ReadingPosition(
      kind: kind,
      number: number,
      offset: offset.isFinite ? offset : 0,
      ayah: json['ayah'] as int?,
      surah: json['surah'] as int?,
    );
  }
}

class QuranReaderPreferences {
  const QuranReaderPreferences({
    this.fontSize = 26,
    this.positions = const {},
    this.last,
    this.bookmarks = const [],
  });
  final double fontSize;
  final Map<String, ReadingPosition> positions;
  final ReadingPosition? last;
  final List<ReadingPosition> bookmarks;
}

final quranReaderPreferencesProvider =
    AsyncNotifierProvider<
      QuranReaderPreferencesController,
      QuranReaderPreferences
    >(QuranReaderPreferencesController.new);

class QuranReaderPreferencesController
    extends AsyncNotifier<QuranReaderPreferences> {
  Future<void> _writes = Future.value();
  @override
  Future<QuranReaderPreferences> build() async {
    final prefs = ref.watch(appPreferencesProvider);
    try {
      final raw = await prefs.getString('quran.reader.v1');
      if (raw == null) return const QuranReaderPreferences();
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final positions = <String, ReadingPosition>{};
      for (final item in (json['positions'] as List? ?? [])) {
        try {
          final position = ReadingPosition.fromJson(
            item as Map<String, dynamic>,
          );
          positions[position.key] = position;
        } catch (_) {
          /* Skip damaged entries. */
        }
      }
      final bookmarks = <ReadingPosition>[];
      for (final item in (json['bookmarks'] as List? ?? [])) {
        try {
          bookmarks.add(ReadingPosition.fromJson(item as Map<String, dynamic>));
        } catch (_) {
          /* Skip damaged entries. */
        }
      }
      return QuranReaderPreferences(
        fontSize: ((json['fontSize'] as num?)?.toDouble() ?? 26).clamp(20, 42),
        positions: positions,
        last: positions[json['last']],
        bookmarks: bookmarks,
      );
    } catch (_) {
      return const QuranReaderPreferences();
    }
  }

  Future<void> _save(QuranReaderPreferences next) {
    state = AsyncData(next);
    final prefs = ref.read(appPreferencesProvider);
    final encoded = jsonEncode({
      'fontSize': next.fontSize,
      'last': next.last?.key,
      'positions': next.positions.values.map((p) => p.toJson()).toList(),
      'bookmarks': next.bookmarks.map((p) => p.toJson()).toList(),
    });
    final operation = _writes
        .catchError((Object _) {})
        .then((_) => prefs.setString('quran.reader.v1', encoded));
    _writes = operation;
    return operation;
  }

  Future<void> setFontSize(double size) async {
    final current = state.asData?.value ?? await future;
    await _save(
      QuranReaderPreferences(
        fontSize: size.clamp(20, 42),
        positions: current.positions,
        last: current.last,
        bookmarks: current.bookmarks,
      ),
    );
  }

  Future<void> remember(
    ReadingPosition position, {
    bool makeCurrent = true,
  }) async {
    if (!ref.mounted) return;
    final current = state.asData?.value ?? await future;
    await _save(
      QuranReaderPreferences(
        fontSize: current.fontSize,
        positions: {...current.positions, position.key: position},
        last: makeCurrent || current.last?.key == position.key
            ? position
            : current.last,
        bookmarks: current.bookmarks,
      ),
    );
  }

  Future<void> toggleBookmark(ReadingPosition position) async {
    final current = state.asData?.value ?? await future;
    final bookmarks = [...current.bookmarks];
    if (bookmarks.any((p) => p.bookmarkKey == position.bookmarkKey)) {
      bookmarks.removeWhere((p) => p.bookmarkKey == position.bookmarkKey);
    } else {
      bookmarks.add(position);
    }
    await _save(
      QuranReaderPreferences(
        fontSize: current.fontSize,
        positions: current.positions,
        last: current.last,
        bookmarks: bookmarks,
      ),
    );
  }
}
