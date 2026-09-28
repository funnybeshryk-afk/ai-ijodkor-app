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
Единый бренд с веб-платформой (`ai-ijodkor-platform/src/app/globals.css`) и сайтом:
- Цвета: акцент brand-500 `#F2A93B` (шкала 50–900: `#FEFAF3 #FDF2E2 #FBE4C0 #F8D299 #F5BE6A
  #F2A93B #D09133 #A97629 #835B20 #614418`), текст/тёмный `#14213D`, фон `#F7F8FA`,
  поверхности `#FFFFFF`, приглушённые `#F0F1F5`. Текст на янтарной кнопке — `#14213D`.
- **Запрещено:** `ColorScheme.fromSeed` с фиолетовым/сине-фиолетовым, фиолетовые градиенты,
  стандартный вид Material 3 «из коробки», эмодзи вместо иконок, одинаковые карточки
  с тенью подряд, заглушки вида «Lorem ipsum»/«Coming soon».
- Шрифты: Golos Text (заголовки), Inter (текст) — через `google_fonts` или ассеты.
- Иконки: одна библиотека (`lucide_icons`, как `lucide-react` на платформе), один стиль.
- Токены в `lib/core/theme.dart` (цвета, радиусы, отступы, типографика) — в виджетах
  никаких «магических» цветов и размеров.
- Характер: тёплый, взрослый-дружелюбный, как у платформы; для детей — крупнее и ярче
  через акценты и прогресс, а не через мультяшность. Персонаж платформы Ijodbek
  (`src/components/ijodbek-avatar.tsx`) можно использовать в пустых состояниях.
- Экран считается готовым только с реальными состояниями: загрузка (skeleton), пусто, ошибка.

## Правила работы
- Маленькие, законченные шаги; после каждого — `flutter analyze` и `flutter test` без ошибок.
- Весь текст интерфейса — через l10n, без захардкоженных строк.
- Дизайн: крупные элементы, дружелюбно для детей; родительский экран — максимально простой.
- План и статус этапов — в `ROADMAP.md`; отмечать выполненное там.
