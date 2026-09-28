import 'package:supabase_flutter/supabase_flutter.dart';

/// Thrown when email/password do not match.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

abstract class AuthRepository {
  /// Id of the signed-in user, or `null`.
  String? get currentUserId;

  /// Emits the current user id immediately, then on every auth change.
  Stream<String?> userIdChanges();

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> sendPasswordReset(String email);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  Stream<String?> userIdChanges() async* {
    yield currentUserId;
    yield* _client.auth.onAuthStateChange
        .map((state) => state.session?.user.id)
        .distinct();
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } on AuthApiException catch (e) {
      if (e.code == 'invalid_credentials') {
        throw const InvalidCredentialsException();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  // Without redirectTo Supabase uses the project's Site URL, i.e. the
  // platform's own password-reset flow.
  @override
  Future<void> sendPasswordReset(String email) =>
      _client.auth.resetPasswordForEmail(email);
}
