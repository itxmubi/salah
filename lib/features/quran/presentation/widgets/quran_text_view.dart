import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/surah.dart';
import 'ayah_end_marker.dart';
import 'mushaf_theme.dart';

/// A bounded paragraph of flowing ayahs, never a card for each verse.
/// Selection/playback are inputs so existing action or audio UI can connect
/// without introducing another provider or changing Quran models.
class QuranTextView extends StatefulWidget {
  const QuranTextView({
    required this.ayahs,
    this.selectedAyah,
    this.playingAyah,
    this.onAyahTap,
    this.openingBismillah,
    this.palette,
    this.fontSize = 26,
    super.key,
  });

  final List<QuranAyah> ayahs;
  final double fontSize;
  final QuranAyah? selectedAyah;
  final QuranAyah? playingAyah;
  final ValueChanged<QuranAyah>? onAyahTap;

  /// Set only when a separate Bismillah is displayed before this paragraph.
  final String? openingBismillah;
  final MushafTheme? palette;

  @override
  State<QuranTextView> createState() => _QuranTextViewState();
}

class _QuranTextViewState extends State<QuranTextView> {
  final _recognizers = <TapGestureRecognizer>[];

  @override
  void initState() {
    super.initState();
    _createRecognizers();
  }

  @override
  void didUpdateWidget(QuranTextView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.ayahs, widget.ayahs)) {
      _disposeRecognizers();
      _createRecognizers();
    }
  }

  void _createRecognizers() {
    for (final ayah in widget.ayahs) {
      _recognizers.add(
        TapGestureRecognizer()..onTap = () => widget.onAyahTap?.call(ayah),
      );
    }
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  bool _matches(QuranAyah ayah, QuranAyah? other) {
    if (other == null) return false;
    if (ayah.globalNumber != null && other.globalNumber != null) {
      return ayah.globalNumber == other.globalNumber;
    }
    return ayah.surahNumber == other.surahNumber &&
        ayah.numberInSurah == other.numberInSurah;
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.palette ?? MushafTheme.of(context);
    final spans = <InlineSpan>[];
    for (var index = 0; index < widget.ayahs.length; index++) {
      final ayah = widget.ayahs[index];
      final highlighted =
          _matches(ayah, widget.selectedAyah) ||
          _matches(ayah, widget.playingAyah);
      final text = index == 0 && widget.openingBismillah != null
          ? _withoutOpeningBismillah(ayah.text, widget.openingBismillah!)
          : ayah.text;
      spans.addAll([
        TextSpan(
          text: text,
          recognizer: widget.onAyahTap == null ? null : _recognizers[index],
          style: TextStyle(
            backgroundColor: highlighted ? colors.highlight : null,
          ),
        ),
        const TextSpan(text: ' '),
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: AyahEndMarker(
            number: ayah.numberInSurah,
            isHighlighted: highlighted,
            palette: colors,
            onTap: widget.onAyahTap == null
                ? null
                : () => widget.onAyahTap!(ayah),
          ),
        ),
        const TextSpan(text: ' '),
      ]);
    }
    return Text.rich(
      TextSpan(children: spans),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
      softWrap: true,
      // Natural font metrics and extra leading leave room for Quranic marks.
      style: TextStyle(
        fontFamily: MushafTheme.fontFamily,
        fontSize: widget.fontSize,
        height: 2,
        color: colors.text,
      ),
    );
  }
}

final _arabicMarks = RegExp(
  r'[\s\u0610-\u061A\u0640\u064B-\u065F\u0670\u06D6-\u06ED]',
);

String _normalizeOpening(String text) =>
    text.replaceAll(_arabicMarks, '').replaceAll('ٱ', 'ا');

String _withoutOpeningBismillah(String text, String bismillah) {
  // Some editions prepend the basmalah to ayah 1. Remove only that displayed
  // prefix when a separate line exists, leaving the original model untouched.
  final prefix = _normalizeOpening(bismillah);
  if (prefix.isEmpty) return text;
  var matched = '';
  for (var index = 0; index < text.length; index++) {
    matched += _normalizeOpening(text[index]);
    if (!prefix.startsWith(matched)) return text;
    if (matched == prefix) {
      var end = index + 1;
      while (end < text.length && _arabicMarks.hasMatch(text[end])) {
        end++;
      }
      final remainder = text.substring(end).trimLeft();
      return remainder.isEmpty ? text : remainder;
    }
  }
  return text;
}
