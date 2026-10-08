import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_icons.dart';
import '../core/widgets/app_navigation_bar.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/location/presentation/screens/location_screen.dart';
import '../features/notifications/presentation/screens/notification_settings_screen.dart';
import '../features/prayer/presentation/screens/prayer_times_screen.dart';
import '../features/qibla/presentation/screens/qibla_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
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
              path: '/qibla',
              name: 'qibla',
              builder: (context, state) => const QiblaScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
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
            icon: const Icon(AppIcons.qibla),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: strings.navQibla,
          ),
          NavigationDestination(
            icon: const Icon(AppIcons.settings),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: strings.settingsTitle,
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
