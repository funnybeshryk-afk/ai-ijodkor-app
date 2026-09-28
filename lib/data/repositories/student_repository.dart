import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/lesson.dart';
import '../models/quiz.dart';
import '../models/student_records.dart';

/// Everything the student screens read and write. All calls run under the
/// student's own session, so RLS is the access control; the quiz goes
/// through the security-definer RPCs from migration 0019.
abstract class StudentRepository {
  /// Lessons granted to the student via `lesson_access`.
  Future<List<Lesson>> fetchLessons(String studentId);

  /// lesson id -> status
  Future<Map<String, ProgressStatus>> fetchProgress(String studentId);

  /// not_started -> viewed only; never downgrades a further status.
  Future<void> markViewed(String studentId, String lessonId);

  /// Self-completion, only offered for lessons without a quiz (same rule as
  /// updateLessonProgressAction on the web).
  Future<void> markCompleted(String studentId, String lessonId);

  Future<int> fetchPointsTotal(String studentId);

  Future<List<QuizQuestion>> fetchQuiz(String lessonId);

  /// question id -> answer
  Future<QuizResult> submitQuiz(String lessonId, Map<String, String> answers);

  /// Newest first.
  Future<List<HomeworkSubmission>> fetchHomework(String studentId);

  Future<void> submitHomework({
    required String studentId,
    required String lessonId,
    required String text,
  });

  Future<List<LeaderboardEntry>> fetchLeaderboard();

  /// Newest first.
  Future<List<Certificate>> fetchCertificates(String studentId);
}

class SupabaseStudentRepository implements StudentRepository {
  SupabaseStudentRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Lesson>> fetchLessons(String studentId) async {
    // RLS already limits a student to granted lessons; the explicit join on
    // lesson_access states that rule here too instead of relying on it.
    final rows = await _client
        .from('lessons')
        .select(
          // `*` rather than a column list: picks up the *_ru translations
          // (migration 0020) once applied without failing before that.
          '*, lesson_access!inner(student_id)',
        )
        .eq('lesson_access.student_id', studentId)
        .order('order_index');
    return [for (final row in rows) Lesson.fromJson(row)];
  }

  @override
  Future<Map<String, ProgressStatus>> fetchProgress(String studentId) async {
    final rows = await _client
        .from('lesson_progress')
        .select('lesson_id, status')
        .eq('student_id', studentId);
    return {
      for (final row in rows)
        row['lesson_id'] as String: ProgressStatus.parse(
          row['status'] as String?,
        ),
    };
  }

  Future<ProgressStatus?> _currentStatus(String studentId, String lessonId) =>
      _client
          .from('lesson_progress')
          .select('status')
          .eq('student_id', studentId)
          .eq('lesson_id', lessonId)
          .maybeSingle()
          .then(
            (row) => row == null ? null : ProgressStatus.parse(row['status']),
          );

  Future<void> _upsertStatus(
    String studentId,
    String lessonId,
    ProgressStatus status,
  ) => _client.from('lesson_progress').upsert({
    'student_id': studentId,
    'lesson_id': lessonId,
    'status': status.dbValue,
    'updated_at': DateTime.now().toUtc().toIso8601String(),
  }, onConflict: 'student_id,lesson_id');

  @override
  Future<void> markViewed(String studentId, String lessonId) async {
    final current = await _currentStatus(studentId, lessonId);
    if (current == null || current == ProgressStatus.notStarted) {
      await _upsertStatus(studentId, lessonId, ProgressStatus.viewed);
    }
  }

  @override
  Future<void> markCompleted(String studentId, String lessonId) =>
      _upsertStatus(studentId, lessonId, ProgressStatus.completed);

  @override
  Future<int> fetchPointsTotal(String studentId) async {
    final rows = await _client
        .from('points_ledger')
        .select('amount')
        .eq('student_id', studentId);
    return rows.fold<int>(
      0,
      (sum, row) => sum + (row['amount'] as num).toInt(),
    );
  }

  @override
  Future<List<QuizQuestion>> fetchQuiz(String lessonId) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'get_lesson_quiz',
        params: {'p_lesson_id': lessonId},
      );
      return [
        for (final row in rows)
          QuizQuestion.fromJson(Map<String, dynamic>.from(row as Map)),
      ];
    } on PostgrestException catch (e) {
      throw QuizException.fromMessage(e.message);
    }
  }

  @override
  Future<QuizResult> submitQuiz(
    String lessonId,
    Map<String, String> answers,
  ) async {
    try {
      final result = await _client.rpc<Map<String, dynamic>>(
        'submit_lesson_quiz',
        params: {'p_lesson_id': lessonId, 'p_answers': answers},
      );
      return QuizResult.fromJson(result);
    } on PostgrestException catch (e) {
      throw QuizException.fromMessage(e.message);
    }
  }

  @override
  Future<List<HomeworkSubmission>> fetchHomework(String studentId) async {
    final rows = await _client
        .from('homework_submissions')
        .select(
          'id, lesson_id, status, content_text, reviewer_notes, submitted_at, '
          'reviewed_at',
        )
        .eq('student_id', studentId)
        .order('submitted_at', ascending: false);
    return [for (final row in rows) HomeworkSubmission.fromJson(row)];
  }

  @override
  Future<void> submitHomework({
    required String studentId,
    required String lessonId,
    required String text,
  }) async {
    await _client.from('homework_submissions').insert({
      'student_id': studentId,
      'lesson_id': lessonId,
      'status': 'pending',
      'content_text': text,
    });
    // Submitting signals active work on the lesson — but never downgrade a
    // lesson that is already completed.
    final current = await _currentStatus(studentId, lessonId);
    if (current == null ||
        current == ProgressStatus.notStarted ||
        current == ProgressStatus.viewed) {
      await _upsertStatus(studentId, lessonId, ProgressStatus.inProgress);
    }
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    final rows = await _client.rpc<List<dynamic>>('get_class_leaderboard');
    return [
      for (final row in rows)
        LeaderboardEntry.fromJson(Map<String, dynamic>.from(row as Map)),
    ]..sort((a, b) => b.totalScore.compareTo(a.totalScore));
  }

  @override
  Future<List<Certificate>> fetchCertificates(String studentId) async {
    final rows = await _client
        .from('certificates')
        .select('id, issued_at, teacher_name_snapshot, courses(*)')
        .eq('student_id', studentId)
        .order('issued_at', ascending: false);
    return [for (final row in rows) Certificate.fromJson(row)];
  }
}
