import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/teacher_records.dart';

/// Round initials avatar (students and teachers in lists).
class PersonAvatar extends StatelessWidget {
  const PersonAvatar({super.key, required this.person, this.large = false});

  final Person person;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final size = large ? AppSize.avatarLg : AppSize.avatar;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: person.isArchived ? colors.surfaceMuted : colors.brandTint,
        shape: BoxShape.circle,
        border: large
            ? Border.all(color: colors.brand, width: AppSize.avatarBorder)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        person.initials,
        style: (large ? AppText.displaySm : AppText.bodyStrong).copyWith(
          color: person.isArchived ? colors.inkMuted : colors.brandDeep,
        ),
      ),
    );
  }
}

/// Small number-over-label tile on a muted fill.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.tileGap,
        vertical: AppSpace.s3,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.tile),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: AppText.heading.copyWith(color: color),
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.chip.copyWith(
              color: colors.inkSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header row of a teacher tab: big title and optional trailing actions.
class TeacherTabHeader extends StatelessWidget {
  const TeacherTabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.s5,
        AppSpace.s5,
        AppSpace.s3,
        AppSpace.s2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppText.displayMd.copyWith(color: colors.ink),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppText.labelLg.copyWith(color: colors.inkMuted),
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Yes/no dialog; resolves to true on confirm.
Future<bool> confirmAction(
  BuildContext context, {
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final l10n = context.l10n;
  final colors = context.colors;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      content: Text(message, style: AppText.body.copyWith(color: colors.ink)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        FilledButton(
          style: destructive
              ? FilledButton.styleFrom(
                  backgroundColor: colors.inverse,
                  foregroundColor: colors.onInverse,
                )
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}

/// Runs a write and reports failure with the generic error message.
/// Returns true on success.
Future<bool> runAction(
  BuildContext context,
  Future<void> Function() action, {
  String? successMessage,
}) async {
  final l10n = context.l10n;
  try {
    await action();
    if (context.mounted && successMessage != null) {
      showMessage(context, successMessage);
    }
    return true;
  } catch (_) {
    if (context.mounted) showMessage(context, l10n.errorGeneric);
    return false;
  }
}
