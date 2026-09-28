# AI IJODKOR — мобильное приложение

Flutter-приложение (Android, iOS) образовательной программы AI IJODKOR.
Работает поверх той же базы Supabase, что и веб-платформа `ai-ijodkor-platform`.
Спецификация — в [CLAUDE.md](CLAUDE.md), план — в [ROADMAP.md](ROADMAP.md).

## Настройка ключей

Ключи передаются только через `--dart-define` и **никогда не коммитятся**.
Нужен только публичный anon-ключ; `service_role` в приложении запрещён.

| Переменная          | Что это                                        |
|---------------------|------------------------------------------------|
| `SUPABASE_URL`      | URL проекта Supabase                           |
| `SUPABASE_ANON_KEY` | anon (publishable) ключ                        |
| `PLATFORM_URL`      | адрес веб-платформы (тренажёры в WebView)      |

Удобнее всего через файл:

```bash
cp dart_defines.example.json dart_defines.json   # файл в .gitignore
# впишите свои значения
flutter run --dart-define-from-file=dart_defines.json
```

Или напрямую:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=PLATFORM_URL=https://...
```

Без ключей приложение запускается и показывает экран «Ilova sozlanmagan».

## Разработка

```bash
flutter pub get
flutter gen-l10n        # после правки lib/l10n/*.arb
flutter analyze
flutter test
flutter build apk --debug
```

- Тексты интерфейса — только в `lib/l10n/app_uz.arb` (основной) и `app_ru.arb`.
- Язык по умолчанию — узбекский (латиница), выбор сохраняется между запусками.
- Редирект по роли (`profiles.role`): student → `/student`, parent → `/parent`,
  teacher и admin → `/teacher`. Логика — `lib/core/routes.dart`.

## Зависимость от платформы

Тест к уроку работает через RPC `get_lesson_quiz` и `submit_lesson_quiz`
(миграция `0019_lesson_quiz_rpc.sql` в `ai-ijodkor-platform`). Пока миграция не
применена к базе, экран урока показывает ошибку загрузки теста.
Правильные ответы в приложение не попадают никогда.

Тренажёры открываются в WebView на `PLATFORM_URL/student/practice/<key>`;
сессия передаётся cookie в формате `@supabase/ssr`, повторный вход не нужен.

## Иконка и splash

Исходники — `assets/branding/` (из `intelliqos-site/public/assets/logo-icon.png`).
После замены картинок:

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

CI (GitHub Actions) на каждый PR: формат, `flutter analyze`, `flutter test`,
сборка debug APK (артефакт `app-debug-apk`). Если в репозитории заданы секреты
`SUPABASE_URL` и `SUPABASE_ANON_KEY` (и опционально `PLATFORM_URL`), APK
собирается с ними; иначе — без ключей.
