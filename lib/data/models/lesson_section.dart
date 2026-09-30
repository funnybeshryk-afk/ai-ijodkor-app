import 'dart:convert';

/// A `lesson_sections` row (platform migration 0023). Bodies follow the
/// platform's src/lib/lesson-sections.ts: markdown for `text`, a small JSON
/// object for every other kind.
enum SectionKind {
  text,
  code,
  callout,
  image,
  video,
  diagram,
  exercise,
  trainerLink;

  static SectionKind? parse(String? value) => switch (value) {
    'text' => text,
    'code' => code,
    'callout' => callout,
    'image' => image,
    'video' => video,
    'diagram' => diagram,
    'exercise' => exercise,
    'trainer_link' => trainerLink,
    _ => null,
  };
}

class LessonSection {
  const LessonSection({
    required this.id,
    required this.orderIndex,
    required this.kind,
    required this.bodyUz,
    this.bodyRu,
    this.mediaPath,
  });

  final String id;
  final int orderIndex;
  final SectionKind kind;
  final String bodyUz;
  final String? bodyRu;
  final String? mediaPath;

  /// Russian when it exists, else Uzbek (same rule as the site).
  String bodyFor({required bool ru}) =>
      ru && (bodyRu?.trim().isNotEmpty ?? false) ? bodyRu! : bodyUz;

  SectionContent contentFor({required bool ru}) =>
      SectionContent.parse(kind, bodyFor(ru: ru));

  /// Null for a kind this app version doesn't know (newer platform).
  static LessonSection? fromJson(Map<String, dynamic> json) {
    final kind = SectionKind.parse(json['kind'] as String?);
    if (kind == null) return null;
    return LessonSection(
      id: json['id'] as String,
      orderIndex: (json['order_index'] as num).toInt(),
      kind: kind,
      bodyUz: (json['body_uz'] as String?) ?? '',
      bodyRu: json['body_ru'] as String?,
      mediaPath: json['media_path'] as String?,
    );
  }
}

enum CalloutTone { info, warn, good }

/// A parsed section body. Parsing never throws: a broken body becomes a
/// text section showing the raw value, so one bad row can't break a lesson.
sealed class SectionContent {
  const SectionContent();

  static SectionContent parse(SectionKind kind, String body) {
    if (kind == SectionKind.text) return TextContent(body);
    final Map<String, dynamic> o;
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return TextContent(body);
      o = decoded;
    } on FormatException {
      return TextContent(body);
    }
    String s(String key) => o[key] is String ? o[key] as String : '';
    return switch (kind) {
      SectionKind.text => TextContent(body),
      SectionKind.code => CodeContent(
        language: s('language').isEmpty ? 'text' : s('language'),
        code: s('code'),
      ),
      SectionKind.callout => CalloutContent(
        tone: switch (s('tone')) {
          'warn' => CalloutTone.warn,
          'good' => CalloutTone.good,
          _ => CalloutTone.info,
        },
        title: s('title'),
        text: s('text'),
      ),
      SectionKind.exercise => ExerciseContent(
        practice: s('variant') == 'practice',
        label: s('label'),
        title: s('title'),
        text: s('text'),
      ),
      SectionKind.diagram => DiagramContent(
        svg: s('svg'),
        caption: s('caption'),
        alt: s('alt'),
      ),
      SectionKind.image => ImageContent(alt: s('alt'), caption: s('caption')),
      SectionKind.video => VideoContent(url: s('url'), caption: s('caption')),
      SectionKind.trainerLink => TrainerLinkContent(
        href: s('href'),
        title: s('title'),
        text: s('text'),
      ),
    };
  }
}

class TextContent extends SectionContent {
  const TextContent(this.markdown);
  final String markdown;
}

class CodeContent extends SectionContent {
  const CodeContent({required this.language, required this.code});
  final String language;
  final String code;
}

class CalloutContent extends SectionContent {
  const CalloutContent({
    required this.tone,
    required this.title,
    required this.text,
  });
  final CalloutTone tone;
  final String title;
  final String text;
}

class ExerciseContent extends SectionContent {
  const ExerciseContent({
    required this.practice,
    required this.label,
    required this.title,
    required this.text,
  });

  /// «Sinab ko'ring!» practice (hand icon) vs. a task (pencil icon).
  final bool practice;
  final String label;
  final String title;
  final String text;
}

class DiagramContent extends SectionContent {
  const DiagramContent({
    required this.svg,
    required this.caption,
    required this.alt,
  });
  final String svg;
  final String caption;
  final String alt;
}

class ImageContent extends SectionContent {
  const ImageContent({required this.alt, required this.caption});
  final String alt;
  final String caption;
}

class VideoContent extends SectionContent {
  const VideoContent({required this.url, required this.caption});
  final String url;
  final String caption;
}

class TrainerLinkContent extends SectionContent {
  const TrainerLinkContent({
    required this.href,
    required this.title,
    required this.text,
  });
  final String href;
  final String title;
  final String text;
}

/// A learning objective of a lesson (AI4K12 / CSTA), approved by a teacher.
class LessonObjective {
  const LessonObjective({
    required this.code,
    required this.titleUz,
    this.titleRu,
  });

  final String code;
  final String titleUz;
  final String? titleRu;

  String titleIn({required bool ru}) =>
      ru && (titleRu?.trim().isNotEmpty ?? false) ? titleRu! : titleUz;
}
