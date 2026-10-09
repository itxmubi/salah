import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/surah.dart';
import '../providers/quran_providers.dart';

class QuranCollectionReaderScreen extends ConsumerWidget {
  const QuranCollectionReaderScreen({this.juzNumber, super.key});

  final int? juzNumber;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reading = juzNumber == null
        ? ref.watch(fullQuranProvider)
        : ref.watch(juzReadingProvider(juzNumber!));
    final title = juzNumber == null
        ? strings.quranFull
        : strings.quranJuzNumber(juzNumber!);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: reading.when(
          loading: () =>
              Center(child: AppLoadingState(label: strings.quranLoading)),
          error: (error, stack) => AppErrorState(
            title: title,
            description: strings.quranLoadError,
            retryLabel: strings.retry,
            onRetry: () {
              if (juzNumber == null) {
                ref.invalidate(fullQuranProvider);
              } else {
                ref.invalidate(juzReadingProvider(juzNumber!));
              }
            },
          ),
          data: (data) => _QuranCollectionBody(data: data),
        ),
      ),
    );
  }
}

class _QuranCollectionBody extends ConsumerWidget {
  const _QuranCollectionBody({required this.data});

  final QuranReadingData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final bismillah = ref.watch(quranBismillahProvider).asData?.value;
    final surahs = {for (final surah in data.surahs) surah.number: surah};
    final rows = <_ReaderRow>[];
    int? lastSurah;
    for (final ayah in data.ayahs) {
      final surahNumber = ayah.surahNumber;
      if (surahNumber != null && surahNumber != lastSurah) {
        rows.add(_ReaderRow.header(surahs[surahNumber]));
        lastSurah = surahNumber;
      }
      rows.add(_ReaderRow.ayah(ayah));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: rows.length,
          itemBuilder: (context, index) {
            final row = rows[index];
            if (row.surah != null) {
              final surah = row.surah!;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  child: Column(
                    children: [
                      Text(
                        surah.name,
                        textDirection: TextDirection.rtl,
                        style: Theme.of(
                          context,
                        ).textTheme.titleLarge?.copyWith(color: colors.primary),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        surah.englishName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (bismillah != null &&
                          surah.number != 1 &&
                          surah.number != 9 &&
                          data.ayahs.any(
                            (ayah) =>
                                ayah.surahNumber == surah.number &&
                                ayah.numberInSurah == 1,
                          )) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          bismillah,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(height: 1.8),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }
            final ayah = row.ayah!;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 17,
                          backgroundColor: colors.secondaryContainer,
                          child: Text(
                            '${ayah.numberInSurah}',
                            style: TextStyle(
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (ayah.page != null)
                          Text(
                            '${strings.quranPage} ${ayah.page}',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      ayah.text,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(height: 2, fontFamily: 'serif'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReaderRow {
  const _ReaderRow._({this.surah, this.ayah});

  factory _ReaderRow.header(Surah? surah) => _ReaderRow._(surah: surah);
  factory _ReaderRow.ayah(QuranAyah ayah) => _ReaderRow._(ayah: ayah);

  final Surah? surah;
  final QuranAyah? ayah;
}
