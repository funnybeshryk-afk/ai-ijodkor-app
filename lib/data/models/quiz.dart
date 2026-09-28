/// One question of a lesson quiz as returned by the `get_lesson_quiz` RPC
/// (migration 0019). Never contains the correct answer.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.isMultipleChoice,
    required this.question,
    this.options = const [],
  });

  final String id;
  final bool isMultipleChoice;
  final String question;
  final List<String> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    isMultipleChoice: json['type'] == 'multiple_choice',
    question: json['question'] as String,
    options: [
      for (final option in (json['options'] as List?) ?? const [])
        option.toString(),
    ],
  );
}

/// Result of the `submit_lesson_quiz` RPC.
class QuizResult {
  const QuizResult({
    required this.passed,
    required this.correctCount,
    required this.total,
    required this.required,
    required this.correctById,
    this.nextLessonId,
  });

  final bool passed;
  final int correctCount;
  final int total;
  final int required;

  /// question id -> answered correctly
  final Map<String, bool> correctById;
  final String? nextLessonId;

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
    passed: json['passed'] as bool,
    correctCount: (json['correct_count'] as num).toInt(),
    total: (json['total'] as num).toInt(),
    required: (json['required'] as num).toInt(),
    correctById: {
      for (final r in (json['results'] as List? ?? const []))
        (r as Map)['assignment_id'] as String: r['correct'] as bool,
    },
    nextLessonId: json['next_lesson_id'] as String?,
  );
}

/// Error keys raised by the quiz RPCs (see 0019_lesson_quiz_rpc.sql).
enum QuizError { noAccess, archived, answerAll, other }

class QuizException implements Exception {
  const QuizException(this.error);

  final QuizError error;

  static QuizException fromMessage(String message) => QuizException(
    message.contains('no_access')
        ? QuizError.noAccess
        : message.contains('archived')
        ? QuizError.archived
        : message.contains('answer_all')
        ? QuizError.answerAll
        : QuizError.other,
  );
}
