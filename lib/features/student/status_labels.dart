import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../data/models/lesson.dart';
import '../../data/models/student_records.dart';

extension ProgressStatusUi on ProgressStatus {
  String label(AppLocalizations l10n) => switch (this) {
    ProgressStatus.notStarted => l10n.statusNotStarted,
    ProgressStatus.viewed => l10n.statusViewed,
    ProgressStatus.inProgress => l10n.statusInProgress,
    ProgressStatus.completed => l10n.statusCompleted,
  };

  IconData get icon => switch (this) {
    ProgressStatus.notStarted => Icons.radio_button_unchecked,
    ProgressStatus.viewed => Icons.visibility_outlined,
    ProgressStatus.inProgress => Icons.timelapse,
    ProgressStatus.completed => Icons.check_circle,
  };

  Color color(ColorScheme colors) => switch (this) {
    ProgressStatus.completed => Colors.green.shade600,
    ProgressStatus.inProgress => Colors.orange.shade700,
    ProgressStatus.viewed => colors.primary,
    ProgressStatus.notStarted => colors.outline,
  };
}

extension HomeworkStatusUi on HomeworkStatus {
  String label(AppLocalizations l10n) => switch (this) {
    HomeworkStatus.pending => l10n.homeworkPending,
    HomeworkStatus.approved => l10n.homeworkApproved,
    HomeworkStatus.rejected => l10n.homeworkRejected,
  };

  Color color(ColorScheme colors) => switch (this) {
    HomeworkStatus.pending => Colors.orange.shade700,
    HomeworkStatus.approved => Colors.green.shade600,
    HomeworkStatus.rejected => colors.error,
  };
}

/// Small rounded status pill.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
