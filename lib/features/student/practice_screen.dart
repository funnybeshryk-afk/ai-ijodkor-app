import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/env.dart';
import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'student_shell.dart';
import 'trainers.dart';

/// Trainer hub; each trainer opens the platform page in a WebView.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Env.platformUrl.isEmpty
            ? MessageView(
                icon: LucideIcons.settings,
                title: l10n.platformNotConfigured,
              )
            : ListView(
                padding: const EdgeInsets.all(AppSpace.s5),
                children: [
                  TabTitle(l10n.practiceTitle),
                  const SizedBox(height: AppSpace.s1),
                  Text(
                    l10n.practiceSubtitle,
                    style: AppText.body.copyWith(color: colors.inkMuted),
                  ),
                  for (final group in PracticeGroup.values) ...[
                    const SizedBox(height: AppSpace.s6),
                    SectionHeader(title: group.title(l10n)),
                    const SizedBox(height: AppSpace.s2),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpace.tileGap,
                      crossAxisSpacing: AppSpace.tileGap,
                      childAspectRatio: 1.45,
                      children: [
                        for (final trainer in trainers.where(
                          (t) => t.group == group,
                        ))
                          _TrainerCard(trainer: trainer),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _TrainerCard extends StatelessWidget {
  const _TrainerCard({required this.trainer});

  final Trainer trainer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      padding: const EdgeInsets.all(AppSpace.card),
      onTap: () => context.push(Routes.trainer(trainer.key)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            trainer.icon,
            size: AppSize.iconXl,
            color: trainer.group.color(colors),
          ),
          Text(
            trainer.title(context.l10n),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppText.labelLg.copyWith(
              color: colors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
