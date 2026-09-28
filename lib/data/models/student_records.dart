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
    this.reviewerNotes,
  });

  final String id;
  final String lessonId;
  final HomeworkStatus status;
  final String? contentText;
  final String? reviewerNotes;
  final DateTime submittedAt;

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) =>
      HomeworkSubmission(
        id: json['id'] as String,
        lessonId: json['lesson_id'] as String,
        status: HomeworkStatus.parse(json['status'] as String?),
        contentText: json['content_text'] as String?,
        reviewerNotes: json['reviewer_notes'] as String?,
        submittedAt: DateTime.parse(json['submitted_at'] as String),
      );
}

/// A row of `get_class_leaderboard()` (this week's trainer score).
class LeaderboardEntry {
  const LeaderboardEntry({
    required this.studentId,
    required this.fullName,
    required this.totalScore,
  });

  final String studentId;
  final String fullName;
  final int totalScore;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      LeaderboardEntry(
        studentId: json['student_id'] as String,
        fullName: (json['full_name'] as String?) ?? '',
        totalScore: (json['total_score'] as num).toInt(),
      );
}

class Certificate {
  const Certificate({
    required this.id,
    required this.courseName,
    required this.issuedAt,
    required this.teacherName,
  });

  /// The certificate number, e.g. "AIJ-2026-000123".
  final String id;
  final String courseName;
  final DateTime issuedAt;
  final String teacherName;

  factory Certificate.fromJson(Map<String, dynamic> json) => Certificate(
    id: json['id'] as String,
    courseName: ((json['courses'] as Map?)?['name'] as String?) ?? '',
    issuedAt: DateTime.parse(json['issued_at'] as String),
    teacherName: (json['teacher_name_snapshot'] as String?) ?? '',
  );
}
