import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'homework_sheet.dart';
import 'status_labels.dart';
import 'student_providers.dart';

/// Homework history with statuses and teacher notes, plus a submit button.
class HomeworkScreen extends ConsumerWidget {
  const HomeworkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final lessons = ref.watch(lessonsProvider).value ?? const [];
    final ru = context.contentRu;
    final titles = {for (final l in lessons) l.id: l.titleIn(ru: ru)};
    final dates = MaterialLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backLabel,
          icon: const Icon(LucideIcons.chevronLeft, size: AppSize.iconLg),
          onPressed: () => context.pop(),
        ),
        title: Text(l10n.homeworkTitle),
      ),
      floatingActionButton: lessons.isEmpty
          ? null
          : FloatingActionButton.extended(
              key: const Key('homework_fab'),
              icon: const Icon(LucideIcons.plus),
              label: Text(l10n.submitHomeworkButton),
              onPressed: () => showHomeworkSheet(context, lessons: lessons),
            ),
      body: AsyncValueView(
        value: ref.watch(homeworkProvider),
        onRetry: () => ref.invalidate(homeworkProvider),
        builder: (items) {
          if (items.isEmpty) {
            return MessageView(
              icon: LucideIcons.clipboardList,
              title: l10n.noHomework,
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(homeworkProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s5,
                AppSpace.s2,
                AppSpace.s5,
                96,
              ),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpace.s3),
              itemBuilder: (context, i) {
                final hw = items[i];
                return Panel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              titles[hw.lessonId] ?? '',
                              style: AppText.bodyStrong.copyWith(
                                color: colors.ink,
                              ),
                            ),
                          ),
                          StatusChip(
                            label: hw.status.label(l10n),
                            color: hw.status.color(colors),
                          ),
                        ],
                      ),
                      Text(
                        dates.formatMediumDate(hw.submittedAt.toLocal()),
                        style: AppText.caption.copyWith(color: colors.inkMuted),
                      ),
                      const SizedBox(height: AppSpace.s2),
                      Text(
                        hw.contentText ?? '—',
                        style: AppText.body.copyWith(color: colors.ink),
                      ),
                      if (hw.reviewerNotes != null) ...[
                        const SizedBox(height: AppSpace.s2),
                        NotePanel(
                          icon: LucideIcons.messageSquare,
                          text: l10n.teacherNote(hw.reviewerNotes!),
                        ),
                      ],
                    ],
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
