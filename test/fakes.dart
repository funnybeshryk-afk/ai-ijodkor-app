import 'dart:async';

import 'package:ai_ijodkor/app.dart';
import 'package:ai_ijodkor/core/locale_controller.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:ai_ijodkor/data/providers.dart';
import 'package:ai_ijodkor/data/repositories/auth_repository.dart';
import 'package:ai_ijodkor/data/repositories/profile_repository.dart';
import 'package:ai_ijodkor/data/repositories/parent_repository.dart';
import 'package:ai_ijodkor/data/repositories/student_repository.dart';
import 'package:ai_ijodkor/data/repositories/teacher_repository.dart';
import 'package:ai_ijodkor/features/parent/parent_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'fake_parent_repository.dart';
export 'fake_student_repository.dart';
export 'fake_teacher_repository.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.password = 'secret'});

  final String password;
  final _changes = StreamController<String?>.broadcast();
  String? _userId;

  /// email -> user id
  final users = <String, String>{};

  @override
  String? get currentUserId => _userId;

  @override
  Stream<String?> userIdChanges() async* {
    yield _userId;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final id = users[email];
    if (id == null || password != this.password) {
      throw const InvalidCredentialsException();
    }
    _userId = id;
    _changes.add(id);
  }

  @override
  Future<void> signOut() async {
    _userId = null;
    _changes.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}
}

class FakeProfileRepository implements ProfileRepository {
  /// user id -> role (null = no role)
  final roles = <String, UserRole?>{};

  /// user id -> full name ("Familiya Ism")
  final names = <String, String>{};
  final archived = <String>{};

  @override
  Future<Profile?> fetchProfile(String userId) async {
    if (!roles.containsKey(userId)) return null;
    return Profile(
      id: userId,
      role: roles[userId],
      fullName: names[userId] ?? '',
      archivedAt: archived.contains(userId) ? DateTime(2026, 9, 1) : null,
    );
  }
}

/// Pumps the whole app with fake repositories.
Future<void> pumpApp(
  WidgetTester tester, {
  AuthRepository? auth,
  ProfileRepository? profiles,
  StudentRepository? student,
  ParentRepository? parent,
  TeacherRepository? teacher,
  PaymentLinks? paymentLinks,
  Map<String, Object> prefs = const {},
}) async {
  // A tall phone-like surface so whole lesson pages fit without scrolling.
  tester.view.physicalSize = const Size(900, 2000);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        authRepositoryProvider.overrideWithValue(auth),
        profileRepositoryProvider.overrideWithValue(profiles),
        studentRepositoryProvider.overrideWithValue(student),
        parentRepositoryProvider.overrideWithValue(parent),
        teacherRepositoryProvider.overrideWithValue(teacher),
        if (paymentLinks != null)
          paymentLinksProvider.overrideWithValue(paymentLinks),
      ],
      child: const AiIjodkorApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder byKey(String key) => find.byKey(Key(key));
