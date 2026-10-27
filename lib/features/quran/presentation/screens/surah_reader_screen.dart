import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/quran_providers.dart';
import '../widgets/quran_reader_experience.dart';
import '../providers/quran_reader_preferences.dart';
import '../widgets/mushaf_theme.dart';

class SurahReaderScreen extends ConsumerWidget {
  const SurahReaderScreen({
    required this.number,
    this.initialPosition,
    super.key,
  });
  final int number;
  final ReadingPosition? initialPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reading = ref.watch(surahReadingProvider(number));
    final paper = MushafTheme.of(context);
    return Scaffold(
      backgroundColor: paper.background,
      appBar: AppBar(
        title: Text(strings.quranReadingTitle),
        backgroundColor: paper.background,
        foregroundColor: paper.text,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: reading.when(
          loading: () =>
              Center(child: AppLoadingState(label: strings.quranLoading)),
          error: (error, stack) => AppErrorState(
            title: strings.quranReadingTitle,
            description: quranErrorMessage(strings, error),
            retryLabel: strings.retry,
            onRetry: () => ref.invalidate(surahReadingProvider(number)),
          ),
          data: (data) => QuranReaderExperience(
            key: ValueKey(number),
            kind: 'surah',
            number: number,
            initialPosition: initialPosition,
            ayahs: data.ayahs,
            surahs: [data.surah],
            bismillah: ref.watch(quranBismillahProvider).asData?.value,
          ),
        ),
      ),
    );
  }
}
