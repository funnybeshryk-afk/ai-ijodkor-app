import '../data/models/profile.dart';
import 'auth_gate.dart';

class Routes {
  const Routes._();

  static const splash = '/splash';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const configMissing = '/config-missing';
  static const accessProblem = '/access-problem';
  static const profile = '/profile';
  static const student = '/student';
  static const parent = '/parent';
  static const teacher = '/teacher';

  static const _public = {login, forgotPassword};

  /// Home area for a role. Admins use the teacher screens.
  static String homeFor(UserRole role) => switch (role) {
    UserRole.student => student,
    UserRole.parent => parent,
    UserRole.teacher || UserRole.admin => teacher,
  };

  /// Pure redirect logic: returns where to go, or `null` to stay.
  static String? redirect(AuthGate gate, String location) {
    String? only(String target) => location == target ? null : target;

    switch (gate.status) {
      case GateStatus.unconfigured:
        return only(configMissing);
      case GateStatus.loading:
        return only(splash);
      case GateStatus.signedOut:
        return _public.contains(location) ? null : login;
      case GateStatus.noRole:
      case GateStatus.error:
        return only(accessProblem);
      case GateStatus.signedIn:
        final home = homeFor(gate.role!);
        if (location == profile) return null;
        if (location == home || location.startsWith('$home/')) return null;
        return home;
    }
  }
}
