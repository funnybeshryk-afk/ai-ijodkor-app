import 'dart:convert';
import 'dart:io';

import 'package:ai_ijodkor/core/locale_controller.dart';
import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/models/review.dart';
import 'package:ai_ijodkor/data/review_schedule.dart';
import 'package:ai_ijodkor/features/student/task_answer_input.dart';
import 'package:ai_ijodkor/core/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Map<String, dynamic> _loc(String uz, [String? ru]) => {
  'uz': uz,
  'ru': ru ?? uz,
};

ReviewQuestion _single(String id, String prompt) => ReviewQuestion(
  taskId: id,
  type: 'single_choice',
  promptUz: prompt,
  promptRu: '$prompt (ru)',
  payload: {
    'options': [_loc('Birinchi', 'Первый'), _loc('Ikkinchi', 'Второй')],
  },
);

void main() {
  group('schedule helpers (the platform\'s cases)', () {
    final cases = jsonDecode(
      File('test/fixtures/review-schedule-cases.json').readAsStringSync(),
    ) as Map<String, dynamic>;

    test('tashkentDayKey', () {
      for (final c in cases['dayKeys'] as List) {
        final m = c as Map<String, dynamic>;
        expect(
          tashkentDayKey(DateTime.parse(m['at'] as String)),
          m['expected'],
          reason: m['name'] as String,
        );
      }
    });

    test('streakFromDayKeys', () {
      for (final c in cases['streak'] as List) {
        final m = c as Map<String, dynamic>;
        expect(
          streakFromDayKeys({
            for (final d in m['days'] as List) d as String,
          }, DateTime.parse(m['now'] as String)),
          m['expected'],
          reason: m['name'] as String,
        );
      }
    });
  });

  group('models', () {
    test('summary and daily review parse the RPC JSON', () {
      final s = ReviewSummary.fromJson({
        'due_now': 3,
        'due_total': 5,
        'reviewed_today': 2,
        'queue_size': 9,
        'day_done': false,
      });
      expect(
        (s.dueNow, s.dueTotal, s.reviewedToday, s.queueSize, s.dayDone),
        (3, 5, 2, 9, false),
      );

      final d = DailyReview.fromJson({
        'reviewed_today': 1,
        'due_total': 2,
        'questions': [
          {
            'task_id': 'a',
            'type': 'single_choice',
            'prompt_uz': 'Savol',
            'prompt_ru': null,
            'payload': {
              'options': [_loc('A', 'А')],
            },
            'difficulty': 1,
          },
        ],
      });
      expect(d.questions.single.promptIn(ru: true), 'Savol');
      expect(d.questions.single.texts('options', ru: true), ['А']);
      expect(d.questions.single.texts('options', ru: false), ['A']);
      expect(d.questions.single.texts('missing', ru: false), isEmpty);
    });

    test('the RPC error keys map to errors', () {
      expect(ReviewException.fromMessage('not_due').error, ReviewError.notDue);
      expect(
        ReviewException.fromMessage('daily_limit').error,
        ReviewError.dailyLimit,
      );
      expect(ReviewException.fromMessage('boom').error, ReviewError.other);
    });
  });

  group('TaskAnswer', () {
    test('is null while incomplete and encodes each type', () {
      final single = ReviewQuestion(
        taskId: 's',
        type: 'single_choice',
        promptUz: 'x',
      );
      final a = TaskAnswer.initial(single);
      expect(a.toJson('single_choice'), isNull);
      a.single = 1;
      expect(a.toJson('single_choice'), {'index': 1});

      final multi = TaskAnswer.initial(single)..multi.addAll([2, 0]);
      expect(multi.toJson('multi_choice'), {
        'indexes': [2, 0],
      });
      expect(TaskAnswer.initial(single).toJson('multi_choice'), isNull);

      final text = TaskAnswer.initial(single)..text = '  ';
      expect(text.toJson('short_text'), isNull);
      text.text = 'for';
      expect(text.toJson('short_text'), {'text': 'for'});

      final order = ReviewQuestion(
        taskId: 'o',
        type: 'order',
        promptUz: 'x',
        payload: {
          'items': [_loc('a'), _loc('b'), _loc('c')],
        },
      );
      expect(TaskAnswer.initial(order).toJson('order'), {
        'order': [0, 1, 2],
      });

      final match = ReviewQuestion(
        taskId: 'm',
        type: 'match',
        promptUz: 'x',
        payload: {
          'left': [_loc('l1'), _loc('l2')],
          'right': [_loc('r1'), _loc('r2')],
        },
      );
      final m = TaskAnswer.initial(match);
      expect(m.toJson('match'), isNull);
      m.match[0] = 1;
      expect(m.toJson('match'), isNull);
      m.match[1] = 0;
      expect(m.toJson('match'), {
        'pairs': [
          [0, 1],
          [1, 0],
        ],
      });
    });
  });

  group('screen', () {
    late FakeAuthRepository auth;
    late FakeProfileRepository profiles;
    late FakeStudentRepository repo;

    setUp(() {
      auth = FakeAuthRepository()..users['kid@test.uz'] = 'u1';
      profiles = FakeProfileRepository()
        ..roles['u1'] = UserRole.student
        ..names['u1'] = 'Karimov Ali';
      repo = FakeStudentRepository()
        ..allLessons.add(
          const Lesson(
            id: 'l1',
            title: 'Dars',
            module: 'Python asoslari',
            orderIndex: 1,
          ),
        )
        ..access.add('l1');
    });

    Future<void> start(WidgetTester tester, {String? locale}) async {
      await pumpApp(
        tester,
        auth: auth,
        profiles: profiles,
        student: repo,
        prefs: {LocaleController.storageKey: ?locale},
      );
      await tester.enterText(byKey('login_email'), 'kid@test.uz');
      await tester.enterText(byKey('login_password'), auth.password);
      await tester.tap(byKey('login_submit'));
      await tester.pumpAndSettle();
    }

    void queue({int dueNow = 2, bool done = false, int reviewed = 0}) {
      repo
        ..reviewSummary = ReviewSummary(
          dueNow: dueNow,
          dueTotal: dueNow,
          reviewedToday: reviewed,
          queueSize: 5,
          dayDone: done,
        )
        ..dailyReview = DailyReview(
          reviewedToday: reviewed,
          dueTotal: dueNow,
          questions: [
            _single('t1', 'Birinchi savol'),
            _single('t2', 'Ikkinchi savol'),
          ].take(dueNow).toList(),
        )
        ..reviewRight.addAll({
          't1': {'index': 0},
          't2': {'index': 1},
        });
    }

    testWidgets(
      'the home card says how many questions wait, and opens the review',
      (tester) async {
        queue();
        await start(tester);
        expect(find.text('Bugungi takrorlash: 2 ta savol'), findsOneWidget);
        await tester.tap(byKey('review_card'));
        await tester.pumpAndSettle();
        expect(find.text('Savol 1 / 2'), findsOneWidget);
        expect(find.text('Birinchi savol'), findsOneWidget);
      },
    );

    testWidgets('no card while the queue is empty', (tester) async {
      await start(tester);
      expect(byKey('review_card'), findsNothing);
    });

    testWidgets('the card says the day is done', (tester) async {
      queue(dueNow: 0, done: true, reviewed: 3);
      await start(tester);
      expect(find.text('Bugungi takrorlash bajarildi'), findsOneWidget);
    });

    testWidgets('going through the review: verdicts, the end, the streak', (
      tester,
    ) async {
      queue();
      repo.practiceStreak = 4;
      await start(tester);
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();

      // The check button waits for an answer.
      expect(
        tester
            .widget<FilledButton>(
              find.descendant(
                of: byKey('review_check'),
                matching: find.byType(FilledButton),
              ),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(byKey('option_0')); // right
      await tester.pumpAndSettle();
      await tester.tap(byKey('review_check'));
      await tester.pumpAndSettle();
      expect(find.text('To‘g‘ri!'), findsOneWidget);
      await tester.tap(byKey('review_next'));
      await tester.pumpAndSettle();

      expect(find.text('Savol 2 / 2'), findsOneWidget);
      await tester.tap(byKey('option_0')); // wrong
      await tester.pumpAndSettle();
      await tester.tap(byKey('review_check'));
      await tester.pumpAndSettle();
      expect(find.text('Noto‘g‘ri. Bu savol ertaga qaytadi.'), findsOneWidget);
      expect(repo.calls.where((c) => c.startsWith('review:')), [
        'review:t1',
        'review:t2',
      ]);

      await tester.tap(byKey('review_next')); // «Yakunlash»
      await tester.pumpAndSettle();
      expect(byKey('review_done'), findsOneWidget);
      expect(find.text('2 tadan 1 to‘g‘ri'), findsOneWidget);
      expect(find.text('4 kun ketma-ket'), findsOneWidget);
    });

    testWidgets('an empty queue explains itself and points to the lessons', (
      tester,
    ) async {
      await start(tester); // queue empty: no card, so open the screen by route
      GoRouter.of(tester.element(find.byType(Scaffold).first))
          .push(Routes.studentReview);
      await tester.pumpAndSettle();
      expect(find.text('Takrorlash hali yo‘q'), findsOneWidget);
      expect(find.text('Darslarga o‘tish'), findsOneWidget);
    });

    testWidgets('nothing is due today, but the queue is not empty', (
      tester,
    ) async {
      repo.reviewSummary = const ReviewSummary(
        dueNow: 0,
        dueTotal: 0,
        reviewedToday: 0,
        queueSize: 5,
        dayDone: false,
      );
      await start(tester);
      expect(find.text('Bugun takrorlash yo‘q'), findsOneWidget); // the card
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bugun takrorlash yo‘q'),
        findsOneWidget,
      ); // the screen (the card is behind it)
      expect(
        find.text(
          'Bugun takrorlanadigan savol yo‘q. Keyingilari o‘z vaqtida keladi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('the day is done', (tester) async {
      queue(dueNow: 0, done: true, reviewed: 3);
      repo.dailyReview = const DailyReview(
        reviewedToday: 3,
        dueTotal: 0,
        questions: [],
      );
      await start(tester);
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();
      expect(find.text('Bugun hammasi tayyor'), findsOneWidget);
      expect(
        find.text(
          'Bugun 3 ta savol takrorlandi. Ertaga yangi savollar kutadi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a failed load offers a retry', (tester) async {
      queue();
      await start(tester);
      repo.failReview = true;
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();
      expect(find.text('Qayta urinish'), findsOneWidget);
      repo.failReview = false;
      await tester.tap(find.text('Qayta urinish'));
      await tester.pumpAndSettle();
      expect(find.text('Savol 1 / 2'), findsOneWidget);
    });

    testWidgets('a daily-limit error is explained', (tester) async {
      queue();
      repo.reviewFailure = ReviewError.dailyLimit;
      await start(tester);
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('option_0'));
      await tester.pumpAndSettle();
      await tester.tap(byKey('review_check'));
      await tester.pumpAndSettle();
      expect(
        find.text('Bugungi 10 ta takrorlash bajarildi. Ertaga davom eting.'),
        findsOneWidget,
      );
    });

    testWidgets('shows the Russian texts', (tester) async {
      queue();
      await start(tester, locale: 'ru');
      expect(find.text('Повторение на сегодня: 2 вопросов'), findsOneWidget);
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();
      expect(find.text('Вопрос 1 / 2'), findsOneWidget);
      expect(find.text('Первый'), findsOneWidget);
      expect(find.text('Birinchi savol (ru)'), findsOneWidget);
    });

    testWidgets('all five question types can be answered', (tester) async {
      final order = ReviewQuestion(
        taskId: 'o',
        type: 'order',
        promptUz: 'Tartib',
        payload: {
          'items': [_loc('Bir'), _loc('Ikki')],
        },
      );
      final match = ReviewQuestion(
        taskId: 'm',
        type: 'match',
        promptUz: 'Juftlik',
        payload: {
          'left': [_loc('Chap')],
          'right': [_loc('O‘ng A'), _loc('O‘ng B')],
        },
      );
      final multi = ReviewQuestion(
        taskId: 'mc',
        type: 'multi_choice',
        promptUz: 'Ko‘p javob',
        payload: {
          'options': [_loc('Bir'), _loc('Ikki')],
        },
      );
      final text = ReviewQuestion(
        taskId: 'tx',
        type: 'short_text',
        promptUz: 'Matn',
      );
      repo
        ..reviewSummary = const ReviewSummary(
          dueNow: 4,
          dueTotal: 4,
          reviewedToday: 0,
          queueSize: 4,
          dayDone: false,
        )
        ..dailyReview = DailyReview(
          reviewedToday: 0,
          dueTotal: 4,
          questions: [multi, text, order, match],
        )
        ..reviewRight.addAll({
          'mc': {
            'indexes': [0, 1],
          },
          'tx': {'text': 'for'},
          'o': {
            'order': [1, 0],
          },
          'm': {
            'pairs': [
              [0, 1],
            ],
          },
        });
      await start(tester);
      await tester.tap(byKey('review_card'));
      await tester.pumpAndSettle();

      Future<void> checkAndNext() async {
        await tester.tap(byKey('review_check'));
        await tester.pumpAndSettle();
        await tester.tap(byKey('review_next'));
        await tester.pumpAndSettle();
      }

      await tester.tap(byKey('option_0'));
      await tester.tap(byKey('option_1'));
      await tester.pumpAndSettle();
      await checkAndNext();

      await tester.enterText(byKey('answer_text'), 'for');
      await tester.pumpAndSettle();
      await checkAndNext();

      await tester.tap(byKey('down_0')); // Bir goes below Ikki
      await tester.pumpAndSettle();
      await checkAndNext();

      await tester.tap(byKey('match_0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('O‘ng B').last);
      await tester.pumpAndSettle();
      await tester.tap(byKey('review_check'));
      await tester.pumpAndSettle();
      expect(find.text('To‘g‘ri!'), findsOneWidget);
    });
  });
}
