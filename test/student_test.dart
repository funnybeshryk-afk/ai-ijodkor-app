import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/models/quiz.dart';
import 'package:ai_ijodkor/data/models/student_records.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _l1 = Lesson(
  id: 'l1',
  title: 'Klaviatura bilan tanishuv',
  module: 'Kompyuter asoslari',
  orderIndex: 1,
);
const _l2 = Lesson(
  id: 'l2',
  title: 'Sichqoncha',
  module: 'Kompyuter asoslari',
  orderIndex: 2,
  contentUrl: 'https://example.com/video',
);
// Lower order_index than the computer lessons, but its module comes later
// in the curriculum tracks.
const _p1 = Lesson(
  id: 'p1',
  title: 'print() funksiyasi',
  module: 'Python asoslari',
  orderIndex: 0,
);

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late FakeStudentRepository repo;

  setUp(() {
    auth = FakeAuthRepository()..users['kid@test.uz'] = 'u1';
    profiles = FakeProfileRepository()
      ..roles['u1'] = UserRole.student
      ..names['u1'] = 'Karimov Ali';
    repo = FakeStudentRepository()
      ..allLessons.addAll([_p1, _l2, _l1])
      ..access.addAll(['l1', 'p1'])
      ..points = 25
      ..quizzes['l1'] = const [
        QuizQuestion(
          id: 'q1',
          isMultipleChoice: true,
          question: 'Qaysi tugma bo‘sh joy qo‘yadi?',
          options: ['Enter', 'Space'],
        ),
        QuizQuestion(
          id: 'q2',
          isMultipleChoice: false,
          question: 'Harflarni katta qiladigan tugma?',
        ),
      ]
      ..correctAnswers.addAll({'q1': 'Space', 'q2': 'Shift'});
  });

  Future<void> start(WidgetTester tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles, student: repo);
    await tester.enterText(byKey('login_email'), 'kid@test.uz');
    await tester.enterText(byKey('login_password'), auth.password);
    await tester.tap(byKey('login_submit'));
    await tester.pumpAndSettle();
  }

  Future<void> openTab(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home shows greeting, stats, tracks and the next lesson', (
    tester,
  ) async {
    repo.progress['p1'] = ProgressStatus.completed;
    repo.homework.add(
      HomeworkSubmission(
        id: 'h1',
        lessonId: 'p1',
        status: HomeworkStatus.pending,
        submittedAt: DateTime(2026, 9, 27),
      ),
    );
    repo.leaderboard.add(
      const LeaderboardEntry(
        studentId: 'u1',
        fullName: 'Karimov Ali',
        totalScore: 40,
      ),
    );
    await start(tester);

    expect(find.text('Xayrli kun,'), findsOneWidget);
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(find.text('1/2'), findsOneWidget);
    expect(find.text('#1'), findsOneWidget);
    expect(find.text('KEYINGI DARS'), findsOneWidget);
    expect(find.text('Kompyuter asoslari · 1-dars'), findsOneWidget);
    expect(find.text(_l1.title), findsOneWidget);
    expect(find.text('2 savolli test'), findsOneWidget);
    // Tracks: Digital Start 0/1, AI & Creative closed, Code & Tech 1/1.
    expect(find.text('0 / 1'), findsOneWidget);
    expect(find.text('yopiq'), findsOneWidget);
    expect(find.text('1 / 1'), findsOneWidget);
    expect(byKey('homework_in_review'), findsOneWidget);

    await tester.tap(byKey('continue_lesson'));
    await tester.pumpAndSettle();
    expect(find.text('Dars testi'), findsOneWidget);
    expect(find.text('Kompyuter asoslari · 1 / 1'), findsOneWidget);
  });

  testWidgets('lessons are grouped by module in curriculum order', (
    tester,
  ) async {
    await start(tester);
    await openTab(tester, 'Darslar');

    final computer = tester.getTopLeft(find.text('Kompyuter asoslari'));
    final python = tester.getTopLeft(find.text('Python asoslari'));
    expect(computer.dy, lessThan(python.dy));
    // Not granted -> not listed.
    expect(find.text(_l2.title), findsNothing);
  });

  testWidgets('quiz: failing shows the threshold, passing unlocks next', (
    tester,
  ) async {
    await start(tester);
    await openTab(tester, 'Darslar');
    await tester.tap(find.text(_l1.title));
    await tester.pumpAndSettle();
    await tester.tap(byKey('quiz_start'));
    await tester.pumpAndSettle();

    // Submitting with an empty answer is caught before the server call.
    await tester.tap(find.text('Space'));
    await tester.pump();
    await tester.tap(byKey('quiz_submit'));
    await tester.pumpAndSettle();
    expect(find.text('Barcha savollarga javob bering.'), findsOneWidget);
    expect(repo.calls.where((c) => c.startsWith('quiz:')), isEmpty);

    await tester.enterText(find.byType(TextField), 'Ctrl');
    await tester.tap(byKey('quiz_submit'));
    await tester.pumpAndSettle();
    expect(find.text('1 / 2 to‘g‘ri'), findsOneWidget);
    expect(find.textContaining('kamida 2 ta'), findsOneWidget);

    await tester.tap(byKey('quiz_retry'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '  shift ');
    await tester.tap(byKey('quiz_submit'));
    await tester.pumpAndSettle();
    expect(find.text('Barakalla! Dars yakunlandi.'), findsOneWidget);
    expect(repo.access, contains('l2'));

    await tester.tap(find.text('Keyingi dars ochildi!'));
    await tester.pumpAndSettle();
    expect(find.text('Dars materiali'), findsOneWidget);
    // l2 has no quiz, so it can be completed by hand.
    await tester.tap(byKey('mark_completed'));
    await tester.pumpAndSettle();
    expect(repo.progress['l2'], ProgressStatus.completed);
    expect(byKey('mark_completed'), findsNothing);
  });

  testWidgets('homework can be submitted and shows as pending', (tester) async {
    await start(tester);
    await openTab(tester, 'Profil');
    await tester.tap(find.text('Uy vazifalarim'));
    await tester.pumpAndSettle();
    expect(find.text('Hali vazifa topshirmagansiz.'), findsOneWidget);

    await tester.tap(byKey('homework_fab'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('homework_send'));
    await tester.pumpAndSettle();
    expect(find.text('Javobingizni kiriting'), findsOneWidget);

    await tester.enterText(byKey('homework_text'), 'https://scratch.mit.edu/1');
    await tester.tap(byKey('homework_send'));
    await tester.pumpAndSettle();

    expect(repo.homework, hasLength(1));
    expect(find.text('https://scratch.mit.edu/1'), findsOneWidget);
    expect(find.text('Tekshirilmoqda'), findsOneWidget);
  });

  testWidgets('rating highlights the current student', (tester) async {
    repo.leaderboard.addAll(const [
      LeaderboardEntry(
        studentId: 'u2',
        fullName: 'Aliyev Vali',
        totalScore: 90,
      ),
      LeaderboardEntry(
        studentId: 'u1',
        fullName: 'Karimov Ali',
        totalScore: 70,
      ),
    ]);
    await start(tester);
    await openTab(tester, 'Reyting');

    expect(find.text('Aliyev Vali'), findsOneWidget);
    expect(find.text('Karimov Ali (Siz)'), findsOneWidget);
    expect(byKey('rating_me'), findsOneWidget);
  });

  testWidgets('certificates are listed', (tester) async {
    repo.certificates.add(
      Certificate(
        id: 'AIJ-2026-000123',
        courseName: 'Digital Start',
        issuedAt: DateTime(2026, 9, 20),
        teacherName: 'Nurbek',
      ),
    );
    await start(tester);
    await openTab(tester, 'Profil');
    await tester.tap(find.text('Sertifikatlarim'));
    await tester.pumpAndSettle();

    expect(find.text('Digital Start'), findsOneWidget);
    expect(find.text('Raqami: AIJ-2026-000123'), findsOneWidget);
  });
}
