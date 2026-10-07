import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/lesson.dart';
import '../../data/models/parent_records.dart';
import '../../data/models/student_records.dart';
import '../../data/models/teacher_records.dart';
import '../../widgets/async_value_view.dart';
import '../../widgets/message_view.dart';
import '../../widgets/ui.dart';
import '../student/status_labels.dart';
import 'assign_teacher_sheet.dart';
import 'certificate_sheet.dart';
import 'payment_sheet.dart';
import 'review_sheet.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// Student card: progress, points, lesson access, homework, payments,
/// parents, certificates; archive/return; for admins the teacher.
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({super.key, required this.studentId});

  final String studentId;

  void _refresh(WidgetRef ref) {
    ref
      ..invalidate(studentDetailProvider(studentId))
      ..invalidate(studentsProvider)
      ..invalidate(archivedStudentsProvider)
      ..invalidate(allLessonsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final student = ref.watch(studentByIdProvider(studentId));
    final rosterLoading =
        ref.watch(studentsProvider).isLoading ||
        ref.watch(archivedStudentsProvider).isLoading;
    final detail = ref.watch(studentDetailProvider(studentId));
    final lessons = ref.watch(allLessonsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: l10n.backLabel,
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.teacher),
        ),
      ),
      body: student == null
          ? (rosterLoading
                ? const SkeletonList()
                : MessageView(
                    icon: LucideIcons.userX,
                    title: l10n.unknownStudent,
                  ))
          : AsyncValueView(
              value: detail,
              onRetry: () => _refresh(ref),
              builder: (d) => RefreshIndicator(
                onRefresh: () async {
                  _refresh(ref);
                  await ref.read(studentDetailProvider(studentId).future);
                },
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.s5,
                    0,
                    AppSpace.s5,
                    AppSpace.s8,
                  ),
                  children: [
                    _HeaderCard(student: student, detail: d),
                    const SizedBox(height: AppSpace.section),
                    _AccessSection(
                      student: student,
                      detail: d,
                      lessons: lessons,
                    ),
                    const SizedBox(height: AppSpace.section),
                    _HomeworkSection(
                      student: student,
                      detail: d,
                      lessons: lessons.value ?? const [],
                    ),
                    const SizedBox(height: AppSpace.section),
                    _PaymentsSection(student: student, detail: d),
                    const SizedBox(height: AppSpace.section),
                    _ParentsSection(detail: d),
                    const SizedBox(height: AppSpace.section),
                    _CertificatesSection(student: student, detail: d),
                    const SizedBox(height: AppSpace.section),
                    _ArchiveButton(student: student),
                  ],
                ),
              ),
            ),
    );
  }
}

class _HeaderCard extends ConsumerWidget {
  const _HeaderCard({required this.student, required this.detail});

