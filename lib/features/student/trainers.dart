import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';

/// Trainer groups of the platform's /student/practice hub, each tied to the
/// learning direction it belongs to (for its track color).
enum PracticeGroup {
  basics,
  python,
  logic,
  ai;

  String title(AppLocalizations l10n) => switch (this) {
    PracticeGroup.basics => l10n.trackBasics,
    PracticeGroup.python => l10n.trackPython,
    PracticeGroup.logic => l10n.trackLogic,
    PracticeGroup.ai => l10n.trackAi,
  };

  Color color(AppColors colors) => switch (this) {
    PracticeGroup.basics || PracticeGroup.logic => colors.trackMoss,
    PracticeGroup.python => colors.trackGrape,
    PracticeGroup.ai => colors.trackSky,
  };
}

/// A practice trainer page on the platform: `/student/practice/<key>`.
class Trainer {
  const Trainer(this.key, this.icon, this.group);

  final String key;
  final IconData icon;
  final PracticeGroup group;

  String title(AppLocalizations l10n) => switch (key) {
    'typing' => l10n.trainerTyping,
    'mouse' => l10n.trainerMouse,
    'shortcuts' => l10n.trainerShortcuts,
    'files-folders' => l10n.trainerFilesFolders,
    'internet-safety' => l10n.trainerInternetSafety,
    'godot' => l10n.trainerGodot,
    'python' => l10n.trainerPython,
    'code-output' => l10n.trainerCodeOutput,
    'debug' => l10n.trainerDebug,
    'python-brain' => l10n.trainerPythonBrain,
    'logic' => l10n.trainerLogic,
    'critical-thinking' => l10n.trainerCriticalThinking,
    'prompting' => l10n.trainerPrompting,
    'prompt-checklist' => l10n.trainerPromptChecklist,
    'experiment-lab' => l10n.trainerExperimentLab,
    'teacher-simulator' => l10n.trainerTeacherSimulator,
    _ => key,
  };
}

/// Same trainers and order as the platform's hub.
const trainers = <Trainer>[
  Trainer('typing', LucideIcons.keyboard, PracticeGroup.basics),
  Trainer('mouse', LucideIcons.mousePointer, PracticeGroup.basics),
  Trainer('shortcuts', LucideIcons.zap, PracticeGroup.basics),
  Trainer('files-folders', LucideIcons.folder, PracticeGroup.basics),
  Trainer('internet-safety', LucideIcons.shield, PracticeGroup.basics),
  Trainer('godot', LucideIcons.gamepad2, PracticeGroup.basics),
  Trainer('python', LucideIcons.terminal, PracticeGroup.python),
  Trainer('code-output', LucideIcons.monitor, PracticeGroup.python),
  Trainer('debug', LucideIcons.bug, PracticeGroup.python),
  Trainer('python-brain', LucideIcons.code, PracticeGroup.python),
  Trainer('logic', LucideIcons.puzzle, PracticeGroup.logic),
  Trainer('critical-thinking', LucideIcons.brain, PracticeGroup.logic),
  Trainer('prompting', LucideIcons.messageSquare, PracticeGroup.ai),
  Trainer('prompt-checklist', LucideIcons.listChecks, PracticeGroup.ai),
  Trainer('experiment-lab', LucideIcons.flaskConical, PracticeGroup.ai),
  Trainer('teacher-simulator', LucideIcons.graduationCap, PracticeGroup.ai),
];

Trainer? trainerByKey(String key) {
  for (final trainer in trainers) {
    if (trainer.key == key) return trainer;
  }
  return null;
}

/// Title for a trainer key, for app bars.
String trainerTitle(BuildContext context, String key) =>
    trainerByKey(key)?.title(context.l10n) ?? key;
