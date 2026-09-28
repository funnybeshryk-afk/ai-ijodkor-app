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

  @override
  String get archivedTitle => 'Аккаунт в архиве';

  @override
  String get archivedBody =>
      'Вы больше не числитесь в программе. Если есть вопросы, обратитесь к учителю.';

  @override
  String get navHome => 'Главная';

  @override
  String get navLessons => 'Уроки';

  @override
  String get navHomework => 'Задания';

  @override
  String get navPractice => 'Тренажёры';

  @override
  String get navRating => 'Рейтинг';

  @override
  String greeting(String name) {
    return 'Привет, $name!';
  }

  @override
  String get homeSubtitle => 'Здесь твои уроки и задания на сегодня.';

  @override
  String get statPoints => 'Твои баллы';

  @override
  String get statCompleted => 'Пройдено уроков';

  @override
  String get statPendingHomework => 'На проверке';

  @override
  String get nextLessonTitle => 'Следующий урок';

  @override
  String get allLessonsDone =>
      'Все открытые уроки пройдены! Скоро откроются новые.';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get certificatesTitle => 'Мои сертификаты';

  @override
  String get noLessons => 'Уроки пока не открыты. Учитель скоро откроет их.';

  @override
  String get statusNotStarted => 'Не начат';

  @override
  String get statusViewed => 'Просмотрен';

  @override
  String get statusInProgress => 'В процессе';

  @override
  String get statusCompleted => 'Пройден';

  @override
  String get lessonMaterialTitle => 'Материал урока';

  @override
  String get openMaterialButton => 'Открыть материал';

  @override
  String get noMaterial => 'К этому уроку не прикреплён материал.';

  @override
  String get openInBrowser => 'Открыть в браузере';

  @override
  String get markCompletedButton => 'Я прошёл урок';

  @override
  String get lessonNotFound => 'Урок не найден или ещё не открыт.';

  @override
  String get quizTitle => 'Тест';

  @override
  String get quizHint =>
      'Ответь правильно на достаточное число вопросов — урок будет пройден, и откроется следующий.';

  @override
  String get quizAnswerHint => 'Твой ответ';

  @override
  String get quizSubmitButton => 'Проверить';

  @override
  String get quizAnswerAll => 'Ответь на все вопросы.';

  @override
  String quizScore(int correct, int total) {
    return '$correct / $total верно';
  }

  @override
  String get quizPassed => 'Молодец! Урок пройден.';

  @override
  String get quizNextUnlocked => 'Открыт следующий урок!';

  @override
  String quizFailed(int required) {
    return 'Нужно минимум $required верных ответов. Попробуй ещё раз!';
  }

  @override
  String get quizRetryButton => 'Попробовать снова';

  @override
  String get quizAlreadyCompleted =>
      'Урок уже пройден. Можно пройти тест ещё раз.';

  @override
  String quizQuestionNumber(int number) {
    return 'Вопрос $number';
  }

  @override
  String get homeworkTitle => 'Домашние задания';

  @override
  String get homeworkForLessonTitle => 'Задания по этому уроку';

  @override
  String get submitHomeworkButton => 'Сдать задание';

  @override
  String get homeworkLessonLabel => 'Урок';

  @override
  String get homeworkTextLabel => 'Ответ или ссылка';

  @override
  String get homeworkTextHint => 'Напиши ответ или вставь ссылку на проект';

  @override
  String get homeworkTextRequired => 'Введите ответ';

  @override
  String get homeworkSent => 'Задание отправлено!';

  @override
  String get sendButton => 'Отправить';

  @override
  String get noHomework => 'Ты ещё не сдавал заданий.';

  @override
  String get homeworkPending => 'На проверке';

  @override
  String get homeworkApproved => 'Принято';

  @override
  String get homeworkRejected => 'Возвращено';

  @override
  String teacherNote(String note) {
    return 'Комментарий учителя: $note';
  }

  @override
  String get practiceTitle => 'Тренажёры';

  @override
  String get practiceSubtitle =>
      'Тренажёры — не уроки и не влияют на прогресс. Играй и учись!';

  @override
  String get platformNotConfigured => 'Для тренажёров не задан PLATFORM_URL.';

  @override
  String get trackBasics => 'Компьютер и базовые навыки';

  @override
  String get trackPython => 'Python';

  @override
  String get trackLogic => 'Логика и критическое мышление';

  @override
  String get trackAi => 'ИИ и промптинг';

  @override
  String get trainerTyping => 'Клавиатурный тренажёр';

  @override
  String get trainerMouse => 'Тренажёр мыши';

  @override
  String get trainerShortcuts => 'Горячие клавиши';

  @override
  String get trainerFilesFolders => 'Файлы и папки';

  @override
  String get trainerInternetSafety => 'Безопасность в интернете';

  @override
  String get trainerGodot => 'Понятия Godot';

  @override
  String get trainerPython => 'Тренажёр Python';

  @override
  String get trainerCodeOutput => 'Результат кода';

  @override
  String get trainerDebug => 'Найди ошибку';

  @override
  String get trainerPythonBrain => 'Проверь знание Python';

  @override
  String get trainerLogic => 'Тренажёр логики';

  @override
  String get trainerCriticalThinking => 'Факт или мнение?';

  @override
  String get trainerPrompting => 'Тренажёр промптов';

  @override
  String get trainerPromptChecklist => 'Проверка промпта';

  @override
  String get trainerExperimentLab => 'Сравнение промптов';

  @override
  String get trainerTeacherSimulator => 'Объясни ИИ-ученику';

  @override
  String get ratingTitle => 'Рейтинг класса';

  @override
  String get ratingSubtitle =>
      'Баллы за тренажёры на этой неделе. Обновляется каждый понедельник.';

  @override
  String get ratingEmpty =>
      'На этой неделе ещё никто не занимался. Будь первым!';

  @override
  String get ratingYou => 'Ты';

  @override
  String ratingScore(int score) {
    return '$score баллов';
  }

  @override
  String get noCertificates =>
      'Сертификатов пока нет. Они появятся здесь после окончания курса.';

  @override
  String certificateNumber(String id) {
    return 'Номер: $id';
  }

  @override
  String certificateIssued(String date) {
    return 'Дата выдачи: $date';
  }

  @override
  String certificateTeacher(String name) {
    return 'Учитель: $name';
  }

  @override
  String get certificateVerifyButton => 'Посмотреть сертификат';
}
