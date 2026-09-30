import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/lesson.dart';
import '../../data/models/lesson_section.dart';
import '../../data/models/quiz.dart';
import '../../data/models/student_records.dart';
import '../../data/providers.dart';
import '../../data/repositories/student_repository.dart';

/// Repository + signed-in student id; throws if either is missing, which
/// only happens outside the student area (the router keeps us out).
Future<(StudentRepository, String)> _studentContext(Ref ref) async {
  final repo = ref.watch(studentRepositoryProvider);
  final userId = await ref.watch(currentUserIdProvider.future);
  if (repo == null || userId == null) {
    throw StateError('No signed-in student');
  }
  return (repo, userId);
}

final lessonsProvider = FutureProvider<List<Lesson>>((ref) async {
  final (repo, id) = await _studentContext(ref);
  return repo.fetchLessons(id);
});

final progressProvider = FutureProvider<Map<String, ProgressStatus>>((
  ref,
) async {
  final (repo, id) = await _studentContext(ref);
  return repo.fetchProgress(id);
});

final pointsProvider = FutureProvider<int>((ref) async {
  final (repo, id) = await _studentContext(ref);
  return repo.fetchPointsTotal(id);
});

final homeworkProvider = FutureProvider<List<HomeworkSubmission>>((ref) async {
  final (repo, id) = await _studentContext(ref);
  return repo.fetchHomework(id);
});

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final (repo, _) = await _studentContext(ref);
  return repo.fetchLeaderboard();
});

final certificatesProvider = FutureProvider<List<Certificate>>((ref) async {
  final (repo, id) = await _studentContext(ref);
  return repo.fetchCertificates(id);
});

/// Questions of one lesson's quiz (empty list = the lesson has no quiz).
final quizProvider = FutureProvider.family<List<QuizQuestion>, String>((
  ref,
  lessonId,
) async {
  final (repo, _) = await _studentContext(ref);
  return repo.fetchQuiz(lessonId);
});

/// Write operations; each refreshes the providers it affects.
class StudentActions {
  StudentActions(this._ref);

  final Ref _ref;

  Future<(StudentRepository, String)> get _ctx => _studentContext(_ref);

  Future<void> markViewed(String lessonId) async {
    final (repo, id) = await _ctx;
    await repo.markViewed(id, lessonId);
    _ref.invalidate(progressProvider);
  }

  Future<void> markCompleted(String lessonId) async {
    final (repo, id) = await _ctx;
    await repo.markCompleted(id, lessonId);
    _ref.invalidate(progressProvider);
  }

  Future<QuizResult> submitQuiz(
    String lessonId,
    Map<String, String> answers,
  ) async {
    final (repo, _) = await _ctx;
    final result = await repo.submitQuiz(lessonId, answers);
    if (result.passed) {
      _ref.invalidate(progressProvider);
      _ref.invalidate(lessonsProvider);
    }
    return result;
  }

  Future<void> submitHomework(String lessonId, String text) async {
    final (repo, id) = await _ctx;
    await repo.submitHomework(studentId: id, lessonId: lessonId, text: text);
    _ref.invalidate(homeworkProvider);
    _ref.invalidate(progressProvider);
  }
}

final studentActionsProvider = Provider<StudentActions>(StudentActions.new);

final lessonSectionsProvider =
    FutureProvider.family<List<LessonSection>, String>((ref, lessonId) async {
      final (repo, _) = await _studentContext(ref);
      return repo.fetchSections(lessonId);
    });

final lessonObjectivesProvider =
    FutureProvider.family<List<LessonObjective>, String>((ref, lessonId) async {
      final (repo, _) = await _studentContext(ref);
      return repo.fetchObjectives(lessonId);
    });

final lessonMediaUrlProvider = FutureProvider.family<Uri, String>((
  ref,
  path,
) async {
  final (repo, _) = await _studentContext(ref);
  return repo.lessonMediaUrl(path);
});
