import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/datasources/quran_api_data_source.dart';
import '../../domain/entities/surah.dart';
import '../providers/quran_providers.dart';
import '../providers/quran_reader_preferences.dart';
import 'mushaf_reader.dart';

String quranErrorMessage(AppLocalizations strings, Object error) =>
    error is QuranNetworkException && error.timedOut
    ? strings.quranTimeout
    : strings.quranLoadError;

class QuranReaderExperience extends ConsumerWidget {
  const QuranReaderExperience({
    required this.kind,
    required this.number,
    required this.ayahs,
    required this.surahs,
    this.bismillah,
    this.initialPosition,
    super.key,
  });
  final String kind;
  final int number;
  final List<QuranAyah> ayahs;
  final List<Surah> surahs;
  final String? bismillah;
  final ReadingPosition? initialPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferences = ref.watch(quranReaderPreferencesProvider);
    return preferences.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: TextButton(
          onPressed: () => ref.invalidate(quranReaderPreferencesProvider),
          child: Text(AppLocalizations.of(context).retry),
        ),
      ),
      data: (settings) => _ReaderSession(
        kind: kind,
        number: number,
        ayahs: ayahs,
        surahs: surahs,
        bismillah: bismillah,
        fontSize: settings.fontSize,
        initialPosition: initialPosition ?? settings.positions['$kind:$number'],
      ),
    );
  }
}

class _ReaderSession extends ConsumerStatefulWidget {
  const _ReaderSession({
    required this.kind,
    required this.number,
    required this.ayahs,
    required this.surahs,
    required this.fontSize,
    this.bismillah,
    this.initialPosition,
  });
  final String kind;
  final int number;
  final List<QuranAyah> ayahs;
  final List<Surah> surahs;
  final double fontSize;
  final String? bismillah;
  final ReadingPosition? initialPosition;
  @override
  ConsumerState<_ReaderSession> createState() => _ReaderSessionState();
}

