import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/student_records.dart';
import '../../data/xp.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';
import 'student_shell.dart';

/// The platform rating (platform migration 0040): ONE rating for everybody,
/// by month (the main one, everybody starts from zero on the 1st) or by week.
/// «All time» is not a rating but the student's own XP, shown below.
class RatingScreen extends ConsumerStatefulWidget {
  const RatingScreen({super.key});

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  RatingPeriod _period = RatingPeriod.month;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final provider = ratingProvider(_period);
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: ref.watch(provider),
          onRetry: () => ref.invalidate(provider),
          builder: (rows) {
            final me = rows.where((r) => r.isMe).firstOrNull;
            final empty = rows.every((r) => r.points <= 0);
            return RefreshIndicator(
              onRefresh: () {
                ref.invalidate(xpProvider);
                return ref.refresh(provider.future);
              },
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.s5),
                children: [
                  TabTitle(l10n.ratingTitle),
                  const SizedBox(height: AppSpace.s1),
                  Text(
                    l10n.ratingSubtitle,
                    style: AppText.body.copyWith(color: colors.inkMuted),
                  ),
                  const SizedBox(height: AppSpace.s4),
                  SegmentedButton<RatingPeriod>(
                    key: const Key('rating_period'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: RatingPeriod.month,
                        label: Text(l10n.ratingTabMonth),
                      ),
                      ButtonSegment(
                        value: RatingPeriod.week,
                        label: Text(l10n.ratingTabWeek),
                      ),
                    ],
                    selected: {_period},
                    onSelectionChanged: (s) =>
                        setState(() => _period = s.first),
                  ),
                  const SizedBox(height: AppSpace.s5),
                  if (empty)
                    MessageView(
                      icon: LucideIcons.trophy,
                      title: _period == RatingPeriod.month
                          ? l10n.ratingEmptyMonth
                          : l10n.ratingEmptyWeek,
                    )
                  else
                    Panel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final (i, row) in rows.indexed) ...[
                            if (i > 0)
                              // The own place is not next to the podium: a
                              // gap in the numbers, not a different list.
                              if (row.place - rows[i - 1].place > 1)
                                const _Gap()
                              else
                                const Divider(height: 1),
                            _Row(
                              key: row.isMe ? const Key('rating_me') : null,
                              place: row.place,
                              name: row.isMe
                                  ? '${row.fullName} (${l10n.ratingYou})'
                                  : row.fullName,
                              score: l10n.ratingScore(row.points),
                              highlighted: row.isMe,
                            ),
                          ],
                        ],
                      ),
                    ),
                  if (me != null) ...[
                    const SizedBox(height: AppSpace.s3),
                    Text(
                      key: const Key('rating_your_place'),
                      l10n.ratingYourPlace(me.place, me.totalStudents),
                      style: AppText.label.copyWith(color: colors.inkSoft),
                    ),
                  ],
                  const SizedBox(height: AppSpace.s6),
                  const _XpCard(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// All-time XP: a personal achievement, not a rating.
class _XpCard extends ConsumerWidget {
  const _XpCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final xp = ref.watch(xpProvider);
    final updating = xp.hasError && xp.error is DataUpdatingException;
    return Panel(
      padding: const EdgeInsets.all(AppSpace.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon: LucideIcons.star),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.ratingXpTitle,
                  style: AppText.bodyStrong.copyWith(color: colors.ink),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  key: const Key('rating_xp'),
                  // Never a zero in place of a number that could not be read.
                  updating ? l10n.dataUpdating : (xp.value?.toString() ?? '…'),
                  style: AppText.displaySm.copyWith(color: colors.ink),
                ),
                const SizedBox(height: AppSpace.s1),
                Text(
                  l10n.ratingXpNote,
                  style: AppText.caption.copyWith(color: colors.inkMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Gap extends StatelessWidget {
  const _Gap();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      height: AppSpace.s5,
      alignment: Alignment.center,
      child: Icon(
        LucideIcons.ellipsis,
        size: AppSize.iconMd,
        color: colors.inkMuted,
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
