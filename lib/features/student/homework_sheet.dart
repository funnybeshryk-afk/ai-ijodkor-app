import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show StorageException;

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/homework_files.dart';
import '../../data/models/lesson.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/ui.dart';
import 'homework_file_picker.dart';
import 'student_providers.dart';

/// Bottom sheet to submit homework (text or a link, plus an optional file)
/// for one of [lessons].
Future<void> showHomeworkSheet(
  BuildContext context, {
  required List<Lesson> lessons,
  String? lessonId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _HomeworkSheet(lessons: lessons, initialLessonId: lessonId),
  );
}

class _HomeworkSheet extends ConsumerStatefulWidget {
  const _HomeworkSheet({required this.lessons, this.initialLessonId});

  final List<Lesson> lessons;
  final String? initialLessonId;

  @override
  ConsumerState<_HomeworkSheet> createState() => _HomeworkSheetState();
}

class _HomeworkSheetState extends ConsumerState<_HomeworkSheet> {
  final _formKey = GlobalKey<FormState>();
  final _text = TextEditingController();
  late String? _lessonId =
      widget.initialLessonId ??
      (widget.lessons.isEmpty ? null : widget.lessons.first.id);
  HomeworkAttachment? _file;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  String _problemText(HomeworkFileProblem problem) {
    final l10n = context.l10n;
    return switch (problem) {
      HomeworkFileProblem.type => l10n.fileTypeNotAllowed,
      HomeworkFileProblem.empty => l10n.fileEmpty,
      HomeworkFileProblem.tooLarge => l10n.fileTooLarge,
    };
  }

  Future<void> _pickFile() async {
    final picked = await ref.read(homeworkFilePickerProvider)();
    if (!mounted || picked == null) return;
    setState(() {
      _file = picked.file;
      _error = picked.problem == null ? null : _problemText(picked.problem!);
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (!_formKey.currentState!.validate() || _lessonId == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(studentActionsProvider)
          .submitHomework(_lessonId!, _text.text.trim(), attachment: _file);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.homeworkSent)));
    } on StorageException {
      if (mounted) setState(() => _error = l10n.fileUploadFailed);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.s5,
        0,
        AppSpace.s5,
        AppSpace.s5 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.submitHomeworkButton,
              style: AppText.displaySm.copyWith(color: colors.ink),
            ),
            const SizedBox(height: AppSpace.s4),
            if (widget.lessons.length > 1) ...[
              Text(
                l10n.homeworkLessonLabel,
                style: AppText.label.copyWith(color: colors.ink),
              ),
              const SizedBox(height: AppSpace.labelGap),
              DropdownButtonFormField<String>(
                initialValue: _lessonId,
                isExpanded: true,
                icon: const Icon(LucideIcons.chevronDown),
                style: AppText.input.copyWith(color: colors.ink),
                borderRadius: BorderRadius.circular(AppRadius.md),
                items: [
                  for (final lesson in widget.lessons)
                    DropdownMenuItem(
                      value: lesson.id,
                      child: Text(
                        lesson.titleIn(ru: context.contentRu),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) => setState(() => _lessonId = id),
              ),
              const SizedBox(height: AppSpace.s4),
            ],
            AppTextField(
              fieldKey: const Key('homework_text'),
              label: l10n.homeworkTextLabel,
              hint: l10n.homeworkTextHint,
              controller: _text,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.homeworkTextRequired
                  : null,
            ),
            if (_file == null) ...[
              OutlinedButton.icon(
                key: const Key('homework_attach'),
                onPressed: _busy ? null : _pickFile,
                icon: const Icon(LucideIcons.paperclip),
                label: Text(l10n.attachFileButton),
              ),
              const SizedBox(height: AppSpace.s1),
              Text(
                l10n.attachFileHint,
                style: AppText.caption.copyWith(color: colors.inkMuted),
              ),
            ] else
              Panel(
                key: const Key('homework_file'),
                color: colors.surfaceMuted,
                bordered: false,
                padding: const EdgeInsetsDirectional.only(
                  start: AppSpace.s4,
                  end: AppSpace.s1,
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.paperclip, color: colors.inkMuted),
                    const SizedBox(width: AppSpace.s2),
                    Expanded(
                      child: Text(
                        _file!.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body.copyWith(color: colors.ink),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.removeFileButton,
                      onPressed: _busy
                          ? null
                          : () => setState(() => _file = null),
                      icon: const Icon(LucideIcons.x),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpace.s4),
            if (_error != null) ...[
              Text(
                _error!,
                style: AppText.label.copyWith(color: colors.danger),
              ),
              const SizedBox(height: AppSpace.s2),
            ],
            const SizedBox(height: AppSpace.s2),
            PrimaryButton(
              key: const Key('homework_send'),
              label: l10n.sendButton,
              icon: LucideIcons.send,
              busy: _busy,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
