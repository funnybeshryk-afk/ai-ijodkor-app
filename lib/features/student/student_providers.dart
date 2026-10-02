import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/homework_files.dart';
import '../../data/models/lesson.dart';
import '../../data/models/lesson_section.dart';
import '../../data/models/quiz.dart';
import '../../data/models/review.dart';
import '../../data/models/skills.dart';
import '../../data/models/student_records.dart';
import '../../data/providers.dart';
import '../../data/repositories/student_repository.dart';
import 'tracks.dart';

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

/// «Takrorlash»: the numbers for the card on the home screen.
final reviewSummaryProvider = FutureProvider<ReviewSummary>((ref) async {
  final (repo, _) = await _studentContext(ref);
  return repo.fetchReviewSummary();
});

/// Today's review questions.
final dailyReviewProvider = FutureProvider<DailyReview>((ref) async {
  final (repo, _) = await _studentContext(ref);
  return repo.fetchDailyReview();
});

/// Days in a row with a practice session (the review counts too).
final practiceStreakProvider = FutureProvider<int>((ref) async {
  final (repo, id) = await _studentContext(ref);
  return repo.fetchPracticeStreak(id);
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

  /// One review answer. The providers are NOT refreshed here (the screen would
  /// swap the session for «all done» under the student before the verdict is
  /// seen); [finishReview] does it when the student leaves the last question.
  Future<ReviewResult> submitReview(
    String taskId,
    Map<String, dynamic> answer, {
    int? durationMs,
  }) async {
    final (repo, _) = await _ctx;
    return repo.submitReview(taskId, answer, durationMs: durationMs);
  }

  void finishReview() {
    _ref
      ..invalidate(reviewSummaryProvider)
      ..invalidate(dailyReviewProvider)
      ..invalidate(practiceStreakProvider);
  }

  Future<void> submitHomework(
    String lessonId,
    String text, {
    HomeworkAttachment? attachment,
  }) async {
    final (repo, id) = await _ctx;
    await repo.submitHomework(
      studentId: id,
      lessonId: lessonId,
      text: text,
      attachment: attachment,
    );
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

/// «Ko'nikmalar»: objectives by direction with the student's level.
final skillsProvider = FutureProvider<SkillsOverview>((ref) async {
  final (repo, id) = await _studentContext(ref);
  final sources = await repo.fetchSkillSources(id);
  return buildSkills(
    lessons: sources.lessons,
    links: sources.links,
    objectives: sources.objectives,
    mastery: sources.mastery,
    trackOrder: [for (final t in Track.values) t.name],
    trackOf: (module) => Track.ofModule(module)?.name,
  );
});
