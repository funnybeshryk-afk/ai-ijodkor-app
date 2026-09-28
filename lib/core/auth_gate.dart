import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/profile.dart';
import '../data/providers.dart';

enum GateStatus { unconfigured, loading, signedOut, signedIn, noRole, error }

/// Everything the router needs to decide where the user belongs.
class AuthGate {
  const AuthGate(this.status, [this.role]);

  final GateStatus status;
  final UserRole? role;

  @override
  bool operator ==(Object other) =>
      other is AuthGate && other.status == status && other.role == role;

  @override
  int get hashCode => Object.hash(status, role);
}

final authGateProvider = Provider<AuthGate>((ref) {
  if (ref.watch(authRepositoryProvider) == null) {
    return const AuthGate(GateStatus.unconfigured);
  }
  final userId = ref.watch(currentUserIdProvider);
  if (!userId.hasValue) return const AuthGate(GateStatus.loading);
  if (userId.value == null) return const AuthGate(GateStatus.signedOut);

  final profile = ref.watch(currentProfileProvider);
  if (profile.isLoading) return const AuthGate(GateStatus.loading);
  if (profile.hasError) return const AuthGate(GateStatus.error);
  final role = profile.value?.role;
  if (role == null) return const AuthGate(GateStatus.noRole);
  return AuthGate(GateStatus.signedIn, role);
});
