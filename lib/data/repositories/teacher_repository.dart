import 'package:supabase_flutter/supabase_flutter.dart';

import '../homework_files.dart';
import '../xp.dart';
import '../models/lesson.dart';
import '../models/parent_records.dart';
import '../models/student_records.dart';
import '../models/teacher_records.dart';

/// Data of the teacher/admin screens. Everything goes through the user's
/// own session and RLS, like the platform's /teacher panel: a teacher only
/// ever sees and changes their own students (is_own_student), an admin
/// sees everyone (is_admin). Archiving and the parents list use the RPCs
/// of platform migration 0021, because the web panel does those with its
/// server-only admin client.
abstract class TeacherRepository {
  /// Active (or archived) students, by name.
  Future<List<Person>> fetchStudents({bool archived = false});

  /// Every lesson of the curriculum (staff read all lessons).
  Future<List<Lesson>> fetchLessons();

  Future<StudentDetail> fetchStudentDetail(String studentId);

  /// Submissions waiting for review, oldest first.
  Future<List<TeacherHomework>> fetchPendingHomework();

  /// A short-lived link to a stored homework file (Storage RLS decides).
  Future<Uri> homeworkFileUrl(String path);

  /// Approve (lesson completed; the points are counted by the platform from
  /// the approved submission) or return with a comment — the platform's
  /// reviewHomework().
  Future<void> reviewHomework({
    required String submissionId,
    required bool approved,
    required String notes,
    required String reviewerId,
  });

  Future<void> setLessonAccess({
    required String studentId,
    required String lessonId,
    required bool open,
    required String grantedBy,
  });

  /// lesson id -> how many of [studentIds] can see it.
  Future<Map<String, int>> fetchAccessCounts(List<String> studentIds);

  Future<void> setLessonAccessForGroup({
    required String lessonId,
    required List<String> studentIds,
    required bool open,
    required String grantedBy,
  });

  /// All payment rows visible to the user (with student ids).
  Future<List<Payment>> fetchPayments();

  Future<void> markPayment({
    required String studentId,
    required String period,
    required num amount,
    required PaymentStatus status,
    required String markedBy,
  });

  Future<List<Course>> fetchCourses();

  /// Returns the new certificate number.
  Future<String> issueCertificate({
    required String studentId,
    required String courseId,
    required String issuedBy,
    required String teacherName,
    required String directorName,
  });

  Future<void> archiveStudent(String studentId, String? reason);
  Future<void> unarchiveStudent(String studentId);

  /// Admin only.
  Future<List<Person>> fetchTeachers();

  /// Admin only; null unassigns.
  Future<void> assignTeacher(String studentId, String? teacherId);
}

class SupabaseTeacherRepository implements TeacherRepository {
  SupabaseTeacherRepository(this._client);

  final SupabaseClient _client;

  static const _personColumns =
      'id, full_name, phone, teacher_id, archived_at, archived_reason';

  @override
  Future<List<Person>> fetchStudents({bool archived = false}) async {
    var query = _client
        .from('profiles')
        .select(_personColumns)
        .eq('role', 'student');
    query = archived
        ? query.not('archived_at', 'is', null)
        : query.isFilter('archived_at', null);
    final rows = await query.order('full_name');
    return [for (final row in rows) Person.fromJson(row)];
  }

  @override
  Future<List<Lesson>> fetchLessons() async {
    final rows = await _client.from('lessons').select().order('order_index');
    return [for (final row in rows) Lesson.fromJson(row)];
  }

  @override
  Future<StudentDetail> fetchStudentDetail(String studentId) async {
    final results = await Future.wait<List<dynamic>>([
      _client
          .from('lesson_progress')
          .select('lesson_id, status, updated_at')
          .eq('student_id', studentId),
      _client
          .from('homework_submissions')
          .select(
            'id, student_id, lesson_id, status, content_text, file_url, '
            'reviewer_notes, submitted_at, reviewed_at',
          )
          .eq('student_id', studentId)
          .order('submitted_at', ascending: false),
      _client
          .from('points_ledger')
          .select('amount, reason, created_at')
          .eq('student_id', studentId)
          .order('created_at', ascending: false),
      _client
          .from('payments')
          .select('id, student_id, period, amount, status, marked_at')
          .eq('student_id', studentId)
          .order('period', ascending: false),
      _client
          .from('lesson_access')
          .select('lesson_id')
          .eq('student_id', studentId),
      _client
          .from('certificates')
          .select('id, issued_at, teacher_name_snapshot, courses(*)')
          .eq('student_id', studentId)
          .order('issued_at', ascending: false),
      _client.rpc<List<dynamic>>(
        'get_student_parents',
        params: {'p_student_id': studentId},
      ),
    ]);
    Map<String, dynamic> m(dynamic row) =>
        Map<String, dynamic>.from(row as Map);
    final xp = await fetchXpOrNull(_client, studentId);
    return StudentDetail(
      progress: [for (final r in results[0]) ProgressRow.fromJson(m(r))],
      homework: [for (final r in results[1]) TeacherHomework.fromJson(m(r))],
      points: [for (final r in results[2]) PointsEntry.fromJson(m(r))],
      payments: [for (final r in results[3]) Payment.fromJson(m(r))],
      openLessonIds: {for (final r in results[4]) m(r)['lesson_id'] as String},
      certificates: [for (final r in results[5]) Certificate.fromJson(m(r))],
      parents: [for (final r in results[6]) StudentParent.fromJson(m(r))],
      xp: xp,
    );
  }

