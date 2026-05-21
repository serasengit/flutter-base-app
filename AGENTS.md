# AGENTS 🤖

## Purpose

This repository is a Flutter base application template designed for API-driven apps with:

- authentication flow
- modular authenticated shell
- global request feedback
- localization
- reusable feature structure
- test, coverage, Sonar and GitLab CI support

Its main functional areas are:

- auth session management with `AuthBloc`
- shell module selection and back-stack history with `AppBloc`
- global dialogs and loading via request tracking
- example top-level modules for `users`, `cities` and `meteo_stations`
- testable API service + repository split

## Project Structure

- `lib/app`: shell state, routes metadata, app config and theme
- `lib/core`: shared infrastructure and reusable technical utilities
- `lib/core/di`: dependency registration with `get_it`
- `lib/core/network`: HTTP client, interceptor, request tracker and feedback coordinator
- `lib/core/dialogs`: global dialog service
- `lib/core/storage`: shared preferences storage helpers
- `lib/core/utils`: small shared helpers
- `lib/core/validators`: form validation helpers
- `lib/features`: business modules grouped by domain
- `lib/l10n`: ARB files and generated localizations
- `test`: unit and widget tests
- `integration_test`: integration-style application flow tests
- `scripts`: helper scripts for coverage and test execution

## Feature Pattern

Each feature should remain as small as the behavior allows.

Start small:

- `presentation/views`

Add more layers only when needed:

- `models`
- `presentation/bloc`
- `presentation/controllers`
- `repositories`
- `services`

Reference implementations:

- `lib/features/auth`
- `lib/features/home`
- `lib/features/users`
- `lib/features/cities`
- `lib/features/meteo_stations`

## Shell And Navigation Pattern

This project does not use route pushes for every top-level module.

Instead:

- `AppBloc` owns the authenticated shell state
- `AppState` stores:
  - available modules
  - active module
  - module history
- `HomeView` renders the active module

Current back navigation contract:

```text
Users -> Cities -> Meteo Stations
Back -> Cities
Back -> Users
Back -> Auth
Back -> exits app
```

Relevant files:

- `lib/app/bloc/app_bloc.dart`
- `lib/app/bloc/app_event.dart`
- `lib/app/bloc/app_state.dart`
- `lib/features/home/presentation/views/home_view.dart`

## Auth Rules

- `AuthBloc` manages only auth/session behavior
- `AuthBloc` should not know unrelated feature blocs
- login/logout effects outside auth should be coordinated at app/shell level
- form logic belongs in `AuthController`
- remote auth calls belong in `AuthService`
- local persistence coordination belongs in `AuthRepository`

## Request Feedback Rules

Keep this separation:

- `HttpInterceptor`: normalize errors, add headers, log requests/responses
- `TrackingHttpClient`: track request lifecycle
- `RequestTracker`: aggregate concurrent operations
- `RequestFeedbackCoordinator`: trigger loader/dialog UI reactions
- `DialogService`: render dialogs

Do not make the interceptor directly own UI decisions.

## Service And Repository Rules

- services own direct HTTP communication
- repositories own service + storage coordination
- blocs should depend on repositories, not low-level HTTP details
- storage persistence should stay out of views

## Localization Rules

- all user-facing strings should live in `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`
- generated localization files should not be edited manually
- remove obsolete localization keys when behavior changes

## Testing Rules

- use `test/` for unit and widget tests
- use `integration_test/` for shell/system/heavier flows
- prefer small isolated tests for blocs, repositories and views
- add integration tests for:
  - auth flow
  - shell back behavior
  - other multi-screen or platform-sensitive flows

Current useful references:

- `test/app/app_bloc_pop_module_test.dart`
- `integration_test/features/auth/auth_flow_test.dart`
- `integration_test/features/home/home_back_navigation_flow_test.dart`

## Documentation Rules

Update `README.md` when:

- shell behavior changes
- auth flow changes
- environment configuration changes
- CI or Sonar configuration changes
- testing or coverage workflow changes

## CI And Sonar Rules

Main files:

- `.gitlab-ci.yml`
- `sonar-project.properties`

Current CI stages:

- `dependencies`
- `analyze`
- `test`
- `build`
- `sonar`

Required GitLab variables:

- `MIN_COVERAGE_PERCENTAGE`
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

Coverage is generated with:

```bash
flutter test --coverage
```

Integration tests are not part of the regular coverage job by default.

## Commands

- install dependencies: `flutter pub get`
- analyze: `flutter analyze`
- run app: `flutter run`
- run tests: `flutter test`
- run coverage: `flutter test --coverage`
- run integration tests: `flutter test integration_test`
- helper scripts:
  - `.\scripts\run_coverage.ps1`
  - `.\scripts\run_integration_tests.ps1`

## Important Notes

- `.env` is declared as a Flutter asset
- CI copies `.env.test` to `.env` before running analysis, tests and build
- `package_info_plus` is used to show app version from `pubspec.yaml`
- some constant-only files may appear artificially under-covered in LCOV reports
- top-level modules are state-driven, not navigator-stack-driven
- use route navigation only when a feature really needs deeper internal flows
