import 'dart:convert';

/// Builds the auth cookies the web platform (Next.js + @supabase/ssr)
/// reads, so a WebView opened on a platform page is already signed in.
///
/// Mirrors @supabase/ssr's cookie storage:
/// * name `sb-<project-ref>-auth-token` (supabase-js's default storage key,
///   project ref = first label of the Supabase URL host);
/// * value `base64-` + base64url(JSON of the session), no padding;
/// * values longer than 3180 characters are split into `<name>.0`,
///   `<name>.1`, ... chunks.
class PlatformSessionCookies {
  const PlatformSessionCookies._();

  /// The platform's language cookie (`aiij_lang`, values `uz` | `ru`).
  static const langCookie = 'aiij_lang';

  /// [url] with `?lang=` set, so the platform opens in the app's language
  /// (its proxy stores the choice in [langCookie]). Only `uz` and `ru` are
  /// supported there; anything else falls back to Uzbek.
  static Uri withLang(Uri url, String languageCode) => url.replace(
    queryParameters: {
      ...url.queryParameters,
      'lang': languageCode == 'ru' ? 'ru' : 'uz',
    },
  );

  static const maxChunkSize = 3180;

  static String cookieName(String supabaseUrl) =>
      'sb-${Uri.parse(supabaseUrl).host.split('.').first}-auth-token';

  static String encodeSession(Map<String, dynamic> sessionJson) {
    final encoded = base64Url
        .encode(utf8.encode(jsonEncode(sessionJson)))
        .replaceAll('=', '');
    return 'base64-$encoded';
  }

  /// cookie name -> value
  static Map<String, String> build({
    required String supabaseUrl,
    required Map<String, dynamic> sessionJson,
  }) {
    final name = cookieName(supabaseUrl);
    final value = encodeSession(sessionJson);
    if (value.length <= maxChunkSize) return {name: value};
    return {
      for (var i = 0; i * maxChunkSize < value.length; i++)
        '$name.$i': value.substring(
          i * maxChunkSize,
          (i + 1) * maxChunkSize > value.length
              ? value.length
              : (i + 1) * maxChunkSize,
        ),
    };
  }
}