  @override
  Future<List<TeacherHomework>> fetchPendingHomework() async {
    final rows = await _client
        .from('homework_submissions')
        .select(
          'id, student_id, lesson_id, status, content_text, file_url, '
          'reviewer_notes, submitted_at, reviewed_at',
        )
        .eq('status', 'pending')
        .order('submitted_at');
    return [for (final row in rows) TeacherHomework.fromJson(row)];
  }

  @override
  Future<Uri> homeworkFileUrl(String path) async => Uri.parse(
    await _client.storage.from(homeworkBucket).createSignedUrl(path, 60 * 60),
  );

  @override
  Future<void> reviewHomework({
    required String submissionId,
    required bool approved,
    required String notes,
    required String reviewerId,
  }) async {
    final submission = await _client
        .from('homework_submissions')
        .select('student_id, lesson_id')
        .eq('id', submissionId)
        .single();
    final now = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('homework_submissions')
        .update({
          'status': approved ? 'approved' : 'rejected',
          'reviewer_id': reviewerId,
          'reviewer_notes': notes.trim().isEmpty ? null : notes.trim(),
          'reviewed_at': now,
        })
        .eq('id', submissionId);
    if (!approved) return;
    await _client.from('lesson_progress').upsert({
      'student_id': submission['student_id'],
      'lesson_id': submission['lesson_id'],
      'status': 'completed',
      'updated_at': now,
    }, onConflict: 'student_id,lesson_id');
    // No points_ledger row: since platform migration 0040 the points of a
    // homework are counted from the approved submission itself (its
    // reviewed_at), at the price the owner set in app_settings.points_rules.
  }

  @override
  Future<void> setLessonAccess({
    required String studentId,
    required String lessonId,
    required bool open,
    required String grantedBy,
  }) async {
    if (open) {
      await _client
          .from('lesson_access')
          .upsert(
            {
              'student_id': studentId,
              'lesson_id': lessonId,
              'granted_by': grantedBy,
            },
            onConflict: 'student_id,lesson_id',
            ignoreDuplicates: true,
          );
    } else {
      await _client
          .from('lesson_access')
          .delete()
          .eq('student_id', studentId)
          .eq('lesson_id', lessonId);
    }
  }

  @override
  Future<Map<String, int>> fetchAccessCounts(List<String> studentIds) async {
    if (studentIds.isEmpty) return const {};
    final rows = await _client
        .from('lesson_access')
        .select('lesson_id')
        .inFilter('student_id', studentIds);
    final counts = <String, int>{};
    for (final row in rows) {
      final id = row['lesson_id'] as String;
      counts[id] = (counts[id] ?? 0) + 1;
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
    if (studentIds.isEmpty) return;
    if (open) {
      await _client
          .from('lesson_access')
          .upsert(
            [
              for (final id in studentIds)
                {
                  'student_id': id,
                  'lesson_id': lessonId,
                  'granted_by': grantedBy,
                },
            ],
            onConflict: 'student_id,lesson_id',
            ignoreDuplicates: true,
          );
    } else {
      await _client
          .from('lesson_access')
          .delete()
          .eq('lesson_id', lessonId)
          .inFilter('student_id', studentIds);
    }
  }

  @override
  Future<List<Payment>> fetchPayments() async {
    final rows = await _client
        .from('payments')
        .select('id, student_id, period, amount, status, marked_at')
        .order('period', ascending: false);
    return [for (final row in rows) Payment.fromJson(row)];
  }

  @override
  Future<void> markPayment({
    required String studentId,
    required String period,
    required num amount,
    required PaymentStatus status,
    required String markedBy,
  }) async {
    await _client.from('payments').upsert({
      'student_id': studentId,
      'period': period,
      'amount': amount,
      'status': status.name,
      'marked_by': markedBy,
      'marked_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'student_id,period');
  }

  @override
  Future<List<Course>> fetchCourses() async {
    final rows = await _client.from('courses').select().order('name');
    return [for (final row in rows) Course.fromJson(row)];
  }

  @override
  Future<String> issueCertificate({
    required String studentId,
    required String courseId,
    required String issuedBy,
    required String teacherName,
    required String directorName,
  }) async {
    final row = await _client
        .from('certificates')
        .insert({
          'student_id': studentId,
          'course_id': courseId,
          'issued_by': issuedBy,
          'teacher_name_snapshot': teacherName,
          'director_name_snapshot': directorName,
        })
        .select('id')
        .single();
    return row['id'] as String;
  }

  @override
  Future<void> archiveStudent(String studentId, String? reason) =>
      _client.rpc<void>(
        'archive_student',
        params: {'p_student_id': studentId, 'p_reason': reason},
      );

  @override
  Future<void> unarchiveStudent(String studentId) => _client.rpc<void>(
    'unarchive_student',
    params: {'p_student_id': studentId},
  );

  @override
  Future<List<Person>> fetchTeachers() async {
    final rows = await _client
        .from('profiles')
        .select(_personColumns)
        .eq('role', 'teacher')
        .order('full_name');
    return [for (final row in rows) Person.fromJson(row)];
  }

  @override
  Future<void> assignTeacher(String studentId, String? teacherId) async {
    await _client
        .from('profiles')
        .update({'teacher_id': teacherId})
        .eq('id', studentId);
  }
}
