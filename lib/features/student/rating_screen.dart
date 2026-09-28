import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';
import 'student_shell.dart';

/// This week's class leaderboard (get_class_leaderboard RPC).
class RatingScreen extends ConsumerWidget {
  const RatingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final me = ref.watch(currentUserIdProvider).value;
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: ref.watch(leaderboardProvider),
          onRetry: () => ref.invalidate(leaderboardProvider),
          builder: (entries) => RefreshIndicator(
            onRefresh: () => ref.refresh(leaderboardProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(AppSpace.s5),
              children: [
                TabTitle(l10n.ratingTitle),
                const SizedBox(height: AppSpace.s1),
                Text(
                  l10n.ratingSubtitle,
                  style: AppText.body.copyWith(color: colors.inkMuted),
                ),
                const SizedBox(height: AppSpace.s5),
                if (entries.isEmpty)
                  MessageView(icon: LucideIcons.trophy, title: l10n.ratingEmpty)
                else
                  Panel(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        for (final (i, entry) in entries.indexed) ...[
                          if (i > 0) const Divider(height: 1),
                          _Row(
                            key: entry.studentId == me
                                ? const Key('rating_me')
                                : null,
                            place: i + 1,
                            name: entry.studentId == me
                                ? '${entry.fullName} (${l10n.ratingYou})'
                                : entry.fullName,
                            score: l10n.ratingScore(entry.totalScore),
                            highlighted: entry.studentId == me,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.place,
    required this.name,
    required this.score,
    required this.highlighted,
  });

  final int place;
  final String name;
  final String score;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final podium = place <= 3;
    return Container(
      color: highlighted ? colors.brandTint : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.card,
      ),
      child: Row(
        children: [
          Container(
            width: AppSize.rankBadge,
            height: AppSize.rankBadge,
            decoration: BoxDecoration(
              color: podium ? colors.brand : colors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: podium
                ? Icon(
                    LucideIcons.trophy,
                    size: AppSize.iconMd,
                    color: colors.onBrand,
                  )
                : Text(
                    '$place',
                    style: AppText.label.copyWith(color: colors.inkSoft),
                  ),
          ),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Text(
              name,
              style: AppText.bodyStrong.copyWith(
                color: colors.ink,
                fontWeight: highlighted ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
          Text(score, style: AppText.label.copyWith(color: colors.inkSoft)),
        ],
      ),
    );
  }
}
