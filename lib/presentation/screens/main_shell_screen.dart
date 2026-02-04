import 'package:auto_route/auto_route.dart';
import 'package:days_tracker/core/utils/extensions/context_extensions.dart';
import 'package:days_tracker/presentation/navigation/app_router.dart';
import 'package:flutter/material.dart';

/// Main shell screen with bottom navigation.
@RoutePage()
class MainShellScreen extends StatelessWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsScaffold(
      routes: const [VisitsRoute(), StatisticsRoute(), SettingsRoute()],
      bottomNavigationBuilder: (context, tabsRouter) {
        return NavigationBar(
          selectedIndex: tabsRouter.activeIndex,
          onDestinationSelected: tabsRouter.setActiveIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.location_on_outlined),
              selectedIcon: const Icon(Icons.location_on),
              label: context.l10n.navVisits,
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: context.l10n.navStatistics,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: context.l10n.navSettings,
            ),
          ],
        );
      },
    );
  }
}
