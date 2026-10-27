import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/surah.dart';
import 'ayah_end_marker.dart';
import 'mushaf_page_border.dart';
import 'mushaf_theme.dart';
import 'quran_text_view.dart';
import 'surah_header_banner.dart';

/// Presents existing models as lazy paper folios without owning fetched data.
class MushafReader extends StatefulWidget {
  const MushafReader({
    required this.ayahs,
    required this.surahs,
    this.bismillah,
    this.pageNumber,
    this.juzNumber,
    this.playingAyah,
    this.onAyahTap,
    this.palette,
    this.scrollController,
    this.fontSize = 26,
    this.startAtAyah,
    super.key,
  });

  final List<QuranAyah> ayahs;
  final List<Surah> surahs;
  final String? bismillah;
  final int? pageNumber;
  final int? juzNumber;
  final QuranAyah? playingAyah;
  final ValueChanged<QuranAyah>? onAyahTap;
  final MushafTheme? palette;
  final ScrollController? scrollController;
  final double fontSize;
  final QuranAyah? startAtAyah;

  @override
  State<MushafReader> createState() => _MushafReaderState();
}

class _MushafReaderState extends State<MushafReader> {
  late List<_Folio> _folios;
  QuranAyah? _selectedAyah;
  final _centerKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _buildFolios();
    _selectedAyah = widget.startAtAyah;
  }

  @override
  void didUpdateWidget(MushafReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.ayahs, widget.ayahs) ||
        !listEquals(oldWidget.surahs, widget.surahs) ||
        oldWidget.pageNumber != widget.pageNumber) {
      _selectedAyah = null;
      _buildFolios();
    }
  }

  void _buildFolios() {
    final surahs = {for (final surah in widget.surahs) surah.number: surah};
    _folios = [];
    for (final ayah in widget.ayahs) {
      final page = ayah.page ?? widget.pageNumber;
      // API page boundaries bound paragraph layout. If page metadata is absent,
      // cap text per folio so a long surah never becomes one enormous RichText.
      if (_folios.isEmpty ||
          _folios.last.pageNumber != page ||
          (page == null &&
              _folios.last.characterCount + ayah.text.length > 1800)) {
        _folios.add(_Folio(page));
      }
      final folio = _folios.last;
      final surahNumber =
          ayah.surahNumber ??
          (widget.surahs.length == 1 ? widget.surahs.single.number : null);
      if (folio.sections.isEmpty ||
          folio.sections.last.surahNumber != surahNumber) {
        folio.sections.add(_SurahSection(surahNumber, surahs[surahNumber]));
      }
      folio.sections.last.ayahs.add(ayah);
      folio.characterCount += ayah.text.length;
    }
  }

  void _selectAyah(QuranAyah ayah) {
    setState(() => _selectedAyah = ayah);
    // Callers can attach their existing copy, bookmark, or other ayah actions.
    widget.onAyahTap?.call(ayah);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.palette ?? MushafTheme.of(context);
    return ColoredBox(
      color: colors.background,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final margin = constraints.maxWidth < 600 ? 10.0 : 24.0;
          final pageWidth = math.min(820.0, constraints.maxWidth - margin * 2);
          final minimumHeight = constraints.hasBoundedHeight
              ? math.max(0.0, constraints.maxHeight - 24)
              : 0.0;
          Widget folio(int index) => Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: pageWidth,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: index == _folios.length - 1 ? 0 : 20,
                ),
                child: _FolioView(
                  folio: _folios[index],
                  minimumHeight: minimumHeight,
                  selectedAyah: _selectedAyah,
                  playingAyah: widget.playingAyah,
                  bismillah: widget.bismillah,
                  juzNumber: widget.juzNumber,
                  onAyahTap: _selectAyah,
                  palette: colors,
                  fontSize: widget.fontSize,
                ),
              ),
            ),
          );
          final start = widget.startAtAyah;
          final startIndex = start == null
              ? 0
              : _folios.indexWhere(
                  (f) => f.sections.any(
                    (s) => s.ayahs.any(
                      (a) =>
                          a.numberInSurah == start.numberInSurah &&
                          a.surahNumber == start.surahNumber,
                    ),
                  ),
                );
          if (startIndex > 0) {
            return CustomScrollView(
              controller: widget.scrollController,
              center: _centerKey,
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: margin),
                  sliver: SliverList.builder(
                    itemCount: startIndex,
                    itemBuilder: (context, i) => folio(startIndex - i - 1),
                  ),
                ),
                SliverPadding(
                  key: _centerKey,
                  padding: EdgeInsets.symmetric(
                    horizontal: margin,
                    vertical: 12,
                  ),
                  sliver: SliverList.builder(
                    itemCount: _folios.length - startIndex,
                    itemBuilder: (context, i) => folio(i + startIndex),
                  ),
                ),
              ],
            );
          }
          return ListView.builder(
            controller: widget.scrollController,
            key: PageStorageKey(
              'mushaf-${widget.pageNumber}-${widget.juzNumber}-${widget.surahs.firstOrNull?.number}',
            ),
            padding: EdgeInsets.symmetric(horizontal: margin, vertical: 12),
            itemCount: _folios.length,
            itemBuilder: (context, index) => folio(index),
          );
        },
      ),
    );
  }
}

