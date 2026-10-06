import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_settings.dart';
import 'app_dialog.dart';

class ThemeSettingsDialog extends ConsumerWidget {
  const ThemeSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localization = AppLocalizations.of(context);
    final settings = ref.watch(themeSettingsProvider);
    final controller = ref.read(themeSettingsProvider.notifier);
    return AppDialog(
      title: localization.appearanceTitle,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localization.accentColor,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            children: [
              for (final color in AppColors.seedOptions)
                IconButton(
                  tooltip: switch (color) {
                    AppColors.forest => localization.colorForest,
                    AppColors.teal => localization.colorTeal,
                    AppColors.indigo => localization.colorIndigo,
                    AppColors.amber => localization.colorAmber,
                    _ => localization.colorRose,
                  },
                  onPressed: () => controller.setSeedColor(color),
                  icon: CircleAvatar(
                    backgroundColor: color,
                    child: settings.seedColor == color
                        ? const Icon(AppIcons.selected, color: Colors.white)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            localization.themeMode,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text(localization.themeSystem),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text(localization.themeLight),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text(localization.themeDark),
              ),
            ],
            selected: {settings.mode},
            onSelectionChanged: (selection) =>
                controller.setMode(selection.first),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localization.close),
        ),
      ],
    );
  }
}
