import 'package:ai_ijodkor/core/auth_gate.dart';
import 'package:ai_ijodkor/core/routes.dart';
import 'package:ai_ijodkor/data/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Routes.redirect', () {
    test('unconfigured app always goes to config screen', () {
      const gate = AuthGate(GateStatus.unconfigured);
      expect(Routes.redirect(gate, Routes.login), Routes.configMissing);
      expect(Routes.redirect(gate, Routes.configMissing), isNull);
    });

    test('loading goes to splash', () {
      const gate = AuthGate(GateStatus.loading);
      expect(Routes.redirect(gate, Routes.student), Routes.splash);
      expect(Routes.redirect(gate, Routes.splash), isNull);
    });

    test('signed out may only see login and password reset', () {
      const gate = AuthGate(GateStatus.signedOut);
      expect(Routes.redirect(gate, Routes.splash), Routes.login);
      expect(Routes.redirect(gate, Routes.teacher), Routes.login);
      expect(Routes.redirect(gate, Routes.profile), Routes.login);
      expect(Routes.redirect(gate, Routes.login), isNull);
      expect(Routes.redirect(gate, Routes.forgotPassword), isNull);
    });

    test('each role lands on its own home', () {
      const cases = {
        UserRole.student: Routes.student,
        UserRole.parent: Routes.parent,
        UserRole.teacher: Routes.teacher,
        UserRole.admin: Routes.teacher,
      };
      cases.forEach((role, home) {
        final gate = AuthGate(GateStatus.signedIn, role);
        expect(Routes.redirect(gate, Routes.login), home);
        expect(Routes.redirect(gate, Routes.splash), home);
        expect(Routes.redirect(gate, home), isNull);
        expect(Routes.redirect(gate, '$home/sub'), isNull);
        expect(Routes.redirect(gate, Routes.profile), isNull);
      });
    });

    test('a role cannot open another role area', () {
      const student = AuthGate(GateStatus.signedIn, UserRole.student);
      expect(Routes.redirect(student, Routes.teacher), Routes.student);
      expect(Routes.redirect(student, Routes.parent), Routes.student);
      expect(Routes.redirect(student, '/studentx'), Routes.student);
      expect(Routes.redirect(student, Routes.studentLesson('l1')), isNull);
      expect(Routes.redirect(student, Routes.trainer('typing')), isNull);
      const teacher = AuthGate(GateStatus.signedIn, UserRole.teacher);
      expect(Routes.redirect(teacher, Routes.studentLessons), Routes.teacher);
    });

    test('missing role or profile error goes to access problem', () {
      for (final status in [
        GateStatus.noRole,
        GateStatus.archived,
        GateStatus.error,
      ]) {
        final gate = AuthGate(status);
        expect(Routes.redirect(gate, Routes.student), Routes.accessProblem);
        expect(Routes.redirect(gate, Routes.accessProblem), isNull);
      }
    });
  });

  test('UserRole.tryParse', () {
    expect(UserRole.tryParse('admin'), UserRole.admin);
    expect(UserRole.tryParse('partner'), isNull);
    expect(UserRole.tryParse(null), isNull);
  });
}
