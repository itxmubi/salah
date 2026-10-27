import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/quran_providers.dart';
import '../widgets/quran_reader_experience.dart';
import '../providers/quran_reader_preferences.dart';
import '../widgets/mushaf_theme.dart';
import '../widgets/quran_page_jump_dialog.dart';

class QuranPageReaderScreen extends ConsumerStatefulWidget {
  const QuranPageReaderScreen({this.initialPosition, super.key});
  final ReadingPosition? initialPosition;

  @override
  ConsumerState<QuranPageReaderScreen> createState() =>
      _QuranPageReaderScreenState();
}

class _QuranPageReaderScreenState extends ConsumerState<QuranPageReaderScreen> {
  static const _lastPage = 604;
  var _page = 1;
  bool _restored = false;

  @override
  void initState() {
    super.initState();
    _page = widget.initialPosition?.number ?? 1;
  }

  Future<void> _jumpPage() async {
    final page = await showDialog<int>(
      context: context,
      builder: (context) => QuranPageJumpDialog(currentPage: _page),
    );
    if (mounted && page != null) setState(() => _page = page);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final preferences = ref.watch(quranReaderPreferencesProvider);
    if (!_restored && preferences.hasValue) {
      _restored = true;
      if (widget.initialPosition == null &&
          preferences.asData?.value.last?.kind == 'page') {
        _page = preferences.asData!.value.last!.number;
      }
    }
    final pageAsync = ref.watch(pageReadingProvider(_page));
    final paper = MushafTheme.of(context);

    return Scaffold(
      backgroundColor: paper.background,
      appBar: AppBar(
        title: Text(strings.quranFull),
        actions: [
          IconButton(
            tooltip: strings.jumpToPage,
            onPressed: _jumpPage,
            icon: const Icon(Icons.find_in_page),
          ),
        ],
        backgroundColor: paper.background,
        foregroundColor: paper.text,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: pageAsync.when(
                loading: () =>
                    Center(child: AppLoadingState(label: strings.quranLoading)),
                error: (error, stack) => AppErrorState(
                  title: strings.quranFull,
                  description: quranErrorMessage(strings, error),
                  retryLabel: strings.retry,
                  onRetry: () => ref.invalidate(pageReadingProvider(_page)),
                ),
                data: (data) => QuranReaderExperience(
                  key: ValueKey(_page),
                  kind: 'page',
                  number: _page,
                  initialPosition: widget.initialPosition?.number == _page
                      ? widget.initialPosition
                      : null,
                  ayahs: data.ayahs,
                  surahs: data.surahs,
                  bismillah: ref.watch(quranBismillahProvider).asData?.value,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                children: [
                  Text(
                    strings.quranPageCount(_page, _lastPage),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: paper.secondaryText,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: paper.text,
                            disabledForegroundColor: paper.secondaryText
                                .withValues(alpha: 0.4),
                            side: BorderSide(
                              color: paper.border.withValues(alpha: 0.55),
                            ),
                          ),
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
                          style: FilledButton.styleFrom(
                            backgroundColor: paper.bannerFill,
                            foregroundColor: paper.text,
                            disabledBackgroundColor: paper.bannerFill,
                            disabledForegroundColor: paper.secondaryText
                                .withValues(alpha: 0.4),
                          ),
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
          ],
        ),
      ),
    );
  }
}
