# csad2526KI404KhmilovskyiBohdan25

## Відомості про роботу

- **ПІП:** Хмільовський Богдан Володимирович
- **Група:** КІ-404
- **Варіант:** 25
- **Технології:** C++, CMake, GoogleTest/CTest

## Опис проєкту

Репозиторій містить конфігурацію AI-агента для GitHub Copilot у VS Code. Агент призначений для створення кросплатформного C++ Hello World проєкту, налаштування збирання через CMake, тестування за допомогою GoogleTest/CTest і CI на GitHub Actions для Windows, Linux та macOS.

## Запуск агента

1. Відкрийте папку репозиторію у VS Code.
2. Відкрийте Copilot Chat.
3. Виберіть агента `build-engineer`.
4. Виконайте команду `/init`.

## Доступні команди

- `git-init` — перевіряє Git-репозиторій і створює або доповнює `.gitignore`.
- `create-project` — створює початкові файли C++ проєкту Hello World.
- `create-build` — налаштовує CMake, GoogleTest/CTest і платформні CI-скрипти.
- `create-actions` — створює GitHub Actions workflow для Windows, Linux і macOS.
- `check` — перевіряє структуру, збирання, тести, workflow та Git-ігнорування.
- `init` — послідовно виконує ініціалізаційні команди та завершує перевіркою.

## Build and run

- Windows, multi-config (Visual Studio): `build\Release\hello.exe`
- Windows, single-config: `build\hello.exe`
- Linux/macOS, single-config: `./build/hello`
- Linux/macOS, multi-config: `./build/Release/hello`
