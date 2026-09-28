import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import 'homework_sheet.dart';
import 'status_labels.dart';
import 'student_providers.dart';
import 'student_shell.dart';

/// Homework history with statuses and teacher notes, plus a submit button.
class HomeworkScreen extends ConsumerWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final lessons = ref.watch(lessonsProvider).value ?? const [];
    final titles = {for (final l in lessons) l.id: l.title};
    final localizations = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeworkTitle),
        actions: const [ProfileAction()],
      ),
      floatingActionButton: lessons.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('homework_fab'),
              icon: const Icon(Icons.add),
              label: Text(l10n.submitHomeworkButton),
              onPressed: () => showHomeworkSheet(context, lessons: lessons),
            ),
      body: AsyncValueView(
        value: ref.watch(homeworkProvider),
        onRetry: () => ref.invalidate(homeworkProvider),
        builder: (items) {
          if (items.isEmpty) {
            return MessageView(
              icon: Icons.assignment_outlined,
              title: l10n.noHomework,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(homeworkProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final hw = items[i];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                titles[hw.lessonId] ?? '',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            StatusChip(
                              label: hw.status.label(l10n),
                              color: hw.status.color(theme.colorScheme),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          localizations.formatMediumDate(
                            hw.submittedAt.toLocal(),
                          ),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(hw.contentText ?? '—'),
                        if (hw.reviewerNotes != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.teacherNote(hw.reviewerNotes!),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
