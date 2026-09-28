import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'review_sheet.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// «Tekshirish»: homework waiting for review, oldest first.
class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref
      ..invalidate(pendingHomeworkProvider)
      ..invalidate(allLessonsProvider);
    await ref.read(pendingHomeworkProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final queue = ref.watch(pendingHomeworkProvider);
    final lessons = ref.watch(allLessonsProvider).value ?? const [];
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherTabHeader(
              title: l10n.reviewTitle,
              subtitle: (queue.value?.isNotEmpty ?? false)
                  ? l10n.reviewCount(queue.value!.length)
                  : null,
            ),
            Expanded(
              child: AsyncValueView(
                value: queue,
                onRetry: () => _refresh(ref),
                builder: (list) => list.isEmpty
                    ? MessageView(
                        icon: LucideIcons.checkCheck,
                        title: l10n.reviewEmptyTitle,
                        message: l10n.reviewEmptyBody,
                      )
                    : RefreshIndicator(
                        onRefresh: () => _refresh(ref),
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.s5,
                            AppSpace.s2,
                            AppSpace.s5,
                            AppSpace.s8,
                          ),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpace.s3),
                          itemBuilder: (context, i) {
                            final h = list[i];
                            final student = ref.watch(
                              studentByIdProvider(h.studentId),
                            );
                            final studentName =
                                student?.fullName ?? l10n.unknownStudent;
                            final lessonTitle =
                                lessons
                                    .where((l) => l.id == h.lessonId)
                                    .firstOrNull
                                    ?.titleIn(ru: context.contentRu) ??
                                l10n.unknownLesson;
                            void open() => showReviewSheet(
                              context,
                              h,
                              studentName: studentName,
                              lessonTitle: lessonTitle,
                            );
                            return Panel(
                              key: Key('review_${h.id}'),
                              onTap: open,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      if (student != null) ...[
                                        PersonAvatar(person: student),
                                        const SizedBox(width: AppSpace.s3),
                                      ],
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              studentName,
                                              style: AppText.bodyStrong
                                                  .copyWith(color: colors.ink),
                                            ),
                                            Text(
                                              lessonTitle,
                                              style: AppText.caption.copyWith(
                                                color: colors.inkMuted,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        formatEventTime(context, h.submittedAt),
                                        style: AppText.caption.copyWith(
                                          color: colors.inkMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpace.s3),
                                  Text(
                                    (h.contentText ?? '').trim().isEmpty
                                        ? '—'
                                        : h.contentText!.trim(),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.body.copyWith(
                                      color: colors.inkSoft,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpace.s3),
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: FilledButton.icon(
                                      key: Key('review_open_${h.id}'),
                                      onPressed: open,
                                      icon: const Icon(
                                        LucideIcons.clipboardCheck,
                                      ),
                                      label: Text(l10n.navReview),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
