import 'package:ai_ijodkor/core/locale_controller.dart';
import 'package:ai_ijodkor/data/models/lesson.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/models/skills.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _py = Lesson(
  id: 'py',
  title: 'Sikllar',
  module: 'Python asoslari',
  orderIndex: 1,
);
const _ai = Lesson(
  id: 'ai',
  title: 'Kirish',
  module: 'AI asoslari',
  orderIndex: 1,
);
const _odd = Lesson(
  id: 'odd',
  title: 'Boshqa',
  module: 'Noma‘lum',
  orderIndex: 1,
);

const _a = Objective(id: 'a', code: 'A-1', titleUz: 'Birinchi maqsad');
const _b = Objective(
  id: 'b',
  code: 'B-1',
  titleUz: 'Ikkinchi maqsad',
  titleRu: 'Вторая цель',
);
const _c = Objective(id: 'c', code: 'C-1', titleUz: 'Uchinchi maqsad');

const _order = ['digitalStart', 'aiCreative', 'codeTech'];
String? _trackOf(String module) => switch (module) {
  'Kompyuter asoslari' => 'digitalStart',
  'AI asoslari' => 'aiCreative',
  'Python asoslari' => 'codeTech',
  _ => null,
};

SkillsOverview _build({
  List<Lesson> lessons = const [_py, _ai, _odd],
  List<ObjectiveLink> links = const [],
  List<Objective> objectives = const [_a, _b, _c],
  List<Mastery> mastery = const [],
}) => buildSkills(
  lessons: lessons,
  links: links,
  objectives: objectives,
  mastery: mastery,
  trackOrder: _order,
  trackOf: _trackOf,
);

Mastery _m(String id, int level, int attempts, int solved) =>
    Mastery(objectiveId: id, level: level, attempts: attempts, solved: solved);

