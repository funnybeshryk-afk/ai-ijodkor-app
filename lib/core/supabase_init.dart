import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

/// Initializes Supabase with the anon key. Returns `false` when the app was
/// built without `SUPABASE_URL` / `SUPABASE_ANON_KEY`.
Future<bool> initSupabase() async {
  if (!Env.isSupabaseConfigured) return false;
  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseAnonKey,
  );
  return true;
}
