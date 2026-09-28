import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/common/access_problem_screen.dart';
import '../features/common/config_missing_screen.dart';
import '../features/common/profile_screen.dart';
import '../features/common/splash_screen.dart';
import '../features/common/web_page_screen.dart';
import '../features/parent/parent_home_screen.dart';
import '../features/student/certificates_screen.dart';
import '../features/student/homework_screen.dart';
import '../features/student/lesson_screen.dart';
import '../features/student/lessons_screen.dart';
import '../features/student/practice_screen.dart';
import '../features/student/rating_screen.dart';
import '../features/student/student_home_screen.dart';
import '../features/student/student_providers.dart';
import '../features/student/student_shell.dart';
import '../features/student/trainers.dart';
import '../features/teacher/lessons_access_screen.dart';
import '../features/teacher/payments_screen.dart';
import '../features/teacher/review_screen.dart';
import '../features/teacher/student_detail_screen.dart';
import '../features/teacher/students_screen.dart';
import '../features/teacher/teacher_shell.dart';
import '../features/teacher/teachers_screen.dart';
import 'auth_gate.dart';
import 'env.dart';
import 'l10n.dart';
import 'routes.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final rootKey = GlobalKey<NavigatorState>();
  final gate = ValueNotifier<AuthGate>(ref.read(authGateProvider));
  ref.listen(authGateProvider, (_, next) => gate.value = next);

  final router = GoRouter(
    navigatorKey: rootKey,
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
      _studentShell(rootKey),
      GoRoute(path: Routes.parent, builder: (_, _) => const ParentHomeScreen()),
      _teacherShell(rootKey),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    gate.dispose();
  });
  return router;
});

/// Student area (mockup «2 · O'quvchi»): five tabs, each with its own
/// navigation stack. Full-screen pages (a lesson and its material,
/// homework, certificates, trainers) use the root navigator.
StatefulShellRoute _studentShell(
  GlobalKey<NavigatorState> rootKey,
) => StatefulShellRoute.indexedStack(
  builder: (_, _, shell) => StudentShell(shell: shell),
  branches: [
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.student,
          builder: (_, _) => const StudentHomeScreen(),
          routes: [
            GoRoute(
              path: 'certificates',
              parentNavigatorKey: rootKey,
              builder: (_, _) => const CertificatesScreen(),
            ),
            GoRoute(
              path: 'homework',
              parentNavigatorKey: rootKey,
              builder: (_, _) => const HomeworkScreen(),
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.studentLessons,
          builder: (_, _) => const LessonsScreen(),
          routes: [
            GoRoute(
              path: ':id',
              parentNavigatorKey: rootKey,
              builder: (_, state) =>
                  LessonScreen(lessonId: state.pathParameters['id']!),
              routes: [
                GoRoute(
                  path: 'material',
                  parentNavigatorKey: rootKey,
                  builder: (_, state) =>
                      _LessonMaterial(lessonId: state.pathParameters['id']!),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.studentPractice,
          builder: (_, _) => const PracticeScreen(),
          routes: [
            GoRoute(
              path: ':key',
              parentNavigatorKey: rootKey,
              builder: (context, state) {
                final key = state.pathParameters['key']!;
                return WebPageScreen(
                  url: Uri.parse(Env.platformUrl)
                      .resolve('/student/practice/${Uri.encodeComponent(key)}'),
                  title: trainerTitle(context, key),
                  withPlatformSession: true,
                );
              },
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.studentRating,
          builder: (_, _) => const RatingScreen(),
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          path: Routes.studentProfile,
          builder: (_, _) => const ProfileScreen(asTab: true),
        ),
      ],
    ),
  ],
);

/// Teacher/admin area: students, review queue, lesson access, payments,
/// profile. The student card and the admin teachers list open full-screen.
StatefulShellRoute _teacherShell(GlobalKey<NavigatorState> rootKey) =>
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => TeacherShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.teacher,
              builder: (_, _) => const StudentsScreen(),
              routes: [
                GoRoute(
                  path: 'students/:id',
                  parentNavigatorKey: rootKey,
                  builder: (_, state) => StudentDetailScreen(
                    studentId: state.pathParameters['id']!,
                  ),
                ),
                GoRoute(
                  path: 'teachers',
                  parentNavigatorKey: rootKey,
                  builder: (_, _) => const TeachersScreen(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.teacherReview,
              builder: (_, _) => const ReviewScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.teacherLessons,
              builder: (_, _) => const LessonsAccessScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.teacherPayments,
              builder: (_, _) => const PaymentsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.teacherProfile,
              builder: (_, _) => const ProfileScreen(asTab: true),
            ),
          ],
        ),
      ],
    );

/// Lesson material (content_url: video, slides, ...) in a WebView.
class _LessonMaterial extends ConsumerWidget {
  const _LessonMaterial({required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = ref
        .watch(lessonsProvider)
        .value
        ?.where((l) => l.id == lessonId)
        .firstOrNull;
    final url = Uri.tryParse(lesson?.contentUrl ?? '');
    if (lesson == null || url == null || !url.hasScheme) {
      return Scaffold(appBar: AppBar(), body: const SizedBox.shrink());
    }
    return WebPageScreen(
      url: url,
      title: lesson.titleIn(ru: context.contentRu),
    );
  }
}
