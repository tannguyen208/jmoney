import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../widgets/button_label.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'manage_screen.dart';
import 'stats_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destinations = [
      _Destination(l10n.navHome, Icons.home_outlined, Icons.home_rounded),
      _Destination(
        l10n.navHistory,
        Icons.receipt_long_outlined,
        Icons.receipt_long_rounded,
      ),
      _Destination(
        l10n.navStats,
        Icons.donut_large_outlined,
        Icons.donut_large_rounded,
      ),
      _Destination(
        l10n.navManage,
        Icons.tune_outlined,
        Icons.tune_rounded,
      ),
    ];
    const screens = [
      HomeScreen(),
      HistoryScreen(),
      StatsScreen(),
      ManageScreen(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= 760;
        final content = IndexedStack(
          index: _selectedIndex,
          children: screens,
        );

        if (useRail) {
          final colors = Theme.of(context).colorScheme;
          return Scaffold(
            body: SafeArea(
              child: Row(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _select,
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: -0.8,
                      destinations: [
                        for (final item in destinations)
                          NavigationRailDestination(
                            icon: Icon(item.icon),
                            selectedIcon: Icon(item.selectedIcon),
                            label: ButtonLabel(item.label),
                          ),
                      ],
                    ),
                  ),
                  Expanded(child: content),
                ],
              ),
            ),
          );
        }

        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          body: content,
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.outlineVariant),
              ),
            ),
            child: SafeArea(
              top: false,
              child: NavigationBar(
                selectedIndex: _selectedIndex,
                onDestinationSelected: _select,
                destinations: [
                  for (final item in destinations)
                    NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _select(int value) => setState(() => _selectedIndex = value);
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
