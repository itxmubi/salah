import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_icons.dart';
import '../core/widgets/app_navigation_bar.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/location/presentation/screens/location_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/prayer/presentation/screens/prayer_times_screen.dart';
import '../features/qibla/presentation/screens/qibla_screen.dart';
import '../l10n/generated/app_localizations.dart';

GoRouter createAppRouter() => GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          _MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/prayer',
              name: 'prayer',
              builder: (context, state) => const PrayerTimesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/quran',
              name: 'quran',
              builder: (context, state) => const _ComingSoonScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/qibla',
              name: 'qibla',
              builder: (context, state) => const QiblaScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/location',
      name: 'location',
      builder: (context, state) => const LocationScreen(),
    ),
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (context, state) => const NotificationSettingsScreen(),
    ),
  ],
);

class _MainShell extends StatelessWidget {
  const _MainShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(AppIcons.home),
            selectedIcon: const Icon(Icons.home_rounded),
            label: strings.navHome,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.prayer),
            selectedIcon: const Icon(Icons.access_time_filled_rounded),
            label: strings.navPrayer,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.quran),
            selectedIcon: const Icon(Icons.menu_book_rounded),
            label: strings.navQuran,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.qibla),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: strings.navQibla,
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}

class _ComingSoonScreen extends StatelessWidget {
  const _ComingSoonScreen();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final title = strings.quranTitle;
    final description = strings.quranComingSoon;
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: SizedBox(
                  width: 88,
                  height: 88,
                  child: Icon(
                    AppIcons.quran,
                    size: 40,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
