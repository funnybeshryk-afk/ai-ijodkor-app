import 'lesson.dart';
import 'student_records.dart';

/// A child linked to the parent via `parent_child_links`.
class Child {
  const Child({required this.id, required this.fullName});

  final String id;
  final String fullName;

  /// Names are stored "Familiya Ism"; the given name is used in the UI.
  String get givenName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.skip(1).join(' ') : fullName.trim();
  }
}

/// `payments.status`
enum PaymentStatus {
  paid,
  unpaid;

  static PaymentStatus parse(String? value) =>
      value == 'paid' ? PaymentStatus.paid : PaymentStatus.unpaid;
}

/// A row of `payments`: one billing month of one student.
class Payment {
  const Payment({
    required this.id,
    required this.period,
    required this.amount,
    required this.status,
    this.markedAt,
    this.studentId,
  });

  final String id;

  /// Set when the row was selected with `student_id` (teacher screens).
  final String? studentId;

  /// 'YYYY-MM'
  final String period;
  final num amount;
  final PaymentStatus status;

  /// When staff marked it paid.
  final DateTime? markedAt;

  int get year => int.parse(period.substring(0, 4));
  int get month => int.parse(period.substring(5, 7));

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json['id'] as String,
    period: json['period'] as String,
    amount: (json['amount'] as num?) ?? 0,
    status: PaymentStatus.parse(json['status'] as String?),
    markedAt: DateTime.tryParse((json['marked_at'] as String?) ?? ''),
    studentId: json['student_id'] as String?,
  );
}

/// A row of `points_ledger`.
class PointsEntry {
  const PointsEntry({
    required this.amount,
    required this.reason,
    required this.createdAt,
  });

  final int amount;
  final String reason;
  final DateTime createdAt;

  factory PointsEntry.fromJson(Map<String, dynamic> json) => PointsEntry(
    amount: (json['amount'] as num).toInt(),
    reason: (json['reason'] as String?) ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

/// A `lesson_progress` row with its timestamp (for the events feed).
class ProgressRow {
  const ProgressRow({
    required this.lessonId,
    required this.status,
    required this.updatedAt,
  });

  final String lessonId;
  final ProgressStatus status;
  final DateTime updatedAt;

  factory ProgressRow.fromJson(Map<String, dynamic> json) => ProgressRow(
    lessonId: json['lesson_id'] as String,
    status: ProgressStatus.parse(json['status'] as String?),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );
}

/// Everything the parent screen shows about one child.
class ChildOverview {
  const ChildOverview({
    required this.lessons,
    required this.progress,
    required this.homework,
    required this.points,
    required this.payments,
    this.xp,
  });

  /// Lessons the child has been granted.
  final List<Lesson> lessons;
  final List<ProgressRow> progress;
  final List<HomeworkSubmission> homework;
  final List<PointsEntry> points;
  final List<Payment> payments;

  /// All-time XP (the same score as the platform rating); null while the
  /// database cannot answer yet — the screen then shows a placeholder.
  final int? xp;

  int get completedCount => lessons
      .where(
        (l) => progress.any(
          (p) => p.lessonId == l.id && p.status == ProgressStatus.completed,
        ),
      )
      .length;

  /// Share of granted lessons completed, 0..1.
  double get completion =>
      lessons.isEmpty ? 0 : completedCount / lessons.length;

  int countHomework(HomeworkStatus status) =>
      homework.where((h) => h.status == status).length;

  /// Newest period first.
  List<Payment> get paymentsByPeriod =>
      [...payments]..sort((a, b) => b.period.compareTo(a.period));

  /// The month to act on: the newest unpaid one, if any.
  Payment? get duePayment => paymentsByPeriod
      .where((p) => p.status == PaymentStatus.unpaid)
      .firstOrNull;

  String lessonTitle(String id, {bool ru = false}) =>
      lessons.where((l) => l.id == id).firstOrNull?.titleIn(ru: ru) ?? '';
}

enum ChildEventKind {
  homeworkSubmitted,
  homeworkApproved,
  homeworkRejected,
  lessonCompleted,
  points,
  paymentPaid,
}

/// One line of the «So'nggi yangiliklar» feed.
class ChildEvent {
  const ChildEvent({
    required this.kind,
    required this.at,
    this.subject = '',
    this.points = 0,
    this.payment,
  });

  final ChildEventKind kind;
  final DateTime at;

  /// Lesson title or points reason.
  final String subject;
  final int points;
  final Payment? payment;
}

/// Builds the newest-first events feed from the child's records.
List<ChildEvent> buildChildEvents(
  ChildOverview o, {
  int limit = 8,
  bool ru = false,
}) {
  final events = <ChildEvent>[
    for (final h in o.homework) ...[
      ChildEvent(
        kind: ChildEventKind.homeworkSubmitted,
        at: h.submittedAt,
        subject: o.lessonTitle(h.lessonId, ru: ru),
      ),
      if (h.reviewedAt != null && h.status != HomeworkStatus.pending)
        ChildEvent(
          kind: h.status == HomeworkStatus.approved
              ? ChildEventKind.homeworkApproved
              : ChildEventKind.homeworkRejected,
          at: h.reviewedAt!,
          subject: o.lessonTitle(h.lessonId, ru: ru),
        ),
    ],
    for (final p in o.progress)
      if (p.status == ProgressStatus.completed)
        ChildEvent(
          kind: ChildEventKind.lessonCompleted,
          at: p.updatedAt,
          subject: o.lessonTitle(p.lessonId, ru: ru),
        ),
    for (final e in o.points)
      ChildEvent(
        kind: ChildEventKind.points,
        at: e.createdAt,
        subject: e.reason,
        points: e.amount,
      ),
    for (final p in o.payments)
      if (p.status == PaymentStatus.paid && p.markedAt != null)
        ChildEvent(
          kind: ChildEventKind.paymentPaid,
          at: p.markedAt!,
          payment: p,
        ),
  ]..sort((a, b) => b.at.compareTo(a.at));
  return events.take(limit).toList();
}
