import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/common/access_problem_screen.dart';
import '../features/common/config_missing_screen.dart';
import '../features/common/profile_screen.dart';
import '../features/common/splash_screen.dart';
import '../features/parent/parent_home_screen.dart';
import '../features/student/student_home_screen.dart';
import '../features/teacher/teacher_home_screen.dart';
import 'auth_gate.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final gate = ValueNotifier<AuthGate>(ref.read(authGateProvider));
  ref.listen(authGateProvider, (_, next) => gate.value = next);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: gate,
    redirect: (context, state) =>
        Routes.redirect(gate.value, state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: Routes.configMissing,
        builder: (_, _) => const ConfigMissingScreen(),
      ),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (_, _) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: Routes.accessProblem,
        builder: (_, _) => const AccessProblemScreen(),
      ),
      GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen()),
      GoRoute(
        path: Routes.student,
        builder: (_, _) => const StudentHomeScreen(),
      ),
      GoRoute(path: Routes.parent, builder: (_, _) => const ParentHomeScreen()),
      GoRoute(
        path: Routes.teacher,
        builder: (_, _) => const TeacherHomeScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    gate.dispose();
  });
  return router;
});
