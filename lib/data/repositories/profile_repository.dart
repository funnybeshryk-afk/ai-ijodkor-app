import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';

abstract class ProfileRepository {
  /// The signed-in user's own profile (RLS allows reading it), or `null`.
  Future<Profile?> fetchProfile(String userId);
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Profile?> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select('id, role')
        .eq('id', userId)
        .maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }
}
