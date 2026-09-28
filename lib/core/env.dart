/// Build-time configuration passed via `--dart-define` / `--dart-define-from-file`.
/// Keys are never committed to the repository.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const platformUrl = String.fromEnvironment('PLATFORM_URL');

  /// Online payment page for parents (Click / Payme). The platform has none
  /// yet; while empty the app shows the amount and a contact button.
  static const paymentUrl = String.fromEnvironment('PAYMENT_URL');

  /// Public contacts of the program (same as on the landing site).
  static const contactTelegramUrl = String.fromEnvironment(
    'CONTACT_TELEGRAM_URL',
    defaultValue: 'https://t.me/AI_IjodkorBot',
  );
  static const contactPhone = String.fromEnvironment(
    'CONTACT_PHONE',
    defaultValue: '+998500114125',
  );

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
