import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/surah.dart';
import '../providers/quran_providers.dart';

class SurahReaderScreen extends ConsumerWidget {
  const SurahReaderScreen({required this.number, super.key});
  final int number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reading = ref.watch(surahReadingProvider(number));
    return Scaffold(
      appBar: AppBar(title: Text(strings.quranReadingTitle)),
      body: SafeArea(
        child: reading.when(
          loading: () =>
              Center(child: AppLoadingState(label: strings.quranLoading)),
          error: (error, stack) => AppErrorState(
            title: strings.quranReadingTitle,
            description: strings.quranLoadError,
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(surahReadingProvider(number)),
          ),
          data: (data) => LayoutBuilder(
            builder: (context, constraints) => Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: _readingList(
                  context,
                  data,
                  ref.watch(quranBismillahProvider).asData?.value,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _readingList(
    BuildContext context,
    SurahReading reading,
    String? bismillah,
  ) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: reading.ayahs.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                children: [
                  Text(
                    reading.surah.name,
                    textDirection: TextDirection.rtl,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: colors.primary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    reading.surah.englishName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (bismillah != null &&
                      reading.surah.number != 1 &&
                      reading.surah.number != 9) ...[
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
                  Text(
                    '${reading.surah.translation} · ${reading.surah.ayahCount} ${strings.quranAyahs} · ${reading.surah.revelationType}',
                  ),
                ],
              ),
            ),
          );
        }
        final ayah = reading.ayahs[index - 1];
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
                        style: TextStyle(color: colors.onSecondaryContainer),
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    height: 2.0,
                    fontFamily: 'serif',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
