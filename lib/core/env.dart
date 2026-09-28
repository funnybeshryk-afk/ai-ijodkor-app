/// Build-time configuration passed via `--dart-define` / `--dart-define-from-file`.
/// Keys are never committed to the repository.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const platformUrl = String.fromEnvironment('PLATFORM_URL');

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
