import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kid_matix/core/extensions/build_context_extension.dart';
import 'package:kid_matix/core/widgets/app_tab_bar.dart';
import 'package:kid_matix/core/widgets/app_tab_item.dart';
import 'package:kid_matix/l10n/app_localizations.dart';

/// Frame shared by the four main tabs: the current tab above the tab bar.
class AppShell extends StatelessWidget {
  /// Creates the shell around [navigationShell].
  const AppShell({required this.navigationShell, super.key});

  /// Branch container provided by the router.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    return Scaffold(
      body: SafeArea(bottom: false, child: navigationShell),
      bottomNavigationBar: AppTabBar(
        semanticLabel: l10n.mainNavigationLabel,
        currentIndex: navigationShell.currentIndex,
        onTabSelected: _selectTab,
        items: <AppTabItem>[
          AppTabItem(icon: Icons.flag_rounded, label: l10n.tabLearningPath),
          AppTabItem(icon: Icons.adjust_rounded, label: l10n.tabTraining),
          AppTabItem(icon: Icons.bolt_rounded, label: l10n.tabChallenges),
          AppTabItem(icon: Icons.person_rounded, label: l10n.tabProfile),
        ],
      ),
    );
  }

  void _selectTab(int index) {
    final bool isCurrentTab = index == navigationShell.currentIndex;
    navigationShell.goBranch(index, initialLocation: isCurrentTab);
  }
}
