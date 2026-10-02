import 'package:supabase_flutter/supabase_flutter.dart';

import '../homework_files.dart';
import '../models/lesson.dart';
import '../models/lesson_section.dart';
import '../models/quiz.dart';
import '../models/review.dart';
import '../review_schedule.dart';
import '../models/skills.dart';
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

  /// The lesson's sections in order (RLS: only granted lessons). Empty when
  /// the lesson has none — or before platform migration 0023 is applied —
  /// and the screen then falls back to content_url.
  Future<List<LessonSection>> fetchSections(String lessonId);

  /// Objectives a teacher has approved (the AI draft is never shown).
  Future<List<LessonObjective>> fetchObjectives(String lessonId);

  /// What «Ko'nikmalar» shows: the student's mastery rows, the objectives and
  /// their lesson links (platform migration 0029). Grouped by buildSkills.
  Future<SkillSources> fetchSkillSources(String studentId);

  /// «Takrorlash» (platform migration 0032): the numbers for the home card.
  Future<ReviewSummary> fetchReviewSummary();

  /// Up to 10 questions for today, oldest debts first, without answers.
  Future<DailyReview> fetchDailyReview();

  /// One review answer; the server checks it and reschedules the task.
  /// Throws [ReviewException].
  Future<ReviewResult> submitReview(
    String taskId,
    Map<String, dynamic> answer, {
    int? durationMs,
  });

  /// Consecutive days with a practice session (trainer_sessions, Tashkent days).
  Future<int> fetchPracticeStreak(String studentId);

  /// Short-lived link to a `lesson-media` object (pictures, videos).
  Future<Uri> lessonMediaUrl(String path);

  /// question id -> answer
  Future<QuizResult> submitQuiz(String lessonId, Map<String, String> answers);

  /// Newest first.
  Future<List<HomeworkSubmission>> fetchHomework(String studentId);

  /// [attachment] is uploaded first to the student's own folder of the
  /// `homework-files` bucket (Storage RLS, migration 0026).
  Future<void> submitHomework({
    required String studentId,
    required String lessonId,
    required String text,
    HomeworkAttachment? attachment,
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
  Future<List<LessonSection>> fetchSections(String lessonId) async {
    try {
      final rows = await _client
          .from('lesson_sections')
          .select('id, order_index, kind, body_uz, body_ru, media_path')
          .eq('lesson_id', lessonId)
          .order('order_index');
      return [for (final row in rows) ?LessonSection.fromJson(row)];
    } on PostgrestException catch (e) {
      // 42P01: the table isn't there yet (migration 0023 not applied).
      if (e.code == '42P01' || e.code == 'PGRST205') return const [];
      rethrow;
    }
  }

  @override
  Future<List<LessonObjective>> fetchObjectives(String lessonId) async {
    try {
      final rows = await _client
          .from('lesson_objectives')
          .select('learning_objectives(code, title_uz, title_ru)')
          .eq('lesson_id', lessonId)
          .eq('status', 'approved');
      return [
        for (final row in rows)
          if (row['learning_objectives'] case final Map<String, dynamic> o)
            LessonObjective(
              code: o['code'] as String,
              titleUz: o['title_uz'] as String,
              titleRu: o['title_ru'] as String?,
            ),
      ]..sort((a, b) => a.code.compareTo(b.code));
    } on PostgrestException catch (e) {
      if (e.code == '42P01' || e.code == 'PGRST205') return const [];
      rethrow;
    }
  }

  @override
  Future<SkillSources> fetchSkillSources(String studentId) async {
    final lessons = await fetchLessons(studentId);
    try {
      final mastery = await _client
          .from('objective_mastery')
          .select('objective_id, level, attempts_count, solved_count')
          .eq('student_id', studentId);
      final objectives = await _client
          .from('learning_objectives')
          .select('id, code, title_uz, title_ru');
      // RLS limits the links to lessons the student has.
      final links = await _client
          .from('lesson_objectives')
          .select('lesson_id, objective_id, status');
      return SkillSources(
        lessons: lessons,
        links: [
          for (final row in links)
            ObjectiveLink(
              lessonId: row['lesson_id'] as String,
              objectiveId: row['objective_id'] as String,
              approved: row['status'] == 'approved',
            ),
        ],
        objectives: [
          for (final row in objectives)
            Objective(
              id: row['id'] as String,
              code: row['code'] as String,
              titleUz: row['title_uz'] as String,
              titleRu: row['title_ru'] as String?,
            ),
        ],
        mastery: [for (final row in mastery) Mastery.fromJson(row)],
      );
    } on PostgrestException catch (e) {
      // 42P01: the tables aren't there yet (migration 0029 not applied).
      if (e.code == '42P01' || e.code == 'PGRST205') return SkillSources.empty;
      rethrow;
    }
  }

  @override
  Future<ReviewSummary> fetchReviewSummary() async {
    try {
      final data = await _client.rpc<dynamic>('get_review_summary');
      return ReviewSummary.fromJson(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      // 42883 / PGRST202: the function isn't there yet (migration 0032).
      if (e.code == '42883' || e.code == 'PGRST202') return ReviewSummary.empty;
      rethrow;
    }
  }

  @override
  Future<DailyReview> fetchDailyReview() async {
    try {
      final data = await _client.rpc<dynamic>('get_daily_review');
      return DailyReview.fromJson(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      if (e.code == '42883' || e.code == 'PGRST202') return DailyReview.empty;
      rethrow;
    }
  }

  @override
  Future<ReviewResult> submitReview(
    String taskId,
    Map<String, dynamic> answer, {
    int? durationMs,
  }) async {
    try {
      final data = await _client.rpc<dynamic>(
        'submit_review',
        params: {
          'p_task_id': taskId,
          'p_answer': answer,
          'p_duration_ms': durationMs,
        },
      );
      return ReviewResult.fromJson(Map<String, dynamic>.from(data as Map));
    } on PostgrestException catch (e) {
      throw ReviewException.fromMessage(e.message);
    }
  }

  @override
  Future<int> fetchPracticeStreak(String studentId) async {
    final rows = await _client
        .from('trainer_sessions')
        .select('played_at')
        .eq('student_id', studentId);
    final days = {
      for (final row in rows)
        if (DateTime.tryParse((row['played_at'] as String?) ?? '')
            case final at?)
          tashkentDayKey(at),
    };
    return streakFromDayKeys(days, DateTime.now());
  }

  @override
  Future<Uri> lessonMediaUrl(String path) async => Uri.parse(
    await _client.storage.from('lesson-media').createSignedUrl(path, 60 * 60),
  );

  @override
  Future<List<HomeworkSubmission>> fetchHomework(String studentId) async {
    final rows = await _client
        .from('homework_submissions')
        .select(
          'id, lesson_id, status, content_text, file_url, reviewer_notes, '
          'submitted_at, reviewed_at',
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
    HomeworkAttachment? attachment,
  }) async {
    String? filePath;
    if (attachment != null) {
      filePath = homeworkObjectPath(studentId, attachment.name, randomUuid());
      await _client.storage
          .from(homeworkBucket)
          .uploadBinary(
            filePath,
            attachment.bytes,
            fileOptions: FileOptions(
              contentType: homeworkContentType(attachment.name),
              upsert: false,
            ),
          );
    }
    await _client.from('homework_submissions').insert({
      'student_id': studentId,
      'lesson_id': lessonId,
      'status': 'pending',
      'content_text': text,
      'file_url': ?filePath,
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
