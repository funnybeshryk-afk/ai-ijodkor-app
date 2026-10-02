import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/review.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';
import 'task_answer_input.dart';

/// «Takrorlash»: today's review — one question at a time, the verdict (never the
/// right answer), the end of the day's set with the streak. The questions, the
/// checking and the schedule are the server's (migration 0032).
class DailyReviewScreen extends ConsumerWidget {
  const DailyReviewScreen({super.key});

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
        title: Text(l10n.dailyReviewTitle),
      ),
      body: AsyncValueView(
        value: ref.watch(dailyReviewProvider),
        onRetry: () => ref.invalidate(dailyReviewProvider),
        builder: (review) {
          if (review.questions.isNotEmpty) {
            return _Session(questions: review.questions);
          }
          return _NothingToDo(reviewedToday: review.reviewedToday);
        },
      ),
    );
  }
}

/// No questions now: the queue is empty, or the day is done, or nothing is due.
class _NothingToDo extends ConsumerWidget {
  const _NothingToDo({required this.reviewedToday});

  final int reviewedToday;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final summary = ref.watch(reviewSummaryProvider);
    return AsyncValueView(
      value: summary,
      onRetry: () => ref.invalidate(reviewSummaryProvider),
      builder: (s) {
        if (s.queueSize == 0) {
          return MessageView(
            icon: LucideIcons.repeat,
            title: l10n.dailyReviewEmptyTitle,
            message: l10n.dailyReviewEmptyBody,
            actions: [
              PrimaryButton(
                label: l10n.skillsGoToLessons,
                onPressed: () => context.go(Routes.studentLessons),
              ),
            ],
          );
        }
        final done = s.dayDone || reviewedToday > 0;
        return MessageView(
          icon: LucideIcons.calendarCheck,
          title: done ? l10n.reviewDoneTitle : l10n.reviewCardNothing,
          message: done
              ? l10n.reviewDoneBody(
                  reviewedToday == 0 ? s.reviewedToday : reviewedToday,
                )
              : l10n.reviewNothingBody,
          actions: [
            PrimaryButton(
              label: l10n.navHome,
              onPressed: () => context.go(Routes.student),
            ),
          ],
        );
      },
    );
  }
}

class _Session extends ConsumerStatefulWidget {
  const _Session({required this.questions});

  final List<ReviewQuestion> questions;

  @override
  ConsumerState<_Session> createState() => _SessionState();
}

class _SessionState extends ConsumerState<_Session> {
  int _index = 0;
  int _right = 0;
  bool? _verdict;
  bool _busy = false;
  bool _finished = false;
  String? _error;
  late TaskAnswer _answer = TaskAnswer.initial(widget.questions.first);
  DateTime? _touchedAt;

  ReviewQuestion get _question => widget.questions[_index];
  bool get _last => _index == widget.questions.length - 1;

  Future<void> _check() async {
    final json = _answer.toJson(_question.type);
    if (json == null || _busy || _verdict != null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final spent = _touchedAt == null
          ? null
          : DateTime.now().difference(_touchedAt!).inMilliseconds;
      final result = await ref
          .read(studentActionsProvider)
          .submitReview(_question.taskId, json, durationMs: spent);
      if (!mounted) return;
      setState(() {
        _verdict = result.correct;
        if (result.correct) _right += 1;
        _busy = false;
      });
    } on ReviewException catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      setState(() {
        _busy = false;
        _error = switch (e.error) {
          ReviewError.dailyLimit => l10n.reviewErrorLimit,
          ReviewError.notDue => l10n.reviewErrorNotDue,
          _ => l10n.errorGeneric,
        };
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = context.l10n.errorGeneric;
      });
    }
  }

  void _next() {
    if (_last) {
      // Refresh the card and the streak now that the set is over.
      ref.read(studentActionsProvider).finishReview();
      setState(() => _finished = true);
      return;
    }
    setState(() {
      _index += 1;
      _answer = TaskAnswer.initial(widget.questions[_index]);
      _verdict = null;
      _error = null;
      _touchedAt = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final streak = ref.watch(practiceStreakProvider).value ?? 0;

    if (_finished) {
      return ListView(
        key: const Key('review_done'),
        padding: const EdgeInsets.all(AppSpace.s5),
        children: [
          Text(
            l10n.reviewFinishedTitle,
            style: AppText.displayMd.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpace.s3),
          Text(
            l10n.reviewScore(_right, widget.questions.length),
            key: const Key('review_score'),
            style: AppText.heading.copyWith(color: colors.ink),
          ),
          if (streak > 0) ...[
            const SizedBox(height: AppSpace.s2),
            Row(
              key: const Key('review_streak'),
              children: [
                Icon(
                  LucideIcons.flame,
                  color: colors.brandStrong,
                  size: AppSize.iconMd,
                ),
                const SizedBox(width: AppSpace.s2),
                Text(
                  l10n.reviewStreak(streak),
                  style: AppText.bodyStrong.copyWith(color: colors.ink),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpace.s6),
          PrimaryButton(
            label: l10n.navHome,
            onPressed: () => context.go(Routes.student),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpace.s5),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.reviewProgress(_index + 1, widget.questions.length),
                key: const Key('review_progress'),
                style: AppText.label.copyWith(color: colors.inkSoft),
              ),
            ),
            if (streak > 0)
              Row(
                children: [
                  Icon(
                    LucideIcons.flame,
                    color: colors.brandStrong,
                    size: AppSize.iconSm,
                  ),
                  const SizedBox(width: AppSpace.s1),
                  Text(
                    l10n.reviewStreak(streak),
                    style: AppText.caption.copyWith(color: colors.inkSoft),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: AppSpace.s3),
        Text(
          _question.promptIn(ru: context.contentRu),
          key: const Key('review_prompt'),
          style: AppText.titleSm.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpace.s4),
        TaskAnswerInput(
          key: ValueKey(_question.taskId),
          question: _question,
          answer: _answer,
          enabled: _verdict == null && !_busy,
          onChanged: () => setState(() => _touchedAt ??= DateTime.now()),
        ),
        const SizedBox(height: AppSpace.s4),
        if (_verdict == null)
          PrimaryButton(
            key: const Key('review_check'),
            label: l10n.reviewCheck,
            busy: _busy,
            onPressed: _answer.toJson(_question.type) == null ? null : _check,
          )
        else ...[
          Row(
            key: const Key('review_verdict'),
            children: [
              Icon(
                _verdict! ? LucideIcons.checkCircle : LucideIcons.xCircle,
                color: _verdict! ? colors.success : colors.danger,
                size: AppSize.iconLg,
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: Text(
                  _verdict! ? l10n.reviewCorrect : l10n.reviewWrong,
                  style: AppText.bodyStrong.copyWith(
                    color: _verdict! ? colors.success : colors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s3),
          InverseButton(
            key: const Key('review_next'),
            label: _last ? l10n.reviewFinish : l10n.reviewNext,
            onPressed: _next,
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: AppSpace.s3),
          Text(
            _error!,
            key: const Key('review_error'),
            style: AppText.caption.copyWith(color: colors.danger),
          ),
        ],
      ],
    );
  }
}
