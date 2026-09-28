import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In uz, this message translates to:
  /// **'AI IJODKOR'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In uz, this message translates to:
  /// **'Yuklanmoqda...'**
  String get loading;

  /// No description provided for @loginTitle.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga kiring'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochta'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In uz, this message translates to:
  /// **'Parol'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get signInButton;

  /// No description provided for @forgotPasswordLink.
  ///
  /// In uz, this message translates to:
  /// **'Parolni unutdingizmi?'**
  String get forgotPasswordLink;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tiklash'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordHint.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochtangizni kiriting — parolni tiklash uchun havola yuboramiz.'**
  String get resetPasswordHint;

  /// No description provided for @sendResetLinkButton.
  ///
  /// In uz, this message translates to:
  /// **'Havolani yuborish'**
  String get sendResetLinkButton;

  /// No description provided for @resetLinkSent.
  ///
  /// In uz, this message translates to:
  /// **'Havola yuborildi. Pochtangizni tekshiring.'**
  String get resetLinkSent;

  /// No description provided for @backToLoginButton.
  ///
  /// In uz, this message translates to:
  /// **'Kirish sahifasiga qaytish'**
  String get backToLoginButton;

  /// No description provided for @errorEmailRequired.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochtani kiriting'**
  String get errorEmailRequired;

  /// No description provided for @errorEmailInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochta noto‘g‘ri'**
  String get errorEmailInvalid;

  /// No description provided for @errorPasswordRequired.
  ///
  /// In uz, this message translates to:
  /// **'Parolni kiriting'**
  String get errorPasswordRequired;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In uz, this message translates to:
  /// **'Pochta yoki parol noto‘g‘ri'**
  String get errorInvalidCredentials;

  /// No description provided for @errorGeneric.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi. Qaytadan urinib ko‘ring.'**
  String get errorGeneric;

  /// No description provided for @retryButton.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retryButton;

  /// No description provided for @signOutButton.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get signOutButton;

  /// No description provided for @profileTitle.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @languageLabel.
  ///
  /// In uz, this message translates to:
  /// **'Til'**
  String get languageLabel;

  /// No description provided for @languageUzbek.
  ///
  /// In uz, this message translates to:
  /// **'O‘zbekcha'**
  String get languageUzbek;

  /// No description provided for @languageRussian.
  ///
  /// In uz, this message translates to:
  /// **'Русский'**
  String get languageRussian;

  /// No description provided for @studentHomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mening darslarim'**
  String get studentHomeTitle;

  /// No description provided for @parentHomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Farzandlarim'**
  String get parentHomeTitle;

  /// No description provided for @teacherHomeTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchilarim'**
  String get teacherHomeTitle;

  /// No description provided for @comingSoon.
  ///
  /// In uz, this message translates to:
  /// **'Tez orada shu yerda paydo bo‘ladi!'**
  String get comingSoon;

  /// No description provided for @configMissingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ilova sozlanmagan'**
  String get configMissingTitle;

  /// No description provided for @configMissingBody.
  ///
  /// In uz, this message translates to:
  /// **'SUPABASE_URL va SUPABASE_ANON_KEY --dart-define orqali berilmagan.'**
  String get configMissingBody;

  /// No description provided for @noAccessTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kirish imkoni yo‘q'**
  String get noAccessTitle;

  /// No description provided for @noAccessBody.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga rol biriktirilmagan. O‘qituvchingiz yoki administratorga murojaat qiling.'**
  String get noAccessBody;

  /// No description provided for @profileLoadError.
  ///
  /// In uz, this message translates to:
  /// **'Profilni yuklab bo‘lmadi. Internetni tekshirib, qayta urinib ko‘ring.'**
  String get profileLoadError;

  /// No description provided for @archivedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hisob arxivlangan'**
  String get archivedTitle;

  /// No description provided for @archivedBody.
  ///
  /// In uz, this message translates to:
  /// **'Siz o‘quv dasturidan chiqarilgansiz. Savollar bo‘lsa, o‘qituvchingizga murojaat qiling.'**
  String get archivedBody;

  /// No description provided for @navHome.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get navHome;

  /// No description provided for @navLessons.
  ///
  /// In uz, this message translates to:
  /// **'Darslar'**
  String get navLessons;

  /// No description provided for @navHomework.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalar'**
  String get navHomework;

  /// No description provided for @navPractice.
  ///
  /// In uz, this message translates to:
  /// **'Mashqlar'**
  String get navPractice;

  /// No description provided for @navRating.
  ///
  /// In uz, this message translates to:
  /// **'Reyting'**
  String get navRating;

  /// No description provided for @greeting.
  ///
  /// In uz, this message translates to:
  /// **'Salom, {name}!'**
  String greeting(String name);

  /// No description provided for @homeSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi darslaringiz va vazifalaringiz shu yerda.'**
  String get homeSubtitle;

  /// No description provided for @statPoints.
  ///
  /// In uz, this message translates to:
  /// **'Ballaringiz'**
  String get statPoints;

  /// No description provided for @statCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlangan darslar'**
  String get statCompleted;

  /// No description provided for @statPendingHomework.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilmoqda'**
  String get statPendingHomework;

  /// No description provided for @nextLessonTitle.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi dars'**
  String get nextLessonTitle;

  /// No description provided for @allLessonsDone.
  ///
  /// In uz, this message translates to:
  /// **'Barcha ochiq darslar yakunlandi! Yangi darslar tez orada ochiladi.'**
  String get allLessonsDone;

  /// No description provided for @continueButton.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get continueButton;

  /// No description provided for @certificatesTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sertifikatlarim'**
  String get certificatesTitle;

  /// No description provided for @noLessons.
  ///
  /// In uz, this message translates to:
  /// **'Sizga hali dars ochilmagan. O‘qituvchingiz tez orada ochib beradi.'**
  String get noLessons;

  /// No description provided for @statusNotStarted.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanmagan'**
  String get statusNotStarted;

  /// No description provided for @statusViewed.
  ///
  /// In uz, this message translates to:
  /// **'Ko‘rilgan'**
  String get statusViewed;

  /// No description provided for @statusInProgress.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get statusInProgress;

  /// No description provided for @statusCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlangan'**
  String get statusCompleted;

  /// No description provided for @lessonMaterialTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dars materiali'**
  String get lessonMaterialTitle;

  /// No description provided for @openMaterialButton.
  ///
  /// In uz, this message translates to:
  /// **'Materialni ochish'**
  String get openMaterialButton;

  /// No description provided for @noMaterial.
  ///
  /// In uz, this message translates to:
  /// **'Bu dars uchun material biriktirilmagan.'**
  String get noMaterial;

  /// No description provided for @openInBrowser.
  ///
  /// In uz, this message translates to:
  /// **'Brauzerda ochish'**
  String get openInBrowser;

  /// No description provided for @markCompletedButton.
  ///
  /// In uz, this message translates to:
  /// **'Darsni yakunladim'**
  String get markCompletedButton;

  /// No description provided for @lessonNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Dars topilmadi yoki sizga hali ochilmagan.'**
  String get lessonNotFound;

  /// No description provided for @quizTitle.
  ///
  /// In uz, this message translates to:
  /// **'Test'**
  String get quizTitle;

  /// No description provided for @quizHint.
  ///
  /// In uz, this message translates to:
  /// **'Savollarga yetarli darajada to‘g‘ri javob bersangiz, dars yakunlanadi va keyingi dars ochiladi.'**
  String get quizHint;

  /// No description provided for @quizAnswerHint.
  ///
  /// In uz, this message translates to:
  /// **'Javobingiz'**
  String get quizAnswerHint;

  /// No description provided for @quizSubmitButton.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirish'**
  String get quizSubmitButton;

  /// No description provided for @quizAnswerAll.
  ///
  /// In uz, this message translates to:
  /// **'Barcha savollarga javob bering.'**
  String get quizAnswerAll;

  /// No description provided for @quizScore.
  ///
  /// In uz, this message translates to:
  /// **'{correct} / {total} to‘g‘ri'**
  String quizScore(int correct, int total);

  /// No description provided for @quizPassed.
  ///
  /// In uz, this message translates to:
  /// **'Barakalla! Dars yakunlandi.'**
  String get quizPassed;

  /// No description provided for @quizNextUnlocked.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi dars ochildi!'**
  String get quizNextUnlocked;

  /// No description provided for @quizFailed.
  ///
  /// In uz, this message translates to:
  /// **'O‘tish uchun kamida {required} ta to‘g‘ri javob kerak. Yana urinib ko‘ring!'**
  String quizFailed(int required);

  /// No description provided for @quizRetryButton.
  ///
  /// In uz, this message translates to:
  /// **'Qaytadan urinish'**
  String get quizRetryButton;

  /// No description provided for @quizAlreadyCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Bu dars allaqachon yakunlangan. Xohlasangiz testni qayta ishlashingiz mumkin.'**
  String get quizAlreadyCompleted;

  /// No description provided for @quizQuestionNumber.
  ///
  /// In uz, this message translates to:
  /// **'{number}-savol'**
  String quizQuestionNumber(int number);

  /// No description provided for @homeworkTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifalari'**
  String get homeworkTitle;

  /// No description provided for @homeworkForLessonTitle.
  ///
  /// In uz, this message translates to:
  /// **'Shu dars bo‘yicha vazifalar'**
  String get homeworkForLessonTitle;

  /// No description provided for @submitHomeworkButton.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa topshirish'**
  String get submitHomeworkButton;

  /// No description provided for @homeworkLessonLabel.
  ///
  /// In uz, this message translates to:
  /// **'Dars'**
  String get homeworkLessonLabel;

  /// No description provided for @homeworkTextLabel.
  ///
  /// In uz, this message translates to:
  /// **'Javob yoki havola'**
  String get homeworkTextLabel;

  /// No description provided for @homeworkTextHint.
  ///
  /// In uz, this message translates to:
  /// **'Javobingizni yozing yoki loyiha havolasini qo‘ying'**
  String get homeworkTextHint;

  /// No description provided for @homeworkTextRequired.
  ///
  /// In uz, this message translates to:
  /// **'Javobingizni kiriting'**
  String get homeworkTextRequired;

  /// No description provided for @homeworkSent.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa yuborildi!'**
  String get homeworkSent;

  /// No description provided for @sendButton.
  ///
  /// In uz, this message translates to:
  /// **'Yuborish'**
  String get sendButton;

  /// No description provided for @noHomework.
  ///
  /// In uz, this message translates to:
  /// **'Hali vazifa topshirmagansiz.'**
  String get noHomework;

  /// No description provided for @homeworkPending.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirilmoqda'**
  String get homeworkPending;

  /// No description provided for @homeworkApproved.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilindi'**
  String get homeworkApproved;

  /// No description provided for @homeworkRejected.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarildi'**
  String get homeworkRejected;

  /// No description provided for @teacherNote.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchi izohi: {note}'**
  String teacherNote(String note);

  /// No description provided for @practiceTitle.
  ///
  /// In uz, this message translates to:
  /// **'Mashqlar'**
  String get practiceTitle;

  /// No description provided for @practiceSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Mashqlar — dars emas, progressga ta’sir qilmaydi. O‘ynang va o‘rganing!'**
  String get practiceSubtitle;

  /// No description provided for @platformNotConfigured.
  ///
  /// In uz, this message translates to:
  /// **'Mashqlar uchun PLATFORM_URL sozlanmagan.'**
  String get platformNotConfigured;

  /// No description provided for @trackBasics.
  ///
  /// In uz, this message translates to:
  /// **'Kompyuter va boshlang‘ich ko‘nikmalar'**
  String get trackBasics;

  /// No description provided for @trackPython.
  ///
  /// In uz, this message translates to:
  /// **'Python'**
  String get trackPython;

  /// No description provided for @trackLogic.
  ///
  /// In uz, this message translates to:
  /// **'Mantiq va tanqidiy fikrlash'**
  String get trackLogic;

  /// No description provided for @trackAi.
  ///
  /// In uz, this message translates to:
  /// **'AI va promptlash'**
  String get trackAi;

  /// No description provided for @trainerTyping.
  ///
  /// In uz, this message translates to:
  /// **'Klaviatura trenajori'**
  String get trainerTyping;

  /// No description provided for @trainerMouse.
  ///
  /// In uz, this message translates to:
  /// **'Sichqoncha trenajori'**
  String get trainerMouse;

  /// No description provided for @trainerShortcuts.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor tugmalar'**
  String get trainerShortcuts;

  /// No description provided for @trainerFilesFolders.
  ///
  /// In uz, this message translates to:
  /// **'Fayllar va papkalar'**
  String get trainerFilesFolders;

  /// No description provided for @trainerInternetSafety.
  ///
  /// In uz, this message translates to:
  /// **'Internetda xavfsizlik'**
  String get trainerInternetSafety;

  /// No description provided for @trainerGodot.
  ///
  /// In uz, this message translates to:
  /// **'Godot tushunchalari'**
  String get trainerGodot;

  /// No description provided for @trainerPython.
  ///
  /// In uz, this message translates to:
  /// **'Python trenajori'**
  String get trainerPython;

  /// No description provided for @trainerCodeOutput.
  ///
  /// In uz, this message translates to:
  /// **'Kod natijasi'**
  String get trainerCodeOutput;

  /// No description provided for @trainerDebug.
  ///
  /// In uz, this message translates to:
  /// **'Xatoni toping'**
  String get trainerDebug;

  /// No description provided for @trainerPythonBrain.
  ///
  /// In uz, this message translates to:
  /// **'Python miyasini sinash'**
  String get trainerPythonBrain;

  /// No description provided for @trainerLogic.
  ///
  /// In uz, this message translates to:
  /// **'Mantiq trenajori'**
  String get trainerLogic;

  /// No description provided for @trainerCriticalThinking.
  ///
  /// In uz, this message translates to:
  /// **'Fakt yoki fikr?'**
  String get trainerCriticalThinking;

  /// No description provided for @trainerPrompting.
  ///
  /// In uz, this message translates to:
  /// **'Promptlash trenajori'**
  String get trainerPrompting;

  /// No description provided for @trainerPromptChecklist.
  ///
  /// In uz, this message translates to:
  /// **'Prompt tekshiruvchisi'**
  String get trainerPromptChecklist;

  /// No description provided for @trainerExperimentLab.
  ///
  /// In uz, this message translates to:
  /// **'Promptni solishtirish'**
  String get trainerExperimentLab;

  /// No description provided for @trainerTeacherSimulator.
  ///
  /// In uz, this message translates to:
  /// **'AI-shogirdga tushuntirish'**
  String get trainerTeacherSimulator;

  /// No description provided for @ratingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sinfdagi reyting'**
  String get ratingTitle;

  /// No description provided for @ratingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Shu haftadagi mashqlar ballari. Har dushanba yangilanadi.'**
  String get ratingSubtitle;

  /// No description provided for @ratingEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Bu hafta hali hech kim mashq qilmadi. Birinchi bo‘ling!'**
  String get ratingEmpty;

  /// No description provided for @ratingYou.
  ///
  /// In uz, this message translates to:
  /// **'Siz'**
  String get ratingYou;

  /// No description provided for @ratingScore.
  ///
  /// In uz, this message translates to:
  /// **'{score} ball'**
  String ratingScore(int score);

  /// No description provided for @noCertificates.
  ///
  /// In uz, this message translates to:
  /// **'Hali sertifikatingiz yo‘q. Kursni tugatsangiz, shu yerda paydo bo‘ladi.'**
  String get noCertificates;

  /// No description provided for @certificateNumber.
  ///
  /// In uz, this message translates to:
  /// **'Raqami: {id}'**
  String certificateNumber(String id);

  /// No description provided for @certificateIssued.
  ///
  /// In uz, this message translates to:
  /// **'Berilgan sana: {date}'**
  String certificateIssued(String date);

  /// No description provided for @certificateTeacher.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchi: {name}'**
  String certificateTeacher(String name);

  /// No description provided for @certificateVerifyButton.
  ///
  /// In uz, this message translates to:
  /// **'Sertifikatni ko‘rish'**
  String get certificateVerifyButton;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
