# Використання

## Запуск агента у VS Code

1. Відкрийте корінь репозиторію у VS Code.
2. Відкрийте Copilot Chat.
3. Виберіть агента `build-engineer`.
4. Виконайте `/init` для повної ініціалізації або `/check` для перевірки проєкту.

## Локальна збірка

Linux/macOS:

```bash
./ci.sh
```

Windows:

```bat
ci.bat
```

## Запуск програми

Linux/macOS:

```bash
./dist/hello
```

Windows:

```bat
dist\hello.exe
```

## Запуск тестів

```bash
ctest --test-dir build -C Release --output-on-failure
```
