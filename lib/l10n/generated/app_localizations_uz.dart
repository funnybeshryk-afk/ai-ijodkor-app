// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'AI IJODKOR';

  @override
  String get loading => 'Yuklanmoqda...';

  @override
  String get loginTitle => 'Xush kelibsiz!';

  @override
  String get loginSubtitle => 'Hisobingizga kiring';

  @override
  String get emailLabel => 'Elektron pochta';

  @override
  String get passwordLabel => 'Parol';

  @override
  String get signInButton => 'Kirish';

  @override
  String get forgotPasswordLink => 'Parolni unutdingizmi?';

  @override
  String get resetPasswordTitle => 'Parolni tiklash';

  @override
  String get resetPasswordHint =>
      'Elektron pochtangizni kiriting — parolni tiklash uchun havola yuboramiz.';

  @override
  String get sendResetLinkButton => 'Havolani yuborish';

  @override
  String get resetLinkSent => 'Havola yuborildi. Pochtangizni tekshiring.';

  @override
  String get backToLoginButton => 'Kirish sahifasiga qaytish';

  @override
  String get errorEmailRequired => 'Elektron pochtani kiriting';

  @override
  String get errorEmailInvalid => 'Elektron pochta noto‘g‘ri';

  @override
  String get errorPasswordRequired => 'Parolni kiriting';

  @override
  String get errorInvalidCredentials => 'Pochta yoki parol noto‘g‘ri';

  @override
  String get errorGeneric => 'Xatolik yuz berdi. Qaytadan urinib ko‘ring.';

  @override
  String get retryButton => 'Qayta urinish';

  @override
  String get signOutButton => 'Chiqish';

  @override
  String get profileTitle => 'Profil';

  @override
  String get languageLabel => 'Til';

  @override
  String get languageUzbek => 'O‘zbekcha';

  @override
  String get languageRussian => 'Русский';

  @override
  String get studentHomeTitle => 'Mening darslarim';

  @override
  String get parentHomeTitle => 'Farzandlarim';

  @override
  String get teacherHomeTitle => 'O‘quvchilarim';

  @override
  String get comingSoon => 'Tez orada shu yerda paydo bo‘ladi!';

  @override
  String get configMissingTitle => 'Ilova sozlanmagan';

  @override
  String get configMissingBody =>
      'SUPABASE_URL va SUPABASE_ANON_KEY --dart-define orqali berilmagan.';

  @override
  String get noAccessTitle => 'Kirish imkoni yo‘q';

  @override
  String get noAccessBody =>
      'Hisobingizga rol biriktirilmagan. O‘qituvchingiz yoki administratorga murojaat qiling.';

  @override
  String get profileLoadError =>
      'Profilni yuklab bo‘lmadi. Internetni tekshirib, qayta urinib ko‘ring.';
}
