import 'lesson.dart';

/// «Takrorlash» (platform migration 0032): the daily review. The server picks
/// the questions, checks the answers and keeps the schedule; the app shows them.

/// `get_review_summary()`: the numbers for the card on the home screen.
class ReviewSummary {
  const ReviewSummary({
    required this.dueNow,
    required this.dueTotal,
    required this.reviewedToday,
    required this.queueSize,
    required this.dayDone,
  });

  static const empty = ReviewSummary(
    dueNow: 0,
    dueTotal: 0,
    reviewedToday: 0,
    queueSize: 0,
    dayDone: false,
  );

  /// Questions waiting now (at most 10 a day, minus those done today).
  final int dueNow;
  final int dueTotal;
  final int reviewedToday;

  /// How many tasks are in the review queue at all.
  final int queueSize;
  final bool dayDone;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => ReviewSummary(
    dueNow: (json['due_now'] as num).toInt(),
    dueTotal: (json['due_total'] as num).toInt(),
    reviewedToday: (json['reviewed_today'] as num).toInt(),
    queueSize: (json['queue_size'] as num).toInt(),
    dayDone: json['day_done'] == true,
  );
}

/// One review question: like a lesson task, never an answer.
class ReviewQuestion {
  const ReviewQuestion({
    required this.taskId,
    required this.type,
    required this.promptUz,
    this.promptRu,
    this.payload = const {},
  });

  final String taskId;

  /// single_choice | multi_choice | short_text | order | match
  final String type;
  final String promptUz;
  final String? promptRu;

  /// options / items / left / right as lists of `{uz, ru}`.
  final Map<String, dynamic> payload;

  String promptIn({required bool ru}) =>
      pickContent(promptUz, promptRu, ru: ru);

  /// The `{uz, ru}` texts of a payload list (empty when absent).
  List<String> texts(String key, {required bool ru}) {
    final raw = payload[key];
    if (raw is! List) return const [];
    return [
      for (final e in raw)
        if (e is Map)
          pickContent((e['uz'] as String?) ?? '', e['ru'] as String?, ru: ru),
    ];
  }

  factory ReviewQuestion.fromJson(Map<String, dynamic> json) => ReviewQuestion(
    taskId: json['task_id'] as String,
    type: json['type'] as String,
    promptUz: json['prompt_uz'] as String,
    promptRu: json['prompt_ru'] as String?,
    payload: Map<String, dynamic>.from((json['payload'] as Map?) ?? const {}),
  );
}

class DailyReview {
  const DailyReview({
    required this.reviewedToday,
    required this.dueTotal,
    required this.questions,
  });

  static const empty = DailyReview(
    reviewedToday: 0,
    dueTotal: 0,
    questions: [],
  );

  final int reviewedToday;
  final int dueTotal;
  final List<ReviewQuestion> questions;

  factory DailyReview.fromJson(Map<String, dynamic> json) => DailyReview(
    reviewedToday: (json['reviewed_today'] as num).toInt(),
    dueTotal: (json['due_total'] as num).toInt(),
    questions: [
      for (final q in (json['questions'] as List? ?? const []))
        ReviewQuestion.fromJson(Map<String, dynamic>.from(q as Map)),
    ],
  );
}

/// `submit_review()`: only the verdict and where the day stands.
class ReviewResult {
  const ReviewResult({
    required this.correct,
    required this.intervalDays,
    required this.reviewedToday,
    required this.remainingDue,
    required this.dayDone,
  });

  final bool correct;
  final int intervalDays;
  final int reviewedToday;
  final int remainingDue;
  final bool dayDone;

  factory ReviewResult.fromJson(Map<String, dynamic> json) => ReviewResult(
    correct: json['correct'] == true,
    intervalDays: (json['interval_days'] as num).toInt(),
    reviewedToday: (json['reviewed_today'] as num).toInt(),
    remainingDue: (json['remaining_due'] as num).toInt(),
    dayDone: json['day_done'] == true,
  );
}

/// The review failed for a reason the student can be told about.
enum ReviewError { notDue, dailyLimit, invalidAnswer, other }

class ReviewException implements Exception {
  const ReviewException(this.error);

  final ReviewError error;

  /// Maps the stable message keys the RPC raises.
  factory ReviewException.fromMessage(String message) =>
      ReviewException(switch (message) {
        'not_due' => ReviewError.notDue,
        'daily_limit' => ReviewError.dailyLimit,
        'invalid_answer' => ReviewError.invalidAnswer,
        _ => ReviewError.other,
      });
}
