import 'lesson.dart';

/// `homework_submissions.status`
enum HomeworkStatus {
  pending,
  approved,
  rejected;

  static HomeworkStatus parse(String? value) => values.firstWhere(
    (s) => s.name == value,
    orElse: () => HomeworkStatus.pending,
  );
}

class HomeworkSubmission {
  const HomeworkSubmission({
    required this.id,
    required this.lessonId,
    required this.status,
    required this.submittedAt,
    this.contentText,
    this.fileUrl,
    this.reviewerNotes,
    this.reviewedAt,
  });

  final String id;
  final String lessonId;
  final HomeworkStatus status;
  final String? contentText;

  /// Storage path of the attached file (see homework_files.dart).
  final String? fileUrl;
  final String? reviewerNotes;
  final DateTime submittedAt;

  /// When a teacher approved/rejected it (null while pending).
  final DateTime? reviewedAt;

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) =>
      HomeworkSubmission(
        id: json['id'] as String,
        lessonId: json['lesson_id'] as String,
        status: HomeworkStatus.parse(json['status'] as String?),
        contentText: json['content_text'] as String?,
        fileUrl: json['file_url'] as String?,
        reviewerNotes: json['reviewer_notes'] as String?,
        submittedAt: DateTime.parse(json['submitted_at'] as String),
        reviewedAt: DateTime.tryParse((json['reviewed_at'] as String?) ?? ''),
      );
}

/// The rating period: the month (the main one, from the 1st, Tashkent time;
/// everybody starts from zero) or the week (from Monday).
enum RatingPeriod {
  month('month'),
  week('week');

  const RatingPeriod(this.dbValue);

  final String dbValue;
}

/// A row of `get_rating(period)`: the top three, the student's own place and
/// the place right above it.
class RatingRow {
  const RatingRow({
    required this.place,
    required this.studentId,
    required this.fullName,
    required this.points,
    required this.isMe,
    required this.totalStudents,
  });

  final int place;
  final String studentId;
  final String fullName;
  final int points;
  final bool isMe;

  /// Students in the whole platform rating.
  final int totalStudents;

  factory RatingRow.fromJson(Map<String, dynamic> json) => RatingRow(
    place: (json['place'] as num).toInt(),
    studentId: json['student_id'] as String,
    fullName: (json['full_name'] as String?) ?? '',
    points: (json['points'] as num).toInt(),
    isMe: (json['is_me'] as bool?) ?? false,
    totalStudents: (json['total_students'] as num?)?.toInt() ?? 0,
  );
}

class Certificate {
  const Certificate({
    required this.id,
    required this.courseName,
    required this.issuedAt,
    required this.teacherName,
    this.courseNameRu,
  });

  /// The certificate number, e.g. "AIJ-2026-000123".
  final String id;
  final String courseName;

  /// `courses.name_ru` (platform migration 0020), if translated.
  final String? courseNameRu;
  final DateTime issuedAt;
  final String teacherName;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: json['id'] as String,
    courseName: ((json['courses'] as Map?)?['name'] as String?) ?? '',
    issuedAt: DateTime.parse(json['issued_at'] as String),
    teacherName: (json['teacher_name_snapshot'] as String?) ?? '',
    courseNameRu: (json['courses'] as Map?)?['name_ru'] as String?,
  );

  String courseNameIn({required bool ru}) =>
      pickContent(courseName, courseNameRu, ru: ru);
}
