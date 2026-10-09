import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/surah.dart';
import '../providers/quran_providers.dart';

class QuranPageReaderScreen extends ConsumerStatefulWidget {
  const QuranPageReaderScreen({super.key});

  @override
  ConsumerState<QuranPageReaderScreen> createState() =>
      _QuranPageReaderScreenState();
}

class _QuranPageReaderScreenState extends ConsumerState<QuranPageReaderScreen> {
  static const _lastPage = 604;
  var _page = 1;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final pageAsync = ref.watch(pageReadingProvider(_page));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(strings.quranFull)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: pageAsync.when(
                  loading: () => Center(
                    child: AppLoadingState(label: strings.quranLoading),
                  ),
                  error: (error, stack) => AppErrorState(
                    title: strings.quranFull,
                    description: strings.quranLoadError,
                    retryLabel: strings.retry,
                    onRetry: () => ref.invalidate(pageReadingProvider(_page)),
                  ),
                  data: (data) => _MushafPage(
                    pageNumber: _page,
                    data: data,
                    bismillah: ref.watch(quranBismillahProvider).asData?.value,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                strings.quranPageCount(_page, _lastPage),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _page > 1
                          ? () => setState(() => _page--)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                      label: Text(strings.previousPage),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _page < _lastPage
                          ? () => setState(() => _page++)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                      label: Text(strings.nextPage),
                      iconAlignment: IconAlignment.end,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MushafPage extends StatelessWidget {
  const _MushafPage({
    required this.pageNumber,
    required this.data,
    required this.bismillah,
  });

  final int pageNumber;
  final QuranReadingData data;
  final String? bismillah;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final surahs = {for (final surah in data.surahs) surah.number: surah};
    final sections = <_SurahPageSection>[];
    for (final ayah in data.ayahs) {
      final surahNumber = ayah.surahNumber;
      if (sections.isEmpty || sections.last.surah.number != surahNumber) {
        final surah = surahs[surahNumber];
        if (surah != null) sections.add(_SurahPageSection(surah));
      }
      if (sections.isNotEmpty) sections.last.ayahs.add(ayah);
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colors.outlineVariant, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Divider(color: colors.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Text(
                    '$pageNumber',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: colors.outlineVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: sections.length,
                itemBuilder: (context, index) => _SurahPageText(
                  section: sections[index],
                  bismillah: bismillah,
                  isFirstSection: index == 0,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Divider(color: colors.outlineVariant),
            Text(
              '$pageNumber',
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahPageSection {
  _SurahPageSection(this.surah);

  final Surah surah;
  final List<QuranAyah> ayahs = [];
}

class _SurahPageText extends StatelessWidget {
  const _SurahPageText({
    required this.section,
    required this.bismillah,
    required this.isFirstSection,
  });

  final _SurahPageSection section;
  final String? bismillah;
  final bool isFirstSection;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasSurahStart = section.ayahs.any((ayah) => ayah.numberInSurah == 1);
    final showBismillah =
        hasSurahStart &&
        section.surah.number != 1 &&
        section.surah.number != 9 &&
        bismillah != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        children: [
          if (!isFirstSection || hasSurahStart)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(child: Divider(color: colors.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    child: Text(
                      section.surah.name,
                      textDirection: TextDirection.rtl,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: colors.outlineVariant)),
                ],
              ),
            ),
          if (showBismillah)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                bismillah!,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  height: 1.8,
                  color: colors.primary,
                ),
              ),
            ),
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text.rich(
              TextSpan(
                children: [
                  for (final ayah in section.ayahs) ...[
                    TextSpan(text: '${ayah.text} '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: _AyahEndMarker(number: ayah.numberInSurah),
                    ),
                    const TextSpan(text: ' '),
                  ],
                ],
              ),
              textAlign: TextAlign.justify,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                height: 2.1,
                fontFamily: 'serif',
                color: colors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahEndMarker extends StatelessWidget {
  const _AyahEndMarker({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: 30,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colors.primary.withValues(alpha: 0.65)),
      ),
      child: Text(
        _arabicIndic(number),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _arabicIndic(int number) {
    const digits = '٠١٢٣٤٥٦٧٨٩';
    return number
        .toString()
        .split('')
        .map((digit) => digits[int.parse(digit)])
        .join();
  }
}
