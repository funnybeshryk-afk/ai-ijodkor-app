import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/profile.dart';
import '../../data/providers.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/sign_out_button.dart';
import '../../widgets/ui.dart';

/// Profile for every role: name, language, sign-out; students also get
/// their homework and certificates here. Shown as the student's «Profil»
/// tab and pushed from the other roles' screens.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.asTab = false});

  /// In the student tab bar: no back button.
  final bool asTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final profile = ref.watch(currentProfileProvider).value;
    final isStudent = profile?.role == UserRole.student;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: asTab
            ? null
            : IconButton(
                tooltip: l10n.backLabel,
                icon: const Icon(LucideIcons.chevronLeft, size: AppSize.iconLg),
                onPressed: () => context.pop(),
              ),
        title: Text(l10n.profileTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.s5),
        children: [
          if (profile != null && profile.fullName.isNotEmpty) ...[
            Text(
              profile.fullName,
              style: AppText.displaySm.copyWith(color: colors.ink),
            ),
            const SizedBox(height: AppSpace.s6),
          ],
          if (isStudent) ...[
            Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _LinkRow(
                    icon: LucideIcons.clipboardList,
                    label: l10n.myHomeworkLink,
                    onTap: () => context.push(Routes.studentHomework),
                  ),
                  const Divider(height: 1, indent: AppSpace.s4),
                  _LinkRow(
                    icon: LucideIcons.award,
                    label: l10n.certificatesTitle,
                    onTap: () => context.push(Routes.studentCertificates),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.s6),
          ],
          Text(
            l10n.languageLabel,
            style: AppText.label.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpace.s2),
          const Align(
            alignment: Alignment.centerLeft,
            child: LanguageSwitcher(),
          ),
          const SizedBox(height: AppSpace.s8),
          const SignOutButton(),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s4,
          vertical: AppSpace.s3,
        ),
        child: Row(
          children: [
            IconTile(icon: icon),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyStrong.copyWith(color: colors.ink),
              ),
            ),
            Icon(LucideIcons.chevronRight, color: colors.inkMuted),
          ],
        ),
      ),
    );
  }
}