  final Person student;
  final StudentDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final d = detail;
    final isAdmin = ref.watch(isAdminProvider);
    final teacherName = isAdmin
        ? ref
              .watch(teachersProvider)
              .value
              ?.where((t) => t.id == student.teacherId)
              .firstOrNull
              ?.fullName
        : null;
    return Panel(
      radius: AppRadius.lg,
      padding: const EdgeInsets.all(AppSpace.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              PersonAvatar(person: student, large: true),
              const SizedBox(width: AppSpace.card),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: AppText.heading.copyWith(color: colors.ink),
                    ),
                    if ((student.phone ?? '').isNotEmpty)
                      Text(
                        student.phone!,
                        style: AppText.labelLg.copyWith(color: colors.inkMuted),
                      ),
                  ],
                ),
              ),
              if (student.isArchived)
                StatusChip(label: l10n.archivedBadge, color: colors.inkMuted),
            ],
          ),
          if (isAdmin) ...[
            const SizedBox(height: AppSpace.s3),
            Panel(
              key: const Key('change_teacher'),
              color: colors.surfaceMuted,
              bordered: false,
              onTap: () => showAssignTeacherSheet(context, student),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s3,
                vertical: AppSpace.s2,
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.graduationCap,
                    size: AppSize.iconMd,
                    color: colors.brandStrong,
                  ),
                  const SizedBox(width: AppSpace.s2),
                  Expanded(
                    child: Text(
                      '${l10n.teacherLabel}: '
                      '${teacherName ?? l10n.unassignedTeacher}',
                      style: AppText.label.copyWith(color: colors.ink),
                    ),
                  ),
                  Icon(
                    LucideIcons.pencil,
                    size: AppSize.iconSm,
                    color: colors.inkMuted,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpace.panel),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  l10n.studentProgressTitle,
                  style: AppText.bodyStrong.copyWith(color: colors.ink),
                ),
              ),
              Text(
                l10n.percentValue((d.completion * 100).round()),
                style: AppText.statValue.copyWith(color: colors.ink),
              ),
            ],
          ),
          const SizedBox(height: AppSpace.s2),
          ProgressBar(
            value: d.completion,
            color: colors.brand,
            height: AppSize.progressBarLg,
          ),
          const SizedBox(height: AppSpace.s2),
          Text(
            l10n.parentProgressCaption(
              d.completedOpenCount,
              d.openLessonIds.length,
            ),
            style: AppText.caption.copyWith(color: colors.inkSoft),
          ),
          const SizedBox(height: AppSpace.panel),
          Row(
            children: [
              Expanded(
                child: StatTile(
                  value: formatAmount(d.pointsTotal),
                  label: l10n.tilePoints,
                  color: colors.ink,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: StatTile(
                  value: '${d.pendingHomework}',
                  label: l10n.tilePending,
                  color: colors.brandStrong,
                ),
              ),
              const SizedBox(width: AppSpace.s2),
              Expanded(
                child: StatTile(
                  value:
                      '${d.homework.where((h) => h.status == HomeworkStatus.approved).length}',
                  label: l10n.tileApproved,
                  color: colors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Every lesson with a switch: open or closed for this student.
class _AccessSection extends ConsumerStatefulWidget {
  const _AccessSection({
    required this.student,
    required this.detail,
    required this.lessons,
  });

  final Person student;
  final StudentDetail detail;
  final AsyncValue<List<Lesson>> lessons;

  @override
  ConsumerState<_AccessSection> createState() => _AccessSectionState();
}

class _AccessSectionState extends ConsumerState<_AccessSection> {
  final _busy = <String>{};

  Future<void> _toggle(Lesson lesson, bool open) async {
    setState(() => _busy.add(lesson.id));
    await runAction(
      context,
      () => ref
          .read(teacherActionsProvider)
          .setLessonAccess(widget.student.id, lesson.id, open: open),
    );
    if (mounted) setState(() => _busy.remove(lesson.id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final ru = context.contentRu;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.lessonsAccessTitle),
        Text(
          l10n.lessonsAccessHint,
          style: AppText.caption.copyWith(color: colors.inkSoft),
        ),
        const SizedBox(height: AppSpace.s3),
        widget.lessons.when(
          loading: () => const SkeletonBox(height: AppSize.listRow * 2),
          error: (_, _) =>
              ErrorRetryView(onRetry: () => ref.invalidate(allLessonsProvider)),
          data: (lessons) {
            if (lessons.isEmpty) {
              return Text(
                l10n.noLessonsTeacher,
                style: AppText.body.copyWith(color: colors.inkMuted),
              );
            }
            return Panel(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (final module in groupLessonsByModule(lessons)) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpace.s4,
                        AppSpace.s3,
                        AppSpace.s4,
                        AppSpace.s1,
                      ),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          module.label(ru: ru).toUpperCase(),
                          style: AppText.overline.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      ),
                    ),
                    for (final lesson in module.lessons)
                      _AccessRow(
                        lesson: lesson,
                        open: widget.detail.openLessonIds.contains(lesson.id),
                        status: widget.detail.statusOf(lesson.id),
                        busy: _busy.contains(lesson.id),
                        onChanged: (v) => _toggle(lesson, v),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccessRow extends StatelessWidget {
  const _AccessRow({
    required this.lesson,
    required this.open,
    required this.status,
    required this.busy,
    required this.onChanged,
  });

  final Lesson lesson;
  final bool open;
  final ProgressStatus status;
  final bool busy;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(left: AppSpace.s4, right: AppSpace.s2),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.titleIn(ru: context.contentRu),
                  style: AppText.body.copyWith(
                    color: open ? colors.ink : colors.inkMuted,
                  ),
                ),
                if (open && status != ProgressStatus.notStarted)
                  Text(
                    status.label(l10n),
                    style: AppText.caption.copyWith(
                      color: status.color(colors),
                    ),
                  ),
              ],
            ),
          ),
          Switch(
            key: Key('access_${lesson.id}'),
            value: open,
            onChanged: busy ? null : onChanged,
          ),
        ],
      ),
    );
  }
}

class _HomeworkSection extends ConsumerWidget {
  const _HomeworkSection({
    required this.student,
    required this.detail,
    required this.lessons,
  });

  final Person student;
  final StudentDetail detail;
  final List<Lesson> lessons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    String title(String id) =>
        lessons
            .where((l) => l.id == id)
            .firstOrNull
            ?.titleIn(ru: context.contentRu) ??
        l10n.unknownLesson;
    final items = detail.homework.take(10).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.homeworkTitle),
        const SizedBox(height: AppSpace.s2),
        if (items.isEmpty)
          Text(
            l10n.noHomeworkStudent,
            style: AppText.body.copyWith(color: colors.inkMuted),
          ),
        for (final h in items) ...[
          Panel(
            key: Key('homework_${h.id}'),
            onTap: h.status == HomeworkStatus.pending
                ? () => showReviewSheet(
                    context,
                    h,
                    studentName: student.fullName,
                    lessonTitle: title(h.lessonId),
                  )
                : null,
            padding: const EdgeInsets.all(AppSpace.s3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title(h.lessonId),
                        style: AppText.bodyStrong.copyWith(color: colors.ink),
                      ),
                    ),
                    StatusChip(
                      label: h.status.label(l10n),
                      color: h.status.color(colors),
                    ),
                  ],
                ),
                if ((h.contentText ?? '').trim().isNotEmpty)
                  Text(
                    h.contentText!.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.caption.copyWith(color: colors.inkSoft),
                  ),
                if ((h.reviewerNotes ?? '').trim().isNotEmpty)
                  Text(
                    l10n.teacherNote(h.reviewerNotes!.trim()),
                    style: AppText.caption.copyWith(color: colors.inkMuted),
                  ),
                Text(
                  formatEventTime(context, h.submittedAt),
                  style: AppText.caption.copyWith(color: colors.inkMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s2),
        ],
      ],
    );
  }
}

