import 'package:ai_ijodkor/core/format.dart';
import 'package:ai_ijodkor/core/locale_controller.dart';
import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/parent_records.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/models/student_records.dart';
import 'package:ai_ijodkor/data/models/teacher_records.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _aziz = Person(
  id: 's1',
  fullName: 'Karimov Aziz',
  phone: '+998901112233',
  teacherId: 't1',
);
const _dilnoza = Person(
  id: 's2',
  fullName: 'Rashidova Dilnoza',
  teacherId: 't1',
);
final _old = Person(
  id: 's3',
  fullName: 'Toshmatov Sardor',
  teacherId: 't1',
  archivedAt: DateTime(2026, 9, 1),
  archivedReason: 'Ko‘chib ketdi',
);
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
);

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late FakeTeacherRepository repo;

  setUp(() {
    auth = FakeAuthRepository()
      ..users['teacher@test.uz'] = 't1'
      ..users['admin@test.uz'] = 'a1';
    profiles = FakeProfileRepository()
      ..roles['t1'] = UserRole.teacher
      ..names['t1'] = 'Yusupov Nurbek'
      ..roles['a1'] = UserRole.admin
      ..names['a1'] = 'Rahimov Bekzod';
    repo = FakeTeacherRepository()
      ..students.addAll([_aziz, _dilnoza, _old])
      ..teachers.addAll(const [
        Person(id: 't1', fullName: 'Yusupov Nurbek'),
        Person(id: 't2', fullName: 'Tosheva Malika'),
      ])
      ..lessons.addAll([_l1, _l2])
      ..access['s1'] = {'l1'}
      ..progress[('s1', 'l1')] = ProgressStatus.inProgress
      ..homework.add(
        TeacherHomework(
          id: 'h1',
          studentId: 's1',
          lessonId: 'l1',
          status: HomeworkStatus.pending,
          submittedAt: DateTime(2026, 9, 27, 10),
          contentText: 'https://replit.com/@aziz/klaviatura',
          fileUrl: 's1/3f2b8c1e-1d2a-4b3c-9d4e-5f6a7b8c9d0e-klaviatura.png',
        ),
      )
      ..parents['s1'] = const [
        StudentParent(
          id: 'p1',
          fullName: 'Karimova Gulnora',
          phone: '+998907778899',
          login: '998907778899@parent.aiijodkor.uz',
        ),
      ]
      ..courses.add(const Course(id: 'c1', name: 'Digital Start'));
  });

  Future<void> start(
    WidgetTester tester, {
    String email = 'teacher@test.uz',
    String? locale,
  }) async {
    await pumpApp(
      tester,
      auth: auth,
      profiles: profiles,
      teacher: repo,
      prefs: {LocaleController.storageKey: ?locale},
    );
    await tester.enterText(byKey('login_email'), email);
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

  testWidgets('students: list, search, archive section', (tester) async {
    await start(tester);
    expect(find.text('O‘quvchilarim'), findsOneWidget);
    expect(find.text('2 ta o‘quvchi'), findsOneWidget);
    expect(find.text('Karimov Aziz'), findsOneWidget);
    expect(find.text('Rashidova Dilnoza'), findsOneWidget);
    // Archived students are hidden until the archive is opened.
    expect(find.text('Toshmatov Sardor'), findsNothing);
    // Aziz has homework waiting.
    expect(
      find.descendant(of: byKey('pending_s1'), matching: find.text('1')),
      findsOneWidget,
    );
    expect(byKey('pending_s2'), findsNothing);

    await tester.enterText(byKey('student_search'), 'dil');
    await tester.pumpAndSettle();
    expect(find.text('Karimov Aziz'), findsNothing);
    expect(find.text('Rashidova Dilnoza'), findsOneWidget);

    await tester.enterText(byKey('student_search'), 'zzz');
    await tester.pumpAndSettle();
    expect(find.text('Hech kim topilmadi'), findsOneWidget);

    await tester.enterText(byKey('student_search'), '');
    await tester.tap(byKey('toggle_archive'));
    await tester.pumpAndSettle();
    expect(find.text('Toshmatov Sardor'), findsOneWidget);
    expect(find.text('Ko‘chib ketdi'), findsOneWidget);
    // Teachers don't get the admin screens.
    expect(byKey('open_teachers'), findsNothing);
  });

  testWidgets('student card: progress, parents, access switch, archive', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.text('Karimov Aziz'));
    await tester.pumpAndSettle();

    expect(find.text('+998901112233'), findsOneWidget);
    expect(find.text('0 ta dars o‘tildi · 1 tadan'), findsOneWidget);
    expect(find.text('Karimova Gulnora'), findsOneWidget);
    expect(
      find.text('Login: 998907778899@parent.aiijodkor.uz'),
      findsOneWidget,
    );

    // l2 is closed for Aziz; open it.
    final l2Switch = tester.widget<Switch>(byKey('access_l2'));
    expect(l2Switch.value, isFalse);
    await tester.tap(byKey('access_l2'));
    await tester.pumpAndSettle();
    expect(repo.calls, contains('access:s1:l2:true'));
    expect(tester.widget<Switch>(byKey('access_l2')).value, isTrue);
    expect(find.text('0 ta dars o‘tildi · 2 tadan'), findsOneWidget);

    // Archive with a reason.
    await tester.scrollUntilVisible(
      byKey('archive_toggle'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(byKey('archive_toggle'));
    await tester.pumpAndSettle();
    await tester.enterText(byKey('archive_reason'), 'Boshqa shaharga ketdi');
    await tester.tap(byKey('archive_confirm'));
    await tester.pumpAndSettle();
    expect(repo.calls, contains('archive:s1:Boshqa shaharga ketdi'));
    expect(find.text('Arxivdan qaytarish'), findsOneWidget);
    expect(find.text('Arxivda'), findsOneWidget);

    await tester.tap(byKey('archive_toggle'));
    await tester.pumpAndSettle();
    expect(repo.calls, contains('unarchive:s1'));
    expect(find.text('Arxivga olish'), findsOneWidget);
  });

  testWidgets('review: return needs a comment, approve gives points', (
    tester,
  ) async {
    await start(tester);
    await openTab(tester, 'Tekshirish');
    expect(find.text('Vazifalarni tekshirish'), findsOneWidget);
    expect(find.text('1 ta vazifa kutmoqda'), findsOneWidget);
    expect(find.text('Karimov Aziz'), findsOneWidget);
    expect(find.text('Klaviatura bilan tanishuv'), findsOneWidget);

    await tester.tap(byKey('review_open_h1'));
    await tester.pumpAndSettle();
    expect(find.text('Havolani ochish'), findsOneWidget);

    await tester.tap(byKey('review_return'));
    await tester.pumpAndSettle();
    expect(find.text('Qaytarish uchun izoh yozing'), findsOneWidget);
    expect(repo.calls, isEmpty);

    await tester.enterText(byKey('review_notes'), 'Zo‘r!');
    await tester.tap(byKey('review_approve'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['review:h1:true:Zo‘r!']);
    expect(repo.points['s1']!.single.amount, 10);
    expect(repo.progress[('s1', 'l1')], ProgressStatus.completed);
    expect(find.text('Hammasi tekshirildi'), findsOneWidget);
  });

  testWidgets('review: the attached file opens through a signed link', (
    tester,
  ) async {
    await start(tester);
    await openTab(tester, 'Tekshirish');
    await tester.tap(byKey('review_open_h1'));
    await tester.pumpAndSettle();
    expect(find.text('Faylni ochish: klaviatura.png'), findsOneWidget);
    await tester.tap(byKey('review_open_file'));
    await tester.pumpAndSettle();
    expect(repo.signedPaths, [
      's1/3f2b8c1e-1d2a-4b3c-9d4e-5f6a7b8c9d0e-klaviatura.png',
    ]);
  });

  testWidgets('review: returning with a comment', (tester) async {
    await start(tester);
    await openTab(tester, 'Tekshirish');
    await tester.tap(byKey('review_open_h1'));
    await tester.pumpAndSettle();
    await tester.enterText(byKey('review_notes'), 'Havola ochilmayapti');
    await tester.tap(byKey('review_return'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['review:h1:false:Havola ochilmayapti']);
    expect(repo.points['s1'], isNull);
    expect(find.text('Hammasi tekshirildi'), findsOneWidget);
  });

  testWidgets('lessons: open and close a lesson for the whole group', (
    tester,
  ) async {
    await start(tester);
    await openTab(tester, 'Darslar');
    expect(find.text('Darslarni ochish'), findsOneWidget);
    expect(
      find.descendant(
        of: byKey('lesson_group_l1'),
        matching: find.text('1 / 2 ochiq'),
      ),
      findsOneWidget,
    );

    await tester.tap(byKey('open_all_l2'));
    await tester.pumpAndSettle();
    expect(
      find.text('«Sichqoncha» darsini barcha o‘quvchilarga ochasizmi?'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Hammaga ochish').last);
    await tester.pumpAndSettle();
    expect(repo.calls, ['group:l2:true:2']);
    expect(
      find.descendant(
        of: byKey('lesson_group_l2'),
        matching: find.text('2 / 2 ochiq'),
      ),
      findsOneWidget,
    );
    // Archived students are not part of the group.
    expect(repo.access['s3'], isNull);

    await tester.tap(byKey('close_all_l2'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Hammadan yopish').last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: byKey('lesson_group_l2'),
        matching: find.text('0 / 2 ochiq'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('payments: month stats, debtors filter, marking paid', (
    tester,
  ) async {
    final period = periodOf(DateTime.now());
    repo.payments.add(
      Payment(
        id: 'p1',
        studentId: 's2',
        period: period,
        amount: 300000,
        status: PaymentStatus.paid,
      ),
    );
    await start(tester);
    await openTab(tester, 'To‘lovlar');

    // Aziz: nothing saved and no history -> no amount, counted as a debtor.
    // Expected and collected both come to Dilnoza's 300 000.
    expect(find.text(formatAmount(300000)), findsNWidgets(2));
    expect(
      find.descendant(
        of: byKey('payment_s1'),
        matching: find.text('summa belgilanmagan'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: byKey('payment_s1'),
        matching: find.text('belgilanmagan'),
      ),
      findsOneWidget,
    );

    await tester.tap(byKey('debtors_only'));
    await tester.pumpAndSettle();
    expect(byKey('payment_s2'), findsNothing);
    expect(byKey('payment_s1'), findsOneWidget);

    await tester.tap(byKey('payment_s1'));
    await tester.pumpAndSettle();
    // No standard fee: the field starts empty and the two prices are buttons.
    expect(
      tester.widget<TextField>(byKey('payment_amount')).controller!.text,
      isEmpty,
    );
    expect(byKey('payment_tariff_100000'), findsOneWidget);
    await tester.tap(byKey('payment_tariff_150000'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TextField>(byKey('payment_amount')).controller!.text,
      '150000',
    );
    await tester.tap(byKey('payment_save'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['pay:s1:$period:150000:paid']);
    expect(find.text('Bu oyda qarzdorlar yo‘q'), findsOneWidget);

    // Previous month: nobody has paid yet.
    await tester.tap(byKey('debtors_only'));
    await tester.tap(byKey('prev_month'));
    await tester.pumpAndSettle();
    expect(find.text('belgilanmagan'), findsNWidgets(2));
  });

  testWidgets('certificate: required fields, then issued', (tester) async {
    await start(tester);
    await tester.tap(find.text('Karimov Aziz'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      byKey('issue_certificate'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(byKey('issue_certificate'));
    await tester.pumpAndSettle();

    // Teacher name is prefilled; course and director are required.
    expect(find.text('Yusupov Nurbek'), findsOneWidget);
    await tester.tap(byKey('certificate_issue'));
    await tester.pumpAndSettle();
    expect(find.text('To‘ldiring'), findsNWidgets(2));

    await tester.tap(byKey('certificate_course'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Digital Start').last);
    await tester.pumpAndSettle();
    await tester.enterText(byKey('certificate_director'), 'Aliyev Anvar');
    await tester.tap(byKey('certificate_issue'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['cert:s1:c1:Yusupov Nurbek:Aliyev Anvar']);
    expect(find.text('Sertifikat berildi: AIJ-2026-000001'), findsOneWidget);
  });

  testWidgets('admin: teachers screen and moving a student', (tester) async {
    repo.students.add(const Person(id: 's4', fullName: 'Yangi Bola'));
    await start(tester, email: 'admin@test.uz');
    await tester.tap(byKey('open_teachers'));
    await tester.pumpAndSettle();
    expect(find.text('Yusupov Nurbek'), findsOneWidget);
    expect(
      find.descendant(
        of: byKey('teacher_t1'),
        matching: find.text('2 ta o‘quvchi'),
      ),
      findsOneWidget,
    );
    expect(find.text('O‘qituvchisiz o‘quvchilar'), findsOneWidget);

    await tester.tap(find.text('Yangi Bola'));
    await tester.pumpAndSettle();
    expect(find.text('O‘qituvchi: O‘qituvchi biriktirilmagan'), findsOneWidget);
    await tester.tap(byKey('change_teacher'));
    await tester.pumpAndSettle();
    await tester.tap(byKey('assign_t2'));
    await tester.pumpAndSettle();
    expect(repo.calls, ['assign:s4:t2']);
    expect(find.text('O‘qituvchi: Tosheva Malika'), findsOneWidget);
  });

  testWidgets('error state with retry, and Russian UI', (tester) async {
    repo.failStudents = true;
    await start(tester, locale: 'ru');
    expect(find.text('Ученики'), findsWidgets);
    expect(find.text('Повторить'), findsOneWidget);
    repo.failStudents = false;
    await tester.tap(find.text('Повторить'));
    await tester.pumpAndSettle();
    expect(find.text('Учеников: 2'), findsOneWidget);
    await openTab(tester, 'Оплаты');
    expect(find.text('Только должники'), findsOneWidget);
  });
}
