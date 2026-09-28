import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../data/models/lesson.dart';
import '../../data/models/quiz.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import 'homework_sheet.dart';
import 'quiz_section.dart';
import 'status_labels.dart';
import 'student_providers.dart';

/// One lesson: material, quiz, self-completion and its homework.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessons = ref.watch(lessonsProvider);
    final lesson = lessons.value?.where((l) => l.id == lessonId).firstOrNull;
    return Scaffold(
      appBar: AppBar(title: Text(lesson?.title ?? '')),
      body: AsyncValueView(
        value: lessons,
        onRetry: () => ref.invalidate(lessonsProvider),
        builder: (_) => lesson == null
            ? MessageView(
                icon: Icons.lock_outline,
                title: context.l10n.lessonNotFound,
              )
            : _LessonBody(lesson: lesson),
      ),
    );
  }
}

class _LessonBody extends ConsumerWidget {
  const _LessonBody({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final status =
        ref.watch(progressProvider).value?[lesson.id] ??
        ProgressStatus.notStarted;
    final quiz = ref.watch(quizProvider(lesson.id));
    final homework = (ref.watch(homeworkProvider).value ?? const [])
        .where((h) => h.lessonId == lesson.id)
        .toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(progressProvider)
          ..invalidate(quizProvider(lesson.id))
          ..invalidate(homeworkProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(lesson.module, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(lesson.title, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: StatusChip(
              label: status.label(l10n),
              color: status.color(theme.colorScheme),
            ),
          ),
          if ((lesson.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(lesson.description!, style: theme.textTheme.bodyLarge),
          ],
          const SizedBox(height: 20),
          _Section(
            title: l10n.lessonMaterialTitle,
            child: lesson.contentUrl == null || lesson.contentUrl!.isEmpty
                ? Text(l10n.noMaterial)
                : FilledButton.icon(
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.openMaterialButton),
                    onPressed: () {
                      ref.read(studentActionsProvider).markViewed(lesson.id);
                      context.push(Routes.lessonMaterial(lesson.id));
                    },
                  ),
          ),
          quiz.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => _Section(
              title: l10n.quizTitle,
              child: OutlinedButton(
                onPressed: () => ref.invalidate(quizProvider(lesson.id)),
                child: Text(l10n.retryButton),
              ),
            ),
            data: (questions) => _QuizOrCompletion(
              lesson: lesson,
              questions: questions,
              status: status,
            ),
          ),
          _Section(
            title: l10n.homeworkForLessonTitle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final hw in homework)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      hw.contentText ?? '—',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: hw.reviewerNotes == null
                        ? null
                        : Text(l10n.teacherNote(hw.reviewerNotes!)),
                    trailing: StatusChip(
                      label: hw.status.label(l10n),
                      color: hw.status.color(theme.colorScheme),
                    ),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_rounded),
                  label: Text(l10n.submitHomeworkButton),
                  onPressed: () => showHomeworkSheet(
                    context,
                    lessons: [lesson],
                    lessonId: lesson.id,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizOrCompletion extends ConsumerWidget {
  const _QuizOrCompletion({
    required this.lesson,
    required this.questions,
    required this.status,
  });

  final Lesson lesson;
  final List<QuizQuestion> questions;
  final ProgressStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final completed = status == ProgressStatus.completed;
    if (questions.isNotEmpty) {
      return _Section(
        title: l10n.quizTitle,
        child: QuizSection(
          lessonId: lesson.id,
          questions: questions,
          alreadyCompleted: completed,
        ),
      );
    }
    // No quiz: the student may mark the lesson done themselves, same as
    // on the web. With a quiz, only passing it completes the lesson.
    if (completed) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: FilledButton.icon(
        key: const Key('mark_completed'),
        icon: const Icon(Icons.check_rounded),
        label: Text(l10n.markCompletedButton),
        onPressed: () =>
            ref.read(studentActionsProvider).markCompleted(lesson.id),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
