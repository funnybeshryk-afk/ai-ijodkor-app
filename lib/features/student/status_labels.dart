import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
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
    ProgressStatus.notStarted => LucideIcons.circle,
    ProgressStatus.viewed => LucideIcons.eye,
    ProgressStatus.inProgress => LucideIcons.circleDashed,
    ProgressStatus.completed => LucideIcons.checkCircle,
  };

  Color color(AppColors colors) => switch (this) {
    ProgressStatus.completed => colors.success,
    ProgressStatus.inProgress => colors.brandStrong,
    ProgressStatus.viewed => colors.ink,
    ProgressStatus.notStarted => colors.inkMuted,
  };
}

extension HomeworkStatusUi on HomeworkStatus {
  String label(AppLocalizations l10n) => switch (this) {
    HomeworkStatus.pending => l10n.homeworkPending,
    HomeworkStatus.approved => l10n.homeworkApproved,
    HomeworkStatus.rejected => l10n.homeworkRejected,
  };

  Color color(AppColors colors) => switch (this) {
    HomeworkStatus.pending => colors.brandStrong,
    HomeworkStatus.approved => colors.success,
    HomeworkStatus.rejected => colors.danger,
  };
}
