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

/// «O'quvchilarim»: the teacher's students (admin: everyone) with a name
/// search and the archive underneath.
class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
  final _search = TextEditingController();
  bool _showArchived = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(studentsProvider)
      ..invalidate(archivedStudentsProvider)
      ..invalidate(pendingHomeworkProvider);
    await ref.read(studentsProvider.future);
  }

  bool _matches(Person p) {
    final q = _search.text.trim().toLowerCase();
    return q.isEmpty ||
        p.fullName.toLowerCase().contains(q) ||
        (p.phone ?? '').replaceAll(' ', '').contains(q.replaceAll(' ', ''));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final students = ref.watch(studentsProvider);
    final archived = ref.watch(archivedStudentsProvider).value ?? const [];
    final isAdmin = ref.watch(isAdminProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TeacherTabHeader(
              title: l10n.teacherHomeTitle,
              subtitle: students.hasValue
                  ? l10n.studentsCount(students.value!.length)
                  : null,
              actions: [
                if (isAdmin)
                  IconButton(
                    key: const Key('open_teachers'),
                    tooltip: l10n.teachersButton,
                    icon: const Icon(LucideIcons.graduationCap),
                    onPressed: () => context.push(Routes.teacherTeachers),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s5,
                AppSpace.s2,
                AppSpace.s5,
                AppSpace.s3,
              ),
              child: TextField(
                key: const Key('student_search'),
                controller: _search,
                onChanged: (_) => setState(() {}),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.searchStudentsHint,
                  prefixIcon: const Icon(LucideIcons.search),
                ),
              ),
            ),
            Expanded(
              child: AsyncValueView(
                value: students,
                onRetry: _refresh,
                builder: (list) {
                  if (list.isEmpty && archived.isEmpty) {
                    return MessageView(
                      icon: LucideIcons.users,
                      title: l10n.noStudentsTitle,
                      message: l10n.noStudentsBody,
                    );
                  }
                  final active = list.where(_matches).toList();
                  final old = archived.where(_matches).toList();
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.s5,
                        0,
                        AppSpace.s5,
                        AppSpace.s8,
                      ),
                      children: [
                        if (active.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(AppSpace.s6),
                            child: Text(
                              l10n.noSearchResults,
                              textAlign: TextAlign.center,
                              style: AppText.body.copyWith(
                                color: context.colors.inkMuted,
                              ),
                            ),
                          ),
                        for (final s in active) ...[
                          _StudentRow(student: s),
                          const SizedBox(height: AppSpace.s2),
                        ],
                        if (archived.isNotEmpty) ...[
                          const SizedBox(height: AppSpace.s3),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: TextButton.icon(
                              key: const Key('toggle_archive'),
                              onPressed: () => setState(
                                () => _showArchived = !_showArchived,
                              ),
                              icon: Icon(
                                _showArchived
                                    ? LucideIcons.chevronUp
                                    : LucideIcons.archive,
                              ),
                              label: Text(l10n.archivedToggle(archived.length)),
                            ),
                          ),
                          if (_showArchived)
                            for (final s in old) ...[
                              _StudentRow(student: s),
                              const SizedBox(height: AppSpace.s2),
                            ],
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentRow extends ConsumerWidget {
  const _StudentRow({required this.student});

  final Person student;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final pending =
        ref
            .watch(pendingHomeworkProvider)
            .value
            ?.where((h) => h.studentId == student.id)
            .length ??
        0;
    final subtitle = student.isArchived
        ? (student.archivedReason?.trim().isNotEmpty ?? false)
              ? student.archivedReason!
              : l10n.archivedBadge
        : student.phone ?? '';
    return Panel(
      key: Key('student_${student.id}'),
      onTap: () => context.push(Routes.teacherStudent(student.id)),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.s4,
        vertical: AppSpace.s3,
      ),
      child: Row(
        children: [
          PersonAvatar(person: student),
          const SizedBox(width: AppSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: AppText.bodyStrong.copyWith(
                    color: student.isArchived ? colors.inkMuted : colors.ink,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(color: colors.inkMuted),
                  ),
              ],
            ),
          ),
          if (pending > 0) ...[
            Semantics(
              label: l10n.homeworkPending,
              child: Container(
                key: Key('pending_${student.id}'),
                constraints: const BoxConstraints(
                  minWidth: AppSize.stepBadge,
                  minHeight: AppSize.stepBadge,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.s2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.brand,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  '$pending',
                  style: AppText.chip.copyWith(color: colors.onBrand),
                ),
              ),
            ),
            const SizedBox(width: AppSpace.s2),
          ],
          Icon(
            LucideIcons.chevronRight,
            size: AppSize.iconMd,
            color: colors.inkMuted,
          ),
        ],
      ),
    );
  }
}
