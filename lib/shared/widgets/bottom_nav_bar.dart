import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/extensions/l10n_ext.dart';

class ScaffoldWithBottomNav extends StatelessWidget {
  const ScaffoldWithBottomNav({super.key, required this.child});

  final Widget child;

  static const _tabPaths = [
    AppRoutes.home,
    AppRoutes.statistics,
    AppRoutes.log,
    AppRoutes.family,
  ];

  static const _tabIcons = [
    Icons.home_outlined,
    Icons.bar_chart_outlined,
    Icons.list_alt_outlined,
    Icons.people_outline,
  ];

  static const _tabActiveIcons = [
    Icons.home,
    Icons.bar_chart,
    Icons.list_alt,
    Icons.people,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final idx = _tabPaths.indexWhere((p) => p == location);
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final l10n = context.l10n;

    final tabLabels = [
      l10n.tabHome,
      l10n.tabStatistics,
      l10n.tabLog,
      l10n.tabFamily,
    ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (i) => context.go(_tabPaths[i]),
          items: List.generate(
            _tabPaths.length,
            (i) => BottomNavigationBarItem(
              icon: Icon(_tabIcons[i]),
              activeIcon: Icon(_tabActiveIcons[i]),
              label: tabLabels[i],
            ),
          ),
        ),
      ),
    );
  }
}