class _Folio {
  _Folio(this.pageNumber);

  final int? pageNumber;
  final List<_SurahSection> sections = [];
  var characterCount = 0;
}

class _SurahSection {
  _SurahSection(this.surahNumber, this.surah);

  final int? surahNumber;
  final Surah? surah;
  final List<QuranAyah> ayahs = [];
}

class _FolioView extends StatelessWidget {
  const _FolioView({
    required this.folio,
    required this.minimumHeight,
    required this.selectedAyah,
    required this.playingAyah,
    required this.bismillah,
    required this.juzNumber,
    required this.onAyahTap,
    required this.palette,
    required this.fontSize,
  });

  static const _defaultBismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

  final _Folio folio;
  final double minimumHeight;
  final QuranAyah? selectedAyah;
  final QuranAyah? playingAyah;
  final String? bismillah;
  final int? juzNumber;
  final ValueChanged<QuranAyah> onAyahTap;
  final MushafTheme palette;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final firstSection = folio.sections.first;
    final firstAyah = firstSection.ayahs.first;
    final part = firstAyah.juz ?? juzNumber;
    final opening = bismillah ?? _defaultBismillah;
    return MushafPageBorder(
      palette: palette,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: math.max(0, minimumHeight - 40)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DefaultTextStyle(
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    color: palette.secondaryText,
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                  child: Row(
                    textDirection: TextDirection.ltr,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          firstSection.surah?.englishName ??
                              firstAyah.surahName ??
                              strings.quranReadingTitle,
                        ),
                      ),
                      if (part != null)
                        Expanded(
                          flex: 2,
                          child: Text(
                            strings.quranPartNumber(part),
                            textAlign: TextAlign.right,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Divider(height: 1, thickness: 0.5, color: palette.border),
                const SizedBox(height: 18),
                for (final section in folio.sections) ...[
                  if (section.ayahs.first.numberInSurah == 1 &&
                      section.surah != null) ...[
                    SurahHeaderBanner(
                      surahNameArabic: section.surah!.name,
                      palette: palette,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (_showBismillah(section)) ...[
                    Text(
                      opening,
                      key: const ValueKey('mushaf-bismillah'),
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: MushafTheme.fontFamily,
                        fontSize: 22,
                        height: 2,
                        color: palette.text,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                  QuranTextView(
                    ayahs: section.ayahs,
                    fontSize: fontSize,
                    selectedAyah: selectedAyah,
                    playingAyah: playingAyah,
                    onAyahTap: onAyahTap,
                    openingBismillah: _showBismillah(section) ? opening : null,
                    palette: palette,
                  ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
            if (folio.pageNumber case final page?)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.diamond_outlined,
                      size: 9,
                      color: palette.border,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        arabicIndicDigits(page),
                        semanticsLabel: '${strings.quranPage} $page',
                        style: TextStyle(
                          fontFamily: MushafTheme.fontFamily,
                          fontSize: 15,
                          height: 1.5,
                          color: palette.secondaryText,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.diamond_outlined,
                      size: 9,
                      color: palette.border,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _showBismillah(_SurahSection section) =>
      section.ayahs.first.numberInSurah == 1 &&
      section.surahNumber != null &&
      section.surahNumber != 1 &&
      section.surahNumber != 9;
}
