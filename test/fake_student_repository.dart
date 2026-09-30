import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/lesson_section.dart';
import 'package:ai_ijodkor/data/models/quiz.dart';
import 'package:ai_ijodkor/data/models/student_records.dart';
import 'package:ai_ijodkor/data/repositories/student_repository.dart';

/// In-memory stand-in for Supabase. The quiz is graded here the same way
/// the `submit_lesson_quiz` RPC does it, so screens can be tested end to end.
class FakeStudentRepository implements StudentRepository {
  /// Every lesson of the curriculum, granted or not.
  final allLessons = <Lesson>[];

  /// Granted lesson ids (lesson_access).
  final access = <String>{};
  final progress = <String, ProgressStatus>{};
  int points = 0;

  /// lesson id -> questions; and question id -> correct answer.
  final quizzes = <String, List<QuizQuestion>>{};
  final correctAnswers = <String, String>{};

  final homework = <HomeworkSubmission>[];
  final leaderboard = <LeaderboardEntry>[];
  final certificates = <Certificate>[];

  /// Recorded calls, for assertions.
  final calls = <String>[];

  @override
  Future<List<Lesson>> fetchLessons(String studentId) async =>
      allLessons.where((l) => access.contains(l.id)).toList();

  @override
  Future<Map<String, ProgressStatus>> fetchProgress(String studentId) async =>
      Map.of(progress);

  @override
  Future<void> markViewed(String studentId, String lessonId) async {
    calls.add('viewed:$lessonId');
    if ((progress[lessonId] ?? ProgressStatus.notStarted) ==
        ProgressStatus.notStarted) {
      progress[lessonId] = ProgressStatus.viewed;
    }
  }

  @override
  Future<void> markCompleted(String studentId, String lessonId) async {
    calls.add('completed:$lessonId');
    progress[lessonId] = ProgressStatus.completed;
  }

  @override
  Future<int> fetchPointsTotal(String studentId) async => points;

  @override
  Future<List<QuizQuestion>> fetchQuiz(String lessonId) async {
    if (!access.contains(lessonId)) {
      throw const QuizException(QuizError.noAccess);
    }
    return quizzes[lessonId] ?? const [];
  }

  @override
  Future<QuizResult> submitQuiz(
    String lessonId,
    Map<String, String> answers,
  ) async {
    calls.add('quiz:$lessonId');
    final questions = quizzes[lessonId]!;
    final correct = {
      for (final q in questions)
        q.id:
            answers[q.id]!.trim().toLowerCase() ==
            correctAnswers[q.id]!.trim().toLowerCase(),
    };
    final count = correct.values.where((c) => c).length;
    final required = questions.length >= 4
        ? questions.length - 1
        : questions.length;
    String? next;
    if (count >= required) {
      progress[lessonId] = ProgressStatus.completed;
      final sorted = [
        for (final m in groupLessonsByModule(allLessons)) ...m.lessons,
      ];
      final i = sorted.indexWhere((l) => l.id == lessonId);
      if (i >= 0 && i + 1 < sorted.length) {
        next = sorted[i + 1].id;
        access.add(next);
      }
    }
    return QuizResult(
      passed: count >= required,
      correctCount: count,
      total: questions.length,
      required: required,
      correctById: correct,
      nextLessonId: next,
    );
  }

  /// lesson id -> sections / approved objectives.
  final sections = <String, List<LessonSection>>{};
  final objectives = <String, List<LessonObjective>>{};

  /// Makes fetchSections fail (error state).
  bool failSections = false;

  @override
  Future<List<LessonSection>> fetchSections(String lessonId) async {
    if (failSections) throw Exception('network');
    return sections[lessonId] ?? const [];
  }

  @override
  Future<List<LessonObjective>> fetchObjectives(String lessonId) async =>
      objectives[lessonId] ?? const [];

  @override
  Future<Uri> lessonMediaUrl(String path) async =>
      Uri.parse('https://storage.test/$path');

  @override
  Future<List<HomeworkSubmission>> fetchHomework(String studentId) async =>
      homework.reversed.toList();

  @override
  Future<void> submitHomework({
    required String studentId,
    required String lessonId,
    required String text,
  }) async {
    homework.add(
      HomeworkSubmission(
        id: 'hw${homework.length}',
        lessonId: lessonId,
        status: HomeworkStatus.pending,
        contentText: text,
        submittedAt: DateTime(2026, 9, 28),
      ),
    );
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard() async => leaderboard;

  @override
  Future<List<Certificate>> fetchCertificates(String studentId) async =>
      certificates;
}
