import 'lesson.dart';

/// Objective mastery of a student (platform migration 0029) and the
/// «Ko'nikmalar» overview built from it. The rules mirror the platform's
/// src/lib/skills.ts and src/lib/mastery.ts — the level itself is computed
/// by the database (check_task_answer); the app only reads and groups it.

/// Below this level an objective is offered for repeating.
const reviewBelow = 60;

/// A learning objective (AI4K12 / CSTA) as listed in `learning_objectives`.
class Objective {
  const Objective({
    required this.id,
    required this.code,
    required this.titleUz,
    this.titleRu,
  });

  final String id;
  final String code;
  final String titleUz;
  final String? titleRu;

  String titleIn({required bool ru}) => pickContent(titleUz, titleRu, ru: ru);
}

/// A row of `lesson_objectives` (link status draft until a teacher approves).
class ObjectiveLink {
  const ObjectiveLink({
    required this.lessonId,
    required this.objectiveId,
    required this.approved,
  });

  final String lessonId;
  final String objectiveId;
  final bool approved;
}

/// A row of `objective_mastery`.
class Mastery {
  const Mastery({
    required this.objectiveId,
    required this.level,
    required this.attempts,
    required this.solved,
  });

  final String objectiveId;

  /// 0–100.
  final int level;
  final int attempts;

  /// Tasks solved at least once.
  final int solved;

  factory Mastery.fromJson(Map<String, dynamic> json) => Mastery(
    objectiveId: json['objective_id'] as String,
    level: (json['level'] as num).toInt().clamp(0, 100),
    attempts: (json['attempts_count'] as num).toInt(),
    solved: (json['solved_count'] as num).toInt(),
  );
}

/// «new» until the first attempt, then the level band.
enum SkillState {
  fresh,
  start,
  growing,
  strong;

  static SkillState of(int level, int attempts) {
    if (attempts <= 0) return fresh;
    if (level >= 75) return strong;
    if (level >= reviewBelow - 20) return growing;
    return start;
  }
}

class SkillItem {
  const SkillItem({
    required this.objective,
    required this.level,
    required this.attempts,
    required this.solved,
  });

  final Objective objective;
  final int level;
  final int attempts;
  final int solved;

  SkillState get state => SkillState.of(level, attempts);

  /// Practised, but not yet solid.
  bool get needsReview => attempts > 0 && level < reviewBelow;
}

/// What «Ko'nikmalar» is built from (see [buildSkills]).
class SkillSources {
  const SkillSources({
    required this.lessons,
    required this.links,
    required this.objectives,
    required this.mastery,
  });

  static const empty = SkillSources(
    lessons: [],
    links: [],
    objectives: [],
    mastery: [],
  );

  final List<Lesson> lessons;
  final List<ObjectiveLink> links;
  final List<Objective> objectives;
  final List<Mastery> mastery;
}

/// The objectives of one direction. [track] is null for objectives whose
/// lessons belong to no direction.
class SkillGroup {
  const SkillGroup(this.track, this.items);

  final String? track;
  final List<SkillItem> items;
}

class SkillsOverview {
  const SkillsOverview({
    required this.groups,
    required this.review,
    required this.practised,
    required this.solved,
  });

  static const empty = SkillsOverview(
    groups: [],
    review: [],
    practised: 0,
    solved: 0,
  );

  final List<SkillGroup> groups;

  /// Practised objectives to repeat, weakest first (at most 5).
  final List<SkillItem> review;
  final int practised;
  final int solved;

  bool get isEmpty => groups.isEmpty;
}

/// Which objectives are shown: those the student has practised (they come
/// from tasks a teacher activated), and those linked with status `approved`
/// to a lesson the student has — as «not started». A draft link alone never
/// puts an objective on the page. An objective sits under the first direction
/// (curriculum order, [trackOrder]) of its lessons; [trackOf] maps a module to
/// a direction key or null.
SkillsOverview buildSkills({
  required List<Lesson> lessons,
  required List<ObjectiveLink> links,
  required List<Objective> objectives,
  required List<Mastery> mastery,
  required List<String> trackOrder,
  required String? Function(String module) trackOf,
}) {
  final masteryBy = {for (final m in mastery) m.objectiveId: m};
  final objectiveBy = {for (final o in objectives) o.id: o};
  final moduleOf = {for (final l in lessons) l.id: l.module};

  final trackOfObjective = <String, String>{};
  for (final link in links) {
    final module = moduleOf[link.lessonId];
    final key = module == null ? null : trackOf(module);
    if (key == null) continue;
    final current = trackOfObjective[link.objectiveId];
    if (current == null ||
        trackOrder.indexOf(key) < trackOrder.indexOf(current)) {
      trackOfObjective[link.objectiveId] = key;
    }
  }

  final visible = {
    ...mastery.map((m) => m.objectiveId),
    ...links.where((l) => l.approved).map((l) => l.objectiveId),
  };

  final byTrack = <String?, List<SkillItem>>{};
  for (final id in visible) {
    final objective = objectiveBy[id];
    if (objective == null) continue;
    final m = masteryBy[id];
    byTrack
        .putIfAbsent(trackOfObjective[id], () => [])
        .add(
          SkillItem(
            objective: objective,
            level: m?.level ?? 0,
            attempts: m?.attempts ?? 0,
            solved: m?.solved ?? 0,
          ),
        );
  }

  final groups = [
    for (final key in [...trackOrder, null])
      if (byTrack[key] case final items?)
        SkillGroup(
          key,
          items..sort((a, b) => a.objective.code.compareTo(b.objective.code)),
        ),
  ];
  final all = [for (final g in groups) ...g.items];
  final review = all.where((i) => i.needsReview).toList()
    ..sort((a, b) {
      final byLevel = a.level.compareTo(b.level);
      return byLevel != 0
          ? byLevel
          : a.objective.code.compareTo(b.objective.code);
    });
  return SkillsOverview(
    groups: groups,
    review: review.take(5).toList(),
    practised: all.where((i) => i.attempts > 0).length,
    solved: all.fold(0, (sum, i) => sum + i.solved),
  );
}
