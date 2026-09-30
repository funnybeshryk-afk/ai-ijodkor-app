import 'lesson.dart';
import 'parent_records.dart';
import 'student_records.dart';

/// A student (or, for admins, a teacher) row of `profiles`, as the teacher
/// screens use it.
class Person {
  const Person({
    required this.id,
    required this.fullName,
    this.phone,
    this.teacherId,
    this.archivedAt,
    this.archivedReason,
  });

  final String id;
  final String fullName;
  final String? phone;

  /// The student's teacher (`profiles.teacher_id`), null when unassigned.
  final String? teacherId;
  final DateTime? archivedAt;
  final String? archivedReason;

  bool get isArchived => archivedAt != null;

  /// Up to two initials for the avatar ("Karimov Aziz" -> "KA").
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p.substring(0, 1).toUpperCase())
        .join();
  }

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'] as String,
    fullName: (json['full_name'] as String?) ?? '',
    phone: json['phone'] as String?,
    teacherId: json['teacher_id'] as String?,
    archivedAt: DateTime.tryParse((json['archived_at'] as String?) ?? ''),
    archivedReason: json['archived_reason'] as String?,
  );
}

/// A parent linked to a student — `get_student_parents` (migration 0021).
class StudentParent {
  const StudentParent({
    required this.id,
    required this.fullName,
    this.phone,
    this.login,
  });

  final String id;
  final String fullName;
  final String? phone;

  /// The parent's sign-in email (for phone logins, `<digits>@parent...`).
  final String? login;

  factory StudentParent.fromJson(Map<String, dynamic> json) => StudentParent(
    id: json['parent_id'] as String,
    fullName: (json['full_name'] as String?) ?? '',
    phone: json['phone'] as String?,
    login: json['login'] as String?,
  );
}

/// A `homework_submissions` row with its student, for the review queue and
/// the student card.
class TeacherHomework {
  const TeacherHomework({
    required this.id,
    required this.studentId,
    required this.lessonId,
    required this.status,
    required this.submittedAt,
    this.contentText,
    this.fileUrl,
    this.reviewerNotes,
    this.reviewedAt,
  });

  final String id;
  final String studentId;
  final String lessonId;
  final HomeworkStatus status;
  final DateTime submittedAt;
  final String? contentText;

  /// Storage path of the attached file (see homework_files.dart).
  final String? fileUrl;
  final String? reviewerNotes;
  final DateTime? reviewedAt;

  /// The answer when it is a single web link (opened in the browser).
  Uri? get link {
    final text = contentText?.trim() ?? '';
    if (text.contains(RegExp(r'\s'))) return null;
    final uri = Uri.tryParse(text);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https')
        ? uri
        : null;
  }

  factory TeacherHomework.fromJson(Map<String, dynamic> json) =>
      TeacherHomework(
        id: json['id'] as String,
        studentId: json['student_id'] as String,
        lessonId: json['lesson_id'] as String,
        status: HomeworkStatus.parse(json['status'] as String?),
        submittedAt: DateTime.parse(json['submitted_at'] as String),
        contentText: json['content_text'] as String?,
        fileUrl: json['file_url'] as String?,
        reviewerNotes: json['reviewer_notes'] as String?,
        reviewedAt: DateTime.tryParse((json['reviewed_at'] as String?) ?? ''),
      );
}

/// A `courses` row (certificate courses).
class Course {
  const Course({required this.id, required this.name, this.nameRu});

  final String id;
  final String name;
  final String? nameRu;

  String nameIn({required bool ru}) => pickContent(name, nameRu, ru: ru);

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    name: (json['name'] as String?) ?? '',
    nameRu: json['name_ru'] as String?,
  );
}

/// Everything the student card shows about one student.
class StudentDetail {
  const StudentDetail({
    required this.progress,
    required this.homework,
    required this.points,
    required this.payments,
    required this.openLessonIds,
    required this.certificates,
    required this.parents,
  });

  final List<ProgressRow> progress;

  /// Newest first.
  final List<TeacherHomework> homework;
  final List<PointsEntry> points;

  /// Newest period first.
  final List<Payment> payments;

  /// Lessons the student can see (`lesson_access`).
  final Set<String> openLessonIds;
  final List<Certificate> certificates;
  final List<StudentParent> parents;

  int get pointsTotal => points.fold(0, (sum, e) => sum + e.amount);

  ProgressStatus statusOf(String lessonId) =>
      progress.where((p) => p.lessonId == lessonId).firstOrNull?.status ??
      ProgressStatus.notStarted;

  int get completedOpenCount => openLessonIds
      .where((id) => statusOf(id) == ProgressStatus.completed)
      .length;

  /// Share of the open lessons completed, 0..1.
  double get completion =>
      openLessonIds.isEmpty ? 0 : completedOpenCount / openLessonIds.length;

  int get pendingHomework =>
      homework.where((h) => h.status == HomeworkStatus.pending).length;
}

/// 'YYYY-MM' of [at].
String periodOf(DateTime at) =>
    '${at.year}-${at.month.toString().padLeft(2, '0')}';

/// [period] moved by [months] (may cross years).
String shiftPeriod(String period, int months) {
  final year = int.parse(period.substring(0, 4));
  final month = int.parse(period.substring(5, 7));
  final index = year * 12 + (month - 1) + months;
  return '${index ~/ 12}-${(index % 12 + 1).toString().padLeft(2, '0')}';
}

/// Standard monthly fee — the platform's DEFAULT_AMOUNT (payments-panel).
const defaultMonthlyFee = 350000;

/// One student's line in the payments list for a month: the saved row, or
/// a default (last known amount, else the standard fee; unpaid) — exactly
/// like the platform's payments panel. Nothing is written until saved.
class PaymentLine {
  const PaymentLine({
    required this.student,
    required this.amount,
    required this.status,
    this.saved,
  });

  final Person student;
  final num amount;
  final PaymentStatus status;
  final Payment? saved;

  bool get isDebt => status == PaymentStatus.unpaid;
}

List<PaymentLine> paymentLinesFor(
  List<Person> students,
  List<Payment> payments,
  String period,
) {
  return [
    for (final student in students)
      () {
        final own = payments.where((p) => p.studentId == student.id).toList()
          ..sort((a, b) => b.period.compareTo(a.period));
        final saved = own.where((p) => p.period == period).firstOrNull;
        final latest = own.firstOrNull;
        return PaymentLine(
          student: student,
          saved: saved,
          amount: saved?.amount ?? latest?.amount ?? defaultMonthlyFee,
          status: saved?.status ?? PaymentStatus.unpaid,
        );
      }(),
  ];
}
