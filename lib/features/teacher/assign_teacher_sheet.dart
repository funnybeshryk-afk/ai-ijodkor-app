import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/teacher_records.dart';
import '../../widgets/async_value_view.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// Admin: pick the teacher a student belongs to (or none).
Future<void> showAssignTeacherSheet(BuildContext context, Person student) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _AssignTeacherSheet(student: student),
    );

class _AssignTeacherSheet extends ConsumerWidget {
  const _AssignTeacherSheet({required this.student});

  final Person student;

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref,
    String? teacherId,
  ) async {
    final l10n = context.l10n;
    final navigator = Navigator.of(context);
    final ok = await runAction(
      context,
      () =>
          ref.read(teacherActionsProvider).assignTeacher(student.id, teacherId),
      successMessage: l10n.teacherChanged,
    );
    if (ok) navigator.pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final teachers = ref.watch(teachersProvider);
    Widget option(String? id, String name) {
      final selected = student.teacherId == id;
      return ListTile(
        key: Key('assign_${id ?? 'none'}'),
        minTileHeight: AppSize.touch,
        leading: Icon(
          selected ? LucideIcons.circleCheck : LucideIcons.circle,
          color: selected ? colors.brandStrong : colors.inkMuted,
        ),
        title: Text(name, style: AppText.body.copyWith(color: colors.ink)),
        onTap: selected ? null : () => _assign(context, ref, id),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.s5),
            child: Text(
              l10n.changeTeacherTitle,
              style: AppText.heading.copyWith(color: colors.ink),
            ),
          ),
          const SizedBox(height: AppSpace.s2),
          Flexible(
            child: AsyncValueView(
              value: teachers,
              onRetry: () => ref.invalidate(teachersProvider),
              builder: (list) => ListView(
                shrinkWrap: true,
                children: [
                  for (final t in list) option(t.id, t.fullName),
                  option(null, l10n.noTeacherOption),
                  const SizedBox(height: AppSpace.s4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
