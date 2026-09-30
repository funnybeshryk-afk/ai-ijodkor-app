import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/lesson.dart';
import '../../data/models/quiz.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'homework_sheet.dart';
import 'lesson_sections.dart';
import 'quiz_section.dart';
import 'status_labels.dart';
import 'student_providers.dart';
import 'tracks.dart';

/// Mockup «3 · Dars»: material, what we learn, quiz, homework, and a bottom
/// action to mark the lesson.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    return AsyncValueView(
      value: lessons,
      onRetry: () => ref.invalidate(lessonsProvider),
      loading: const Scaffold(body: SafeArea(child: _LessonSkeleton())),
      builder: (all) {
        final lesson = all.where((l) => l.id == lessonId).firstOrNull;
        if (lesson == null) {
          return Scaffold(
            appBar: AppBar(),
            body: MessageView(
              icon: LucideIcons.lock,
              title: context.l10n.lessonNotFound,
            ),
          );
        }
        return _LessonPage(lesson: lesson, all: all);
      },
    );
  }
}

class _LessonPage extends ConsumerStatefulWidget {
  const _LessonPage({required this.lesson, required this.all});

  final Lesson lesson;
  final List<Lesson> all;

  @override
  ConsumerState<_LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends ConsumerState<_LessonPage> {
  bool _quizOpen = false;

  Lesson get lesson => widget.lesson;

  @override
  void didUpdateWidget(_LessonPage old) {
    super.didUpdateWidget(old);
    if (old.lesson.id != lesson.id) {
      _quizOpen = false;
      _viewedMarked = false;
    }
  }

  void _openMaterial() {
    ref.read(studentActionsProvider).markViewed(lesson.id);
    context.push(Routes.lessonMaterial(lesson.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final status =
        ref.watch(progressProvider).value?[lesson.id] ??
        ProgressStatus.notStarted;
    final quiz = ref.watch(quizProvider(lesson.id));
    final module = groupLessonsByModule(widget.all)
        .firstWhere((m) => m.name == lesson.module);
    final track = Track.ofModule(lesson.module);
    final ru = context.contentRu;
    final description = lesson.descriptionIn(ru: ru);
    // Teacher-approved objectives (AI4K12 / CSTA) when there are any, else
    // the lesson description as before.
    final objectives = ref.watch(lessonObjectivesProvider(lesson.id)).value;
    final goals = objectives != null && objectives.isNotEmpty
        ? [for (final o in objectives) o.titleIn(ru: ru)]
        : _descriptionLines(description ?? '');

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s3,
                AppSpace.s3,
                AppSpace.s3,
                AppSpace.s2,
              ),
              child: Row(
                children: [
                  IconButton(
                    tooltip: l10n.backLabel,
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      size: AppSize.iconLg,
                    ),
                    onPressed: () => context.canPop()
                        ? context.pop()
                        : context.go(Routes.studentLessons),
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(
                    child: Text(
                      l10n.lessonPosition(
                        module.label(ru: ru),
                        module.lessons.indexOf(lesson) + 1,
                        module.lessons.length,
                      ),
                      overflow: TextOverflow.ellipsis,
                      style: AppText.labelLg.copyWith(color: colors.inkMuted),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref
                    ..invalidate(progressProvider)
                    ..invalidate(quizProvider(lesson.id))
                    ..invalidate(lessonSectionsProvider(lesson.id))
                    ..invalidate(lessonObjectivesProvider(lesson.id))
                    ..invalidate(homeworkProvider);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.s5,
                    AppSpace.s1,
                    AppSpace.s5,
                    AppSpace.s6,
                  ),
                  children: [
                    Wrap(
                      spacing: AppSpace.s2,
                      runSpacing: AppSpace.s2,
                      children: [
                        if (track != null) TrackBadge(track: track),
                        StatusChip(
                          label: status.label(l10n),
                          color: status.color(colors),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.tileGap),
                    Text(
                      lesson.titleIn(ru: ru),
                      style: AppText.displayLg.copyWith(color: colors.ink),
                    ),
                    const SizedBox(height: AppSpace.s5),
                    ..._content(goals),
                    const SizedBox(height: AppSpace.s5),
                    quiz.when(
                      loading: () =>
                          const SkeletonBox(height: 150, radius: AppRadius.lg),
                      error: (_, _) => Panel(
                        child: ErrorRetryView(
                          onRetry: () =>
                              ref.invalidate(quizProvider(lesson.id)),
                        ),
                      ),
                      data: (questions) => questions.isEmpty
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpace.s5,
                              ),
                              child: _QuizCard(
                                lessonId: lesson.id,
                                questions: questions,
                                completed: status == ProgressStatus.completed,
                                open: _quizOpen,
                                onOpen: () => setState(() => _quizOpen = true),
                              ),
                            ),
                    ),
                    _HomeworkCard(lesson: lesson),
                  ],
                ),
              ),
            ),
            _BottomAction(
              lesson: lesson,
              status: status,
              hasQuiz: quiz.value?.isNotEmpty,
            ),
          ],
        ),
      ),
    );
  }

  /// The lesson body: native sections when the lesson has them (goals first,
  /// then the sections), otherwise the content_url panel of the mockup
  /// followed by the goals.
  List<Widget> _content(List<String> goals) {
    final sections = ref.watch(lessonSectionsProvider(lesson.id));
    final goalsBlock = [
      if (goals.isNotEmpty) ...[
        const SizedBox(height: AppSpace.s5),
        _Goals(lines: goals),
      ],
    ];
    return sections.when(
      loading: () => [
        const SkeletonBox(height: AppSize.mediaPanel, radius: AppRadius.lg),
        ...goalsBlock,
      ],
      error: (_, _) => [
        Panel(
          child: ErrorRetryView(
            onRetry: () => ref.invalidate(lessonSectionsProvider(lesson.id)),
          ),
        ),
      ],
      data: (list) {
        if (list.isEmpty) {
          return [
            _MaterialPanel(
              hasMaterial: (lesson.contentUrl ?? '').isNotEmpty,
              onOpen: _openMaterial,
            ),
            ...goalsBlock,
          ];
        }
        _markViewedOnce();
        return [
          if (goals.isNotEmpty) ...[
            _Goals(lines: goals),
            const SizedBox(height: AppSpace.s6),
          ],
          LessonSectionsView(sections: list),
        ];
      },
    );
  }

  // Seeing the lesson body counts as viewing it (the content_url panel does
  // this when opened).
  bool _viewedMarked = false;
  void _markViewedOnce() {
    if (_viewedMarked) return;
    _viewedMarked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(studentActionsProvider).markViewed(lesson.id);
    });
  }
}

