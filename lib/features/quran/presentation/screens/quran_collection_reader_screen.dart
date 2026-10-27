import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/quran_providers.dart';
import '../widgets/quran_reader_experience.dart';
import '../providers/quran_reader_preferences.dart';
import '../widgets/mushaf_theme.dart';

class QuranCollectionReaderScreen extends ConsumerWidget {
  const QuranCollectionReaderScreen({
    this.juzNumber,
    this.initialPosition,
    super.key,
  });

  final int? juzNumber;
  final ReadingPosition? initialPosition;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final reading = juzNumber == null
        ? ref.watch(fullQuranProvider)
        : ref.watch(juzReadingProvider(juzNumber!));
    final title = juzNumber == null
        ? strings.quranFull
        : strings.quranJuzNumber(juzNumber!);
    final paper = MushafTheme.of(context);
    return Scaffold(
      backgroundColor: paper.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: paper.background,
        foregroundColor: paper.text,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: reading.when(
          loading: () =>
              Center(child: AppLoadingState(label: strings.quranLoading)),
          error: (error, stack) => AppErrorState(
            title: title,
            description: quranErrorMessage(strings, error),
            retryLabel: strings.retry,
            onRetry: () {
              if (juzNumber == null) {
                ref.invalidate(fullQuranProvider);
              } else {
                ref.invalidate(juzReadingProvider(juzNumber!));
              }
            },
          ),
          data: (data) => QuranReaderExperience(
            ayahs: data.ayahs,
            surahs: data.surahs,
            kind: 'juz',
            number: juzNumber ?? 1,
            initialPosition: initialPosition,
            bismillah: ref.watch(quranBismillahProvider).asData?.value,
          ),
        ),
      ),
    );
  }
}
