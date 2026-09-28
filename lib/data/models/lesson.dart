/// A row of `lessons`. Students only ever receive rows granted to them
/// through `lesson_access` (RLS policy lessons_select_own_granted).
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.module,
    required this.orderIndex,
    this.description,
    this.contentUrl,
  });

  final String id;
  final String title;
  final String? description;
  final String module;
  final int orderIndex;
  final String? contentUrl;

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    module: json['module'] as String,
    orderIndex: (json['order_index'] as num).toInt(),
    contentUrl: json['content_url'] as String?,
  );
}

/// `lesson_progress.status`, in increasing order of progress.
enum ProgressStatus {
  notStarted('not_started'),
  viewed('viewed'),
  inProgress('in_progress'),
  completed('completed');

  const ProgressStatus(this.dbValue);

  final String dbValue;

  static ProgressStatus parse(String? value) => values.firstWhere(
    (s) => s.dbValue == value,
    orElse: () => ProgressStatus.notStarted,
  );
}

class LessonModule {
  const LessonModule(this.name, this.lessons);

  final String name;
  final List<Lesson> lessons;
}

/// Module names per curriculum track, in display order — mirrors TRACKS in
/// the platform's src/lib/data/tracks.ts.
const curriculumTrackModules = [
  'Kompyuter asoslari',
  'AI asoslari',
  'Scratch bilan tanishuv',
  'Python asoslari',
  'Godot bilan tanishuv',
];

/// Groups lessons like the platform's groupLessonsByTrack: known modules in
/// track order, then any other module in order of first appearance (by
/// order_index); lessons inside a module by order_index.
List<LessonModule> groupLessonsByModule(List<Lesson> lessons) {
  final sorted = [...lessons]
    ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
  final byModule = <String, List<Lesson>>{};
  for (final lesson in sorted) {
    byModule.putIfAbsent(lesson.module, () => []).add(lesson);
  }
  final known = [
    for (final name in curriculumTrackModules)
      if (byModule.containsKey(name)) name,
  ];
  final other = byModule.keys.where((m) => !known.contains(m));
  return [
    for (final name in [...known, ...other])
      LessonModule(name, byModule[name]!),
  ];
}

/// First lesson (in display order) that is not completed yet.
Lesson? nextLessonToStudy(
  List<Lesson> lessons,
  Map<String, ProgressStatus> progress,
) {
  for (final module in groupLessonsByModule(lessons)) {
    for (final lesson in module.lessons) {
      if (progress[lesson.id] != ProgressStatus.completed) return lesson;
    }
  }
  return null;
}
