import 'package:flutter/material.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/models/lesson.dart';
import '../../widgets/ui.dart';

/// The platform's three learning directions (src/lib/data/tracks.ts) — the
/// only place track colors are used.
enum Track {
  digitalStart(['Kompyuter asoslari']),
  aiCreative(['AI asoslari']),
  codeTech([
    'Scratch bilan tanishuv',
    'Python asoslari',
    'Godot bilan tanishuv',
  ]);

  const Track(this.modules);

  /// Exact `lessons.module` values of this track.
  final List<String> modules;

  static Track? ofModule(String module) {
    for (final track in values) {
      if (track.modules.contains(module)) return track;
    }
    return null;
  }

  String label(AppLocalizations l10n) => switch (this) {
    Track.digitalStart => l10n.trackDigitalStart,
    Track.aiCreative => l10n.trackAiCreative,
    Track.codeTech => l10n.trackCodeTech,
  };

  Color color(AppColors colors) => switch (this) {
    Track.digitalStart => colors.trackMoss,
    Track.aiCreative => colors.trackSky,
    Track.codeTech => colors.trackGrape,
  };
}

/// Completed / granted lessons of one track.
class TrackProgress {
  const TrackProgress(this.track, this.done, this.granted);

  final Track track;
  final int done;
  final int granted;
}

List<TrackProgress> trackProgress(
  List<Lesson> lessons,
  Map<String, ProgressStatus> progress,
) => [
  for (final track in Track.values)
    TrackProgress(
      track,
      lessons
          .where(
            (l) =>
                Track.ofModule(l.module) == track &&
                progress[l.id] == ProgressStatus.completed,
          )
          .length,
      lessons.where((l) => Track.ofModule(l.module) == track).length,
    ),
];

/// Pill naming a lesson's track (brand book: TrackBadge).
class TrackBadge extends StatelessWidget {
  const TrackBadge({super.key, required this.track});

  final Track track;

  @override
  Widget build(BuildContext context) => StatusChip(
    label: track.label(context.l10n),
    color: track.color(context.colors),
  );
}
