import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Must be overridden in `main()` (and in tests) with a loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

const supportedAppLocales = [Locale('uz'), Locale('ru')];
const defaultAppLocale = Locale('uz');

/// Current UI language. Uzbek (Latin) by default, persisted between launches.
class LocaleController extends Notifier<Locale> {
  static const storageKey = 'app_locale';

  @override
  Locale build() {
    final code = ref.read(sharedPreferencesProvider).getString(storageKey);
    return supportedAppLocales.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => defaultAppLocale,
    );
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await ref
        .read(sharedPreferencesProvider)
        .setString(storageKey, locale.languageCode);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
