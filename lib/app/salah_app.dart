import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_settings.dart';
import 'app_router.dart';
import '../l10n/generated/app_localizations.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

class SalahApp extends ConsumerWidget {
  const SalahApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.light(seedColor: themeSettings.seedColor),
      darkTheme: AppTheme.dark(seedColor: themeSettings.seedColor),
      themeMode: themeSettings.mode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
