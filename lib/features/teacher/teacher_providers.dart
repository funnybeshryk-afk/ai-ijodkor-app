import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson.dart';
import '../../data/models/parent_records.dart';
import '../../data/models/profile.dart';
import '../../data/models/teacher_records.dart';
import '../../data/providers.dart';
import '../../data/repositories/teacher_repository.dart';

TeacherRepository _repo(Ref ref) {
  final repo = ref.watch(teacherRepositoryProvider);
  if (repo == null) throw StateError('No teacher repository');
  return repo;
}

/// Admins see every student and get the teacher-assignment screens.
final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(currentProfileProvider).value?.role == UserRole.admin,
);

/// Active students, by name.
final studentsProvider = FutureProvider<List<Person>>(
  (ref) => _repo(ref).fetchStudents(),
);

final archivedStudentsProvider = FutureProvider<List<Person>>(
  (ref) => _repo(ref).fetchStudents(archived: true),
);

final allLessonsProvider = FutureProvider<List<Lesson>>(
  (ref) => _repo(ref).fetchLessons(),
);

final studentDetailProvider = FutureProvider.family<StudentDetail, String>(
  (ref, studentId) => _repo(ref).fetchStudentDetail(studentId),
);

final pendingHomeworkProvider = FutureProvider<List<TeacherHomework>>(
  (ref) => _repo(ref).fetchPendingHomework(),
);

final paymentsProvider = FutureProvider<List<Payment>>(
  (ref) => _repo(ref).fetchPayments(),
);

final coursesProvider = FutureProvider<List<Course>>(
  (ref) => _repo(ref).fetchCourses(),
);

final teachersProvider = FutureProvider<List<Person>>(
  (ref) => _repo(ref).fetchTeachers(),
);

/// lesson id -> how many active students can see it.
final accessCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final students = await ref.watch(studentsProvider.future);
  return _repo(ref).fetchAccessCounts([for (final s in students) s.id]);
});

/// Any student, active or archived, by id (for names on cards and queues).
final studentByIdProvider = Provider.family<Person?, String>((ref, id) {
  for (final list in [
    ref.watch(studentsProvider).value,
    ref.watch(archivedStudentsProvider).value,
  ]) {
    final match = list?.where((s) => s.id == id).firstOrNull;
    if (match != null) return match;
  }
  return null;
});

/// Month shown on the payments tab, 'YYYY-MM'.
class SelectedPeriod extends Notifier<String> {
  @override
  String build() => periodOf(DateTime.now());

  void shift(int months) => state = shiftPeriod(state, months);
}

final selectedPeriodProvider = NotifierProvider<SelectedPeriod, String>(
  SelectedPeriod.new,
);

/// Write operations; each refreshes what it affects.
class TeacherActions {
  TeacherActions(this._ref);

  final Ref _ref;

  Future<(TeacherRepository, String)> get _ctx async {
    final repo = _ref.read(teacherRepositoryProvider);
    final userId = await _ref.read(currentUserIdProvider.future);
    if (repo == null || userId == null) throw StateError('Not signed in');
    return (repo, userId);
  }

  Future<Uri> homeworkFileUrl(String path) async {
    final (repo, _) = await _ctx;
    return repo.homeworkFileUrl(path);
  }

  Future<void> reviewHomework(
    TeacherHomework homework, {
    required bool approved,
    required String notes,
  }) async {
    final (repo, userId) = await _ctx;
    await repo.reviewHomework(
      submissionId: homework.id,
      approved: approved,
      notes: notes,
      reviewerId: userId,
    );
    _ref.invalidate(pendingHomeworkProvider);
    _ref.invalidate(studentDetailProvider(homework.studentId));
  }

  Future<void> setLessonAccess(
    String studentId,
    String lessonId, {
    required bool open,
  }) async {
    final (repo, userId) = await _ctx;
    await repo.setLessonAccess(
      studentId: studentId,
      lessonId: lessonId,
      open: open,
      grantedBy: userId,
    );
    _ref.invalidate(studentDetailProvider(studentId));
    _ref.invalidate(accessCountsProvider);
  }

  Future<void> setGroupAccess(String lessonId, {required bool open}) async {
    final (repo, userId) = await _ctx;
    final students = await _ref.read(studentsProvider.future);
    await repo.setLessonAccessForGroup(
      lessonId: lessonId,
      studentIds: [for (final s in students) s.id],
      open: open,
      grantedBy: userId,
    );
    _ref.invalidate(accessCountsProvider);
    _ref.invalidate(studentDetailProvider);
  }

  Future<void> markPayment(
    String studentId,
    String period, {
    required num amount,
    required PaymentStatus status,
  }) async {
    final (repo, userId) = await _ctx;
    await repo.markPayment(
      studentId: studentId,
      period: period,
      amount: amount,
      status: status,
      markedBy: userId,
    );
    _ref.invalidate(paymentsProvider);
    _ref.invalidate(studentDetailProvider(studentId));
  }

  Future<String> issueCertificate({
    required String studentId,
    required String courseId,
    required String teacherName,
    required String directorName,
  }) async {
    final (repo, userId) = await _ctx;
    final id = await repo.issueCertificate(
      studentId: studentId,
      courseId: courseId,
      issuedBy: userId,
      teacherName: teacherName,
      directorName: directorName,
    );
    _ref.invalidate(studentDetailProvider(studentId));
    return id;
  }

  Future<void> archive(String studentId, String? reason) async {
    final (repo, _) = await _ctx;
    await repo.archiveStudent(studentId, reason);
    _refreshRoster(studentId);
  }

  Future<void> unarchive(String studentId) async {
    final (repo, _) = await _ctx;
    await repo.unarchiveStudent(studentId);
    _refreshRoster(studentId);
  }

  Future<void> assignTeacher(String studentId, String? teacherId) async {
    final (repo, _) = await _ctx;
    await repo.assignTeacher(studentId, teacherId);
    _refreshRoster(studentId);
  }

  void _refreshRoster(String studentId) {
    _ref.invalidate(studentsProvider);
    _ref.invalidate(archivedStudentsProvider);
    _ref.invalidate(studentDetailProvider(studentId));
  }
}

final teacherActionsProvider = Provider<TeacherActions>(TeacherActions.new);
