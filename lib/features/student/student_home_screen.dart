import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/lesson.dart';
import '../../data/models/student_records.dart';
import '../../data/providers.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';
import 'trainers.dart';
import 'tracks.dart';

/// Mockup «2 · O'quvchi — bosh sahifa».
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(lessonsProvider)
      ..invalidate(progressProvider)
      ..invalidate(pointsProvider)
      ..invalidate(homeworkProvider)
      ..invalidate(leaderboardProvider)
      ..invalidate(reviewSummaryProvider);
    await ref.read(lessonsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    final progress = ref.watch(progressProvider);
    return Scaffold(
      body: SafeArea(
        child: AsyncValueView(
          value: lessons.hasValue && progress.hasValue
              ? AsyncValue.data((lessons.value!, progress.value!))
              : lessons.hasError || progress.hasError
              ? AsyncValue<(List<Lesson>, Map<String, ProgressStatus>)>.error(
                  lessons.error ?? progress.error!,
                  StackTrace.empty,
                )
              : const AsyncValue.loading(),
          onRetry: () => _refresh(ref),
          loading: const _HomeSkeleton(),
          builder: (data) => RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: _HomeBody(lessons: data.$1, progress: data.$2),
          ),
        ),
      ),
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.lessons, required this.progress});

  final List<Lesson> lessons;
  final Map<String, ProgressStatus> progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final next = nextLessonToStudy(lessons, progress);
    final done = lessons
        .where((l) => progress[l.id] == ProgressStatus.completed)
        .length;
    final pending = (ref.watch(homeworkProvider).value ?? const [])
        .where((h) => h.status == HomeworkStatus.pending)
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s5,
        AppSpace.s5,
        AppSpace.s5,
        AppSpace.s6,
      ),
      children: [
        const _Header(),
        const SizedBox(height: AppSpace.section),
        _NextLessonPanel(
          lessons: lessons,
          next: next,
          hasLessons: lessons.isNotEmpty,
        ),
        const SizedBox(height: AppSpace.section),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                value: '$done/${lessons.length}',
                label: l10n.statLessonsDone,
              ),
            ),
            const SizedBox(width: AppSpace.s3),
            const Expanded(child: _RankTile()),
          ],
        ),
        const SizedBox(height: AppSpace.section),
        const _ReviewCard(),
        const _SkillsLink(),
        const SizedBox(height: AppSpace.section),
        SectionHeader(
          title: l10n.tracksTitle,
          action: l10n.allLessonsLink,
          onAction: () => context.go(Routes.studentLessons),
        ),
        const SizedBox(height: AppSpace.s2),
        _TracksPanel(progress: trackProgress(lessons, progress)),
        if (pending.isNotEmpty) ...[
          const SizedBox(height: AppSpace.section),
          NotePanel(
            key: const Key('homework_in_review'),
            tile: true,
            icon: LucideIcons.fileText,
            title: l10n.homeworkInReviewTitle,
            text: pending.length == 1
                ? l10n.homeworkInReviewBody(
                    lessons
                            .where((l) => l.id == pending.first.lessonId)
                            .firstOrNull
                            ?.titleIn(ru: context.contentRu) ??
                        '',
                  )
                : l10n.homeworkInReviewMany(pending.length),
            onTap: () => context.push(Routes.studentHomework),
          ),
        ],
        const SizedBox(height: AppSpace.section),
        SectionHeader(
          title: l10n.practiceTitle,
          action: l10n.practiceAllLink,
          onAction: () => context.go(Routes.studentPractice),
        ),
        const SizedBox(height: AppSpace.s2),
        const _PracticeRow(),
      ],
    );
  }
}

