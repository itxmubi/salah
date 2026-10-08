import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_icons.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_settings.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/theme_settings_dialog.dart';
import '../../../../l10n/generated/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final appearance = ref.watch(themeSettingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(strings.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _SettingsSection(
            title: strings.settingsPrayerSection,
            children: [
              _SettingsLink(
                icon: AppIcons.prayer,
                title: strings.prayerSettings,
                onTap: () => context.push('/prayer'),
              ),
              _SettingsLink(
                icon: AppIcons.location,
                title: strings.locationTitle,
                onTap: () => context.push('/location'),
              ),
              _SettingsLink(
                icon: AppIcons.notifications,
                title: strings.notificationSettingsTitle,
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsSection(
            title: strings.appearanceTitle,
            children: [
              _SettingsLink(
                icon: AppIcons.palette,
                title: strings.appearanceTitle,
                subtitle:
                    '${_modeName(strings, appearance.mode)} · ${_colorName(strings, appearance.seedColor)}',
                onTap: () => showDialog<void>(
                  context: context,
                  builder: (context) => const ThemeSettingsDialog(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _modeName(AppLocalizations strings, ThemeMode mode) => switch (mode) {
    ThemeMode.system => strings.themeSystem,
    ThemeMode.light => strings.themeLight,
    ThemeMode.dark => strings.themeDark,
  };

  String _colorName(AppLocalizations strings, Color color) =>
      color == AppColors.teal
      ? strings.colorTeal
      : color == AppColors.indigo
      ? strings.colorIndigo
      : color == AppColors.amber
      ? strings.colorAmber
      : color == AppColors.rose
      ? strings.colorRose
      : strings.colorForest;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.xs,
          bottom: AppSpacing.xs,
        ),
        child: Text(title, style: Theme.of(context).textTheme.titleSmall),
      ),
      AppCard(
        padding: 0,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              children[i],
            ],
          ],
        ),
      ),
    ],
  );
}

class _SettingsLink extends StatelessWidget {
  const _SettingsLink({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: const Icon(AppIcons.chevronRight),
    onTap: onTap,
  );
}