List<String> _descriptionLines(String description) => description
    .split('\n')
    .map((l) => l.replaceFirst(RegExp(r'^\s*([-•*]|\d+[.)])\s*'), '').trim())
    .where((l) => l.isNotEmpty)
    .toList();

/// Dark media panel with the amber play button (opens content_url).
class _MaterialPanel extends StatelessWidget {
  const _MaterialPanel({required this.hasMaterial, required this.onOpen});

  final bool hasMaterial;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    if (!hasMaterial) {
      return NotePanel(icon: LucideIcons.fileText, text: l10n.noMaterial);
    }
    return Material(
      color: colors.inverse,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: SizedBox(
          height: AppSize.mediaPanel,
          child: Stack(
            children: [
              Center(
                child: Semantics(
                  button: true,
                  label: l10n.playMaterial,
                  child: Container(
                    width: AppSize.playButton,
                    height: AppSize.playButton,
                    decoration: BoxDecoration(
                      color: colors.brand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      LucideIcons.play,
                      size: AppSize.iconHero,
                      color: colors.onBrand,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: AppSpace.s4,
                bottom: AppSpace.card,
                child: Text(
                  l10n.materialCaption,
                  style: AppText.label.copyWith(color: colors.onInverse),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «What we learn»: approved objectives or the lesson description; several
/// lines become the numbered list from the mockup.
class _Goals extends StatelessWidget {
  const _Goals({required this.lines});

  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          context.l10n.lessonGoalsTitle,
          style: AppText.heading.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpace.s3),
        if (lines.length == 1)
          Text(lines.first, style: AppText.bodyLg.copyWith(color: colors.ink))
        else
          for (final (i, line) in lines.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.s3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: AppSize.stepBadge,
                    height: AppSize.stepBadge,
                    decoration: BoxDecoration(
                      color: colors.brandTint,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${i + 1}',
                      style: AppText.labelLg.copyWith(
                        color: colors.brandStrong,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpace.s3),
                  Expanded(
                    child: Text(
                      line,
                      style: AppText.bodyLg.copyWith(color: colors.ink),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

/// Amber-outlined quiz card; opens the quiz in place.
class _QuizCard extends StatelessWidget {
  const _QuizCard({
    required this.lessonId,
    required this.questions,
    required this.completed,
    required this.open,
    required this.onOpen,
  });

  final String lessonId;
  final List<QuizQuestion> questions;
  final bool completed;
  final bool open;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final total = questions.length;
    final required = total >= 4 ? total - 1 : total;
    return Panel(
      radius: AppRadius.lg,
      borderColor: colors.brand,
      borderWidth: AppSize.borderInput,
      padding: const EdgeInsets.all(AppSpace.panel),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const IconTile(icon: LucideIcons.checkSquare),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quizCardTitle,
                      style: AppText.titleSm.copyWith(color: colors.ink),
                    ),
                    Text(
                      completed
                          ? l10n.quizAlreadyCompleted
                          : l10n.quizCardBody(total, required),
                      style: AppText.caption.copyWith(
                        color: colors.inkSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.card),
          if (open)
            QuizSection(lessonId: lessonId, questions: questions)
          else
            PrimaryButton(
              key: const Key('quiz_start'),
              label: completed ? l10n.quizRetakeButton : l10n.quizStartButton,
              height: AppSize.button,
              onPressed: onOpen,
            ),
        ],
      ),
    );
  }
}

class _HomeworkCard extends ConsumerWidget {
  const _HomeworkCard({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final submissions = (ref.watch(homeworkProvider).value ?? const [])
        .where((h) => h.lessonId == lesson.id)
        .toList();
    return Panel(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(LucideIcons.upload, color: colors.brandStrong),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeworkCardTitle,
                      style: AppText.bodyStrong.copyWith(color: colors.ink),
                    ),
                    Text(
                      l10n.homeworkCardBody,
                      style: AppText.caption.copyWith(
                        color: colors.inkSoft,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                key: const Key('lesson_homework'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, AppSize.touch),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.s4),
                  textStyle: AppText.labelLg.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.tile),
                  ),
                ),
                onPressed: () => showHomeworkSheet(
                  context,
                  lessons: [lesson],
                  lessonId: lesson.id,
                ),
                child: Text(l10n.homeworkSubmitShort),
              ),
            ],
          ),
          for (final hw in submissions) ...[
            const Divider(height: AppSpace.s6),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hw.contentText ?? '—',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body.copyWith(color: colors.ink),
                      ),
                      if (hw.reviewerNotes != null)
                        Text(
                          l10n.teacherNote(hw.reviewerNotes!),
                          style: AppText.caption.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.s2),
                StatusChip(
                  label: hw.status.label(l10n),
                  color: hw.status.color(colors),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Fixed bottom bar. Without a quiz the student completes the lesson here
/// (same rule as the web); with a quiz only passing it completes the
/// lesson, so the bar just records that it was viewed.
class _BottomAction extends ConsumerWidget {
  const _BottomAction({
    required this.lesson,
    required this.status,
    required this.hasQuiz,
  });

  final Lesson lesson;
  final ProgressStatus status;

  /// null while the quiz is loading.
  final bool? hasQuiz;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final actions = ref.read(studentActionsProvider);
    final Widget? button = switch ((hasQuiz, status)) {
      (null, _) || (_, ProgressStatus.completed) => null,
      (false, _) => InverseButton(
        key: const Key('mark_completed'),
        label: l10n.markCompletedButton,
        icon: LucideIcons.check,
        onPressed: () => actions.markCompleted(lesson.id),
      ),
      (true, ProgressStatus.notStarted) => InverseButton(
        key: const Key('mark_viewed'),
        label: l10n.lessonViewedButton,
        icon: LucideIcons.check,
        onPressed: () => actions.markViewed(lesson.id),
      ),
      _ => null,
    };
    if (button == null) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpace.s5,
        AppSpace.card,
        AppSpace.s5,
        AppSpace.card + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceCard,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: button,
    );
  }
}

class _LessonSkeleton extends StatelessWidget {
  const _LessonSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpace.s5),
      children: const [
        SkeletonBox(height: AppSpace.s5, width: 160),
        SizedBox(height: AppSpace.s5),
        SkeletonBox(height: AppSpace.s6, width: 120, radius: AppRadius.pill),
        SizedBox(height: AppSpace.s3),
        SkeletonBox(height: AppSize.playButton),
        SizedBox(height: AppSpace.s5),
        SkeletonBox(height: AppSize.mediaPanel, radius: AppRadius.lg),
        SizedBox(height: AppSpace.s5),
        SkeletonBox(height: 150, radius: AppRadius.lg),
      ],
    );
  }
}
