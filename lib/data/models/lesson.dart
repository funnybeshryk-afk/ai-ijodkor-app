/// The Russian twin of a content field when [ru] is set and it is filled
/// in, otherwise the Uzbek original (the source of truth).
String pickContent(String uz, String? russian, {required bool ru}) =>
    ru && russian != null && russian.trim().isNotEmpty ? russian : uz;

/// A row of `lessons`. Students only ever receive rows granted to them
/// through `lesson_access` (RLS policy lessons_select_own_granted).
///
/// [title], [description] and [module] are the Uzbek originals; `module`
/// stays the grouping key everywhere. The `*Ru` fields are optional Russian
/// translations (platform migration 0020) — shown via [titleIn] and friends.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.module,
    required this.orderIndex,
    this.description,
    this.contentUrl,
    this.titleRu,
    this.descriptionRu,
    this.moduleRu,
  });

  final String id;
  final String title;
  final String? description;
  final String module;
  final int orderIndex;
  final String? contentUrl;
  final String? titleRu;
  final String? descriptionRu;
  final String? moduleRu;

  String titleIn({required bool ru}) => pickContent(title, titleRu, ru: ru);

  String? descriptionIn({required bool ru}) => description == null
      ? null
      : pickContent(description!, descriptionRu, ru: ru);

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String?,
    module: json['module'] as String,
    orderIndex: (json['order_index'] as num).toInt(),
    contentUrl: json['content_url'] as String?,
    titleRu: json['title_ru'] as String?,
    descriptionRu: json['description_ru'] as String?,
    moduleRu: json['module_ru'] as String?,
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

  /// Display name. `module_ru` is stored per lesson; the first translation
  /// found in the module names the whole module (as on the platform).
  String label({required bool ru}) => pickContent(
    name,
    lessons
        .map((l) => l.moduleRu)
        .firstWhere(
          (m) => m != null && m.trim().isNotEmpty,
          orElse: () => null,
        ),
    ru: ru,
  );
}

/// Display name of [lesson]'s module, see [LessonModule.label].
String moduleLabelOf(Lesson lesson, List<Lesson> all, {required bool ru}) =>
    LessonModule(lesson.module, [
      lesson,
      ...all.where((l) => l.module == lesson.module),
    ]).label(ru: ru);

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
