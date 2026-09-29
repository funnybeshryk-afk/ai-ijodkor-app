import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import 'teacher_providers.dart';

/// Bottom navigation of the teacher/admin area: students, review queue,
/// lesson access, payments, profile.
class TeacherShell extends ConsumerWidget {
  const TeacherShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pending = ref.watch(pendingHomeworkProvider).value?.length ?? 0;
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
              icon: const Icon(LucideIcons.users),
              label: l10n.navStudents,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pending > 0,
                label: Text('$pending'),
                child: const Icon(LucideIcons.clipboardCheck),
              ),
              label: l10n.navReview,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.bookOpen),
              label: l10n.navLessons,
            ),
            NavigationDestination(
              icon: const Icon(LucideIcons.wallet),
              label: l10n.navPayments,
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
