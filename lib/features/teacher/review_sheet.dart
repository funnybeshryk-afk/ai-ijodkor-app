import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/format.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/homework_files.dart';
import '../../data/models/teacher_records.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../widgets/ui.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// Bottom sheet to approve a homework or return it with a comment.
Future<void> showReviewSheet(
  BuildContext context,
  TeacherHomework homework, {
  required String studentName,
  required String lessonTitle,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _ReviewSheet(
    homework: homework,
    studentName: studentName,
    lessonTitle: lessonTitle,
  ),
);

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({
    required this.homework,
    required this.studentName,
    required this.lessonTitle,
  });

  final TeacherHomework homework;
  final String studentName;
  final String lessonTitle;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  final _notes = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _openFile(String path) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final url = await ref.read(teacherActionsProvider).homeworkFileUrl(path);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  Future<void> _submit({required bool approved}) async {
    final l10n = context.l10n;
    if (!approved && _notes.text.trim().isEmpty) {
      setState(() => _error = l10n.returnCommentRequired);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final ok = await runAction(
      context,
      () => ref
          .read(teacherActionsProvider)
          .reviewHomework(
            widget.homework,
            approved: approved,
            notes: _notes.text,
          ),
      successMessage: approved ? l10n.homeworkApproved : l10n.homeworkRejected,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final h = widget.homework;
    final link = h.link;
    final file = HomeworkFileRef.parse(h.fileUrl);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.s5,
        0,
        AppSpace.s5,
        AppSpace.s5 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.studentName,
              style: AppText.heading.copyWith(color: colors.ink),
            ),
            Text(
              '${widget.lessonTitle} · ${formatEventTime(context, h.submittedAt)}',
              style: AppText.caption.copyWith(color: colors.inkMuted),
            ),
            const SizedBox(height: AppSpace.s4),
            Panel(
              color: colors.surfaceMuted,
              bordered: false,
              child: SelectableText(
                h.contentText?.trim().isNotEmpty == true
                    ? h.contentText!.trim()
                    : '—',
                style: AppText.body.copyWith(color: colors.ink),
              ),
            ),
            if (link != null) ...[
              const SizedBox(height: AppSpace.s2),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton.icon(
                  onPressed: () =>
                      launchUrl(link, mode: LaunchMode.externalApplication),
                  icon: const Icon(LucideIcons.externalLink),
                  label: Text(l10n.openLinkButton),
                ),
              ),
            ],
            if (file != null) ...[
              const SizedBox(height: AppSpace.s2),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: file.stored
                    ? TextButton.icon(
                        key: const Key('review_open_file'),
                        onPressed: () => _openFile(file.path!),
                        icon: const Icon(LucideIcons.paperclip),
                        label: Text('${l10n.openFileButton}: ${file.name}'),
                      )
                    : Text(
                        '${file.name} · ${l10n.fileNotSaved}',
                        style: AppText.caption.copyWith(color: colors.inkMuted),
                      ),
              ),
            ],
            const SizedBox(height: AppSpace.s4),
            TextField(
              key: const Key('review_notes'),
              controller: _notes,
              minLines: 2,
              maxLines: 5,
              maxLength: 1000,
              enabled: !_busy,
              decoration: InputDecoration(
                labelText: l10n.commentLabel,
                hintText: l10n.returnCommentHint,
                helperText: l10n.commentOptionalHint,
                errorText: _error,
              ),
            ),
            const SizedBox(height: AppSpace.s2),
            Text(
              l10n.approveHint(homeworkApprovedPoints),
              style: AppText.caption.copyWith(color: colors.inkSoft),
            ),
            const SizedBox(height: AppSpace.s4),
            PrimaryButton(
              key: const Key('review_approve'),
              label: l10n.approveButton,
              icon: LucideIcons.check,
              busy: _busy,
              onPressed: () => _submit(approved: true),
            ),
            const SizedBox(height: AppSpace.s2),
            OutlinedButton.icon(
              key: const Key('review_return'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(AppSize.button),
              ),
              onPressed: _busy ? null : () => _submit(approved: false),
              icon: const Icon(LucideIcons.undo2),
              label: Text(l10n.returnButton),
            ),
          ],
        ),
      ),
    );
  }
}
