import 'package:ai_ijodkor/core/locale_controller.dart';
import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/lesson_section.dart';
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

  testWidgets('a lesson with sections is shown natively, goals first', (
    tester,
  ) async {
    repo
      ..sections['l1'] = const [
        LessonSection(
          id: 's1',
          orderIndex: 0,
          kind: SectionKind.text,
          bodyUz: '## Klaviatura\n\n- **Space** — bo‘sh joy',
          bodyRu: '## Клавиатура\n\n- **Space** — пробел',
        ),
        LessonSection(
          id: 's2',
          orderIndex: 1,
          kind: SectionKind.code,
          bodyUz: '{"language":"python","code":"print(\\"salom\\")"}',
        ),
        LessonSection(
          id: 's3',
          orderIndex: 2,
          kind: SectionKind.callout,
          bodyUz: '{"tone":"warn","title":"Diqqat","text":"Shift + harf"}',
        ),
        LessonSection(
          id: 's4',
          orderIndex: 3,
          kind: SectionKind.exercise,
          bodyUz: '{"variant":"practice","label":"Sinab ko‘ring!","title":"Ismingizni yozing","text":"1. Bloknotni oching"}',
        ),
        LessonSection(
          id: 's5',
          orderIndex: 4,
          kind: SectionKind.diagram,
          bodyUz: '{"svg":"<svg viewBox=\\"0 0 10 10\\"><rect width=\\"10\\" height=\\"10\\" fill=\\"var(--moss)\\"/></svg>","caption":"Sxema","alt":"Yashil kvadrat"}',
        ),
      ]
      ..objectives['l1'] = const [
        LessonObjective(
          code: '1A-CS-02',
          titleUz: 'Kompyuter qismlarini to‘g‘ri nomlash',
          titleRu: 'Правильно называть части компьютера',
        ),
      ];
    await start(tester);
    await openTab(tester, 'Darslar');
    await tester.tap(find.text(_l1.title));
    await tester.pumpAndSettle();

    expect(find.text('Kompyuter qismlarini to‘g‘ri nomlash'), findsOneWidget);
    expect(find.text('Klaviatura'), findsOneWidget);
    expect(find.textContaining('bo‘sh joy'), findsOneWidget);
    expect(find.text('print("salom")'), findsOneWidget);
    expect(find.text('PYTHON'), findsOneWidget);
    expect(find.text('Diqqat'), findsOneWidget);
    expect(find.text('Ismingizni yozing'), findsOneWidget);
    expect(find.text('Sxema'), findsOneWidget);
    // Built from sections: no content_url panel, and seeing it marks viewed.
    expect(find.text('Dars materiali'), findsNothing);
    expect(repo.calls, contains('viewed:l1'));
    final goals = tester.getTopLeft(
      find.text('Kompyuter qismlarini to‘g‘ri nomlash'),
    );
    final body = tester.getTopLeft(find.text('Klaviatura'));
    expect(goals.dy, lessThan(body.dy));
  });

  testWidgets('sections that fail to load offer a retry', (tester) async {
    repo.failSections = true;
    await start(tester);
    await openTab(tester, 'Darslar');
    await tester.tap(find.text(_l1.title));
    await tester.pumpAndSettle();
    expect(find.text('Qayta urinish'), findsOneWidget);

    repo
      ..failSections = false
      ..sections['l1'] = const [
        LessonSection(
          id: 's1',
          orderIndex: 0,
          kind: SectionKind.text,
          bodyUz: 'Endi yuklandi',
        ),
      ];
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(find.text('Endi yuklandi'), findsOneWidget);
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

  testWidgets('Russian UI shows translated content, quiz grades Uzbek', (
    tester,
  ) async {
    repo
      ..allLessons.clear()
      ..allLessons.addAll([
        const Lesson(
          id: 'l1',
          title: 'Klaviatura bilan tanishuv',
          titleRu: 'Знакомство с клавиатурой',
          description: 'Tugmalar',
          descriptionRu: 'Клавиши',
          module: 'Kompyuter asoslari',
          moduleRu: 'Основы компьютера',
          orderIndex: 1,
        ),
        // Untranslated: falls back to Uzbek, module name from l1.
        const Lesson(
          id: 'l2',
          title: 'Sichqoncha',
          module: 'Kompyuter asoslari',
          orderIndex: 2,
        ),
      ])
      ..access.add('l2')
      ..quizzes['l1'] = const [
        QuizQuestion(
          id: 'q1',
          isMultipleChoice: true,
          question: 'Qaysi tugma bo‘sh joy qo‘yadi?',
          questionRu: 'Какая клавиша ставит пробел?',
          options: ['Kirish', 'Probel'],
          optionsRu: ['Ввод', 'Пробел'],
        ),
      ]
      ..correctAnswers['q1'] = 'Probel';
    repo.certificates.add(
      Certificate(
        id: 'AIJ-2026-000123',
        courseName: 'Raqamli start',
        courseNameRu: 'Цифровой старт',
        issuedAt: DateTime(2026, 9, 20),
        teacherName: 'Nurbek',
      ),
    );

    await start(tester, locale: 'ru');
    expect(find.text('Знакомство с клавиатурой'), findsWidgets);
    await openTab(tester, 'Уроки');
    expect(find.text('Основы компьютера'), findsOneWidget);
    expect(find.text('Kompyuter asoslari'), findsNothing);
    expect(find.text('Sichqoncha'), findsOneWidget);

    await tester.tap(find.text('Знакомство с клавиатурой'));
    await tester.pumpAndSettle();
    expect(find.text('Клавиши'), findsOneWidget);
    await tester.tap(byKey('quiz_start'));
    await tester.pumpAndSettle();
    expect(find.text('Какая клавиша ставит пробел?'), findsOneWidget);
    expect(find.text('Probel'), findsNothing);
    await tester.tap(find.text('Пробел'));
    await tester.pump();
    await tester.tap(byKey('quiz_submit'));
    await tester.pumpAndSettle();
    // The fake grades against the Uzbek option, so passing proves the
    // Uzbek value was submitted.
    expect(find.text('Молодец! Урок пройден.'), findsOneWidget);
    expect(repo.progress['l1'], ProgressStatus.completed);
  });

  test('translations fall back to Uzbek when empty or misaligned', () {
    const lesson = Lesson(
      id: 'x',
      title: 'Nomi',
      titleRu: '  ',
      module: 'M',
      orderIndex: 1,
    );
    expect(lesson.titleIn(ru: true), 'Nomi');
    expect(lesson.descriptionIn(ru: true), isNull);
    const q = QuizQuestion(
      id: 'q',
      isMultipleChoice: true,
      question: 'Savol',
      options: ['a', 'b'],
      optionsRu: ['а'],
    );
    expect(q.optionLabel(0, ru: true), 'a');
    expect(q.optionLabel(1, ru: false), 'b');
    expect(
      QuizQuestion.fromJson({
        'id': 'q',
        'type': 'multiple_choice',
        'question': 'Savol',
        'question_ru': 'Вопрос',
        'options': ['a', 'b'],
        'options_ru': ['а', 'б'],
      }).optionLabel(1, ru: true),
      'б',
    );
  });
}