void main() {
  group('SkillState', () {
    test('is fresh until the first attempt, then follows the level', () {
      expect(SkillState.of(0, 0), SkillState.fresh);
      expect(SkillState.of(0, 1), SkillState.start);
      expect(SkillState.of(39, 3), SkillState.start);
      expect(SkillState.of(40, 3), SkillState.growing);
      expect(SkillState.of(74, 3), SkillState.growing);
      expect(SkillState.of(75, 3), SkillState.strong);
    });
  });

  group('buildSkills', () {
    test('shows practised objectives and approved links, not a lone draft', () {
      final skills = _build(
        links: const [
          ObjectiveLink(lessonId: 'py', objectiveId: 'a', approved: false),
          ObjectiveLink(lessonId: 'py', objectiveId: 'b', approved: true),
          ObjectiveLink(lessonId: 'ai', objectiveId: 'c', approved: false),
        ],
        mastery: [_m('a', 20, 1, 1)],
      );
      final codes = [
        for (final g in skills.groups) ...g.items.map((i) => i.objective.code),
      ]..sort();
      expect(codes, ['A-1', 'B-1']);
    });

    test('untouched objectives are fresh at level 0', () {
      final skills = _build(
        links: const [
          ObjectiveLink(lessonId: 'py', objectiveId: 'b', approved: true),
        ],
      );
      final item = skills.groups.single.items.single;
      expect(item.state, SkillState.fresh);
      expect(item.level, 0);
      expect(item.needsReview, isFalse);
    });

    test(
      'review lists practised objectives below 60, weakest first, max 5',
      () {
        final many = [
          for (var i = 0; i < 7; i++)
            Objective(id: 'o$i', code: 'O-$i', titleUz: 'Maqsad $i'),
        ];
        final skills = _build(
          objectives: many,
          links: [
            for (final o in many)
              ObjectiveLink(lessonId: 'py', objectiveId: o.id, approved: true),
          ],
          mastery: [for (var i = 0; i < 7; i++) _m('o$i', 10 + i * 5, 2, 0)],
        );
        expect(skills.review.map((i) => i.level), [10, 15, 20, 25, 30]);
        final solid = _build(
          links: const [
            ObjectiveLink(lessonId: 'py', objectiveId: 'a', approved: true),
          ],
          mastery: [_m('a', 60, 3, 3)],
        );
        expect(solid.review, isEmpty);
      },
    );

    test('an objective sits under the first direction of its lessons', () {
      final skills = _build(
        links: const [
          ObjectiveLink(lessonId: 'py', objectiveId: 'a', approved: true),
          ObjectiveLink(lessonId: 'ai', objectiveId: 'a', approved: true),
        ],
      );
      expect(skills.groups.map((g) => g.track), ['aiCreative']);
    });

    test('an objective with no direction goes to the trailing group', () {
      final skills = _build(mastery: [_m('c', 30, 1, 0)]);
      expect(skills.groups.map((g) => g.track), [null]);
    });

    test('counts practised objectives and solved tasks', () {
      final skills = _build(
        links: const [
          ObjectiveLink(lessonId: 'py', objectiveId: 'a', approved: true),
          ObjectiveLink(lessonId: 'py', objectiveId: 'b', approved: true),
        ],
        mastery: [_m('a', 40, 3, 2), _m('b', 20, 1, 1)],
      );
      expect(skills.practised, 2);
      expect(skills.solved, 3);
    });

    test('is empty for a student with nothing', () {
      expect(_build().isEmpty, isTrue);
    });

    test('picks the Russian title when asked and available', () {
      expect(_b.titleIn(ru: true), 'Вторая цель');
      expect(_a.titleIn(ru: true), 'Birinchi maqsad');
      expect(_b.titleIn(ru: false), 'Ikkinchi maqsad');
    });
  });

  group('Mastery.fromJson', () {
    test('reads the row and keeps the level within 0–100', () {
      final m = Mastery.fromJson({
        'objective_id': 'a',
        'level': 120,
        'attempts_count': 4,
        'solved_count': 2,
      });
      expect((m.level, m.attempts, m.solved), (100, 4, 2));
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
        ..allLessons.addAll([_py, _ai])
        ..access.addAll(['py', 'ai']);
    });

    Future<void> openSkills(WidgetTester tester, {String? locale}) async {
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
      await tester.tap(byKey('skills_link'));
      await tester.pumpAndSettle();
    }

    testWidgets('empty state points to the lessons', (tester) async {
      await openSkills(tester);
      expect(find.text('Hali mashq boshlanmagan'), findsOneWidget);
      expect(find.text('Darslarga o‘tish'), findsOneWidget);
    });

    testWidgets('shows levels by direction and what to repeat', (tester) async {
      repo.objectiveList.addAll([_a, _b]);
      repo.objectiveLinks.addAll(const [
        ObjectiveLink(lessonId: 'py', objectiveId: 'a', approved: true),
        ObjectiveLink(lessonId: 'ai', objectiveId: 'b', approved: true),
      ]);
      repo.masteryRows.addAll([_m('a', 20, 2, 1), _m('b', 80, 4, 3)]);
      await openSkills(tester);

      expect(find.text('Birinchi maqsad'), findsNWidgets(2)); // review + group
      expect(find.text('Takrorlash kerak'), findsOneWidget);
      expect(find.text('Ikkinchi maqsad'), findsOneWidget);
      expect(find.text('20%'), findsNWidgets(2));
      expect(find.text('80%'), findsOneWidget);
      expect(find.text('Mustahkam'), findsOneWidget);
      expect(find.text('Boshlang‘ich'), findsNWidgets(2));
      expect(find.text('B-1 · 3 ta vazifa yechildi'), findsOneWidget);
      expect(find.text('Code & Technology'), findsOneWidget);
      expect(find.text('AI & Creative'), findsOneWidget);
    });

    testWidgets('shows the Russian title and labels', (tester) async {
      repo.objectiveList.add(_b);
      repo.masteryRows.add(_m('b', 50, 2, 1));
      repo.objectiveLinks.add(
        const ObjectiveLink(lessonId: 'ai', objectiveId: 'b', approved: true),
      );
      await openSkills(tester, locale: 'ru');
      expect(find.text('Вторая цель'), findsNWidgets(2)); // review + group
      expect(find.text('Растёт'), findsNWidgets(2));
    });

    testWidgets('an error offers a retry', (tester) async {
      repo.failSkills = true;
      await openSkills(tester);
      expect(find.text('Hali mashq boshlanmagan'), findsNothing);
      expect(find.text('Qayta urinish'), findsOneWidget);
      repo.failSkills = false;
      await tester.tap(find.text('Qayta urinish'));
      await tester.pumpAndSettle();
      expect(find.text('Hali mashq boshlanmagan'), findsOneWidget);
    });

    testWidgets('the home card summarises the practice', (tester) async {
      repo.objectiveList.add(_a);
      repo.objectiveLinks.add(
        const ObjectiveLink(lessonId: 'py', objectiveId: 'a', approved: true),
      );
      repo.masteryRows.add(_m('a', 20, 2, 1));
      await pumpApp(tester, auth: auth, profiles: profiles, student: repo);
      await tester.enterText(byKey('login_email'), 'kid@test.uz');
      await tester.enterText(byKey('login_password'), auth.password);
      await tester.tap(byKey('login_submit'));
      await tester.pumpAndSettle();
      expect(
        find.text('1 ta ko‘nikma mashq qilingan, 1 ta vazifa yechilgan'),
        findsOneWidget,
      );
    });
  });
}
