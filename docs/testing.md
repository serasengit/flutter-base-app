# Testing 🧪

## 🗂️ Test layout

Regular tests:

```text
test/
  app/
  core/
  features/
  widget_test.dart
```

Integration-style flows:

```text
integration_test/
  features/
```

## 🧩 Unit and widget tests

Run:

```bash
flutter test
```

Generate coverage:

```bash
flutter test --coverage
```

Coverage report:

```text
coverage/lcov.info
```

Helper script:

```powershell
.\scripts\run_coverage.ps1
```

## 🔄 Integration tests

Run:

```bash
flutter test integration_test
```

Helper script:

```powershell
.\scripts\run_integration_tests.ps1
```

Current heavier flows include:

- auth flow
- home back-navigation flow

## 📌 Why they are separate

`flutter test --coverage` is intended for the regular `test/` suite.

Keeping heavier app-flow tests under `integration_test/` makes coverage runs more stable and avoids hangs in the default runner.

## 📊 Coverage notes

Coverage in Dart/Flutter may under-report files made only of compile-time constants.

Examples:

- route constants
- color constants
- layout constants

Because of that, the project excludes some low-signal constant-only files from Sonar coverage calculations.

## ✅ What to test when changing code

Typical checklist:

- model behavior or mapping
- repository coordination
- bloc transitions
- widget rendering and user interaction
- shell navigation changes
- auth login/logout behavior
- request feedback behavior
- integration tests when the flow depends on back/system/app shell interactions