class _ReaderSessionState extends ConsumerState<_ReaderSession> {
  late ScrollController _scroll;
  Timer? _saveTimer;
  QuranAyah? _anchor;
  int _jump = 0;
  late QuranReaderPreferencesController _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = ref.read(quranReaderPreferencesProvider.notifier);
    final position = widget.initialPosition;
    _anchor = widget.ayahs
        .where(
          (a) =>
              a.numberInSurah == position?.ayah &&
              (a.surahNumber ?? widget.surahs.firstOrNull?.number) ==
                  position?.surah,
        )
        .firstOrNull;
    _scroll = ScrollController(
      initialScrollOffset: position?.offset ?? 0,
      keepScrollOffset: false,
    )..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _save();
    });
  }

  ReadingPosition _position({QuranAyah? ayah}) => ReadingPosition(
    kind: widget.kind,
    number: widget.number,
    offset: _scroll.hasClients ? _scroll.offset : 0,
    ayah: (ayah ?? _anchor)?.numberInSurah,
    surah: (ayah ?? _anchor)?.surahNumber ?? widget.surahs.firstOrNull?.number,
  );

  void _save() {
    _preferences.remember(_position()).catchError((Object _) {
      // Storage errors surface on explicit actions; scrolling remains usable.
    });
  }

  void _onScroll() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 400), _save);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    final position = _position();
    // Flush the last scroll after teardown without replacing a newer reader's
    // Continue reading entry or mutating a provider during widget disposal.
    scheduleMicrotask(
      () => _preferences
          .remember(position, makeCurrent: false)
          .catchError((Object _) {}),
    );
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _jumpToAyah() async {
    final strings = AppLocalizations.of(context);
    final selected = await showDialog<QuranAyah>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(strings.jumpToAyah),
        children: [
          SizedBox(
            width: 320,
            height: 360,
            child: ListView.builder(
              itemCount: widget.ayahs.length,
              itemBuilder: (context, i) {
                final ayah = widget.ayahs[i];
                return ListTile(
                  title: Text(
                    '${ayah.surahNumber ?? widget.surahs.firstOrNull?.number}:${ayah.numberInSurah}',
                  ),
                  subtitle: Text(
                    ayah.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  onTap: () => Navigator.pop(context, ayah),
                );
              },
            ),
          ),
        ],
      ),
    );
    if (selected == null || !mounted) return;
    final old = _scroll;
    old.removeListener(_onScroll);
    setState(() {
      _anchor = selected;
      _jump++;
      _scroll = ScrollController(keepScrollOffset: false)
        ..addListener(_onScroll);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      old.dispose();
      if (mounted) _save();
    });
  }

  Future<void> _fontSettings() async {
    final strings = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Consumer(
          builder: (context, ref, child) {
            final size =
                ref
                    .watch(quranReaderPreferencesProvider)
                    .asData
                    ?.value
                    .fontSize ??
                26;
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    strings.quranFontSize,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Slider(
                    value: size,
                    min: 20,
                    max: 42,
                    divisions: 11,
                    label: '${size.round()}',
                    semanticFormatterCallback: (value) => '${value.round()}',
                    onChanged: (value) async {
                      try {
                        await ref
                            .read(quranReaderPreferencesProvider.notifier)
                            .setFontSize(value);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(strings.saveFailed)),
                          );
                        }
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(strings.close),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            children: [
              TextButton.icon(
                onPressed: _jumpToAyah,
                icon: const Icon(Icons.numbers),
                label: Text(strings.jumpToAyah),
              ),
              IconButton(
                tooltip: strings.quranFontSize,
                onPressed: _fontSettings,
                icon: const Icon(Icons.text_fields),
              ),
            ],
          ),
        ),
        Expanded(
          child: MushafReader(
            key: ValueKey(_jump),
            ayahs: widget.ayahs,
            surahs: widget.surahs,
            scrollController: _scroll,
            startAtAyah: _anchor,
            fontSize: widget.fontSize,
            bismillah: widget.bismillah,
            pageNumber: widget.kind == 'page' ? widget.number : null,
            juzNumber: widget.kind == 'juz' ? widget.number : null,
            onAyahTap: (ayah) => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              builder: (context) => _AyahActions(
                ayah: ayah,
                surahNumber:
                    ayah.surahNumber ?? widget.surahs.firstOrNull?.number,
                // Bookmark starts at the selected ayah's folio rather than an unrelated scroll offset.
                position: ReadingPosition(
                  kind: widget.kind,
                  number: widget.number,
                  ayah: ayah.numberInSurah,
                  surah: ayah.surahNumber ?? widget.surahs.firstOrNull?.number,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AyahActions extends ConsumerStatefulWidget {
  const _AyahActions({
    required this.ayah,
    required this.surahNumber,
    required this.position,
  });
  final QuranAyah ayah;
  final int? surahNumber;
  final ReadingPosition position;
  @override
  ConsumerState<_AyahActions> createState() => _AyahActionsState();
}

class _AyahActionsState extends ConsumerState<_AyahActions> {
  AudioPlayer? _player;
  String? _translation;
  String? _error;
  bool _busy = false;
  bool _playing = false;
  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _action(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = quranErrorMessage(AppLocalizations.of(context), error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _translate() async {
    final result = await ref
        .read(quranApiDataSourceProvider)
        .getAyahReference(
          '${widget.surahNumber}:${widget.ayah.numberInSurah}',
          edition: 'en.sahih',
        );
    final text = (result.data as Map<String, dynamic>)['text'] as String;
    if (mounted) setState(() => _translation = text);
  }

  Future<void> _play() async {
    if (_playing) {
      await _player?.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }
    final result = await ref
        .read(quranApiDataSourceProvider)
        .getAyahReference(
          '${widget.surahNumber}:${widget.ayah.numberInSurah}',
          edition: 'ar.alafasy',
        );
    if (!mounted) return;
    final url = (result.data as Map<String, dynamic>)['audio'] as String;
    _player ??= AudioPlayer()
      ..onPlayerComplete.listen((_) {
        if (mounted) setState(() => _playing = false);
      });
    await _player!.play(UrlSource(url));
    if (mounted) setState(() => _playing = true);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final saved =
        ref
            .watch(quranReaderPreferencesProvider)
            .asData
            ?.value
            .bookmarks
            .any((p) => p.bookmarkKey == widget.position.bookmarkKey) ??
        false;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${widget.surahNumber}:${widget.ayah.numberInSurah}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                widget.ayah.text,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontSize: 24, height: 2),
              ),
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _action(
                            () => ref
                                .read(quranReaderPreferencesProvider.notifier)
                                .toggleBookmark(widget.position),
                          ),
                    icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
                    label: Text(
                      saved ? strings.removeBookmark : strings.bookmarkAyah,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _action(() async {
                      await Clipboard.setData(
                        ClipboardData(
                          text:
                              '${widget.ayah.text}\n${widget.surahNumber}:${widget.ayah.numberInSurah}',
                        ),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(strings.copied)));
                      }
                    }),
                    icon: const Icon(Icons.copy),
                    label: Text(strings.copyAyah),
                  ),
                  if (widget.surahNumber != null) ...[
                    TextButton(
                      onPressed: _busy ? null : () => _action(_translate),
                      child: Text(strings.showTranslation),
                    ),
                    TextButton.icon(
                      onPressed: _busy ? null : () => _action(_play),
                      icon: Icon(_playing ? Icons.stop : Icons.play_arrow),
                      label: Text(
                        _playing
                            ? strings.stopRecitation
                            : strings.playRecitation,
                      ),
                    ),
                  ],
                ],
              ),
              if (_busy) const LinearProgressIndicator(),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              if (_translation != null) ...[
                Text(
                  strings.translationAttribution,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                SelectableText(_translation!, textDirection: TextDirection.ltr),
              ],
              Text(
                strings.recitationAttribution,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
