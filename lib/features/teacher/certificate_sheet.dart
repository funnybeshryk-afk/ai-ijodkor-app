import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/locale_controller.dart';
import '../../core/theme.dart';
import '../../data/models/teacher_records.dart';
import '../../data/providers.dart';
import '../../widgets/ui.dart';
import 'teacher_providers.dart';
import 'teacher_widgets.dart';

/// Where the last director name is kept, so it is typed once per device.
const directorNameKey = 'teacher_director_name';

/// Bottom sheet to issue a certificate — the web «Sertifikat berish» form:
/// course, teacher and director names printed on it.
Future<void> showCertificateSheet(BuildContext context, Person student) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _CertificateSheet(student: student),
    );

class _CertificateSheet extends ConsumerStatefulWidget {
  const _CertificateSheet({required this.student});

  final Person student;

  @override
  ConsumerState<_CertificateSheet> createState() => _CertificateSheetState();
}

class _CertificateSheetState extends ConsumerState<_CertificateSheet> {
  final _form = GlobalKey<FormState>();
  late final _teacher = TextEditingController(
    text: ref.read(currentProfileProvider).value?.fullName ?? '',
  );
  late final _director = TextEditingController(
    text: ref.read(sharedPreferencesProvider).getString(directorNameKey) ?? '',
  );
  String? _courseId;
  bool _busy = false;

  @override
  void dispose() {
    _teacher.dispose();
    _director.dispose();
    super.dispose();
  }

  Future<void> _issue() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    setState(() => _busy = true);
    String? id;
    final ok = await runAction(context, () async {
      id = await ref
          .read(teacherActionsProvider)
          .issueCertificate(
            studentId: widget.student.id,
            courseId: _courseId!,
            teacherName: _teacher.text.trim(),
            directorName: _director.text.trim(),
          );
      await ref
          .read(sharedPreferencesProvider)
          .setString(directorNameKey, _director.text.trim());
    });
    if (!mounted) return;
    if (ok) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.certificateIssuedMsg(id ?? ''))),
      );
    } else {
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final courses = ref.watch(coursesProvider);
    String? required(String? v) =>
        (v == null || v.trim().isEmpty) ? l10n.fieldRequired : null;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.s5,
        0,
        AppSpace.s5,
        AppSpace.s5 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.issueCertificateButton,
                style: AppText.heading.copyWith(color: colors.ink),
              ),
              Text(
                widget.student.fullName,
                style: AppText.caption.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: AppSpace.s4),
              courses.when(
                loading: () => const SkeletonBox(height: AppSize.input),
                error: (_, _) => Text(
                  l10n.errorGeneric,
                  style: AppText.caption.copyWith(color: colors.danger),
                ),
                data: (list) => list.isEmpty
                    ? Text(
                        l10n.noCourses,
                        style: AppText.body.copyWith(color: colors.inkMuted),
                      )
                    : DropdownButtonFormField<String>(
                        key: const Key('certificate_course'),
                        initialValue: _courseId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: l10n.courseLabel,
                        ),
                        validator: required,
                        items: [
                          for (final c in list)
                            DropdownMenuItem(
                              value: c.id,
                              child: Text(
                                c.nameIn(ru: context.contentRu),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _courseId = v),
                      ),
              ),
              const SizedBox(height: AppSpace.s3),
              TextFormField(
                key: const Key('certificate_teacher'),
                controller: _teacher,
                enabled: !_busy,
                validator: required,
                decoration: InputDecoration(labelText: l10n.teacherNameLabel),
              ),
              const SizedBox(height: AppSpace.s3),
              TextFormField(
                key: const Key('certificate_director'),
                controller: _director,
                enabled: !_busy,
                validator: required,
                decoration: InputDecoration(labelText: l10n.directorNameLabel),
              ),
              const SizedBox(height: AppSpace.s5),
              PrimaryButton(
                key: const Key('certificate_issue'),
                label: l10n.issueCertificateButton,
                icon: LucideIcons.award,
                busy: _busy,
                onPressed: (courses.value?.isEmpty ?? true) ? null : _issue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