class _PaymentsSection extends StatelessWidget {
  const _PaymentsSection({required this.student, required this.detail});

  final Person student;
  final StudentDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final current = periodOf(DateTime.now());
    final saved = {for (final p in detail.payments) p.period: p};
    final latestAmount = detail.payments.firstOrNull?.amount;
    // This month and the five before it, newest first — like the web panel,
    // a month without a row is shown unmarked until saved.
    final periods = [for (var i = 0; i < 6; i++) shiftPeriod(current, -i)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.paymentTitle),
        const SizedBox(height: AppSpace.s2),
        Panel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (final period in periods)
                () {
                  final p = saved[period];
                  final amount = p?.amount ?? latestAmount;
                  final year = int.parse(period.substring(0, 4));
                  final month = int.parse(period.substring(5, 7));
                  return ListTile(
                    key: Key('pay_$period'),
                    minTileHeight: AppSize.listRow,
                    title: Text(
                      formatPeriod(context, year, month),
                      style: AppText.bodyStrong.copyWith(color: colors.ink),
                    ),
                    subtitle: Text(
                      amount == null
                          ? l10n.amountNotSet
                          : formatMoney(context, amount),
                      style: AppText.caption.copyWith(color: colors.inkMuted),
                    ),
                    trailing: p == null
                        ? StatusChip(
                            label: l10n.paymentNotMarked,
                            color: colors.inkMuted,
                          )
                        : StatusChip(
                            label: p.status == PaymentStatus.paid
                                ? l10n.paymentPaid
                                : l10n.paymentUnpaid,
                            color: p.status == PaymentStatus.paid
                                ? colors.success
                                : colors.danger,
                          ),
                    onTap: () => showPaymentSheet(
                      context,
                      student: student,
                      period: period,
                      amount: amount,
                      status: p?.status ?? PaymentStatus.paid,
                    ),
                  );
                }(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParentsSection extends StatelessWidget {
  const _ParentsSection({required this.detail});

  final StudentDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.parentsTitle),
        const SizedBox(height: AppSpace.s2),
        if (detail.parents.isEmpty)
          Text(
            l10n.noParents,
            style: AppText.body.copyWith(color: colors.inkMuted),
          ),
        for (final p in detail.parents) ...[
          Panel(
            padding: const EdgeInsets.all(AppSpace.s3),
            child: Row(
              children: [
                const IconTile(icon: LucideIcons.userRound),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.fullName,
                        style: AppText.bodyStrong.copyWith(color: colors.ink),
                      ),
                      if ((p.phone ?? '').isNotEmpty)
                        Text(
                          p.phone!,
                          style: AppText.caption.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      if ((p.login ?? '').isNotEmpty)
                        SelectableText(
                          l10n.parentLogin(p.login!),
                          style: AppText.caption.copyWith(
                            color: colors.inkSoft,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s2),
        ],
      ],
    );
  }
}

class _CertificatesSection extends StatelessWidget {
  const _CertificatesSection({required this.student, required this.detail});

  final Person student;
  final StudentDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: l10n.certificatesSectionTitle),
        const SizedBox(height: AppSpace.s2),
        if (detail.certificates.isEmpty)
          Text(
            l10n.noCertificatesStudent,
            style: AppText.body.copyWith(color: colors.inkMuted),
          ),
        for (final c in detail.certificates) ...[
          Panel(
            padding: const EdgeInsets.all(AppSpace.s3),
            child: Row(
              children: [
                const IconTile(icon: LucideIcons.award),
                const SizedBox(width: AppSpace.s3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.courseNameIn(ru: context.contentRu),
                        style: AppText.bodyStrong.copyWith(color: colors.ink),
                      ),
                      Text(
                        '${l10n.certificateNumber(c.id)} · '
                        '${MaterialLocalizations.of(context).formatMediumDate(c.issuedAt.toLocal())}',
                        style: AppText.caption.copyWith(color: colors.inkMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.s2),
        ],
        if (!student.isArchived) ...[
          const SizedBox(height: AppSpace.s2),
          InverseButton(
            key: const Key('issue_certificate'),
            label: l10n.issueCertificateButton,
            icon: LucideIcons.award,
            onPressed: () => showCertificateSheet(context, student),
          ),
        ],
      ],
    );
  }
}

class _ArchiveButton extends ConsumerStatefulWidget {
  const _ArchiveButton({required this.student});

  final Person student;

  @override
  ConsumerState<_ArchiveButton> createState() => _ArchiveButtonState();
}

class _ArchiveButtonState extends ConsumerState<_ArchiveButton> {
  bool _busy = false;

  Future<void> _archive() async {
    final l10n = context.l10n;
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _ArchiveDialog(),
    );
    if (reason == null || !mounted) return;
    setState(() => _busy = true);
    await runAction(
      context,
      () => ref
          .read(teacherActionsProvider)
          .archive(widget.student.id, reason.isEmpty ? null : reason),
      successMessage: l10n.archivedDone,
    );
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _unarchive() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    await runAction(
      context,
      () => ref.read(teacherActionsProvider).unarchive(widget.student.id),
      successMessage: l10n.unarchivedDone,
    );
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final archived = widget.student.isArchived;
    return OutlinedButton.icon(
      key: const Key('archive_toggle'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSize.button),
        foregroundColor: archived ? null : context.colors.danger,
        side: archived ? null : BorderSide(color: context.colors.danger),
      ),
      onPressed: _busy ? null : (archived ? _unarchive : _archive),
      icon: Icon(archived ? LucideIcons.archiveRestore : LucideIcons.archive),
      label: Text(archived ? l10n.unarchiveButton : l10n.archiveButton),
    );
  }
}

class _ArchiveDialog extends StatefulWidget {
  const _ArchiveDialog();

  @override
  State<_ArchiveDialog> createState() => _ArchiveDialogState();
}

class _ArchiveDialogState extends State<_ArchiveDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return AlertDialog(
      title: Text(l10n.archiveTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.archiveBody,
            style: AppText.body.copyWith(color: colors.ink),
          ),
          const SizedBox(height: AppSpace.s4),
          TextField(
            key: const Key('archive_reason'),
            controller: _reason,
            maxLength: 500,
            decoration: InputDecoration(labelText: l10n.archiveReasonLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          key: const Key('archive_confirm'),
          onPressed: () => Navigator.of(context).pop(_reason.text.trim()),
          child: Text(l10n.archiveButton),
        ),
      ],
    );
  }
}
