import 'package:ai_ijodkor/core/locale_controller.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository();
    auth.users
      ..['kid@test.uz'] = 'u-student'
      ..['mom@test.uz'] = 'u-parent'
      ..['admin@test.uz'] = 'u-admin'
      ..['nobody@test.uz'] = 'u-none';
    profiles.roles
      ..['u-student'] = UserRole.student
      ..['u-parent'] = UserRole.parent
      ..['u-admin'] = UserRole.admin
      ..['u-none'] = null;
  });

  Future<void> signIn(WidgetTester tester, String email, [String? pwd]) async {
    await tester.enterText(byKey('login_email'), email);
    await tester.enterText(byKey('login_password'), pwd ?? auth.password);
    await tester.tap(byKey('login_submit'));
    await tester.pumpAndSettle();
  }

  testWidgets('without Supabase keys shows config screen', (tester) async {
    await pumpApp(tester);
    expect(find.text('Ilova sozlanmagan'), findsOneWidget);
  });

  testWidgets('signed out user sees login in Uzbek by default', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    expect(find.text('Xush kelibsiz!'), findsOneWidget);
    expect(find.text('Kirish'), findsOneWidget);
  });

  testWidgets('validates empty form', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await tester.tap(byKey('login_submit'));
    await tester.pumpAndSettle();
    expect(find.text('Elektron pochtani kiriting'), findsOneWidget);
    expect(find.text('Parolni kiriting'), findsOneWidget);
  });

  testWidgets('wrong password shows error', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await signIn(tester, 'kid@test.uz', 'wrong');
    expect(find.text('Pochta yoki parol noto‘g‘ri'), findsOneWidget);
  });

  testWidgets('student is redirected to student home', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await signIn(tester, 'kid@test.uz');
    expect(find.text('Mening darslarim'), findsWidgets);
  });

  testWidgets('parent is redirected to parent home', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await signIn(tester, 'mom@test.uz');
    expect(find.text('Farzandlarim'), findsWidgets);
  });

  testWidgets('admin uses teacher screens', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await signIn(tester, 'admin@test.uz');
    expect(find.text('O‘quvchilarim'), findsWidgets);
  });

  testWidgets('user without role sees no-access screen', (tester) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await signIn(tester, 'nobody@test.uz');
    expect(find.text('Kirish imkoni yo‘q'), findsOneWidget);
  });

  testWidgets('language switch in profile persists and sign out works', (
    tester,
  ) async {
    await pumpApp(tester, auth: auth, profiles: profiles);
    await signIn(tester, 'kid@test.uz');

    await tester.tap(find.byIcon(Icons.account_circle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(find.text('Профиль'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LocaleController.storageKey), 'ru');

    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.text('Добро пожаловать!'), findsOneWidget);
  });

  testWidgets('saved language is restored on start', (tester) async {
    await pumpApp(
      tester,
      auth: auth,
      profiles: profiles,
      prefs: {LocaleController.storageKey: 'ru'},
    );
    expect(find.text('Добро пожаловать!'), findsOneWidget);
  });
}
