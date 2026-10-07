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

  /// No description provided for @logoLabel.
  ///
  /// In uz, this message translates to:
  /// **'AI Ijodkor belgisi'**
  String get logoLabel;

  /// No description provided for @loginTagline.
  ///
  /// In uz, this message translates to:
  /// **'Sun’iy intellekt va dasturlash — o‘quvchilar, ota-onalar va o‘qituvchilar uchun'**
  String get loginTagline;

  /// No description provided for @loginNote.
  ///
  /// In uz, this message translates to:
  /// **'Login va parolni o‘qituvchingiz beradi. Ota-onalar ham shu yerdan kiradi.'**
  String get loginNote;

  /// No description provided for @emailHint.
  ///
  /// In uz, this message translates to:
  /// **'ism@misol.uz'**
  String get emailHint;

  /// No description provided for @showPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni ko‘rsatish'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni yashirish'**
  String get hidePassword;

  /// No description provided for @backLabel.
  ///
  /// In uz, this message translates to:
  /// **'Orqaga'**
  String get backLabel;

  /// No description provided for @navProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @greetingPrefix.
  ///
  /// In uz, this message translates to:
  /// **'Xayrli kun,'**
  String get greetingPrefix;

  /// No description provided for @pointsLabel.
  ///
  /// In uz, this message translates to:
  /// **'{points} ball'**
  String pointsLabel(int points);

  /// No description provided for @nextLessonBadge.
  ///
  /// In uz, this message translates to:
  /// **'{module} · {number}-dars'**
  String nextLessonBadge(String module, int number);

  /// No description provided for @metaMaterial.
  ///
  /// In uz, this message translates to:
  /// **'Video + matn'**
  String get metaMaterial;

  /// No description provided for @metaQuiz.
  ///
  /// In uz, this message translates to:
  /// **'{count} savolli test'**
  String metaQuiz(int count);

  /// No description provided for @statLessonsDone.
  ///
  /// In uz, this message translates to:
  /// **'darslar yakunlandi'**
  String get statLessonsDone;

  /// No description provided for @statRank.
  ///
  /// In uz, this message translates to:
  /// **'guruh reytingida'**
  String get statRank;

  /// No description provided for @statNotRanked.
  ///
  /// In uz, this message translates to:
  /// **'bu hafta reytingda yo‘q'**
  String get statNotRanked;

  /// No description provided for @tracksTitle.
  ///
  /// In uz, this message translates to:
  /// **'Yo‘nalishlar'**
  String get tracksTitle;

  /// No description provided for @allLessonsLink.
  ///
  /// In uz, this message translates to:
  /// **'Barcha darslar'**
  String get allLessonsLink;

  /// No description provided for @trackLocked.
  ///
  /// In uz, this message translates to:
  /// **'yopiq'**
  String get trackLocked;

  /// No description provided for @trackDigitalStart.
  ///
  /// In uz, this message translates to:
  /// **'Digital Start'**
  String get trackDigitalStart;

  /// No description provided for @trackAiCreative.
  ///
  /// In uz, this message translates to:
  /// **'AI & Creative'**
  String get trackAiCreative;

  /// No description provided for @trackCodeTech.
  ///
  /// In uz, this message translates to:
  /// **'Code & Technology'**
  String get trackCodeTech;

  /// No description provided for @trackOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get trackOther;

  /// No description provided for @homeworkInReviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifasi tekshiruvda'**
  String get homeworkInReviewTitle;

  /// No description provided for @homeworkInReviewBody.
  ///
  /// In uz, this message translates to:
  /// **'«{lesson}» — o‘qituvchi ko‘rib chiqmoqda'**
  String homeworkInReviewBody(String lesson);

  /// No description provided for @homeworkInReviewMany.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta vazifa — o‘qituvchi ko‘rib chiqmoqda'**
  String homeworkInReviewMany(int count);

  /// No description provided for @practiceAllLink.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi'**
  String get practiceAllLink;

  /// No description provided for @lessonPosition.
  ///
  /// In uz, this message translates to:
  /// **'{module} · {index} / {total}'**
  String lessonPosition(String module, int index, int total);

  /// No description provided for @lessonGoalsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugun nimani o‘rganamiz'**
  String get lessonGoalsTitle;

  /// No description provided for @materialCaption.
  ///
  /// In uz, this message translates to:
  /// **'Dars materiali'**
  String get materialCaption;

  /// No description provided for @playMaterial.
  ///
  /// In uz, this message translates to:
  /// **'Materialni ochish'**
  String get playMaterial;

  /// No description provided for @quizCardTitle.
  ///
  /// In uz, this message translates to:
  /// **'Dars testi'**
  String get quizCardTitle;

  /// No description provided for @quizCardBody.
  ///
  /// In uz, this message translates to:
  /// **'{count} savol · {required} tasiga to‘g‘ri javob — keyingi dars ochiladi'**
  String quizCardBody(int count, int required);

  /// No description provided for @quizStartButton.
  ///
  /// In uz, this message translates to:
  /// **'Testni boshlash'**
  String get quizStartButton;

  /// No description provided for @quizRetakeButton.
  ///
  /// In uz, this message translates to:
  /// **'Testni qayta ishlash'**
  String get quizRetakeButton;

  /// No description provided for @homeworkCardTitle.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifasi'**
  String get homeworkCardTitle;

  /// No description provided for @homeworkCardBody.
  ///
  /// In uz, this message translates to:
  /// **'Matn yoki havola yuboring'**
  String get homeworkCardBody;

  /// No description provided for @homeworkSubmitShort.
  ///
  /// In uz, this message translates to:
  /// **'Topshirish'**
  String get homeworkSubmitShort;

  /// No description provided for @lessonViewedButton.
  ///
  /// In uz, this message translates to:
  /// **'Darsni ko‘rdim'**
  String get lessonViewedButton;

  /// No description provided for @myHomeworkLink.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifalarim'**
  String get myHomeworkLink;

  /// No description provided for @parentTitleOne.
  ///
  /// In uz, this message translates to:
  /// **'Farzandim'**
  String get parentTitleOne;

  /// No description provided for @childLessonsOpened.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta dars ochilgan'**
  String childLessonsOpened(int count);

  /// No description provided for @parentProgressTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kurs bo‘yicha o‘zlashtirish'**
  String get parentProgressTitle;

  /// No description provided for @parentProgressCaption.
  ///
  /// In uz, this message translates to:
  /// **'{done} ta dars o‘tildi · {total} tadan'**
  String parentProgressCaption(int done, int total);

  /// No description provided for @percentValue.
  ///
  /// In uz, this message translates to:
  /// **'{value}%'**
  String percentValue(int value);

  /// No description provided for @tileApproved.
  ///
  /// In uz, this message translates to:
  /// **'qabul qilindi'**
  String get tileApproved;

  /// No description provided for @tilePending.
  ///
  /// In uz, this message translates to:
  /// **'tekshiruvda'**
  String get tilePending;

  /// No description provided for @tilePoints.
  ///
  /// In uz, this message translates to:
  /// **'ball'**
  String get tilePoints;

  /// No description provided for @paymentTitle.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov'**
  String get paymentTitle;

  /// No description provided for @paymentPaid.
  ///
  /// In uz, this message translates to:
  /// **'To‘langan'**
  String get paymentPaid;

  /// No description provided for @paymentUnpaid.
  ///
  /// In uz, this message translates to:
  /// **'To‘lanmagan'**
  String get paymentUnpaid;

  /// No description provided for @payClick.
  ///
  /// In uz, this message translates to:
  /// **'Click orqali'**
  String get payClick;

  /// No description provided for @payPayme.
  ///
  /// In uz, this message translates to:
  /// **'Payme orqali'**
  String get payPayme;

  /// No description provided for @paymentContactHint.
  ///
  /// In uz, this message translates to:
  /// **'Onlayn to‘lov tez orada. Hozircha to‘lov bo‘yicha biz bilan bog‘laning.'**
  String get paymentContactHint;

  /// No description provided for @contactButton.
  ///
  /// In uz, this message translates to:
  /// **'Bog‘lanish'**
  String get contactButton;

  /// No description provided for @contactTelegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram orqali yozish'**
  String get contactTelegram;

  /// No description provided for @contactCall.
  ///
  /// In uz, this message translates to:
  /// **'Qo‘ng‘iroq qilish'**
  String get contactCall;

  /// No description provided for @paymentAllPaid.
  ///
  /// In uz, this message translates to:
  /// **'Barcha to‘lovlar amalga oshirilgan'**
  String get paymentAllPaid;

  /// No description provided for @paymentNone.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov ma’lumotlari hali kiritilmagan'**
  String get paymentNone;

  /// No description provided for @paymentRowPaid.
  ///
  /// In uz, this message translates to:
  /// **'{month} — to‘langan'**
  String paymentRowPaid(String month);

  /// No description provided for @paymentRowUnpaid.
  ///
  /// In uz, this message translates to:
  /// **'{month} — to‘lanmagan'**
  String paymentRowUnpaid(String month);

  /// No description provided for @moneySum.
  ///
  /// In uz, this message translates to:
  /// **'{amount} so‘m'**
  String moneySum(String amount);

  /// No description provided for @monthName.
  ///
  /// In uz, this message translates to:
  /// **'{month, select, m1{Yanvar} m2{Fevral} m3{Mart} m4{Aprel} m5{May} m6{Iyun} m7{Iyul} m8{Avgust} m9{Sentabr} m10{Oktabr} m11{Noyabr} m12{Dekabr} other{?}}'**
  String monthName(String month);

  /// No description provided for @monthYear.
  ///
  /// In uz, this message translates to:
  /// **'{month} {year}'**
  String monthYear(String month, int year);

  /// No description provided for @eventsTitle.
  ///
  /// In uz, this message translates to:
  /// **'So‘nggi yangiliklar'**
  String get eventsTitle;

  /// No description provided for @eventsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hali yangiliklar yo‘q'**
  String get eventsEmpty;

  /// No description provided for @eventHomeworkSubmitted.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifasi topshirildi'**
  String get eventHomeworkSubmitted;

  /// No description provided for @eventHomeworkApproved.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifasi qabul qilindi'**
  String get eventHomeworkApproved;

  /// No description provided for @eventHomeworkRejected.
  ///
  /// In uz, this message translates to:
  /// **'Uy vazifasi qaytarildi'**
  String get eventHomeworkRejected;

  /// No description provided for @eventLessonCompleted.
  ///
  /// In uz, this message translates to:
  /// **'Dars yakunlandi'**
  String get eventLessonCompleted;

  /// No description provided for @eventPoints.
  ///
  /// In uz, this message translates to:
  /// **'{points} ball'**
  String eventPoints(String points);

  /// No description provided for @eventPaymentPaid.
  ///
  /// In uz, this message translates to:
  /// **'To‘lov qabul qilindi'**
  String get eventPaymentPaid;

  /// No description provided for @whenToday.
  ///
  /// In uz, this message translates to:
  /// **'Bugun, {time}'**
  String whenToday(String time);

  /// No description provided for @whenYesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha, {time}'**
  String whenYesterday(String time);

  /// No description provided for @noChildrenTitle.
  ///
  /// In uz, this message translates to:
  /// **'Farzand bog‘lanmagan'**
  String get noChildrenTitle;

  /// No description provided for @noChildrenBody.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizga hali farzand bog‘lanmagan. O‘qituvchi yoki administratorga murojaat qiling.'**
  String get noChildrenBody;

  /// No description provided for @navStudents.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchilar'**
  String get navStudents;

  /// No description provided for @navReview.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirish'**
  String get navReview;

  /// No description provided for @navPayments.
  ///
  /// In uz, this message translates to:
  /// **'To‘lovlar'**
  String get navPayments;

  /// No description provided for @searchStudentsHint.
  ///
  /// In uz, this message translates to:
  /// **'Ism bo‘yicha qidirish'**
  String get searchStudentsHint;

  /// No description provided for @studentsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta o‘quvchi'**
  String studentsCount(int count);

  /// No description provided for @noStudentsTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchilar yo‘q'**
  String get noStudentsTitle;

  /// No description provided for @noStudentsBody.
  ///
  /// In uz, this message translates to:
  /// **'Yangi o‘quvchilar saytdagi o‘qituvchi panelida qo‘shiladi.'**
  String get noStudentsBody;

  /// No description provided for @noSearchResults.
  ///
  /// In uz, this message translates to:
  /// **'Hech kim topilmadi'**
  String get noSearchResults;

  /// No description provided for @archivedToggle.
  ///
  /// In uz, this message translates to:
  /// **'Arxiv ({count})'**
  String archivedToggle(int count);

  /// No description provided for @archivedBadge.
  ///
  /// In uz, this message translates to:
  /// **'Arxivda'**
  String get archivedBadge;

  /// No description provided for @teachersButton.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchilar'**
  String get teachersButton;

  /// No description provided for @unassignedTeacher.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchi biriktirilmagan'**
  String get unassignedTeacher;

  /// No description provided for @studentProgressTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘zlashtirish'**
  String get studentProgressTitle;

  /// No description provided for @lessonsAccessTitle.
  ///
  /// In uz, this message translates to:
  /// **'Darslarga kirish'**
  String get lessonsAccessTitle;

  /// No description provided for @lessonsAccessHint.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchi faqat belgilangan darslarni ko‘radi.'**
  String get lessonsAccessHint;

  /// No description provided for @noHomeworkStudent.
  ///
  /// In uz, this message translates to:
  /// **'Vazifa topshirilmagan'**
  String get noHomeworkStudent;

  /// No description provided for @parentsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ota-onalar'**
  String get parentsTitle;

  /// No description provided for @noParents.
  ///
  /// In uz, this message translates to:
  /// **'Ota-ona biriktirilmagan'**
  String get noParents;

  /// No description provided for @parentLogin.
  ///
  /// In uz, this message translates to:
  /// **'Login: {login}'**
  String parentLogin(String login);

  /// No description provided for @certificatesSectionTitle.
  ///
  /// In uz, this message translates to:
  /// **'Sertifikatlar'**
  String get certificatesSectionTitle;

  /// No description provided for @noCertificatesStudent.
  ///
  /// In uz, this message translates to:
  /// **'Hali sertifikat berilmagan'**
  String get noCertificatesStudent;

  /// No description provided for @issueCertificateButton.
  ///
  /// In uz, this message translates to:
  /// **'Sertifikat berish'**
  String get issueCertificateButton;

  /// No description provided for @courseLabel.
  ///
  /// In uz, this message translates to:
  /// **'Kurs'**
  String get courseLabel;

  /// No description provided for @teacherNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchi F.I.Sh.'**
  String get teacherNameLabel;

  /// No description provided for @directorNameLabel.
  ///
  /// In uz, this message translates to:
  /// **'Direktor F.I.Sh.'**
  String get directorNameLabel;

  /// No description provided for @fieldRequired.
  ///
  /// In uz, this message translates to:
  /// **'To‘ldiring'**
  String get fieldRequired;

  /// No description provided for @noCourses.
  ///
  /// In uz, this message translates to:
  /// **'Kurslar hali qo‘shilmagan'**
  String get noCourses;

  /// No description provided for @certificateIssuedMsg.
  ///
  /// In uz, this message translates to:
  /// **'Sertifikat berildi: {id}'**
  String certificateIssuedMsg(String id);

  /// No description provided for @archiveButton.
  ///
  /// In uz, this message translates to:
  /// **'Arxivga olish'**
  String get archiveButton;

  /// No description provided for @archiveTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchini arxivlash'**
  String get archiveTitle;

  /// No description provided for @archiveBody.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchi ilovaga va saytga kira olmaydi, lekin barcha ma’lumotlari saqlanadi. Istalgan vaqtda qaytarish mumkin.'**
  String get archiveBody;

  /// No description provided for @archiveReasonLabel.
  ///
  /// In uz, this message translates to:
  /// **'Sabab (ixtiyoriy)'**
  String get archiveReasonLabel;

  /// No description provided for @unarchiveButton.
  ///
  /// In uz, this message translates to:
  /// **'Arxivdan qaytarish'**
  String get unarchiveButton;

  /// No description provided for @archivedDone.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchi arxivga olindi'**
  String get archivedDone;

  /// No description provided for @unarchivedDone.
  ///
  /// In uz, this message translates to:
  /// **'O‘quvchi qaytarildi'**
  String get unarchivedDone;

  /// No description provided for @cancelButton.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancelButton;

  /// No description provided for @saveButton.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get saveButton;

  /// No description provided for @savedMessage.
  ///
  /// In uz, this message translates to:
  /// **'Saqlandi'**
  String get savedMessage;

  /// No description provided for @teacherLabel.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchi'**
  String get teacherLabel;

  /// No description provided for @changeTeacherTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchini tanlang'**
  String get changeTeacherTitle;

  /// No description provided for @noTeacherOption.
  ///
  /// In uz, this message translates to:
  /// **'Biriktirilmagan'**
  String get noTeacherOption;

  /// No description provided for @teacherChanged.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchi o‘zgartirildi'**
  String get teacherChanged;

  /// No description provided for @reviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalarni tekshirish'**
  String get reviewTitle;

  /// No description provided for @reviewCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta vazifa kutmoqda'**
  String reviewCount(int count);

  /// No description provided for @reviewEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hammasi tekshirildi'**
  String get reviewEmptyTitle;

  /// No description provided for @reviewEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Yangi uy vazifalari kelganda shu yerda paydo bo‘ladi.'**
  String get reviewEmptyBody;

  /// No description provided for @approveButton.
  ///
  /// In uz, this message translates to:
  /// **'Qabul qilish'**
  String get approveButton;

  /// No description provided for @returnButton.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish'**
  String get returnButton;

  /// No description provided for @approveHint.
  ///
  /// In uz, this message translates to:
  /// **'+{points} ball, dars yakunlangan deb belgilanadi'**
  String approveHint(int points);

  /// No description provided for @commentLabel.
  ///
  /// In uz, this message translates to:
  /// **'Izoh'**
  String get commentLabel;

  /// No description provided for @commentOptionalHint.
  ///
  /// In uz, this message translates to:
  /// **'Ixtiyoriy — o‘quvchi ko‘radi'**
  String get commentOptionalHint;

  /// No description provided for @returnCommentHint.
  ///
  /// In uz, this message translates to:
  /// **'Nimani tuzatish kerakligini yozing'**
  String get returnCommentHint;

  /// No description provided for @returnCommentRequired.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish uchun izoh yozing'**
  String get returnCommentRequired;

  /// No description provided for @openLinkButton.
  ///
  /// In uz, this message translates to:
  /// **'Havolani ochish'**
  String get openLinkButton;

  /// No description provided for @unknownStudent.
  ///
  /// In uz, this message translates to:
  /// **'Noma’lum o‘quvchi'**
  String get unknownStudent;

  /// No description provided for @unknownLesson.
  ///
  /// In uz, this message translates to:
  /// **'Noma’lum dars'**
  String get unknownLesson;

  /// No description provided for @groupAccessTitle.
  ///
  /// In uz, this message translates to:
  /// **'Darslarni ochish'**
  String get groupAccessTitle;

  /// No description provided for @groupAccessHint.
  ///
  /// In uz, this message translates to:
  /// **'Darsni barcha o‘quvchilaringizga birdaniga oching yoki yoping. Bitta o‘quvchi uchun — uning kartasida.'**
  String get groupAccessHint;

  /// No description provided for @openCount.
  ///
  /// In uz, this message translates to:
  /// **'{open} / {total} ochiq'**
  String openCount(int open, int total);

  /// No description provided for @openAllButton.
  ///
  /// In uz, this message translates to:
  /// **'Hammaga ochish'**
  String get openAllButton;

  /// No description provided for @closeAllButton.
  ///
  /// In uz, this message translates to:
  /// **'Hammadan yopish'**
  String get closeAllButton;

  /// No description provided for @openAllConfirm.
  ///
  /// In uz, this message translates to:
  /// **'«{lesson}» darsini barcha o‘quvchilarga ochasizmi?'**
  String openAllConfirm(String lesson);

  /// No description provided for @closeAllConfirm.
  ///
  /// In uz, this message translates to:
  /// **'«{lesson}» darsini barcha o‘quvchilardan yopasizmi? Progress va vazifalar saqlanib qoladi.'**
  String closeAllConfirm(String lesson);

  /// No description provided for @noLessonsTeacher.
  ///
  /// In uz, this message translates to:
  /// **'Darslar hali qo‘shilmagan'**
  String get noLessonsTeacher;

  /// No description provided for @prevMonth.
  ///
  /// In uz, this message translates to:
  /// **'Oldingi oy'**
  String get prevMonth;

  /// No description provided for @nextMonth.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi oy'**
  String get nextMonth;

  /// No description provided for @statExpected.
  ///
  /// In uz, this message translates to:
  /// **'kutilmoqda'**
  String get statExpected;

  /// No description provided for @statCollected.
  ///
  /// In uz, this message translates to:
  /// **'yig‘ildi'**
  String get statCollected;

  /// No description provided for @statDebtors.
  ///
  /// In uz, this message translates to:
  /// **'qarzdor'**
  String get statDebtors;

  /// No description provided for @debtorsOnly.
  ///
  /// In uz, this message translates to:
  /// **'Faqat qarzdorlar'**
  String get debtorsOnly;

  /// No description provided for @noDebtors.
  ///
  /// In uz, this message translates to:
  /// **'Bu oyda qarzdorlar yo‘q'**
  String get noDebtors;

  /// No description provided for @paymentNotMarked.
  ///
  /// In uz, this message translates to:
  /// **'belgilanmagan'**
  String get paymentNotMarked;

  /// No description provided for @markPaymentTitle.
  ///
  /// In uz, this message translates to:
  /// **'{name} · {month}'**
  String markPaymentTitle(String name, String month);

  /// No description provided for @amountLabel.
  ///
  /// In uz, this message translates to:
  /// **'Summa, so‘m'**
  String get amountLabel;

  /// No description provided for @amountInvalid.
  ///
  /// In uz, this message translates to:
  /// **'Summani to‘g‘ri kiriting'**
  String get amountInvalid;

  /// No description provided for @amountNotSet.
  ///
  /// In uz, this message translates to:
  /// **'summa belgilanmagan'**
  String get amountNotSet;

  /// No description provided for @teachersTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchilar'**
  String get teachersTitle;

  /// No description provided for @teacherStudentsCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta o‘quvchi'**
  String teacherStudentsCount(int count);

  /// No description provided for @unassignedStudentsTitle.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchisiz o‘quvchilar'**
  String get unassignedStudentsTitle;

  /// No description provided for @noTeachers.
  ///
  /// In uz, this message translates to:
  /// **'O‘qituvchilar yo‘q'**
  String get noTeachers;

  /// No description provided for @pointsTotalLabel.
  ///
  /// In uz, this message translates to:
  /// **'ball'**
  String get pointsTotalLabel;

  /// No description provided for @sectionStartButton.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get sectionStartButton;

  /// No description provided for @sectionOpenVideo.
  ///
  /// In uz, this message translates to:
  /// **'Videoni ochish'**
  String get sectionOpenVideo;

  /// No description provided for @sectionImageMissing.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklanmadi'**
  String get sectionImageMissing;

  /// No description provided for @sectionDiagramBroken.
  ///
  /// In uz, this message translates to:
  /// **'Sxemani ko‘rsatib bo‘lmadi'**
  String get sectionDiagramBroken;

  /// No description provided for @sectionLinkUnavailable.
  ///
  /// In uz, this message translates to:
  /// **'Bu havola ilovada ochilmaydi'**
  String get sectionLinkUnavailable;

  /// No description provided for @attachFileButton.
  ///
  /// In uz, this message translates to:
  /// **'Fayl biriktirish'**
  String get attachFileButton;

  /// No description provided for @attachFileHint.
  ///
  /// In uz, this message translates to:
  /// **'Rasm, PDF, ZIP, .py, .sb3 yoki Office fayli, 10 MB gacha'**
  String get attachFileHint;

  /// No description provided for @removeFileButton.
  ///
  /// In uz, this message translates to:
  /// **'Faylni olib tashlash'**
  String get removeFileButton;

  /// No description provided for @fileTypeNotAllowed.
  ///
  /// In uz, this message translates to:
  /// **'Bu turdagi faylni yuklab bo‘lmaydi'**
  String get fileTypeNotAllowed;

  /// No description provided for @fileEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Fayl bo‘sh'**
  String get fileEmpty;

  /// No description provided for @fileTooLarge.
  ///
  /// In uz, this message translates to:
  /// **'Fayl 10 MB dan katta'**
  String get fileTooLarge;

  /// No description provided for @fileUploadFailed.
  ///
  /// In uz, this message translates to:
  /// **'Faylni yuklab bo‘lmadi. Qaytadan urinib ko‘ring'**
  String get fileUploadFailed;

  /// No description provided for @openFileButton.
  ///
  /// In uz, this message translates to:
  /// **'Faylni ochish'**
  String get openFileButton;

  /// No description provided for @fileNotSaved.
  ///
  /// In uz, this message translates to:
  /// **'Fayl saqlanmagan'**
  String get fileNotSaved;

  /// No description provided for @skillsTitle.
  ///
  /// In uz, this message translates to:
  /// **'Ko‘nikmalar'**
  String get skillsTitle;

  /// No description provided for @skillsSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalarni yechgan sari har bir ko‘nikmangiz darajasi o‘sib boradi.'**
  String get skillsSubtitle;

  /// No description provided for @skillsEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Hali mashq boshlanmagan'**
  String get skillsEmptyTitle;

  /// No description provided for @skillsEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Darsdagi mashq vazifalarini yeching — bu yerda ko‘nikmalaringiz va ularning darajasi paydo bo‘ladi.'**
  String get skillsEmptyBody;

  /// No description provided for @skillsGoToLessons.
  ///
  /// In uz, this message translates to:
  /// **'Darslarga o‘tish'**
  String get skillsGoToLessons;

  /// No description provided for @skillsReviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Takrorlash kerak'**
  String get skillsReviewTitle;

  /// No description provided for @skillsReviewHint.
  ///
  /// In uz, this message translates to:
  /// **'Bu ko‘nikmalar hali mustahkam emas.'**
  String get skillsReviewHint;

  /// No description provided for @skillStateFresh.
  ///
  /// In uz, this message translates to:
  /// **'Boshlanmagan'**
  String get skillStateFresh;

  /// No description provided for @skillStateStart.
  ///
  /// In uz, this message translates to:
  /// **'Boshlang‘ich'**
  String get skillStateStart;

  /// No description provided for @skillStateGrowing.
  ///
  /// In uz, this message translates to:
  /// **'O‘sib bormoqda'**
  String get skillStateGrowing;

  /// No description provided for @skillStateStrong.
  ///
  /// In uz, this message translates to:
  /// **'Mustahkam'**
  String get skillStateStrong;

  /// No description provided for @skillSolvedCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta vazifa yechildi'**
  String skillSolvedCount(int count);

  /// No description provided for @skillsStatPractised.
  ///
  /// In uz, this message translates to:
  /// **'mashq qilingan'**
  String get skillsStatPractised;

  /// No description provided for @skillsStatSolved.
  ///
  /// In uz, this message translates to:
  /// **'yechilgan'**
  String get skillsStatSolved;

  /// No description provided for @skillsStatToRepeat.
  ///
  /// In uz, this message translates to:
  /// **'takrorlash'**
  String get skillsStatToRepeat;

  /// No description provided for @skillsTrackOther.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa'**
  String get skillsTrackOther;

  /// No description provided for @skillsLinkSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'{practised} ta ko‘nikma mashq qilingan, {solved} ta vazifa yechilgan'**
  String skillsLinkSubtitle(int practised, int solved);

  /// No description provided for @skillsLinkEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Vazifalarni yeching — ko‘nikmalaringiz o‘sadi'**
  String get skillsLinkEmpty;

  /// No description provided for @reviewCardTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi takrorlash: {count} ta savol'**
  String reviewCardTitle(int count);

  /// No description provided for @reviewCardSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Bir necha daqiqa — yechgan savollaringizni eslab qoling.'**
  String get reviewCardSubtitle;

  /// No description provided for @reviewCardDone.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi takrorlash bajarildi'**
  String get reviewCardDone;

  /// No description provided for @reviewCardNothing.
  ///
  /// In uz, this message translates to:
  /// **'Bugun takrorlash yo‘q'**
  String get reviewCardNothing;

  /// No description provided for @reviewCardNextHint.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi savollar o‘z vaqtida qaytadi.'**
  String get reviewCardNextHint;

  /// No description provided for @reviewDoneTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugun hammasi tayyor'**
  String get reviewDoneTitle;

  /// No description provided for @reviewDoneBody.
  ///
  /// In uz, this message translates to:
  /// **'Bugun {count} ta savol takrorlandi. Ertaga yangi savollar kutadi.'**
  String reviewDoneBody(int count);

  /// No description provided for @reviewNothingBody.
  ///
  /// In uz, this message translates to:
  /// **'Bugun takrorlanadigan savol yo‘q. Keyingilari o‘z vaqtida keladi.'**
  String get reviewNothingBody;

  /// No description provided for @reviewProgress.
  ///
  /// In uz, this message translates to:
  /// **'Savol {index} / {total}'**
  String reviewProgress(int index, int total);

  /// No description provided for @reviewCheck.
  ///
  /// In uz, this message translates to:
  /// **'Tekshirish'**
  String get reviewCheck;

  /// No description provided for @reviewNext.
  ///
  /// In uz, this message translates to:
  /// **'Keyingi'**
  String get reviewNext;

  /// No description provided for @reviewFinish.
  ///
  /// In uz, this message translates to:
  /// **'Yakunlash'**
  String get reviewFinish;

  /// No description provided for @reviewCorrect.
  ///
  /// In uz, this message translates to:
  /// **'To‘g‘ri!'**
  String get reviewCorrect;

  /// No description provided for @reviewWrong.
  ///
  /// In uz, this message translates to:
  /// **'Noto‘g‘ri. Bu savol ertaga qaytadi.'**
  String get reviewWrong;

  /// No description provided for @reviewFinishedTitle.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi takrorlash tayyor!'**
  String get reviewFinishedTitle;

  /// No description provided for @reviewScore.
  ///
  /// In uz, this message translates to:
  /// **'{total} tadan {right} to‘g‘ri'**
  String reviewScore(int right, int total);

  /// No description provided for @reviewStreak.
  ///
  /// In uz, this message translates to:
  /// **'{days} kun ketma-ket'**
  String reviewStreak(int days);

  /// No description provided for @reviewErrorLimit.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi 10 ta takrorlash bajarildi. Ertaga davom eting.'**
  String get reviewErrorLimit;

  /// No description provided for @reviewErrorNotDue.
  ///
  /// In uz, this message translates to:
  /// **'Bu savol bugun takrorlanmaydi.'**
  String get reviewErrorNotDue;

  /// No description provided for @taskMultiHint.
  ///
  /// In uz, this message translates to:
  /// **'Bir nechta javob bo‘lishi mumkin.'**
  String get taskMultiHint;

  /// No description provided for @taskOrderHint.
  ///
  /// In uz, this message translates to:
  /// **'To‘g‘ri tartibga keltiring: strelkalar bilan siljiting.'**
  String get taskOrderHint;

  /// No description provided for @taskMatchHint.
  ///
  /// In uz, this message translates to:
  /// **'Har bir qatorga juftini tanlang.'**
  String get taskMatchHint;

  /// No description provided for @taskTextHint.
  ///
  /// In uz, this message translates to:
  /// **'Javobingiz'**
  String get taskTextHint;

  /// No description provided for @taskMoveUp.
  ///
  /// In uz, this message translates to:
  /// **'Yuqoriga'**
  String get taskMoveUp;

  /// No description provided for @taskMoveDown.
  ///
  /// In uz, this message translates to:
  /// **'Pastga'**
  String get taskMoveDown;

  /// No description provided for @dailyReviewTitle.
  ///
  /// In uz, this message translates to:
  /// **'Takrorlash'**
  String get dailyReviewTitle;

  /// No description provided for @dailyReviewEmptyTitle.
  ///
  /// In uz, this message translates to:
  /// **'Takrorlash hali yo‘q'**
  String get dailyReviewEmptyTitle;

  /// No description provided for @dailyReviewEmptyBody.
  ///
  /// In uz, this message translates to:
  /// **'Darslardagi mashq vazifalarini yeching — ular shu yerda takrorlash uchun paydo bo‘ladi.'**
  String get dailyReviewEmptyBody;

  /// No description provided for @codeTasksCardTitle.
  ///
  /// In uz, this message translates to:
  /// **'Python mashqlari'**
  String get codeTasksCardTitle;

  /// No description provided for @codeTasksCardBody.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta vazifa · kodni yozing, u shu yerning o‘zida ishga tushadi va tekshiriladi'**
  String codeTasksCardBody(int count);

  /// No description provided for @codeTasksOpenButton.
  ///
  /// In uz, this message translates to:
  /// **'Kod yozishni boshlash'**
  String get codeTasksOpenButton;
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
