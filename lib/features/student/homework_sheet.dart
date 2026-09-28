import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../data/models/lesson.dart';
import 'student_providers.dart';

/// Bottom sheet to submit homework (text or a link) for one of [lessons].
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
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
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
          .submitHomework(_lessonId!, _text.text.trim());
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.homeworkSent)));
    } catch (_) {
      if (mounted) setState(() => _error = l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.submitHomeworkButton, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _lessonId,
              isExpanded: true,
              decoration: InputDecoration(labelText: l10n.homeworkLessonLabel),
              items: [
                for (final lesson in widget.lessons)
                  DropdownMenuItem(
                    value: lesson.id,
                    child: Text(lesson.title, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (id) => setState(() => _lessonId = id),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('homework_text'),
              controller: _text,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              decoration: InputDecoration(
                labelText: l10n.homeworkTextLabel,
                hintText: l10n.homeworkTextHint,
                alignLabelWithHint: true,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? l10n.homeworkTextRequired
                  : null,
            ),
            if (_error != null) ...[
              Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            FilledButton.icon(
              key: const Key('homework_send'),
              icon: const Icon(Icons.send_rounded),
              label: Text(l10n.sendButton),
              onPressed: _busy ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
