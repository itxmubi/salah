import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../core/settings/app_settings.dart';
import '../features/notifications/presentation/providers/notification_providers.dart';
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
      locale: ref.watch(appSettingsProvider).asData?.value.locale,
      builder: (context, child) => _AppLifecycle(child: child!),
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}

class _AppLifecycle extends ConsumerStatefulWidget {
  const _AppLifecycle({required this.child});
  final Widget child;
  @override
  ConsumerState<_AppLifecycle> createState() => _AppLifecycleState();
}

class _AppLifecycleState extends ConsumerState<_AppLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeLocales(List<Locale>? locales) {
    ref.invalidate(notificationSyncProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationSyncProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(notificationSyncProvider);
    return widget.child;
  }
}
