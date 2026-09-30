import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/parent_records.dart';
import 'package:ai_ijodkor/data/models/student_records.dart';
import 'package:ai_ijodkor/data/models/teacher_records.dart';
import 'package:ai_ijodkor/data/repositories/teacher_repository.dart';

/// In-memory teacher data with the same write rules as the real one
/// (approve = +10 points and completed; group access only adds missing rows).
class FakeTeacherRepository implements TeacherRepository {
  final students = <Person>[];
  final teachers = <Person>[];
  final lessons = <Lesson>[];

  /// student id -> open lesson ids
  final access = <String, Set<String>>{};

  /// (student id, lesson id) -> status
  final progress = <(String, String), ProgressStatus>{};
  final homework = <TeacherHomework>[];

  /// student id -> points entries
  final points = <String, List<PointsEntry>>{};
  final payments = <Payment>[];
  final courses = <Course>[];
  final certificates = <String, List<Certificate>>{};
  final parents = <String, List<StudentParent>>{};
  int _certSeq = 0;
  bool failStudents = false;

  /// Recorded writes, for assertions.
  final calls = <String>[];

  @override
  Future<List<Person>> fetchStudents({bool archived = false}) async {
    if (failStudents) throw Exception('offline');
    return students.where((s) => s.isArchived == archived).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
  }

  @override
  Future<List<Lesson>> fetchLessons() async => List.of(lessons);

  @override
  Future<StudentDetail> fetchStudentDetail(String studentId) async =>
      StudentDetail(
        progress: [
          for (final e in progress.entries)
            if (e.key.$1 == studentId)
              ProgressRow(
                lessonId: e.key.$2,
                status: e.value,
                updatedAt: DateTime(2026, 9, 20),
              ),
        ],
        homework: homework.where((h) => h.studentId == studentId).toList(),
        points: points[studentId] ?? const [],
        payments: payments.where((p) => p.studentId == studentId).toList()
          ..sort((a, b) => b.period.compareTo(a.period)),
        openLessonIds: Set.of(access[studentId] ?? const {}),
        certificates: certificates[studentId] ?? const [],
        parents: parents[studentId] ?? const [],
      );

  @override
  Future<List<TeacherHomework>> fetchPendingHomework() async =>
      homework.where((h) => h.status == HomeworkStatus.pending).toList();

  /// Paths a signed link was asked for.
  final signedPaths = <String>[];

  @override
  Future<Uri> homeworkFileUrl(String path) async {
    signedPaths.add(path);
    return Uri.parse('https://storage.test/$path');
  }

  @override
  Future<void> reviewHomework({
    required String submissionId,
    required bool approved,
    required String notes,
    required String reviewerId,
  }) async {
    calls.add('review:$submissionId:$approved:$notes');
    final i = homework.indexWhere((h) => h.id == submissionId);
    final h = homework[i];
    homework[i] = TeacherHomework(
      id: h.id,
      studentId: h.studentId,
      lessonId: h.lessonId,
      status: approved ? HomeworkStatus.approved : HomeworkStatus.rejected,
      submittedAt: h.submittedAt,
      contentText: h.contentText,
      reviewerNotes: notes.isEmpty ? null : notes,
      reviewedAt: DateTime(2026, 9, 28),
    );
    if (approved) {
      progress[(h.studentId, h.lessonId)] = ProgressStatus.completed;
      points
          .putIfAbsent(h.studentId, () => [])
          .add(
            PointsEntry(
              amount: homeworkApprovedPoints,
              reason: homeworkApprovedReason,
              createdAt: DateTime(2026, 9, 28),
            ),
          );
    }
  }

  @override
  Future<void> setLessonAccess({
    required String studentId,
    required String lessonId,
    required bool open,
    required String grantedBy,
  }) async {
    calls.add('access:$studentId:$lessonId:$open');
    final set = access.putIfAbsent(studentId, () => {});
    open ? set.add(lessonId) : set.remove(lessonId);
  }

  @override
  Future<Map<String, int>> fetchAccessCounts(List<String> studentIds) async {
    final counts = <String, int>{};
    for (final id in studentIds) {
      for (final lessonId in access[id] ?? const <String>{}) {
        counts[lessonId] = (counts[lessonId] ?? 0) + 1;
      }
    }
    return counts;
  }

  @override
  Future<void> setLessonAccessForGroup({
    required String lessonId,
    required List<String> studentIds,
    required bool open,
    required String grantedBy,
  }) async {
    calls.add('group:$lessonId:$open:${studentIds.length}');
    for (final id in studentIds) {
      final set = access.putIfAbsent(id, () => {});
      open ? set.add(lessonId) : set.remove(lessonId);
    }
  }

  @override
  Future<List<Payment>> fetchPayments() async => List.of(payments);

  @override
  Future<void> markPayment({
    required String studentId,
    required String period,
    required num amount,
    required PaymentStatus status,
    required String markedBy,
  }) async {
    calls.add('pay:$studentId:$period:$amount:${status.name}');
    payments.removeWhere((p) => p.studentId == studentId && p.period == period);
    payments.add(
      Payment(
        id: 'p-$studentId-$period',
        studentId: studentId,
        period: period,
        amount: amount,
        status: status,
      ),
    );
  }

  @override
  Future<List<Course>> fetchCourses() async => List.of(courses);

  @override
  Future<String> issueCertificate({
    required String studentId,
    required String courseId,
    required String issuedBy,
    required String teacherName,
    required String directorName,
  }) async {
    final id = 'AIJ-2026-${(++_certSeq).toString().padLeft(6, '0')}';
    calls.add('cert:$studentId:$courseId:$teacherName:$directorName');
    certificates
        .putIfAbsent(studentId, () => [])
        .add(
          Certificate(
            id: id,
            courseName: courses.firstWhere((c) => c.id == courseId).name,
            issuedAt: DateTime(2026, 9, 28),
            teacherName: teacherName,
          ),
        );
    return id;
  }

  Person _replace(String id, Person Function(Person) change) {
    final i = students.indexWhere((s) => s.id == id);
    return students[i] = change(students[i]);
  }

  @override
  Future<void> archiveStudent(String studentId, String? reason) async {
    calls.add('archive:$studentId:$reason');
    _replace(
      studentId,
      (s) => Person(
        id: s.id,
        fullName: s.fullName,
        phone: s.phone,
        teacherId: s.teacherId,
        archivedAt: DateTime(2026, 9, 28),
        archivedReason: reason,
      ),
    );
  }

  @override
  Future<void> unarchiveStudent(String studentId) async {
    calls.add('unarchive:$studentId');
    _replace(
      studentId,
      (s) => Person(
        id: s.id,
        fullName: s.fullName,
        phone: s.phone,
        teacherId: s.teacherId,
      ),
    );
  }

  @override
  Future<List<Person>> fetchTeachers() async => List.of(teachers);

  @override
  Future<void> assignTeacher(String studentId, String? teacherId) async {
    calls.add('assign:$studentId:$teacherId');
    _replace(
      studentId,
      (s) => Person(
        id: s.id,
        fullName: s.fullName,
        phone: s.phone,
        teacherId: teacherId,
        archivedAt: s.archivedAt,
        archivedReason: s.archivedReason,
      ),
    );
  }
}
