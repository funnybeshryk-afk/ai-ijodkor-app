import 'package:flutter/widgets.dart';

import '../../core/l10n.dart';

/// A practice trainer page on the platform: `/student/practice/<key>`.
class Trainer {
  const Trainer(this.key, this.emoji);

  final String key;
  final String emoji;

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

class TrainerTrack {
  const TrainerTrack(this.title, this.trainers);

  final String Function(AppLocalizations) title;
  final List<Trainer> trainers;
}

/// Same tracks and order as the platform's /student/practice hub.
final trainerTracks = <TrainerTrack>[
  TrainerTrack((l) => l.trackBasics, const [
    Trainer('typing', '⌨️'),
    Trainer('mouse', '🖱️'),
    Trainer('shortcuts', '⚡'),
    Trainer('files-folders', '🗂️'),
    Trainer('internet-safety', '🛡️'),
    Trainer('godot', '🎮'),
  ]),
  TrainerTrack((l) => l.trackPython, const [
    Trainer('python', '🐍'),
    Trainer('code-output', '🖥️'),
    Trainer('debug', '🐛'),
    Trainer('python-brain', '🧠'),
  ]),
  TrainerTrack((l) => l.trackLogic, const [
    Trainer('logic', '🧩'),
    Trainer('critical-thinking', '🧠'),
  ]),
  TrainerTrack((l) => l.trackAi, const [
    Trainer('prompting', '💬'),
    Trainer('prompt-checklist', '🔍'),
    Trainer('experiment-lab', '🧪'),
    Trainer('teacher-simulator', '🧒'),
  ]),
];

Trainer? trainerByKey(String key) {
  for (final track in trainerTracks) {
    for (final trainer in track.trainers) {
      if (trainer.key == key) return trainer;
    }
  }
  return null;
}

/// Title for a trainer key, for app bars.
String trainerTitle(BuildContext context, String key) =>
    trainerByKey(key)?.title(context.l10n) ?? key;
