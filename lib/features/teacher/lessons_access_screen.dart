import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/lesson.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// «Darslar»: open or close each lesson for the whole group at once (one
/// student at a time is done on the student card).
class LessonsAccessScreen extends ConsumerStatefulWidget {
  const LessonsAccessScreen({super.key});

  @override
  ConsumerState<LessonsAccessScreen> createState() =>
      _LessonsAccessScreenState();
}

class _LessonsAccessScreenState extends ConsumerState<LessonsAccessScreen> {
  final _busy = <String>{};

  Future<void> _refresh() async {
    ref
      ..invalidate(allLessonsProvider)
      ..invalidate(studentsProvider)
      ..invalidate(accessCountsProvider);
    await ref.read(allLessonsProvider.future);
  }

  Future<void> _setAll(Lesson lesson, {required bool open}) async {
    final l10n = context.l10n;
    final title = lesson.titleIn(ru: context.contentRu);
    final ok = await confirmAction(
      context,
      message: open ? l10n.openAllConfirm(title) : l10n.closeAllConfirm(title),
      confirmLabel: open ? l10n.openAllButton : l10n.closeAllButton,
      destructive: !open,
    );
    if (!ok || !mounted) return;
    setState(() => _busy.add(lesson.id));
    await runAction(
      context,
      () => ref
          .read(teacherActionsProvider)
          .setGroupAccess(lesson.id, open: open),
      successMessage: l10n.savedMessage,
    );
    if (mounted) setState(() => _busy.remove(lesson.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final lessons = ref.watch(allLessonsProvider);
    final total = ref.watch(studentsProvider).value?.length ?? 0;
    final counts = ref.watch(accessCountsProvider).value ?? const {};
    final ru = context.contentRu;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherTabHeader(title: l10n.groupAccessTitle),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s5,
                0,
                AppSpace.s5,
                AppSpace.s3,
              ),
              child: Text(
                l10n.groupAccessHint,
                style: AppText.caption.copyWith(color: colors.inkSoft),
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: lessons,
                onRetry: _refresh,
                builder: (list) => list.isEmpty
                    ? MessageView(
                        icon: LucideIcons.bookOpen,
                        title: l10n.noLessonsTeacher,
                      )
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpace.s5,
                            0,
                            AppSpace.s5,
                            AppSpace.s8,
                          ),
                          children: [
                            for (final module in groupLessonsByModule(
                              list,
                            )) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpace.s4,
                                  bottom: AppSpace.s2,
                                ),
                                child: Text(
                                  module.label(ru: ru),
                                  style: AppText.heading.copyWith(
                                    color: colors.ink,
                                  ),
                                ),
                              ),
                              for (final lesson in module.lessons) ...[
                                _LessonGroupRow(
                                  lesson: lesson,
                                  open: counts[lesson.id] ?? 0,
                                  total: total,
                                  busy: _busy.contains(lesson.id),
                                  onOpenAll: () => _setAll(lesson, open: true),
                                  onCloseAll: () =>
                                      _setAll(lesson, open: false),
                                ),
                                const SizedBox(height: AppSpace.s2),
                              ],
                            ],
                          ],
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

class _LessonGroupRow extends StatelessWidget {
  const _LessonGroupRow({
    required this.lesson,
    required this.open,
    required this.total,
    required this.busy,
    required this.onOpenAll,
    required this.onCloseAll,
  });

  final Lesson lesson;
  final int open;
  final int total;
  final bool busy;
  final VoidCallback onOpenAll;
  final VoidCallback onCloseAll;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final share = total == 0 ? 0.0 : open / total;
    return Panel(
      key: Key('lesson_group_${lesson.id}'),
      padding: const EdgeInsets.all(AppSpace.s3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            lesson.titleIn(ru: context.contentRu),
            style: AppText.bodyStrong.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpace.s2),
          Row(
            children: [
              Expanded(
                child: ProgressBar(
                  value: share,
                  color: open == total && total > 0
                      ? colors.success
                      : colors.brand,
                ),
              ),
              const SizedBox(width: AppSpace.s3),
              Text(
                l10n.openCount(open, total),
                style: AppText.caption.copyWith(color: colors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s2),
          Row(
            children: [
              if (open > 0)
                Expanded(
                  child: OutlinedButton(
                    key: Key('close_all_${lesson.id}'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, AppSize.touch),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s2,
                      ),
                      textStyle: AppText.labelLg,
                    ),
                    onPressed: busy ? null : onCloseAll,
                    child: Text(l10n.closeAllButton),
                  ),
                ),
              if (open > 0 && total > 0 && open < total)
                const SizedBox(width: AppSpace.s2),
              if (total > 0 && open < total)
                Expanded(
                  child: FilledButton(
                    key: Key('open_all_${lesson.id}'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, AppSize.touch),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.s2,
                      ),
                      textStyle: AppText.labelLg,
                    ),
                    onPressed: busy ? null : onOpenAll,
                    child: Text(l10n.openAllButton),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
