import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/skills.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';
import 'tracks.dart';

/// «Ko'nikmalar»: the learning objectives the student has practised (or has
/// ahead of them), by direction, with their level and what to repeat.
/// The levels come from the platform (objective_mastery, migration 0029).
class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backLabel,
          icon: const Icon(LucideIcons.chevronLeft, size: AppSize.iconLg),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.skillsTitle),
      ),
      body: AsyncValueView(
        value: ref.watch(skillsProvider),
        onRetry: () => ref.invalidate(skillsProvider),
        builder: (skills) => RefreshIndicator(
          onRefresh: () => ref.refresh(skillsProvider.future),
          child: skills.isEmpty ? _Empty(l10n: l10n) : _Body(skills: skills),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // A scrollable, so pull-to-refresh also works on the empty state.
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: box.maxHeight,
          child: MessageView(
            icon: LucideIcons.target,
            title: l10n.skillsEmptyTitle,
            message: l10n.skillsEmptyBody,
            actions: [
              PrimaryButton(
                label: l10n.skillsGoToLessons,
                onPressed: () => context.go(Routes.studentLessons),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.skills});

  final SkillsOverview skills;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpace.s5),
      children: [
        Text(
          l10n.skillsSubtitle,
          style: AppText.body.copyWith(color: colors.inkMuted),
        ),
        const SizedBox(height: AppSpace.s4),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                key: const Key('skills_stat_practised'),
                value: skills.practised,
                label: l10n.skillsStatPractised,
              ),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: _StatTile(
                key: const Key('skills_stat_solved'),
                value: skills.solved,
                label: l10n.skillsStatSolved,
              ),
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: _StatTile(
                key: const Key('skills_stat_repeat'),
                value: skills.review.length,
                label: l10n.skillsStatToRepeat,
              ),
            ),
          ],
        ),
        if (skills.review.isNotEmpty) ...[
          const SizedBox(height: AppSpace.section),
          SectionHeader(title: l10n.skillsReviewTitle),
          const SizedBox(height: AppSpace.s1),
          Text(
            l10n.skillsReviewHint,
            style: AppText.caption.copyWith(color: colors.inkSoft),
          ),
          const SizedBox(height: AppSpace.s2),
          _ItemsPanel(key: const Key('skills_review'), items: skills.review),
        ],
        for (final group in skills.groups) ...[
          const SizedBox(height: AppSpace.section),
          _GroupHeader(track: group.track),
          const SizedBox(height: AppSpace.s2),
          _ItemsPanel(items: group.items),
        ],
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s3,
        vertical: AppSpace.s3,
      ),
      child: SizedBox(
        height: AppSize.statTile - AppSpace.s6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$value',
              style: AppText.displayMd.copyWith(color: colors.ink),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.caption.copyWith(color: colors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.track});

  /// A [Track] name; null for objectives of no direction.
  final String? track;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final t = Track.values.where((x) => x.name == track).firstOrNull;
    return Row(
      children: [
        Container(
          width: AppSize.dot,
          height: AppSize.dot,
          decoration: BoxDecoration(
            color: t?.color(colors) ?? colors.inkMuted,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpace.s2),
        Expanded(
          child: Text(
            t?.label(l10n) ?? l10n.skillsTrackOther,
            style: AppText.heading.copyWith(color: colors.ink),
          ),
        ),
      ],
    );
  }
}

class _ItemsPanel extends StatelessWidget {
  const _ItemsPanel({super.key, required this.items});

  final List<SkillItem> items;

  @override
  Widget build(BuildContext context) {
    return Panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) const Divider(height: 1),
            _SkillRow(item: item),
          ],
        ],
      ),
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow({required this.item});

  final SkillItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final strong = item.state == SkillState.strong;
    final label = switch (item.state) {
      SkillState.fresh => l10n.skillStateFresh,
      SkillState.start => l10n.skillStateStart,
      SkillState.growing => l10n.skillStateGrowing,
      SkillState.strong => l10n.skillStateStrong,
    };
    return Padding(
      key: Key('skill_${item.objective.code}'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.objective.titleIn(ru: context.contentRu),
                  style: AppText.bodyStrong.copyWith(color: colors.ink),
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              StatusChip(
                label: label,
                color: strong ? colors.success : colors.inkSoft,
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s2),
          Row(
            children: [
              Expanded(
                child: ProgressBar(
                  value: item.level / 100,
                  color: strong ? colors.success : colors.brand,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Text(
                '${item.level}%',
                key: Key('skill_level_${item.objective.code}'),
                style: AppText.label.copyWith(color: colors.inkSoft),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s1),
          Text(
            item.attempts > 0
                ? '${item.objective.code} · ${l10n.skillSolvedCount(item.solved)}'
                : item.objective.code,
            style: AppText.caption.copyWith(color: colors.inkSoft),
          ),
        ],
      ),
    );
  }
}
