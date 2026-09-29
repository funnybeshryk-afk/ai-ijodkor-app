import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/quiz.dart';
import '../../widgets/ui.dart';
import 'student_providers.dart';

/// The lesson's auto-graded quiz. Answers are checked on the server by the
/// `submit_lesson_quiz` RPC; the app never sees the correct answers.
class QuizSection extends ConsumerStatefulWidget {
  const QuizSection({
    super.key,
    required this.lessonId,
    required this.questions,
  });

  final String lessonId;
  final List<QuizQuestion> questions;

  @override
  ConsumerState<QuizSection> createState() => _QuizSectionState();
}

class _QuizSectionState extends ConsumerState<QuizSection> {
  final _answers = <String, String>{};
  final _controllers = <String, TextEditingController>{};
  QuizResult? _result;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(String id) =>
      _controllers.putIfAbsent(id, TextEditingController.new);

  bool get _allAnswered =>
      widget.questions.every((q) => (_answers[q.id] ?? '').trim().isNotEmpty);

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!_allAnswered) {
      setState(() => _error = l10n.quizAnswerAll);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await ref.read(studentActionsProvider).submitQuiz(
        widget.lessonId,
        {for (final q in widget.questions) q.id: _answers[q.id]!.trim()},
      );
      if (mounted) setState(() => _result = result);
    } on QuizException catch (e) {
      if (mounted) {
        setState(
          () => _error = switch (e.error) {
            QuizError.answerAll => l10n.quizAnswerAll,
            QuizError.noAccess => l10n.lessonNotFound,
            QuizError.archived => l10n.archivedBody,
            QuizError.other => l10n.errorGeneric,
          },
        );
      }
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final result = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, q) in widget.questions.indexed) ...[
          _Question(
            number: i + 1,
            question: q,
            answer: _answers[q.id],
            correct: result?.correctById[q.id],
            enabled: result == null && !_busy,
            controller: q.isMultipleChoice ? null : _controllerFor(q.id),
            onChanged: (value) => setState(() {
              _answers[q.id] = value;
              _error = null;
            }),
          ),
          const SizedBox(height: AppSpace.s5),
        ],
        if (_error != null) ...[
          Text(
            _error!,
            style: AppText.label.copyWith(color: colors.danger),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.s3),
        ],
        if (result == null)
          PrimaryButton(
            key: const Key('quiz_submit'),
            label: l10n.quizSubmitButton,
            height: AppSize.button,
            busy: _busy,
            onPressed: _submit,
          )
        else
          _ResultBanner(
            result: result,
            onRetry: () => setState(() => _result = null),
          ),
      ],
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.number,
    required this.question,
    required this.answer,
    required this.correct,
    required this.enabled,
    required this.controller,
    required this.onChanged,
  });

  final int number;
  final QuizQuestion question;
  final String? answer;
  final bool? correct;
  final bool enabled;
  final TextEditingController? controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.quizQuestionNumber(number).toUpperCase(),
                style: AppText.overline.copyWith(color: colors.inkMuted),
              ),
            ),
            if (correct != null)
              Icon(
                correct! ? LucideIcons.checkCircle : LucideIcons.xCircle,
                color: correct! ? colors.success : colors.danger,
                size: AppSize.iconLg,
              ),
          ],
        ),
        const SizedBox(height: AppSpace.s1),
        Text(
          question.questionIn(ru: context.contentRu),
          style: AppText.titleSm.copyWith(color: colors.ink),
        ),
        const SizedBox(height: AppSpace.s3),
        if (question.isMultipleChoice)
          // The Uzbek option is what gets submitted and graded; only the
          // label is translated.
          for (final (i, option) in question.options.indexed)
            _OptionTile(
              label: question.optionLabel(i, ru: context.contentRu),
              selected: answer == option,
              onTap: enabled ? () => onChanged(option) : null,
            )
        else
          TextField(
            controller: controller,
            enabled: enabled,
            maxLength: 500,
            style: AppText.input.copyWith(color: colors.ink),
            decoration: InputDecoration(
              hintText: l10n.quizAnswerHint,
              counterText: '',
              constraints: const BoxConstraints(minHeight: AppSize.input),
            ),
            onChanged: onChanged,
          ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.s2),
      child: Semantics(
        selected: selected,
        inMutuallyExclusiveGroup: true,
        child: Panel(
          color: selected ? colors.brandTint : colors.surfaceCard,
          borderColor: selected ? colors.brand : colors.border,
          borderWidth: AppSize.borderInput,
          padding: const EdgeInsets.all(AppSpace.card),
          onTap: onTap,
          child: Row(
            children: [
              Icon(
                selected ? LucideIcons.circleDot : LucideIcons.circle,
                color: selected ? colors.brandStrong : colors.inkMuted,
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Text(
                  label,
                  style: AppText.bodyLg.copyWith(color: colors.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  const _ResultBanner({required this.result, required this.onRetry});

  final QuizResult result;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final next = result.nextLessonId;
    return Panel(
      color: result.passed ? colors.brandTint : colors.surfaceMuted,
      bordered: false,
      padding: const EdgeInsets.all(AppSpace.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconTile(
                icon: result.passed
                    ? LucideIcons.partyPopper
                    : LucideIcons.rotateCcw,
                onCard: true,
              ),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quizScore(result.correctCount, result.total),
                      style: AppText.heading.copyWith(color: colors.ink),
                    ),
                    Text(
                      result.passed
                          ? l10n.quizPassed
                          : l10n.quizFailed(result.required),
                      style: AppText.caption.copyWith(color: colors.inkSoft),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s3),
          if (result.passed && next != null)
            PrimaryButton(
              label: l10n.quizNextUnlocked,
              trailingIcon: LucideIcons.arrowRight,
              height: AppSize.button,
              onPressed: () => context.go(Routes.studentLesson(next)),
            )
          else if (!result.passed)
            InverseButton(
              key: const Key('quiz_retry'),
              label: l10n.quizRetryButton,
              icon: LucideIcons.rotateCcw,
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
