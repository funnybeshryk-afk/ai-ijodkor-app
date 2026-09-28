// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'AI IJODKOR';

  @override
  String get loading => 'Загрузка...';

  @override
  String get loginTitle => 'Добро пожаловать!';

  @override
  String get loginSubtitle => 'Войдите в свой аккаунт';

  @override
  String get emailLabel => 'Электронная почта';

  @override
  String get passwordLabel => 'Пароль';

  @override
  String get signInButton => 'Войти';

  @override
  String get forgotPasswordLink => 'Забыли пароль?';

  @override
  String get resetPasswordTitle => 'Восстановление пароля';

  @override
  String get resetPasswordHint =>
      'Введите электронную почту — мы отправим ссылку для восстановления пароля.';

  @override
  String get sendResetLinkButton => 'Отправить ссылку';

  @override
  String get resetLinkSent => 'Ссылка отправлена. Проверьте почту.';

  @override
  String get backToLoginButton => 'Вернуться ко входу';

  @override
  String get errorEmailRequired => 'Введите электронную почту';

  @override
  String get errorEmailInvalid => 'Неверный адрес почты';

  @override
  String get errorPasswordRequired => 'Введите пароль';

  @override
  String get errorInvalidCredentials => 'Неверная почта или пароль';

  @override
  String get errorGeneric => 'Что-то пошло не так. Попробуйте ещё раз.';

  @override
  String get retryButton => 'Повторить';

  @override
  String get signOutButton => 'Выйти';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get languageLabel => 'Язык';

  @override
  String get languageUzbek => 'O‘zbekcha';

  @override
  String get languageRussian => 'Русский';

  @override
  String get studentHomeTitle => 'Мои уроки';

  @override
  String get parentHomeTitle => 'Мои дети';

  @override
  String get teacherHomeTitle => 'Мои ученики';

  @override
  String get comingSoon => 'Скоро здесь появится!';

  @override
  String get configMissingTitle => 'Приложение не настроено';

  @override
  String get configMissingBody =>
      'SUPABASE_URL и SUPABASE_ANON_KEY не переданы через --dart-define.';

  @override
  String get noAccessTitle => 'Нет доступа';

  @override
  String get noAccessBody =>
      'У аккаунта нет роли. Обратитесь к учителю или администратору.';

  @override
  String get profileLoadError =>
      'Не удалось загрузить профиль. Проверьте интернет и попробуйте ещё раз.';
}
