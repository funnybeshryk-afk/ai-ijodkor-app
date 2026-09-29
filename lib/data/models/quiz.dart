import 'lesson.dart';

/// One question of a lesson quiz as returned by the `get_lesson_quiz` RPC
/// (migration 0019). Never contains the correct answer.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.isMultipleChoice,
    required this.question,
    this.options = const [],
    this.questionRu,
    this.optionsRu,
  });

  final String id;
  final bool isMultipleChoice;
  final String question;

  /// Uzbek option texts — what is submitted and graded, always.
  final List<String> options;

  /// Optional Russian translation (platform migration 0020). [optionsRu], when
  /// present, has the same length and order as [options].
  final String? questionRu;
  final List<String>? optionsRu;

  String questionIn({required bool ru}) =>
      pickContent(question, questionRu, ru: ru);

  /// What the student reads for `options[index]`.
  String optionLabel(int index, {required bool ru}) {
    final translated = optionsRu;
    return pickContent(
      options[index],
      translated != null && translated.length == options.length
          ? translated[index]
          : null,
      ru: ru,
    );
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
    id: json['id'] as String,
    isMultipleChoice: json['type'] == 'multiple_choice',
    question: json['question'] as String,
    options: [
      for (final option in (json['options'] as List?) ?? const [])
        option.toString(),
    ],
    questionRu: json['question_ru'] as String?,
    optionsRu: json['options_ru'] is List
        ? [for (final o in json['options_ru'] as List) o.toString()]
        : null,
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
