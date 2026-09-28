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

  @override
  String get archivedTitle => 'Hisob arxivlangan';

  @override
  String get archivedBody =>
      'Siz o‘quv dasturidan chiqarilgansiz. Savollar bo‘lsa, o‘qituvchingizga murojaat qiling.';

  @override
  String get navHome => 'Bosh sahifa';

  @override
  String get navLessons => 'Darslar';

  @override
  String get navHomework => 'Vazifalar';

  @override
  String get navPractice => 'Mashqlar';

  @override
  String get navRating => 'Reyting';

  @override
  String greeting(String name) {
    return 'Salom, $name!';
  }

  @override
  String get homeSubtitle =>
      'Bugungi darslaringiz va vazifalaringiz shu yerda.';

  @override
  String get statPoints => 'Ballaringiz';

  @override
  String get statCompleted => 'Yakunlangan darslar';

  @override
  String get statPendingHomework => 'Tekshirilmoqda';

  @override
  String get nextLessonTitle => 'Keyingi dars';

  @override
  String get allLessonsDone =>
      'Barcha ochiq darslar yakunlandi! Yangi darslar tez orada ochiladi.';

  @override
  String get continueButton => 'Davom etish';

  @override
  String get certificatesTitle => 'Sertifikatlarim';

  @override
  String get noLessons =>
      'Sizga hali dars ochilmagan. O‘qituvchingiz tez orada ochib beradi.';

  @override
  String get statusNotStarted => 'Boshlanmagan';

  @override
  String get statusViewed => 'Ko‘rilgan';

  @override
  String get statusInProgress => 'Jarayonda';

  @override
  String get statusCompleted => 'Yakunlangan';

  @override
  String get lessonMaterialTitle => 'Dars materiali';

  @override
  String get openMaterialButton => 'Materialni ochish';

  @override
  String get noMaterial => 'Bu dars uchun material biriktirilmagan.';

  @override
  String get openInBrowser => 'Brauzerda ochish';

  @override
  String get markCompletedButton => 'Darsni yakunladim';

  @override
  String get lessonNotFound => 'Dars topilmadi yoki sizga hali ochilmagan.';

  @override
  String get quizTitle => 'Test';

  @override
  String get quizHint =>
      'Savollarga yetarli darajada to‘g‘ri javob bersangiz, dars yakunlanadi va keyingi dars ochiladi.';

  @override
  String get quizAnswerHint => 'Javobingiz';

  @override
  String get quizSubmitButton => 'Tekshirish';

  @override
  String get quizAnswerAll => 'Barcha savollarga javob bering.';

  @override
  String quizScore(int correct, int total) {
    return '$correct / $total to‘g‘ri';
  }

  @override
  String get quizPassed => 'Barakalla! Dars yakunlandi.';

  @override
  String get quizNextUnlocked => 'Keyingi dars ochildi!';

  @override
  String quizFailed(int required) {
    return 'O‘tish uchun kamida $required ta to‘g‘ri javob kerak. Yana urinib ko‘ring!';
  }

  @override
  String get quizRetryButton => 'Qaytadan urinish';

  @override
  String get quizAlreadyCompleted =>
      'Bu dars allaqachon yakunlangan. Xohlasangiz testni qayta ishlashingiz mumkin.';

  @override
  String quizQuestionNumber(int number) {
    return '$number-savol';
  }

  @override
  String get homeworkTitle => 'Uy vazifalari';

  @override
  String get homeworkForLessonTitle => 'Shu dars bo‘yicha vazifalar';

  @override
  String get submitHomeworkButton => 'Vazifa topshirish';

  @override
  String get homeworkLessonLabel => 'Dars';

  @override
  String get homeworkTextLabel => 'Javob yoki havola';

  @override
  String get homeworkTextHint =>
      'Javobingizni yozing yoki loyiha havolasini qo‘ying';

  @override
  String get homeworkTextRequired => 'Javobingizni kiriting';

  @override
  String get homeworkSent => 'Vazifa yuborildi!';

  @override
  String get sendButton => 'Yuborish';

  @override
  String get noHomework => 'Hali vazifa topshirmagansiz.';

  @override
  String get homeworkPending => 'Tekshirilmoqda';

  @override
  String get homeworkApproved => 'Qabul qilindi';

  @override
  String get homeworkRejected => 'Qaytarildi';

  @override
  String teacherNote(String note) {
    return 'O‘qituvchi izohi: $note';
  }

  @override
  String get practiceTitle => 'Mashqlar';

  @override
  String get practiceSubtitle =>
      'Mashqlar — dars emas, progressga ta’sir qilmaydi. O‘ynang va o‘rganing!';

  @override
  String get platformNotConfigured =>
      'Mashqlar uchun PLATFORM_URL sozlanmagan.';

  @override
  String get trackBasics => 'Kompyuter va boshlang‘ich ko‘nikmalar';

  @override
  String get trackPython => 'Python';

  @override
  String get trackLogic => 'Mantiq va tanqidiy fikrlash';

  @override
  String get trackAi => 'AI va promptlash';

  @override
  String get trainerTyping => 'Klaviatura trenajori';

  @override
  String get trainerMouse => 'Sichqoncha trenajori';

  @override
  String get trainerShortcuts => 'Tezkor tugmalar';

  @override
  String get trainerFilesFolders => 'Fayllar va papkalar';

  @override
  String get trainerInternetSafety => 'Internetda xavfsizlik';

  @override
  String get trainerGodot => 'Godot tushunchalari';

  @override
  String get trainerPython => 'Python trenajori';

  @override
  String get trainerCodeOutput => 'Kod natijasi';

  @override
  String get trainerDebug => 'Xatoni toping';

  @override
  String get trainerPythonBrain => 'Python miyasini sinash';

  @override
  String get trainerLogic => 'Mantiq trenajori';

  @override
  String get trainerCriticalThinking => 'Fakt yoki fikr?';

  @override
  String get trainerPrompting => 'Promptlash trenajori';

  @override
  String get trainerPromptChecklist => 'Prompt tekshiruvchisi';

  @override
  String get trainerExperimentLab => 'Promptni solishtirish';

  @override
  String get trainerTeacherSimulator => 'AI-shogirdga tushuntirish';

  @override
  String get ratingTitle => 'Sinfdagi reyting';

  @override
  String get ratingSubtitle =>
      'Shu haftadagi mashqlar ballari. Har dushanba yangilanadi.';

  @override
  String get ratingEmpty =>
      'Bu hafta hali hech kim mashq qilmadi. Birinchi bo‘ling!';

  @override
  String get ratingYou => 'Siz';

  @override
  String ratingScore(int score) {
    return '$score ball';
  }

  @override
  String get noCertificates =>
      'Hali sertifikatingiz yo‘q. Kursni tugatsangiz, shu yerda paydo bo‘ladi.';

  @override
  String certificateNumber(String id) {
    return 'Raqami: $id';
  }

  @override
  String certificateIssued(String date) {
    return 'Berilgan sana: $date';
  }

  @override
  String certificateTeacher(String name) {
    return 'O‘qituvchi: $name';
  }

  @override
  String get certificateVerifyButton => 'Sertifikatni ko‘rish';

  @override
  String get logoLabel => 'AI Ijodkor belgisi';

  @override
  String get loginTagline =>
      'Sun’iy intellekt va dasturlash — o‘quvchilar, ota-onalar va o‘qituvchilar uchun';

  @override
  String get loginNote =>
      'Login va parolni o‘qituvchingiz beradi. Ota-onalar ham shu yerdan kiradi.';

  @override
  String get emailHint => 'ism@misol.uz';

  @override
  String get showPassword => 'Parolni ko‘rsatish';

  @override
  String get hidePassword => 'Parolni yashirish';

  @override
  String get backLabel => 'Orqaga';

  @override
  String get navProfile => 'Profil';

  @override
  String get greetingPrefix => 'Xayrli kun,';

  @override
  String pointsLabel(int points) {
    return '$points ball';
  }

  @override
  String nextLessonBadge(String module, int number) {
    return '$module · $number-dars';
  }

  @override
  String get metaMaterial => 'Video + matn';

  @override
  String metaQuiz(int count) {
    return '$count savolli test';
  }

  @override
  String get statLessonsDone => 'darslar yakunlandi';

  @override
  String get statRank => 'guruh reytingida';

  @override
  String get statNotRanked => 'bu hafta reytingda yo‘q';

  @override
  String get tracksTitle => 'Yo‘nalishlar';

  @override
  String get allLessonsLink => 'Barcha darslar';

  @override
  String get trackLocked => 'yopiq';

  @override
  String get trackDigitalStart => 'Digital Start';

  @override
  String get trackAiCreative => 'AI & Creative';

  @override
  String get trackCodeTech => 'Code & Technology';

  @override
  String get trackOther => 'Boshqa';

  @override
  String get homeworkInReviewTitle => 'Uy vazifasi tekshiruvda';

  @override
  String homeworkInReviewBody(String lesson) {
    return '«$lesson» — o‘qituvchi ko‘rib chiqmoqda';
  }

  @override
  String homeworkInReviewMany(int count) {
    return '$count ta vazifa — o‘qituvchi ko‘rib chiqmoqda';
  }

  @override
  String get practiceAllLink => 'Hammasi';

  @override
  String lessonPosition(String module, int index, int total) {
    return '$module · $index / $total';
  }

  @override
  String get lessonGoalsTitle => 'Bugun nimani o‘rganamiz';

  @override
  String get materialCaption => 'Dars materiali';

  @override
  String get playMaterial => 'Materialni ochish';

  @override
  String get quizCardTitle => 'Dars testi';

  @override
  String quizCardBody(int count, int required) {
    return '$count savol · $required tasiga to‘g‘ri javob — keyingi dars ochiladi';
  }

  @override
  String get quizStartButton => 'Testni boshlash';

  @override
  String get quizRetakeButton => 'Testni qayta ishlash';

  @override
  String get homeworkCardTitle => 'Uy vazifasi';

  @override
  String get homeworkCardBody => 'Matn yoki havola yuboring';

  @override
  String get homeworkSubmitShort => 'Topshirish';

  @override
  String get lessonViewedButton => 'Darsni ko‘rdim';

  @override
  String get myHomeworkLink => 'Uy vazifalarim';

  @override
  String get parentSectionBody =>
      'Ota-onalar bo‘limi ilovaning keyingi versiyasida ochiladi. Hozircha farzandingiz natijalarini saytda ko‘ring.';

  @override
  String get teacherSectionBody =>
      'O‘qituvchi bo‘limi ilovaning keyingi versiyasida ochiladi. Hozircha o‘quvchilar va vazifalarni saytda boshqaring.';

  @override
  String get openPlatformButton => 'Saytda ochish';

  @override
  String get parentTitleOne => 'Farzandim';

  @override
  String childLessonsOpened(int count) {
    return '$count ta dars ochilgan';
  }

  @override
  String get parentProgressTitle => 'Kurs bo‘yicha o‘zlashtirish';

  @override
  String parentProgressCaption(int done, int total) {
    return '$done ta dars o‘tildi · $total tadan';
  }

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get tileApproved => 'qabul qilindi';

  @override
  String get tilePending => 'tekshiruvda';

  @override
  String get tilePoints => 'ball';

  @override
  String get paymentTitle => 'To‘lov';

  @override
  String get paymentPaid => 'To‘langan';

  @override
  String get paymentUnpaid => 'To‘lanmagan';

  @override
  String get payClick => 'Click orqali';

  @override
  String get payPayme => 'Payme orqali';

  @override
  String get paymentContactHint =>
      'Onlayn to‘lov tez orada. Hozircha to‘lov bo‘yicha biz bilan bog‘laning.';

  @override
  String get contactButton => 'Bog‘lanish';

  @override
  String get contactTelegram => 'Telegram orqali yozish';

  @override
  String get contactCall => 'Qo‘ng‘iroq qilish';

  @override
  String get paymentAllPaid => 'Barcha to‘lovlar amalga oshirilgan';

  @override
  String get paymentNone => 'To‘lov ma’lumotlari hali kiritilmagan';

  @override
  String paymentRowPaid(String month) {
    return '$month — to‘langan';
  }

  @override
  String paymentRowUnpaid(String month) {
    return '$month — to‘lanmagan';
  }

  @override
  String moneySum(String amount) {
    return '$amount so‘m';
  }

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Yanvar',
      'm2': 'Fevral',
      'm3': 'Mart',
      'm4': 'Aprel',
      'm5': 'May',
      'm6': 'Iyun',
      'm7': 'Iyul',
      'm8': 'Avgust',
      'm9': 'Sentabr',
      'm10': 'Oktabr',
      'm11': 'Noyabr',
      'm12': 'Dekabr',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String monthYear(String month, int year) {
    return '$month $year';
  }

  @override
  String get eventsTitle => 'So‘nggi yangiliklar';

  @override
  String get eventsEmpty => 'Hali yangiliklar yo‘q';

  @override
  String get eventHomeworkSubmitted => 'Uy vazifasi topshirildi';

  @override
  String get eventHomeworkApproved => 'Uy vazifasi qabul qilindi';

  @override
  String get eventHomeworkRejected => 'Uy vazifasi qaytarildi';

  @override
  String get eventLessonCompleted => 'Dars yakunlandi';

  @override
  String eventPoints(String points) {
    return '$points ball';
  }

  @override
  String get eventPaymentPaid => 'To‘lov qabul qilindi';

  @override
  String whenToday(String time) {
    return 'Bugun, $time';
  }

  @override
  String whenYesterday(String time) {
    return 'Kecha, $time';
  }

  @override
  String get noChildrenTitle => 'Farzand bog‘lanmagan';

  @override
  String get noChildrenBody =>
      'Hisobingizga hali farzand bog‘lanmagan. O‘qituvchi yoki administratorga murojaat qiling.';
}
