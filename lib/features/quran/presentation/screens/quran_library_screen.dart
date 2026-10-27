import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/surah.dart';
import '../providers/quran_providers.dart';
import '../providers/quran_reader_preferences.dart';
import 'surah_reader_screen.dart';
import 'quran_collection_reader_screen.dart';
import 'quran_page_reader_screen.dart';

class QuranLibraryScreen extends ConsumerStatefulWidget {
  const QuranLibraryScreen({super.key});

  @override
  ConsumerState<QuranLibraryScreen> createState() => _QuranLibraryScreenState();
}

class _QuranLibraryScreenState extends ConsumerState<QuranLibraryScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final surahs = ref.watch(surahListProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.quranTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _QuranLibraryTools()),
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: surahs.when(
                    loading: () => SliverToBoxAdapter(
                      child: Center(
                        child: AppLoadingState(label: strings.quranLoading),
                      ),
                    ),
                    error: (error, stack) => SliverToBoxAdapter(
                      child: AppErrorState(
                        title: strings.quranTitle,
                        description: strings.quranLoadError,
                        retryLabel: strings.retry,
                        onRetry: () => ref.invalidate(surahListProvider),
                      ),
                    ),
                    data: (items) => SliverList.list(
                      children: _libraryChildren(context, items),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _libraryChildren(BuildContext context, List<Surah> items) {
    final strings = AppLocalizations.of(context);
    final query = _query.trim().toLowerCase();
    final filtered = items
        .where(
          (surah) =>
              query.isEmpty ||
              surah.englishName.toLowerCase().contains(query) ||
              surah.translation.toLowerCase().contains(query) ||
              surah.name.toLowerCase().contains(query) ||
              surah.number.toString() == query,
        )
        .toList(growable: false);
    return [
      AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ref
                  .watch(quranBismillahProvider)
                  .when(
                    data: (text) => Text(
                      text,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.8,
                          ),
                    ),
                    loading: () => const SizedBox(height: AppSpacing.xl),
                    error: (error, stack) => const SizedBox.shrink(),
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              strings.quranLibraryHeading,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(strings.quranLibraryDescription),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: strings.quranSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: strings.clearSearch,
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _query = '';
                        }),
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      _QuranModeTile(
        icon: Icons.view_agenda_outlined,
        title: strings.quranByJuz,
        onTap: () => context.push('/quran/juz'),
      ),
      _QuranModeTile(
        icon: Icons.auto_stories_outlined,
        title: strings.quranFull,
        onTap: () => context.push('/quran/full'),
      ),
      const SizedBox(height: AppSpacing.md),
      Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: Text(
          strings.quranBySurah,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: Text(
          strings.quranSurahCount(items.length),
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
      if (filtered.isEmpty)
        AppCard(
          child: Text(strings.quranNoResults, textAlign: TextAlign.center),
        )
      else
        ...filtered.map(
          (surah) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: _SurahTile(
              surah: surah,
              onTap: () => context.push('/quran/surah/${surah.number}'),
            ),
          ),
        ),
    ];
  }
}

class _QuranModeTile extends StatelessWidget {
  const _QuranModeTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
    child: AppCard(
      padding: 0,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    ),
  );
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah, required this.onTap});
  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    return AppCard(
      padding: 0,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${surah.number}',
            style: TextStyle(
              color: colors.onSecondaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              surah.englishName,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              surah.name,
              textDirection: TextDirection.rtl,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: colors.primary),
            ),
          ],
        ),
        subtitle: Text(
          '${surah.translation} · ${surah.ayahCount} ${strings.quranAyahs} · ${surah.revelationType}',
        ),
      ),
    );
  }
}

class _QuranLibraryTools extends ConsumerWidget {
  const _QuranLibraryTools();
  void _open(BuildContext context, ReadingPosition position) {
    final Widget screen = switch (position.kind) {
      'surah' => SurahReaderScreen(
        number: position.number,
        initialPosition: position,
      ),
      'juz' => QuranCollectionReaderScreen(
        juzNumber: position.number,
        initialPosition: position,
      ),
      _ => QuranPageReaderScreen(initialPosition: position),
    };
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final download = ref.watch(quranDownloadProvider);
    final preferences = ref.watch(quranReaderPreferencesProvider).asData?.value;
    return Column(
      children: [
        ListTile(
          leading: Icon(
            download.asData?.value == true
                ? Icons.offline_pin
                : Icons.download_outlined,
          ),
          title: Text(
            download.isLoading
                ? strings.quranDownloading
                : download.asData?.value == true
                ? strings.quranDownloaded
                : strings.quranDownload,
          ),
          subtitle: download.hasError
              ? Text(strings.downloadFailed)
              : Text(strings.quranDownloadHint),
          onTap: download.isLoading || download.asData?.value == true
              ? null
              : () => ref.read(quranDownloadProvider.notifier).download(),
        ),
        if (download.isLoading) const LinearProgressIndicator(),
        if (preferences?.last case final last?)
          ListTile(
            leading: const Icon(Icons.history),
            title: Text(strings.continueReading),
            subtitle: Text(_label(strings, last)),
            onTap: () => _open(context, last),
          ),
        ExpansionTile(
          leading: const Icon(Icons.bookmarks_outlined),
          title: Text(strings.bookmarks),
          children: [
            if (preferences?.bookmarks.isEmpty ?? true)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(strings.noBookmarks),
              ),
            for (final bookmark
                in preferences?.bookmarks ?? <ReadingPosition>[])
              ListTile(
                title: Text(_label(strings, bookmark)),
                onTap: () => _open(context, bookmark),
                trailing: IconButton(
                  tooltip: strings.removeBookmark,
                  icon: const Icon(Icons.bookmark_remove_outlined),
                  onPressed: () async {
                    try {
                      await ref
                          .read(quranReaderPreferencesProvider.notifier)
                          .toggleBookmark(bookmark);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(strings.saveFailed)),
                        );
                      }
                    }
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }

  String _label(AppLocalizations strings, ReadingPosition p) =>
      '${switch (p.kind) {
        'page' => strings.quranPageCount(p.number, 604),
        'juz' => strings.quranJuzNumber(p.number),
        _ => '${strings.quranBySurah} ${p.number}',
      }}${p.ayah == null ? '' : ' · ${p.surah}:${p.ayah}'}';
}
