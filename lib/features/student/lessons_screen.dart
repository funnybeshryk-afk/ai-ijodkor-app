import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../data/models/lesson.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import 'status_labels.dart';
import 'student_providers.dart';
import 'student_shell.dart';

/// Granted lessons grouped by module, with a progress status per lesson.
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(lessonsProvider)
      ..invalidate(progressProvider);
    await ref.read(lessonsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progress = ref.watch(progressProvider).value ?? const {};
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navLessons),
        actions: const [ProfileAction()],
      ),
      body: AsyncValueView(
        value: ref.watch(lessonsProvider),
        onRetry: () => _refresh(ref),
        builder: (lessons) {
          if (lessons.isEmpty) {
            return MessageView(
              icon: Icons.lock_clock_outlined,
              title: l10n.noLessons,
            );
          }
          final modules = groupLessonsByModule(lessons);
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final module in modules) ...[
                  _ModuleHeader(module: module, progress: progress),
                  for (final lesson in module.lessons)
                    _LessonTile(
                      lesson: lesson,
                      status: progress[lesson.id] ?? ProgressStatus.notStarted,
                    ),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ModuleHeader extends StatelessWidget {
  const _ModuleHeader({required this.module, required this.progress});

  final LessonModule module;
  final Map<String, ProgressStatus> progress;

  @override
  Widget build(BuildContext context) {
    final done = module.lessons
        .where((l) => progress[l.id] == ProgressStatus.completed)
        .length;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          Expanded(child: Text(module.name, style: theme.textTheme.titleLarge)),
          Text(
            '$done/${module.lessons.length}',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.status});

  final Lesson lesson;
  final ProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(status.icon, color: status.color(colors), size: 32),
        title: Text(
          lesson.title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(status.label(context.l10n)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go(Routes.studentLesson(lesson.id)),
      ),
    );
  }
}
