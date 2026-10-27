import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../providers/prayer_controller.dart';
import '../../domain/entities/prayer_issue.dart';
import 'prayer_times_screen.dart';

class CalculationSettingsScreen extends ConsumerWidget {
  const CalculationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final prayer = ref.watch(prayerControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.prayerSettings)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: prayer.when(
              loading: () => AppLoadingState(label: strings.prayerSettings),
              error: (_, _) => AppErrorState(
                title: strings.prayerSettings,
                description: strings.prayerStorageError,
                retryLabel: strings.retry,
                onRetry: () => ref.invalidate(prayerControllerProvider),
              ),
              data: (state) => Column(
                children: [
                  if (state.issue != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          state.issue == PrayerIssue.storageFailed
                              ? strings.prayerStorageError
                              : strings.prayerCalculationError,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: PrayerSettingsSheet(
                      settings: state.settings,
                      onChanged: (settings) => ref
                          .read(prayerControllerProvider.notifier)
                          .updateSettings(settings),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
