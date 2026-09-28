import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/profile.dart';
import 'repositories/auth_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/student_repository.dart';

/// `null` when the app was built without Supabase keys.
/// Overridden in `main()` after `Supabase.initialize`.
final supabaseClientProvider = Provider<SupabaseClient?>((ref) => null);

final authRepositoryProvider = Provider<AuthRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseAuthRepository(client);
});

final profileRepositoryProvider = Provider<ProfileRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseProfileRepository(client);
});

final currentUserIdProvider = StreamProvider<String?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  if (repo == null) return Stream.value(null);
  return repo.userIdChanges();
});

final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final repo = ref.watch(profileRepositoryProvider);
  if (userId == null || repo == null) return null;
  return repo.fetchProfile(userId);
});

final studentRepositoryProvider = Provider<StudentRepository?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseStudentRepository(client);
});
