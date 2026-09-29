import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/teacher_records.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// Admin: teachers with their students, and students without a teacher.
/// A student is moved to another teacher from their card.
class TeachersScreen extends ConsumerWidget {
  const TeachersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final teachers = ref.watch(teachersProvider);
    final students = ref.watch(studentsProvider);
    final data = switch ((teachers, students)) {
      (AsyncData(value: final t), AsyncData(value: final s)) => AsyncData((
        t,
        s,
      )),
      (AsyncError(:final error, :final stackTrace), _) ||
      (
        _,
        AsyncError(:final error, :final stackTrace),
      ) => AsyncError<(List<Person>, List<Person>)>(error, stackTrace),
      _ => const AsyncLoading<(List<Person>, List<Person>)>(),
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backLabel,
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.teacher),
        ),
        title: Text(l10n.teachersTitle),
      ),
      body: AsyncValueView(
        value: data,
        onRetry: () => ref
          ..invalidate(teachersProvider)
          ..invalidate(studentsProvider),
        builder: (d) {
          final (teacherList, studentList) = d;
          if (teacherList.isEmpty && studentList.isEmpty) {
            return MessageView(
              icon: LucideIcons.graduationCap,
              title: l10n.noTeachers,
            );
          }
          final teacherIds = {for (final t in teacherList) t.id};
          final unassigned = studentList
              .where((s) => !teacherIds.contains(s.teacherId))
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpace.s5,
              AppSpace.s2,
              AppSpace.s5,
              AppSpace.s8,
            ),
            children: [
              for (final t in teacherList) ...[
                _TeacherCard(
                  teacher: t,
                  students: studentList
                      .where((s) => s.teacherId == t.id)
                      .toList(),
                ),
                const SizedBox(height: AppSpace.s3),
              ],
              if (unassigned.isNotEmpty) ...[
                const SizedBox(height: AppSpace.s3),
                SectionHeader(title: l10n.unassignedStudentsTitle),
                const SizedBox(height: AppSpace.s2),
                for (final s in unassigned)
                  _StudentLink(student: s, color: colors.danger),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({required this.teacher, required this.students});

  final Person teacher;
  final List<Person> students;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Panel(
      key: Key('teacher_${teacher.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PersonAvatar(person: teacher),
              const SizedBox(width: AppSpace.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.fullName,
                      style: AppText.bodyStrong.copyWith(color: colors.ink),
                    ),
                    Text(
                      l10n.teacherStudentsCount(students.length),
                      style: AppText.caption.copyWith(color: colors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (students.isNotEmpty) ...[
            const SizedBox(height: AppSpace.s2),
            for (final s in students)
              _StudentLink(student: s, color: colors.inkSoft),
          ],
        ],
      ),
    );
  }
}

class _StudentLink extends StatelessWidget {
  const _StudentLink({required this.student, required this.color});

  final Person student;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: AppSize.touch,
      dense: true,
      leading: Icon(LucideIcons.user, size: AppSize.iconMd, color: color),
      title: Text(
        student.fullName,
        style: AppText.body.copyWith(color: context.colors.ink),
      ),
      trailing: Icon(
        LucideIcons.chevronRight,
        size: AppSize.iconMd,
        color: context.colors.inkMuted,
      ),
      onTap: () => context.push(Routes.teacherStudent(student.id)),
    );
  }
}
