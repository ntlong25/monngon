import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/perf_probe.dart';
import '../../l10n/gen/app_localizations.dart';

/// Khung 3 tab dưới: Kế hoạch · Đi chợ · Bạn (US-3.1 AC1).
class AppShell extends StatelessWidget {
  const AppShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) {
          PerfProbe.markTab(i);
          shell.goBranch(i, initialLocation: i == shell.currentIndex);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu_outlined),
            selectedIcon: const Icon(Icons.restaurant_menu),
            label: l.tabPlan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_basket_outlined),
            selectedIcon: const Icon(Icons.shopping_basket),
            label: l.tabShopping,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l.tabProfile,
          ),
        ],
      ),
    );
  }
}