/// «Bugungi takrorlash: N ta savol» — hidden while the review queue is empty.
class _ReviewCard extends ConsumerWidget {
  const _ReviewCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final summary = ref.watch(reviewSummaryProvider).value;
    if (summary == null || summary.queueSize == 0) {
      return const SizedBox.shrink();
    }
    final waiting = summary.dueNow > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.section),
      child: Panel(
        key: const Key('review_card'),
        color: colors.brandTint,
        borderColor: colors.brand,
        onTap: () => context.push(Routes.studentReview),
        child: Row(
          children: [
            const IconTile(icon: LucideIcons.repeat),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    waiting
                        ? l10n.reviewCardTitle(summary.dueNow)
                        : summary.dayDone
                        ? l10n.reviewCardDone
                        : l10n.reviewCardNothing,
                    style: AppText.heading.copyWith(color: colors.ink),
                  ),
                  Text(
                    waiting ? l10n.reviewCardSubtitle : l10n.reviewCardNextHint,
                    style: AppText.caption.copyWith(color: colors.inkSoft),
                  ),
                ],
              ),
            ),
            Icon(
              LucideIcons.chevronRight,
              size: AppSize.iconLg,
              color: colors.inkMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Link card to «Ko'nikmalar» with a one-line summary.
class _SkillsLink extends ConsumerWidget {
  const _SkillsLink();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    // The summary is a nicety: while loading or on an error the card still opens the page.
    final skills = ref.watch(skillsProvider).value;
    return Panel(
      key: const Key('skills_link'),
      onTap: () => context.push(Routes.studentSkills),
      child: Row(
        children: [
          const IconTile(icon: LucideIcons.target),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.skillsTitle,
                  style: AppText.heading.copyWith(color: colors.ink),
                ),
                Text(
                  skills != null && skills.practised > 0
                      ? l10n.skillsLinkSubtitle(skills.practised, skills.solved)
                      : l10n.skillsLinkEmpty,
                  style: AppText.caption.copyWith(color: colors.inkSoft),
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: AppSize.iconLg,
            color: colors.inkMuted,
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final name = ref.watch(currentProfileProvider).value?.givenName ?? '';
    final points = ref.watch(pointsProvider).value;
    return Row(
      children: [
        Container(
          width: AppSize.avatar,
          height: AppSize.avatar,
          decoration: BoxDecoration(
            color: colors.brandTint,
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.brand,
              width: AppSize.avatarBorder,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            name.isEmpty ? '' : name.characters.first.toUpperCase(),
            style: AppText.heading.copyWith(color: colors.brandDeep),
          ),
        ),
        const SizedBox(width: AppSpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.greetingPrefix,
                style: AppText.caption.copyWith(color: colors.inkMuted),
              ),
              Text(
                name,
                style: AppText.displaySm.copyWith(color: colors.ink),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Semantics(
          label: points == null ? null : l10n.pointsLabel(points),
          excludeSemantics: true,
          child: Container(
            height: AppSize.pillHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.card),
            decoration: BoxDecoration(
              color: colors.inverse,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.star,
                  size: AppSize.iconMd,
                  color: colors.brand,
                ),
                const SizedBox(width: AppSpace.labelGap),
                Text(
                  points?.toString() ?? '…',
                  style: AppText.bodyStrong.copyWith(color: colors.onInverse),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NextLessonPanel extends ConsumerWidget {
  const _NextLessonPanel({
    required this.lessons,
    required this.next,
    required this.hasLessons,
  });

  final List<Lesson> lessons;
  final Lesson? next;
  final bool hasLessons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final lesson = next;
    if (lesson == null) {
      return Panel(
        radius: AppRadius.lg,
        color: colors.surfaceMuted,
        bordered: false,
        padding: const EdgeInsets.all(AppSpace.s5),
        child: Row(
          children: [
            IconTile(
              icon: hasLessons ? LucideIcons.partyPopper : LucideIcons.lock,
              onCard: true,
            ),
            const SizedBox(width: AppSpace.s3),
            Expanded(
              child: Text(
                hasLessons ? l10n.allLessonsDone : l10n.noLessons,
                style: AppText.body.copyWith(color: colors.inkSoft),
              ),
            ),
          ],
        ),
      );
    }

    final ru = context.contentRu;
    final module = groupLessonsByModule(lessons)
        .firstWhere((m) => m.name == lesson.module);
    final moduleLessons = module.lessons;
    final number = moduleLessons.indexOf(lesson) + 1;
    final quizCount = ref.watch(quizProvider(lesson.id)).value?.length ?? 0;
    final onBrand = colors.onBrand;
    final meta = AppText.labelLg.copyWith(color: onBrand);

    return Container(
      padding: const EdgeInsets.all(AppSpace.s5),
      decoration: BoxDecoration(
        color: colors.brand,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.nextLessonTitle.toUpperCase(),
                  style: AppText.overline.copyWith(color: onBrand),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.tileGap,
                  vertical: AppSpace.s1,
                ),
                decoration: BoxDecoration(
                  color: colors.surfacePage.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  l10n.nextLessonBadge(module.label(ru: ru), number),
                  style: AppText.label.copyWith(color: onBrand),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.card),
          Text(
            lesson.titleIn(ru: ru),
            style: AppText.displayMd.copyWith(color: onBrand),
          ),
          if (lesson.contentUrl != null || quizCount > 0) ...[
            const SizedBox(height: AppSpace.card),
            Wrap(
              spacing: AppSpace.s4,
              runSpacing: AppSpace.s1,
              children: [
                if (lesson.contentUrl != null)
                  _Meta(
                    icon: LucideIcons.play,
                    text: l10n.metaMaterial,
                    style: meta,
                  ),
                if (quizCount > 0)
                  _Meta(
                    icon: LucideIcons.checkSquare,
                    text: l10n.metaQuiz(quizCount),
                    style: meta,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpace.card),
          InverseButton(
            key: const Key('continue_lesson'),
            label: l10n.continueButton,
            trailingIcon: LucideIcons.arrowRight,
            onPressed: () => context.go(Routes.studentLesson(lesson.id)),
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.text, required this.style});

  final IconData icon;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: AppSize.iconSm, color: style.color),
      const SizedBox(width: AppSpace.labelGap),
      Text(text, style: style),
    ],
  );
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Panel(
      padding: const EdgeInsets.all(AppSpace.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: AppText.statValue.copyWith(color: colors.ink)),
          Text(label, style: AppText.caption.copyWith(color: colors.inkMuted)),
        ],
      ),
    );
  }
}

/// Place in this week's class leaderboard.
class _RankTile extends ConsumerWidget {
  const _RankTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final me = ref.watch(currentUserIdProvider).value;
    final board = ref.watch(leaderboardProvider).value;
    if (board == null) return const SkeletonBox(height: AppSize.statTile);
    final index = board.indexWhere((e) => e.studentId == me);
    return _StatTile(
      value: index < 0 ? '—' : '#${index + 1}',
      label: index < 0 ? l10n.statNotRanked : l10n.statRank,
    );
  }
}

class _TracksPanel extends StatelessWidget {
  const _TracksPanel({required this.progress});

  final List<TrackProgress> progress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Panel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s1,
      ),
      child: Column(
        children: [
          for (final (i, p) in progress.indexed) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpace.card),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppSize.dot,
                        height: AppSize.dot,
                        decoration: BoxDecoration(
                          color: p.track.color(colors),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpace.s2),
                      Expanded(
                        child: Text(
                          p.track.label(l10n),
                          style: AppText.bodyStrong.copyWith(
                            color: colors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        p.granted == 0
                            ? l10n.trackLocked
                            : '${p.done} / ${p.granted}',
                        style: AppText.metric.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.s2),
                  ProgressBar(
                    value: p.granted == 0 ? 0 : p.done / p.granted,
                    color: p.track.color(colors),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// First three trainers as shortcuts (mockup: «Mashqlar»).
class _PracticeRow extends StatelessWidget {
  const _PracticeRow();

  static const _keys = ['typing', 'python-brain', 'logic'];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        for (final (i, key) in _keys.indexed) ...[
          if (i > 0) const SizedBox(width: AppSpace.tileGap),
          Expanded(
            child: Builder(
              builder: (context) {
                final trainer = trainerByKey(key)!;
                return Panel(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.s3,
                    vertical: AppSpace.card,
                  ),
                  onTap: () => context.push(Routes.trainer(key)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        trainer.icon,
                        size: AppSize.iconXl,
                        color: trainer.group.color(colors),
                      ),
                      const SizedBox(height: AppSpace.tileGap),
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
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpace.s5),
      children: const [
        Row(
          children: [
            SkeletonBox(
              height: AppSize.avatar,
              width: AppSize.avatar,
              radius: AppRadius.pill,
            ),
            SizedBox(width: AppSpace.s3),
            Expanded(child: SkeletonBox(height: AppSize.pillHeight)),
          ],
        ),
        SizedBox(height: AppSpace.section),
        SkeletonBox(height: 220, radius: AppRadius.lg),
        SizedBox(height: AppSpace.section),
        Row(
          children: [
            Expanded(child: SkeletonBox(height: AppSize.statTile)),
            SizedBox(width: AppSpace.s3),
            Expanded(child: SkeletonBox(height: AppSize.statTile)),
          ],
        ),
        SizedBox(height: AppSpace.section),
        SkeletonBox(height: 180),
      ],
    );
  }
}
