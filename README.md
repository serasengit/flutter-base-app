# Flutter Base App 📱

Reusable Flutter application template built around a `core + features` structure, global request feedback handling, authentication flow, localized UI, modular shell navigation and CI-ready quality tooling.

It is intended to be a practical starter for API-driven Flutter apps without overengineering the project into excessive layers.

## ℹ️ Summary

- Framework: Flutter
- Language: Dart
- State management: `flutter_bloc`
- Dependency injection: `get_it`
- HTTP: `http` + `http_interceptor`
- Local storage: `shared_preferences`
- Environment configuration: `flutter_dotenv`
- Localization: `flutter_localizations` + generated `l10n`
- Global loading and dialogs: `loader_overlay` + request feedback coordinator
- Testing: `flutter_test` + `integration_test`
- Coverage: `flutter test --coverage`
- Code quality: SonarQube
- CI/CD: GitLab CI/CD

## 🗂️ Main structure

The project follows a lightweight `app + core + features` organization:

- `lib/app/`: application shell, global bloc, routes, config and theme
- `lib/core/`: shared infrastructure and reusable technical utilities
- `lib/core/di/`: dependency registration with `get_it`
- `lib/core/network/`: HTTP client factory, interceptor, request tracker and feedback coordinator
- `lib/core/dialogs/`: dialog service
- `lib/core/storage/`: local persistence helpers
- `lib/core/utils/`: small reusable utilities
- `lib/core/validators/`: shared form validators
- `lib/features/`: business and UI modules grouped by feature
- `lib/features/auth/`: login models, service, repository, bloc, controller and auth view
- `lib/features/home/`: authenticated shell and home module UI
- `lib/features/users/`: example users module view
- `lib/features/cities/`: example cities module view
- `lib/features/meteo_stations/`: example meteo stations module view
- `lib/l10n/`: localization source files and generated localizations
- `test/`: unit and widget tests
- `integration_test/`: integration-style app flow tests
- `scripts/`: helper scripts for coverage and test execution

Example structure:

```text
lib/
  app/
    bloc/
    config/
    routes/
    theme/
    app.dart
  core/
    dialogs/
    di/
    network/
    storage/
    utils/
    validators/
  features/
    auth/
      models/
      presentation/
        bloc/
        controllers/
        views/
      repositories/
      services/
    home/
      presentation/
        views/
    users/
      presentation/
        views/
    cities/
      presentation/
        views/
    meteo_stations/
      presentation/
        views/
  l10n/
test/
  app/
  core/
  features/
integration_test/
  features/
scripts/
.env.test
.gitlab-ci.yml
pubspec.yaml
sonar-project.properties
```

## 🧱 Architecture

This template is intentionally not “clean architecture for everything”. It uses a pragmatic split:

- `app/` for shell-level concerns
- `core/` for shared infrastructure
- `features/` for domain-specific code

### 🏠 App shell

The authenticated part of the app is modeled as a shell:

- `AuthBloc` decides whether the app shows the login flow or the authenticated shell
- `AppBloc` manages the authenticated shell modules and their navigation history
- `HomeView` renders the current active module

Top-level modules are not pushed through `Navigator` routes. They are selected through shell state.

Current example modules:

- `home`
- `users`
- `cities`
- `meteo_stations`
- `logout`

### 🔙 Module back stack

The app keeps a module history stack in `AppBloc`.

Example:

```text
Users -> Cities -> Meteo Stations
Back -> Cities
Back -> Users
Back -> Auth
Back -> exits app
```

This is implemented with:

- `SetModule`
- `PopModule`
- `moduleHistory`
- `PopScope` in `HomeView`

### 🔐 Authentication flow

Authentication is split into:

- `AuthService`: direct HTTP communication
- `AuthRepository`: coordinates auth API + local token storage
- `AuthBloc`: login/logout state transitions
- `AuthController`: form handling and event dispatch
- `AuthView`: login UI

Successful login stores the session token locally and switches the app from `AuthView` to the authenticated shell.

### 🌐 Global request feedback

The template includes a global request feedback pipeline:

- `HttpInterceptor`: request/response decoration, logging and API error normalization
- `TrackingHttpClient`: tracks request lifecycle and success/error outcomes
- `RequestTracker`: aggregates concurrent request state and messages
- `RequestFeedbackCoordinator`: translates tracker events into UI feedback
- `DialogService`: shared dialogs
- `loader_overlay`: global loading indicator

This allows the app to:

- show a global loader during requests
- aggregate request errors in a single dialog
- show success feedback for non-GET, non-auth successful operations

## ✅ Requirements

- Flutter SDK `3.44.x` or compatible
- Dart SDK `3.12.x` or compatible
- Android Studio / VS Code / IntelliJ
- An emulator or physical device for app execution
- SonarQube, if using local Sonar analysis
- GitLab Runner, if using the provided CI/CD pipeline

### 🪟 Windows note

Some Flutter plugins require symlink support on Windows.

If Flutter asks for symlink support, enable Developer Mode:

```powershell
start ms-settings:developers
```

## 🌱 Environment files

The app loads environment values from `.env`.

Committed test-safe file:

- `.env.test`

Typical local flow:

1. create your own `.env`
2. keep `.env.test` for CI and predictable test jobs

Example `.env.test`:

```env
APP_NAME=Flutter Base App
APP_ENVIRONMENT=test
API_URL=http://127.0.0.1:3000/api/v1
```

Main values currently used:

- `APP_NAME`: application display name
- `APP_ENVIRONMENT`: `dev`, `test` or `prod`
- `API_URL`: backend base URL

## 🚀 Development startup

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <deviceId>
```

Generate localizations if needed:

```bash
flutter gen-l10n
```

## 🏷️ App version

The authentication screen shows the app version in its bottom bar.

The version is taken from `pubspec.yaml` through `package_info_plus`.

Example:

```yaml
version: 1.0.0+1
```

Displayed as:

```text
v1.0.0+1
```

## 🌍 Localization

Localization is defined in:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`

Generated files are placed in:

- `lib/l10n/app_localizations.dart`
- `lib/l10n/app_localizations_en.dart`
- `lib/l10n/app_localizations_es.dart`

## 🧪 Testing

The project keeps regular tests and integration-style tests separated.

### 🧩 Unit and widget tests

Location:

```text
test/
```

Run all regular tests:

```bash
flutter test
```

Run with coverage:

```bash
flutter test --coverage
```

Coverage report:

```text
coverage/lcov.info
```

### 🔄 Integration tests

Location:

```text
integration_test/
```

Run integration tests:

```bash
flutter test integration_test
```

Current integration flows include:

- auth flow
- home shell back navigation flow

### 📊 Coverage notes

Coverage in Flutter/Dart can under-report some files made only of compile-time constants.

Typical examples:

- route constant files
- color constant files
- layout constant files

For that reason, `sonar.coverage.exclusions` excludes some low-signal constant-only files.

## 🛠️ Scripts

Available helper scripts:

- `scripts/run_coverage.ps1`
- `scripts/run_integration_tests.ps1`

Examples:

```powershell
.\scripts\run_coverage.ps1
.\scripts\run_integration_tests.ps1
```

## 📘 SonarQube

SonarQube configuration lives in:

```text
sonar-project.properties
```

Configured for:

- `lib` as sources
- `test` and `integration_test` as tests
- `coverage/lcov.info` as coverage input

Main exclusions:

- generated localization files
- build artifacts
- platform folders
- some constant-only files that distort coverage

## 🔁 GitLab CI/CD

The project includes a GitLab pipeline in:

```text
.gitlab-ci.yml
```

Pipeline stages:

```text
dependencies -> analyze -> test -> build -> sonar
```

### 📦 `dependencies`

Installs Flutter dependencies:

```bash
flutter pub get
```

### 🔎 `analyze`

Runs static analysis:

```bash
flutter analyze
```

The pipeline copies `.env.test` to `.env` before analysis so Flutter does not fail on the declared `.env` asset.

### 🧪 `test`

Runs the regular test suite with coverage:

```bash
flutter test --coverage
```

It then computes the global percentage from `coverage/lcov.info` and validates it against:

```text
MIN_COVERAGE_PERCENTAGE
```

If coverage is below the configured minimum, the job fails.

### 🏗️ `build`

Builds an Android debug APK:

```bash
flutter build apk --debug
```

### 📈 `sonar`

Runs SonarScanner using:

- `SONAR_HOST_URL`
- `SONAR_TOKEN`

The scanner uses `sonar-project.properties` plus the coverage artifact generated by the `test` stage.

### 🔐 Required GitLab CI/CD variables

Configure these in:

```text
Project > Settings > CI/CD > Variables
```

Required variables:

- `MIN_COVERAGE_PERCENTAGE`
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

Recommended behavior:

- mark `SONAR_TOKEN` as masked
- mark sensitive variables as protected if needed

### 🚦 Pipeline execution rules

The current pipeline is intended to run on:

- merge requests
- `develop`
- `main`

## 📚 Main dependencies

Runtime dependencies:

- `flutter_bloc`: state management
- `bloc`: core bloc primitives
- `get_it`: dependency injection / service locator
- `http`: HTTP client
- `http_interceptor`: request/response interception
- `flutter_dotenv`: environment loading
- `shared_preferences`: local storage
- `logger`: console logging
- `loader_overlay`: global loading overlay
- `equatable`: value equality
- `intl`: localization/date formatting
- `package_info_plus`: app version metadata

Development dependencies:

- `flutter_test`: testing
- `integration_test`: integration-style testing
- `flutter_lints`: recommended lints

## 📏 Conventions

- Put shared infrastructure in `lib/core`
- Put shell-level concerns in `lib/app`
- Put business-specific code in `lib/features/<feature>`
- Keep top-level modules simple and render them through shell state
- Use normal route navigation only for deeper feature flows when needed
- Keep HTTP and UI feedback separated:
  - interceptor/tracker normalize and collect
  - coordinator/dialogs render feedback
- Keep auth concerns inside `AuthBloc`, not spread across unrelated blocs

## 🧩 Creating a new feature

A lightweight feature usually looks like:

```text
lib/features/<feature>/
  presentation/
    views/
```

If the feature grows, add:

```text
lib/features/<feature>/
  models/
  presentation/
    bloc/
    controllers/
    views/
  repositories/
  services/
```

Recommended steps:

1. create the feature view
2. add services/repository if the feature talks to the API
3. add bloc only if the feature has real async or business state
4. register the feature as a shell module if it is top-level
5. add tests

## 📝 Notes

- This template is meant to stay practical and team-friendly.
- It intentionally avoids excessive “use case per file” architecture.
- Example modules can be replaced or extended for real projects.
- The shell module system is state-driven, not route-stack-driven.
- Back behavior between top-level modules is managed by `AppBloc` history.
