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

  @override
  String get logoLabel => 'Знак AI Ijodkor';

  @override
  String get loginTagline =>
      'Искусственный интеллект и программирование — для учеников, родителей и учителей';

  @override
  String get loginNote =>
      'Логин и пароль выдаёт учитель. Родители входят здесь же.';

  @override
  String get emailHint => 'imya@primer.uz';

  @override
  String get showPassword => 'Показать пароль';

  @override
  String get hidePassword => 'Скрыть пароль';

  @override
  String get backLabel => 'Назад';

  @override
  String get navProfile => 'Профиль';

  @override
  String get greetingPrefix => 'Добрый день,';

  @override
  String pointsLabel(int points) {
    return '$points баллов';
  }

  @override
  String nextLessonBadge(String module, int number) {
    return '$module · урок $number';
  }

  @override
  String get metaMaterial => 'Видео + текст';

  @override
  String metaQuiz(int count) {
    return 'Тест: $count вопр.';
  }

  @override
  String get statLessonsDone => 'уроков пройдено';

  @override
  String get statRank => 'в рейтинге группы';

  @override
  String get statNotRanked => 'на этой неделе нет в рейтинге';

  @override
  String get tracksTitle => 'Направления';

  @override
  String get allLessonsLink => 'Все уроки';

  @override
  String get trackLocked => 'закрыто';

  @override
  String get trackDigitalStart => 'Digital Start';

  @override
  String get trackAiCreative => 'AI & Creative';

  @override
  String get trackCodeTech => 'Code & Technology';

  @override
  String get trackOther => 'Другое';

  @override
  String get homeworkInReviewTitle => 'Домашка на проверке';

  @override
  String homeworkInReviewBody(String lesson) {
    return '«$lesson» — учитель проверяет';
  }

  @override
  String homeworkInReviewMany(int count) {
    return '$count заданий — учитель проверяет';
  }

  @override
  String get practiceAllLink => 'Все';

  @override
  String lessonPosition(String module, int index, int total) {
    return '$module · $index / $total';
  }

  @override
  String get lessonGoalsTitle => 'Что изучаем сегодня';

  @override
  String get materialCaption => 'Материал урока';

  @override
  String get playMaterial => 'Открыть материал';

  @override
  String get quizCardTitle => 'Тест по уроку';

  @override
  String quizCardBody(int count, int required) {
    return '$count вопр. · $required верных — откроется следующий урок';
  }

  @override
  String get quizStartButton => 'Начать тест';

  @override
  String get quizRetakeButton => 'Пройти тест снова';

  @override
  String get homeworkCardTitle => 'Домашнее задание';

  @override
  String get homeworkCardBody => 'Отправь текст или ссылку';

  @override
  String get homeworkSubmitShort => 'Сдать';

  @override
  String get lessonViewedButton => 'Я посмотрел урок';

  @override
  String get myHomeworkLink => 'Мои задания';

  @override
  String get parentTitleOne => 'Мой ребёнок';

  @override
  String childLessonsOpened(int count) {
    return 'Открыто уроков: $count';
  }

  @override
  String get parentProgressTitle => 'Освоение курса';

  @override
  String parentProgressCaption(int done, int total) {
    return 'Пройдено уроков: $done из $total';
  }

  @override
  String percentValue(int value) {
    return '$value%';
  }

  @override
  String get tileApproved => 'принято';

  @override
  String get tilePending => 'на проверке';

  @override
  String get tilePoints => 'баллов';

  @override
  String get paymentTitle => 'Оплата';

  @override
  String get paymentPaid => 'Оплачено';

  @override
  String get paymentUnpaid => 'Не оплачено';

  @override
  String get payClick => 'Через Click';

  @override
  String get payPayme => 'Через Payme';

  @override
  String get paymentContactHint =>
      'Онлайн-оплата скоро появится. Пока по оплате свяжитесь с нами.';

  @override
  String get contactButton => 'Связаться';

  @override
  String get contactTelegram => 'Написать в Telegram';

  @override
  String get contactCall => 'Позвонить';

  @override
  String get paymentAllPaid => 'Все платежи внесены';

  @override
  String get paymentNone => 'Данных об оплате пока нет';

  @override
  String paymentRowPaid(String month) {
    return '$month — оплачено';
  }

  @override
  String paymentRowUnpaid(String month) {
    return '$month — не оплачено';
  }

  @override
  String moneySum(String amount) {
    return '$amount сум';
  }

  @override
  String monthName(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Январь',
      'm2': 'Февраль',
      'm3': 'Март',
      'm4': 'Апрель',
      'm5': 'Май',
      'm6': 'Июнь',
      'm7': 'Июль',
      'm8': 'Август',
      'm9': 'Сентябрь',
      'm10': 'Октябрь',
      'm11': 'Ноябрь',
      'm12': 'Декабрь',
      'other': '?',
    });
    return '$_temp0';
  }

  @override
  String monthYear(String month, int year) {
    return '$month $year';
  }

  @override
  String get eventsTitle => 'Последние события';

  @override
  String get eventsEmpty => 'Событий пока нет';

  @override
  String get eventHomeworkSubmitted => 'Домашнее задание сдано';

  @override
  String get eventHomeworkApproved => 'Домашнее задание принято';

  @override
  String get eventHomeworkRejected => 'Домашнее задание возвращено';

  @override
  String get eventLessonCompleted => 'Урок пройден';

  @override
  String eventPoints(String points) {
    return '$points баллов';
  }

  @override
  String get eventPaymentPaid => 'Оплата получена';

  @override
  String whenToday(String time) {
    return 'Сегодня, $time';
  }

  @override
  String whenYesterday(String time) {
    return 'Вчера, $time';
  }

  @override
  String get noChildrenTitle => 'Ребёнок не привязан';

  @override
  String get noChildrenBody =>
      'К вашему аккаунту пока не привязан ребёнок. Обратитесь к учителю или администратору.';

  @override
  String get navStudents => 'Ученики';

  @override
  String get navReview => 'Проверка';

  @override
  String get navPayments => 'Оплаты';

  @override
  String get searchStudentsHint => 'Поиск по имени';

  @override
  String studentsCount(int count) {
    return 'Учеников: $count';
  }

  @override
  String get noStudentsTitle => 'Учеников пока нет';

  @override
  String get noStudentsBody =>
      'Новых учеников добавляют в панели учителя на сайте.';

  @override
  String get noSearchResults => 'Никого не найдено';

  @override
  String archivedToggle(int count) {
    return 'Архив ($count)';
  }

  @override
  String get archivedBadge => 'В архиве';

  @override
  String get teachersButton => 'Учителя';

  @override
  String get unassignedTeacher => 'Учитель не назначен';

  @override
  String get studentProgressTitle => 'Успеваемость';

  @override
  String get lessonsAccessTitle => 'Доступ к урокам';

  @override
  String get lessonsAccessHint => 'Ученик видит только отмеченные уроки.';

  @override
  String get noHomeworkStudent => 'Заданий пока нет';

  @override
  String get parentsTitle => 'Родители';

  @override
  String get noParents => 'Родители не привязаны';

  @override
  String parentLogin(String login) {
    return 'Логин: $login';
  }

  @override
  String get certificatesSectionTitle => 'Сертификаты';

  @override
  String get noCertificatesStudent => 'Сертификатов ещё нет';

  @override
  String get issueCertificateButton => 'Выдать сертификат';

  @override
  String get courseLabel => 'Курс';

  @override
  String get teacherNameLabel => 'ФИО учителя';

  @override
  String get directorNameLabel => 'ФИО директора';

  @override
  String get fieldRequired => 'Заполните поле';

  @override
  String get noCourses => 'Курсов пока нет';

  @override
  String certificateIssuedMsg(String id) {
    return 'Сертификат выдан: $id';
  }

  @override
  String get archiveButton => 'В архив';

  @override
  String get archiveTitle => 'Архивировать ученика';

  @override
  String get archiveBody =>
      'Ученик не сможет войти в приложение и на сайт, но все данные сохранятся. Вернуть можно в любой момент.';

  @override
  String get archiveReasonLabel => 'Причина (необязательно)';

  @override
  String get unarchiveButton => 'Вернуть из архива';

  @override
  String get archivedDone => 'Ученик в архиве';

  @override
  String get unarchivedDone => 'Ученик возвращён';

  @override
  String get cancelButton => 'Отмена';

  @override
  String get saveButton => 'Сохранить';

  @override
  String get savedMessage => 'Сохранено';

  @override
  String get teacherLabel => 'Учитель';

  @override
  String get changeTeacherTitle => 'Выберите учителя';

  @override
  String get noTeacherOption => 'Без учителя';

  @override
  String get teacherChanged => 'Учитель изменён';

  @override
  String get reviewTitle => 'Проверка заданий';

  @override
  String reviewCount(int count) {
    return 'Ждут проверки: $count';
  }

  @override
  String get reviewEmptyTitle => 'Всё проверено';

  @override
  String get reviewEmptyBody => 'Новые домашние задания появятся здесь.';

  @override
  String get approveButton => 'Принять';

  @override
  String get returnButton => 'Вернуть';

  @override
  String approveHint(int points) {
    return '+$points баллов, урок будет отмечен как завершённый';
  }

  @override
  String get commentLabel => 'Комментарий';

  @override
  String get commentOptionalHint => 'Необязательно — ученик увидит';

  @override
  String get returnCommentHint => 'Напишите, что нужно исправить';

  @override
  String get returnCommentRequired => 'Чтобы вернуть, напишите комментарий';

  @override
  String get openLinkButton => 'Открыть ссылку';

  @override
  String get unknownStudent => 'Неизвестный ученик';

  @override
  String get unknownLesson => 'Неизвестный урок';

  @override
  String get groupAccessTitle => 'Открытие уроков';

  @override
  String get groupAccessHint =>
      'Откройте или закройте урок сразу всем вашим ученикам. Для одного ученика — в его карточке.';

  @override
  String openCount(int open, int total) {
    return 'Открыт: $open из $total';
  }

  @override
  String get openAllButton => 'Открыть всем';

  @override
  String get closeAllButton => 'Закрыть всем';

  @override
  String openAllConfirm(String lesson) {
    return 'Открыть урок «$lesson» всем ученикам?';
  }

  @override
  String closeAllConfirm(String lesson) {
    return 'Закрыть урок «$lesson» для всех учеников? Прогресс и задания сохранятся.';
  }

  @override
  String get noLessonsTeacher => 'Уроков пока нет';

  @override
  String get prevMonth => 'Предыдущий месяц';

  @override
  String get nextMonth => 'Следующий месяц';

  @override
  String get statExpected => 'ожидается';

  @override
  String get statCollected => 'собрано';

  @override
  String get statDebtors => 'должники';

  @override
  String get debtorsOnly => 'Только должники';

  @override
  String get noDebtors => 'В этом месяце должников нет';

  @override
  String get paymentNotMarked => 'не отмечено';

  @override
  String markPaymentTitle(String name, String month) {
    return '$name · $month';
  }

  @override
  String get amountLabel => 'Сумма, сум';

  @override
  String get amountInvalid => 'Введите корректную сумму';

  @override
  String get teachersTitle => 'Учителя';

  @override
  String teacherStudentsCount(int count) {
    return 'Учеников: $count';
  }

  @override
  String get unassignedStudentsTitle => 'Ученики без учителя';

  @override
  String get noTeachers => 'Учителей пока нет';

  @override
  String get pointsTotalLabel => 'баллов';

  @override
  String get sectionStartButton => 'Начать';

  @override
  String get sectionOpenVideo => 'Открыть видео';

  @override
  String get sectionImageMissing => 'Картинка не загрузилась';

  @override
  String get sectionDiagramBroken => 'Не удалось показать схему';

  @override
  String get sectionLinkUnavailable => 'Эта ссылка не открывается в приложении';
}
