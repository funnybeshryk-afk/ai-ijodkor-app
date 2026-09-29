import 'dart:convert';

import 'package:ai_ijodkor/core/platform_session.dart';
import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/models/quiz.dart';
import 'package:flutter_test/flutter_test.dart';

Lesson _lesson(String id, String module, int order) =>
    Lesson(id: id, title: id, module: module, orderIndex: order);

void main() {
  group('groupLessonsByModule', () {
    test('track modules first, then others by first appearance', () {
      final groups = groupLessonsByModule([
        _lesson('x1', 'Maxsus', 0),
        _lesson('p2', 'Python asoslari', 2),
        _lesson('p1', 'Python asoslari', 1),
        _lesson('k1', 'Kompyuter asoslari', 5),
      ]);
      expect(groups.map((g) => g.name), [
        'Kompyuter asoslari',
        'Python asoslari',
        'Maxsus',
      ]);
      expect(groups[1].lessons.map((l) => l.id), ['p1', 'p2']);
    });

    test('nextLessonToStudy skips completed lessons', () {
      final lessons = [
        _lesson('k1', 'Kompyuter asoslari', 1),
        _lesson('k2', 'Kompyuter asoslari', 2),
      ];
      expect(nextLessonToStudy(lessons, {})?.id, 'k1');
      expect(
        nextLessonToStudy(lessons, {'k1': ProgressStatus.completed})?.id,
        'k2',
      );
      expect(
        nextLessonToStudy(lessons, {
          'k1': ProgressStatus.completed,
          'k2': ProgressStatus.completed,
        }),
        isNull,
      );
    });
  });

  test('ProgressStatus.parse maps db values', () {
    expect(ProgressStatus.parse('in_progress'), ProgressStatus.inProgress);
    expect(ProgressStatus.parse('bogus'), ProgressStatus.notStarted);
  });

  test('Profile.givenName drops the surname', () {
    expect(
      const Profile(id: 'a', role: null, fullName: 'Karimov Ali').givenName,
      'Ali',
    );
    expect(
      const Profile(id: 'a', role: null, fullName: 'Ali').givenName,
      'Ali',
    );
  });

  group('quiz', () {
    test('QuizResult.fromJson reads the RPC payload', () {
      final result = QuizResult.fromJson({
        'passed': true,
        'correct_count': 3,
        'total': 4,
        'required': 3,
        'results': [
          {'assignment_id': 'a', 'correct': true},
          {'assignment_id': 'b', 'correct': false},
        ],
        'next_lesson_id': 'n',
      });
      expect(result.passed, isTrue);
      expect(result.correctById, {'a': true, 'b': false});
      expect(result.nextLessonId, 'n');
    });

    test('QuizQuestion has no correct answer field and parses options', () {
      final q = QuizQuestion.fromJson({
        'id': 'q',
        'type': 'multiple_choice',
        'question': '?',
        'options': ['a', 'b'],
        'order_index': 0,
      });
      expect(q.isMultipleChoice, isTrue);
      expect(q.options, ['a', 'b']);
    });

    test('QuizException maps RPC error keys', () {
      expect(QuizException.fromMessage('no_access').error, QuizError.noAccess);
      expect(QuizException.fromMessage('archived').error, QuizError.archived);
      expect(
        QuizException.fromMessage('answer_all').error,
        QuizError.answerAll,
      );
      expect(QuizException.fromMessage('boom').error, QuizError.other);
    });
  });

  group('PlatformSessionCookies', () {
    const url = 'https://abcdefgh.supabase.co';

    String decode(Map<String, String> cookies) {
      final joined = cookies.values.join();
      expect(joined, startsWith('base64-'));
      return utf8.decode(
        base64Url.decode(base64Url.normalize(joined.substring(7))),
      );
    }

    test('small session fits in one cookie named after the project', () {
      final cookies = PlatformSessionCookies.build(
        supabaseUrl: url,
        sessionJson: {'access_token': 'x'},
      );
      expect(cookies.keys, ['sb-abcdefgh-auth-token']);
      expect(jsonDecode(decode(cookies)), {'access_token': 'x'});
      expect(cookies.values.single, isNot(contains('=')));
    });

    test('large session is split into ordered chunks', () {
      final session = {'access_token': 'y' * 5000};
      final cookies = PlatformSessionCookies.build(
        supabaseUrl: url,
        sessionJson: session,
      );
      expect(cookies.keys, [
        'sb-abcdefgh-auth-token.0',
        'sb-abcdefgh-auth-token.1',
        'sb-abcdefgh-auth-token.2',
      ]);
      expect(
        cookies.values.every(
          (v) => v.length <= PlatformSessionCookies.maxChunkSize,
        ),
        isTrue,
      );
      expect(jsonDecode(decode(cookies)), session);
    });

    test('trainer URL carries the app language', () {
      final base = Uri.parse(
        'https://bilim.aiijodkor.uz/student/practice/logic',
      );
      expect(
        PlatformSessionCookies.withLang(base, 'ru').toString(),
        'https://bilim.aiijodkor.uz/student/practice/logic?lang=ru',
      );
      expect(PlatformSessionCookies.withLang(base, 'uz').queryParameters, {
        'lang': 'uz',
      });
      // Unknown languages fall back to Uzbek; other parameters are kept.
      expect(
        PlatformSessionCookies.withLang(
          base.replace(queryParameters: {'a': '1'}),
          'en',
        ).queryParameters,
        {'a': '1', 'lang': 'uz'},
      );
    });
  });
}
