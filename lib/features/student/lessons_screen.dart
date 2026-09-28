import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/lesson.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'status_labels.dart';
import 'student_providers.dart';
import 'student_shell.dart';
import 'tracks.dart';

/// Granted lessons grouped by module, one bordered list per module.
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
      body: SafeArea(
        child: AsyncValueView(
          value: ref.watch(lessonsProvider),
          onRetry: () => _refresh(ref),
          builder: (lessons) {
            if (lessons.isEmpty) {
              return MessageView(icon: LucideIcons.lock, title: l10n.noLessons);
            }
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                padding: const EdgeInsets.all(AppSpace.s5),
                children: [
                  TabTitle(l10n.navLessons),
                  for (final module in groupLessonsByModule(lessons)) ...[
                    const SizedBox(height: AppSpace.s6),
                    _ModuleHeader(module: module, progress: progress),
                    const SizedBox(height: AppSpace.s2),
                    Panel(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          for (final (i, lesson) in module.lessons.indexed) ...[
                            if (i > 0)
                              const Divider(height: 1, indent: AppSpace.s4),
                            _LessonRow(
                              lesson: lesson,
                              status:
                                  progress[lesson.id] ??
                                  ProgressStatus.notStarted,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
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
    final colors = context.colors;
    final track = Track.ofModule(module.name);
    final done = module.lessons
        .where((l) => progress[l.id] == ProgressStatus.completed)
        .length;
    return Row(
      children: [
        if (track != null) ...[
          Container(
            width: AppSize.dot,
            height: AppSize.dot,
            decoration: BoxDecoration(
              color: track.color(colors),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpace.s2),
        ],
        Expanded(
          child: Text(
            module.name,
            style: AppText.heading.copyWith(color: colors.ink),
          ),
        ),
        Text(
          '$done / ${module.lessons.length}',
          style: AppText.metric.copyWith(color: colors.inkMuted),
        ),
      ],
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson, required this.status});

  final Lesson lesson;
  final ProgressStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: () => context.go(Routes.studentLesson(lesson.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: AppSize.listRow),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.s4,
            vertical: AppSpace.s3,
          ),
          child: Row(
            children: [
              Icon(status.icon, color: status.color(colors)),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: AppText.titleSm.copyWith(
                        color: colors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      status.label(context.l10n),
                      style: AppText.caption.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, color: colors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}
