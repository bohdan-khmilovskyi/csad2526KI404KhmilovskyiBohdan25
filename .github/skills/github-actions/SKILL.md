---
name: github-actions
description: Створюй і перевіряй GitHub Actions workflow для C++ проєкту на Windows, Linux і macOS; використовуй, коли потрібно налаштувати CI для GitHub.
---

# GitHub Actions

## Призначення

Створи `.github/workflows/ci.yml` для запуску наявних платформних скриптів CI та публікації зібраного артефакту. Workflow не має самостійно конфігурувати чи збирати проєкт командами CMake або запускати CTest: ці дії виконують `ci.sh` і `ci.bat`.

## Очікувана конфігурація

- Тригери `push` і `pull_request` лише для гілок `develop` та `master`.
- Одна job із matrix `os: [ubuntu-latest, windows-latest, macos-latest]` і `fail-fast: false`.
- Крок checkout через `actions/checkout@v4`.
- Для не-Windows runner запусти тільки `./ci.sh` із `shell: bash`.
- Для Windows runner запусти тільки `ci.bat` із `shell: cmd`.
- Після успішного скрипту завантаж артефакт через `actions/upload-artifact@v4`:
  - `name: hello-${{ matrix.os }}`
  - `path: dist/`
  - `if-no-files-found: error`
- Усі команди `run` у workflow мають лише викликати відповідний скрипт. Не додавай у `run` команди CMake чи CTest, додаткові команди збірки або копіювання.
- Не додавай облікові дані, їхні значення чи інші приватні дані до workflow.

## Порядок роботи

1. Перевір наявність `.github/workflows/ci.yml`, `ci.sh` і `ci.bat`, а також переглянь їхній вміст. Не створюй скрипти збірки цим skill.
2. Переконайся, що скрипти вже виконують configure, build, тести та копіюють артефакт до `dist/`. Якщо вони відсутні або не відповідають цим вимогам, повідом про це, не маскуючи проблему.
3. Перед зміною наявного workflow перевір його конфігурацію. Не перезаписуй наявний файл без перевірки; якщо наявний вміст конфліктує з потрібною поведінкою, повідом шлях і конфлікт.
4. Створи або узгодь workflow так, щоб повторний запуск не додавав дубльовані тригери, job чи кроки.
5. Перевір результат за критеріями нижче та покажи diff або список змін.

## Перевірки

- Перевір валідність YAML командою `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"` або за допомогою `actionlint`, якщо він доступний.
- Переконайся, що в matrix присутні `ubuntu-latest`, `windows-latest` і `macos-latest`, а `fail-fast` вимкнено.
- Переконайся, що тригери охоплюють `push` і `pull_request` на `develop` та `master`.
- Переконайся, що не-Windows runner викликає `./ci.sh` із `bash`, а Windows runner — `ci.bat` із `cmd`.
- Переконайся, що всі команди `run` лише викликають ці скрипти; configure, build, тести й копіювання не виконуються командами workflow.
- Переконайся, що завантаження використовує `actions/upload-artifact@v4`, унікальне ім'я `hello-${{ matrix.os }}`, шлях `dist/` і `if-no-files-found: error`.
- Переконайся, що workflow не містить заборонених назв для конфіденційних даних.
- Якщо файл не проходить перевірку, повідом причину й не вважай роботу успішною.

## Типова помилка

Якщо `ci.sh` не має права на виконання, Linux або macOS job може завершитися помилкою. Перевір режим файлу; встанови executable-біт у Git для `ci.sh`, якщо це потрібно, і повтори перевірку. Не замінюй запуск `./ci.sh` іншою командою workflow, щоб обійти проблему.

## Приклад

Вхід:

```yaml
workflow: ci
branches:
  - develop
  - master
operating_systems:
  - ubuntu-latest
  - windows-latest
  - macos-latest
```

Очікуваний результат: створено `.github/workflows/ci.yml` з тригерами `push` і `pull_request` для вказаних гілок, однією job та matrix із трьома ОС. Ubuntu й macOS запускають `./ci.sh` через Bash, Windows запускає `ci.bat` через cmd, а кожна job завантажує `dist/` як `hello-${{ matrix.os }}`. У workflow немає команд збірки чи тестування поза скриптами.
