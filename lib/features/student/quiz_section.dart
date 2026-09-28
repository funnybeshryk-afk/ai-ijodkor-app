import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../data/models/quiz.dart';
import 'student_providers.dart';

/// The lesson's auto-graded quiz. Answers are checked on the server by the
/// `submit_lesson_quiz` RPC; the app never sees the correct answers.
class QuizSection extends ConsumerStatefulWidget {
  const QuizSection({
    super.key,
    required this.lessonId,
    required this.questions,
    required this.alreadyCompleted,
  });

  final String lessonId;
  final List<QuizQuestion> questions;
  final bool alreadyCompleted;

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
    final theme = Theme.of(context);
    final result = _result;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.alreadyCompleted ? l10n.quizAlreadyCompleted : l10n.quizHint,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        for (final (i, q) in widget.questions.indexed) ...[
          _QuestionCard(
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
          const SizedBox(height: 8),
        ],
        if (_error != null) ...[
          Text(
            _error!,
            style: TextStyle(color: theme.colorScheme.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
        ],
        if (result == null)
          FilledButton(
            key: const Key('quiz_submit'),
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox.square(
                    dimension: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : Text(l10n.quizSubmitButton),
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

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
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
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.quizQuestionNumber(number),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                if (correct != null)
                  Icon(
                    correct! ? Icons.check_circle : Icons.cancel,
                    color: correct!
                        ? Colors.green.shade600
                        : theme.colorScheme.error,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(question.question, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            if (question.isMultipleChoice)
              for (final option in question.options)
                _OptionTile(
                  label: option,
                  selected: answer == option,
                  onTap: enabled ? () => onChanged(option) : null,
                )
            else
              TextField(
                controller: controller,
                enabled: enabled,
                maxLength: 500,
                decoration: InputDecoration(hintText: l10n.quizAnswerHint),
                onChanged: onChanged,
              ),
          ],
        ),
      ),
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
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? colors.primaryContainer : colors.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? colors.primary : colors.outline,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 17)),
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    final color = result.passed
        ? Colors.green.shade600
        : Colors.orange.shade800;
    final next = result.nextLessonId;
    return Card(
      color: color.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              result.passed ? Icons.celebration : Icons.refresh_rounded,
              color: color,
              size: 48,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.quizScore(result.correctCount, result.total),
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              result.passed
                  ? l10n.quizPassed
                  : l10n.quizFailed(result.required),
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            if (result.passed && next != null)
              FilledButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.quizNextUnlocked),
                onPressed: () => context.go(Routes.studentLesson(next)),
              )
            else if (!result.passed)
              FilledButton(
                key: const Key('quiz_retry'),
                onPressed: onRetry,
                child: Text(l10n.quizRetryButton),
              ),
          ],
        ),
      ),
    );
  }
}
