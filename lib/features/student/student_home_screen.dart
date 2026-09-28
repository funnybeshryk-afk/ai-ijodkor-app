import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../data/models/lesson.dart';
import '../../data/models/student_records.dart';
import '../../data/providers.dart';
import '../../widgets/async_value_view.dart';
import 'student_providers.dart';
import 'student_shell.dart';

/// Overview: points, progress, homework on review, next lesson.
class StudentHomeScreen extends ConsumerWidget {
  const StudentHomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(lessonsProvider)
      ..invalidate(progressProvider)
      ..invalidate(pointsProvider)
      ..invalidate(homeworkProvider);
    await ref.read(lessonsProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final name = ref.watch(currentProfileProvider).value?.givenName ?? '';
    final lessons = ref.watch(lessonsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navHome),
        actions: const [ProfileAction()],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.greeting(name),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(l10n.homeSubtitle, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            _StatsRow(),
            const SizedBox(height: 16),
            AsyncValueView(
              value: lessons,
              onRetry: () => _refresh(ref),
              builder: (list) => _NextLessonCard(
                next: nextLessonToStudy(list, progress.value ?? const {}),
                hasLessons: list.isNotEmpty,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                leading: const Icon(Icons.workspace_premium, size: 36),
                title: Text(l10n.certificatesTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Routes.studentCertificates),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final points = ref.watch(pointsProvider).value;
    final lessons = ref.watch(lessonsProvider).value;
    final progress = ref.watch(progressProvider).value;
    final homework = ref.watch(homeworkProvider).value;

    final completed = lessons == null || progress == null
        ? null
        : lessons
              .where((l) => progress[l.id] == ProgressStatus.completed)
              .length;
    final pending = homework
        ?.where((h) => h.status == HomeworkStatus.pending)
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            color: Colors.amber.shade700,
            label: l10n.statPoints,
            value: points?.toString(),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.check_circle,
            color: Colors.green.shade600,
            label: l10n.statCompleted,
            value: completed == null ? null : '$completed/${lessons!.length}',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            icon: Icons.hourglass_top_rounded,
            color: Colors.orange.shade700,
            label: l10n.statPendingHomework,
            value: pending?.toString(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            Text(
              value ?? '…',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({required this.next, required this.hasLessons});

  final Lesson? next;
  final bool hasLessons;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lesson = next;
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.nextLessonTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            if (lesson == null)
              Text(
                hasLessons ? l10n.allLessonsDone : l10n.noLessons,
                style: theme.textTheme.bodyLarge,
              )
            else ...[
              Text(lesson.module, style: theme.textTheme.bodyMedium),
              Text(lesson.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.continueButton),
                onPressed: () => context.go(Routes.studentLesson(lesson.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
