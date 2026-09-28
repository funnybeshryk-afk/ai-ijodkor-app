# AI IJODKOR — мобильное приложение (Flutter)

Мобильное приложение образовательной программы **AI IJODKOR** (Python и ИИ для детей 7–18 лет,
ООО «AI IJODKOR LAB», Фергана). Работает поверх **той же базы Supabase**, что и веб-платформа
`funnybeshryk-afk/ai-ijodkor-platform`. Своего бэкенда у приложения нет.

## Стек
- Flutter (стабильная версия), Dart, null-safety. Цели: Android (в первую очередь), iOS.
- `supabase_flutter` — авторизация и данные.
- Состояние: `flutter_riverpod`. Навигация: `go_router` (редирект по роли).
- Локализация: `flutter_localizations` + ARB (`lib/l10n/app_uz.arb`, `app_ru.arb`).
  **Узбекский (латиница) — язык по умолчанию**, русский — второй; переключатель в профиле.
- Тренажёры и видео: `webview_flutter` (тренажёры не переписываем — открываем страницы платформы).
- Ключи — только через `--dart-define` (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, `PLATFORM_URL`).
  Никогда не коммитить ключи. **service_role ключ в приложении запрещён.**

## Структура
```
lib/
  main.dart
  core/        (supabase init, router, theme, l10n)
  data/        (models + repositories — по одному на таблицу/домен)
  features/
    auth/      (вход, восстановление пароля)
    student/   (главная, уроки, урок, тест, домашка, тренажёры, рейтинг, сертификаты)
    parent/    (дети, прогресс, домашки, оплаты)
    teacher/   (ученики, проверка домашек, выдача доступа к урокам)
    partner/   (позже — роли пока нет в БД)
  widgets/     (общие компоненты)
```

## База данных (Supabase, источник правды — ai-ijodkor-platform/supabase/migrations)
Рабочий проект: `ai-ijodkor-platform`, URL `https://coojogmncenhkrvytyzz.supabase.co`
(не путать со старым проектом `ai-ijodkor` / jyivrotkqulvcdnwweed — он на паузе и не используется).
Роли в `profiles.role`: `student | parent | teacher | admin` (admin использует экраны учителя).
Таблицы: `profiles` (teacher_id, archived_at), `parent_child_links`, `lessons` (module, order_index,
content_url), `lesson_access` (ученик видит урок только при наличии строки), `lesson_progress`
(not_started|viewed|in_progress|completed), `lesson_assignments` (тест к уроку, 1–5 вопросов),
`homework_submissions` (pending|approved|rejected), `points_ledger`, `payments` (period 'YYYY-MM',
paid|unpaid), `certificates`, `courses`, `trainer_sessions`, `constructor_projects`.
RPC: `get_class_leaderboard()`, `get_certificate_for_verification(cert_id)`.
Все доступы защищены RLS — приложение работает под anon-ключом и сессией пользователя.

### Важно по безопасности
- `lesson_assignments.correct_answer` ученику отдавать **нельзя**. Веб-платформа читает его
  админ-клиентом на сервере. Для приложения проверку теста делать через серверный
  эндпоинт платформы или Supabase RPC/Edge Function (`security definer`), который
  возвращает только результат. Не ослаблять RLS ради приложения.
- Новые изменения схемы — только миграциями в репозитории платформы (следующий номер 0019+).

## Тренажёры (WebView)
Страницы платформы: `/student/practice/<key>`, ключи: typing, mouse, shortcuts, files-folders,
logic, python, python-brain, code-output, debug, prompting, prompt-checklist, critical-thinking,
internet-safety, experiment-lab, teacher-simulator, godot. Сессию Supabase передавать в WebView,
чтобы ученик не входил повторно.

## Дизайн (обязательно — приложение не должно выглядеть «сгенерированным»)
Источник правды — брендбук «AI Ijodkor brend kitobi» (https://claude.ai/artifact/PL6Y68t2ftUzKPYRfzi9H1)
и утверждённые макеты экранов (https://claude.ai/artifact/ExYrUVJJhAWR1mi5DYe5iK). Верстать по макетам.
- Цвета (светлая тема): фон `#FFFCF6`, карточки `#FFFFFF`, приглушённый `#F7F0E2`, граница `#ECE1CB`,
  текст `#241C10`, вторичный текст `#7C6F58`, акцент brand-500 `#F2A93B` (единственный акцент на экране),
  текст на акценте `#241C10`, success `#2F7D4F`, danger `#C4432E`.
  Цвета треков — только для обозначения направлений: Digital Start `#3C6E58`, AI & Creative `#2F7FC9`,
  Code & Technology `#8858B0`. Тёмная тема — значения из брендбука (tokens.json).
- Шрифты: Baloo 2 (заголовки, 600/700), Manrope (текст и интерфейс), JetBrains Mono (код).
- Радиусы: 8 (поля), 14 (карточки, кнопки), 20 (крупные панели), pill. Отступы: шаг 4/8/12/16/24/32.
- Кнопки: основная — янтарная с тёмным текстом, высота 52–56; второстепенная — тёмная `#241C10`
  или контурная. Касаемые элементы ≥ 44px.
- **Запрещено:** `ColorScheme.fromSeed` с фиолетовым, фиолетовые/синие градиенты, стандартный
  Material 3 «из коробки», эмодзи вместо иконок (в т.ч. эмодзи треков из tracks.ts платформы),
  одинаковые карточки с тенью подряд, заглушки «Lorem ipsum»/«Coming soon».
- Иконки: одна библиотека (`lucide_icons_flutter`), линейные, один стиль.
- Все значения — токены в `lib/core/theme.dart`; в виджетах никаких «магических» цветов и размеров.
- Логотип-знак — в «badge» с радиусом 20 на белом/нейтральном фоне (правила — в брендбуке).
- Экран готов только с реальными состояниями: загрузка (skeleton), пусто, ошибка.

## Правила работы
- Маленькие, законченные шаги; после каждого — `flutter analyze` и `flutter test` без ошибок.
- Весь текст интерфейса — через l10n, без захардкоженных строк.
- Дизайн: крупные элементы, дружелюбно для детей; родительский экран — максимально простой.
- План и статус этапов — в `ROADMAP.md`; отмечать выполненное там.
