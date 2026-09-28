import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';

/// Bottom navigation of the student area (mockup «2 · O'quvchi»): one tab
/// per shell branch.
class StudentShell extends StatelessWidget {
  const StudentShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: context.colors.border)),
        ),
        child: NavigationBar(
          selectedIndex: shell.currentIndex,
          onDestinationSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          destinations: [
            NavigationDestination(
              icon: const Icon(LucideIcons.home),
              label: l10n.navHome,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.bookOpen),
              label: l10n.navLessons,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.target),
              label: l10n.navPractice,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.trophy),
              label: l10n.navRating,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.user),
              label: l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}

/// Large Baloo 2 page title used at the top of each tab.
class TabTitle extends StatelessWidget {
  const TabTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppText.displayMd.copyWith(color: context.colors.ink));
}
