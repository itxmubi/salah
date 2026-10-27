import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../quran/domain/entities/daily_ayah.dart';
import '../../../quran/presentation/providers/quran_providers.dart';
import '../../../quran/presentation/providers/quran_reader_preferences.dart';
import '../../../quran/presentation/screens/surah_reader_screen.dart';
import '../../../quran/presentation/widgets/mushaf_theme.dart';

class DailyAyahCard extends ConsumerWidget {
  const DailyAyahCard({required this.date, super.key});
  final DateTime date;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final verse = ref.watch(dailyAyahProvider(date));
    final colors = Theme.of(context).colorScheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined, color: colors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  strings.ayahOfTheDay,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          verse.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(strings.dailyAyahUnavailable),
                TextButton.icon(
                  onPressed: () => ref.invalidate(dailyAyahProvider(date)),
                  icon: const Icon(Icons.refresh),
                  label: Text(strings.retry),
                ),
              ],
            ),
            data: (data) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  data.ayah.text,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: MushafTheme.fontFamily,
                    fontSize: 25,
                    height: 2,
                    color: colors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${strings.localeName == 'ar' ? data.surah.name : data.surah.englishName} · ${strings.quranAyahNumber(data.ayah.numberInSurah)}',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: colors.primary),
                ),
                if (strings.localeName != 'ar')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: ref
                        .watch(
                          dailyAyahTranslationProvider(dailyAyahNumber(date)),
                        )
                        .when(
                          loading: () => const LinearProgressIndicator(),
                          error: (_, _) => TextButton(
                            onPressed: () => ref.invalidate(
                              dailyAyahTranslationProvider(
                                dailyAyahNumber(date),
                              ),
                            ),
                            child: Text(strings.dailyTranslationUnavailable),
                          ),
                          data: (text) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SelectableText(
                                text,
                                textDirection: TextDirection.ltr,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strings.translationAttribution,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => SurahReaderScreen(
                          number: data.surah.number,
                          initialPosition: ReadingPosition(
                            kind: 'surah',
                            number: data.surah.number,
                            surah: data.surah.number,
                            ayah: data.ayah.numberInSurah,
                          ),
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: Text(strings.readThisSurah),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
