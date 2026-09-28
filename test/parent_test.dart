import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/parent_records.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/models/student_records.dart';
import 'package:ai_ijodkor/features/parent/parent_providers.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _noOnlinePayment = PaymentLinks(
  paymentUrl: '',
  telegramUrl: 'https://t.me/AI_IjodkorBot',
  phone: '+998500114125',
);

ChildOverview _overview({List<Payment> payments = const []}) {
  final now = DateTime.now();
  return ChildOverview(
    lessons: const [
      Lesson(
        id: 'l1',
        title: 'Neyron tarmoqlar',
        module: 'AI asoslari',
        orderIndex: 1,
      ),
      Lesson(id: 'l2', title: 'LLM', module: 'AI asoslari', orderIndex: 2),
      Lesson(id: 'l3', title: 'Prompt', module: 'AI asoslari', orderIndex: 3),
      Lesson(id: 'l4', title: 'Rasm', module: 'AI asoslari', orderIndex: 4),
    ],
    progress: [
      ProgressRow(
        lessonId: 'l1',
        status: ProgressStatus.completed,
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ProgressRow(
        lessonId: 'l2',
        status: ProgressStatus.viewed,
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ],
    homework: [
      HomeworkSubmission(
        id: 'h1',
        lessonId: 'l1',
        status: HomeworkStatus.approved,
        submittedAt: now.subtract(const Duration(days: 3)),
        reviewedAt: now.subtract(const Duration(minutes: 30)),
      ),
      HomeworkSubmission(
        id: 'h2',
        lessonId: 'l2',
        status: HomeworkStatus.pending,
        submittedAt: now.subtract(const Duration(days: 2, hours: 1)),
      ),
    ],
    points: [
      PointsEntry(
        amount: 1000,
        reason: 'Faol ishtirok',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      PointsEntry(
        amount: 240,
        reason: 'Loyiha',
        createdAt: now.subtract(const Duration(days: 6)),
      ),
    ],
    payments: payments,
  );
}

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late FakeParentRepository parents;

  setUp(() {
    auth = FakeAuthRepository()..users['mom@test.uz'] = 'p1';
    profiles = FakeProfileRepository()..roles['p1'] = UserRole.parent;
    parents = FakeParentRepository()
      ..children.add(const Child(id: 'c1', fullName: 'Karimova Aziza'));
  });

  Future<void> start(WidgetTester tester, {PaymentLinks? links}) async {
    await pumpApp(
      tester,
      auth: auth,
      profiles: profiles,
      parent: parents,
      paymentLinks: links ?? _noOnlinePayment,
    );
    await tester.enterText(byKey('login_email'), 'mom@test.uz');
    await tester.enterText(byKey('login_password'), auth.password);
    await tester.tap(byKey('login_submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('child card shows progress, homework and points', (tester) async {
    parents.overviews['c1'] = _overview();
    await start(tester);

    expect(find.text('Farzandim'), findsOneWidget);
    expect(find.text('Aziza'), findsOneWidget);
    expect(find.text('4 ta dars ochilgan'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    expect(find.text('1 ta dars o‘tildi · 4 tadan'), findsOneWidget);
    expect(find.text('qabul qilindi'), findsOneWidget);
    expect(find.text('tekshiruvda'), findsOneWidget);
    expect(find.text('1 240'), findsOneWidget);
    expect(find.text('To‘lov ma’lumotlari hali kiritilmagan'), findsOneWidget);
  });

  testWidgets('unpaid month without online payment shows amount and contact', (
    tester,
  ) async {
    final year = DateTime.now().year;
    parents.overviews['c1'] = _overview(
      payments: [
        Payment(
          id: 'a',
          period: '$year-09',
          amount: 150000,
          status: PaymentStatus.paid,
          markedAt: DateTime.now(),
        ),
        Payment(
          id: 'b',
          period: '$year-10',
          amount: 150000,
          status: PaymentStatus.unpaid,
        ),
      ],
    );
    await start(tester);

    expect(byKey('due_payment'), findsOneWidget);
    expect(find.text('Oktabr'), findsOneWidget);
    expect(find.text('To‘lanmagan'), findsOneWidget);
    expect(find.text('150 000 so‘m'), findsWidgets);
    expect(find.text('Sentabr — to‘langan'), findsOneWidget);
    expect(byKey('pay_click'), findsNothing);

    await tester.tap(byKey('contact_button'));
    await tester.pumpAndSettle();
    expect(byKey('contact_telegram'), findsOneWidget);
    expect(find.textContaining('+998500114125'), findsOneWidget);
  });

  testWidgets('online payment page shows Click and Payme', (tester) async {
    parents.overviews['c1'] = _overview(
      payments: [
        Payment(
          id: 'b',
          period: '${DateTime.now().year}-10',
          amount: 200000,
          status: PaymentStatus.unpaid,
        ),
      ],
    );
    await start(
      tester,
      links: const PaymentLinks(
        paymentUrl: 'https://bilim.aiijodkor.uz/pay',
        telegramUrl: 'https://t.me/x',
        phone: '+1',
      ),
    );
    expect(byKey('pay_click'), findsOneWidget);
    expect(byKey('pay_payme'), findsOneWidget);
    expect(byKey('contact_button'), findsNothing);
  });

  testWidgets('everything paid shows the all-paid note', (tester) async {
    parents.overviews['c1'] = _overview(
      payments: [
        Payment(
          id: 'a',
          period: '${DateTime.now().year}-09',
          amount: 150000,
          status: PaymentStatus.paid,
        ),
      ],
    );
    await start(tester);
    expect(find.text('Barcha to‘lovlar amalga oshirilgan'), findsOneWidget);
    expect(byKey('due_payment'), findsNothing);
  });

  testWidgets('events feed lists the newest events first', (tester) async {
    parents.overviews['c1'] = _overview();
    await start(tester);

    final approved = find.textContaining('Uy vazifasi qabul qilindi');
    final completed = find.textContaining('Dars yakunlandi');
    expect(approved, findsOneWidget);
    expect(completed, findsOneWidget);
    expect(
      tester.getTopLeft(approved).dy,
      lessThan(tester.getTopLeft(completed).dy),
    );
    expect(find.textContaining('Bugun,'), findsOneWidget);
    expect(find.textContaining('Kecha,'), findsOneWidget);
  });

  testWidgets('several children can be switched', (tester) async {
    parents.children.add(const Child(id: 'c2', fullName: 'Karimov Bobur'));
    parents.overviews['c1'] = _overview();
    parents.overviews['c2'] = const ChildOverview(
      lessons: [],
      progress: [],
      homework: [],
      points: [],
      payments: [],
    );
    await start(tester);

    expect(find.text('Farzandlarim'), findsOneWidget);
    expect(find.text('25%'), findsOneWidget);
    await tester.tap(byKey('child_c2'));
    await tester.pumpAndSettle();
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Hali yangiliklar yo‘q'), findsOneWidget);
  });

  testWidgets('load error offers a retry', (tester) async {
    parents.overviews['c1'] = _overview();
    parents.failOverview = true;
    await start(tester);
    expect(
      find.text('Xatolik yuz berdi. Qaytadan urinib ko‘ring.'),
      findsOneWidget,
    );

    parents.failOverview = false;
    await tester.tap(find.text('Qayta urinish'));
    await tester.pumpAndSettle();
    expect(find.text('25%'), findsOneWidget);
  });

  test('buildChildEvents merges and sorts all record kinds', () {
    final events = buildChildEvents(
      _overview(
        payments: [
          Payment(
            id: 'p',
            period: '2026-09',
            amount: 1,
            status: PaymentStatus.paid,
            markedAt: DateTime.now(),
          ),
        ],
      ),
    );
    expect(events.first.kind, ChildEventKind.paymentPaid);
    expect(events.map((e) => e.kind), contains(ChildEventKind.points));
    for (var i = 1; i < events.length; i++) {
      expect(events[i - 1].at.isBefore(events[i].at), isFalse);
    }
  });
}
