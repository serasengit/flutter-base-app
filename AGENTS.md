# AGENTS 🤖

## 🎯 Purpose

This repository is a Flutter base app template with:

- auth session management
- app shell module navigation
- global request feedback
- localized UI
- test, coverage and CI support

This file is for dev agents and assistants working inside the repo.

## 🗂️ Architecture boundaries

- `lib/app/`: shell, theme, routes, app-level bloc
- `lib/core/`: reusable infrastructure
- `lib/features/`: domain-specific code and UI

Do not blur these boundaries unless there is a strong reason.

## 🧩 Feature rules

Keep features as small as behavior allows.

Start with:

- `presentation/views`

Add only when needed:

- `models`
- `presentation/bloc`
- `presentation/controllers`
- `repositories`
- `services`

Reference features:

- `lib/features/auth`
- `lib/features/home`
- `lib/features/users`
- `lib/features/cities`
- `lib/features/meteo_stations`

Current `users`, `cities` and `meteo_stations` should be treated as sample modules, not mandatory product modules.

## 🔐 Auth rules

- `AuthBloc` manages only auth/session behavior
- `AuthBloc` must not know unrelated feature blocs
- form orchestration belongs in `AuthController`
- direct remote auth calls belong in `AuthService`
- storage coordination belongs in `AuthRepository`

## 🧭 Shell and navigation rules

- top-level modules are state-driven through `AppBloc`
- shell history is managed with `SetModule`, `PopModule` and `moduleHistory`
- use route-stack navigation only for deeper feature flows

Current top-level back contract:

```text
Users -> Cities -> Meteo Stations
Back -> Cities
Back -> Users
Back -> Auth
Back -> exits app
```

## 🌐 Request feedback rules

Keep this separation:

- `HttpInterceptor`: request/response decoration and API error normalization
- `TrackingHttpClient`: request lifecycle tracking
- `RequestTracker`: concurrent request aggregation
- `RequestFeedbackCoordinator`: UI reaction bridge
- `DialogService`: dialog rendering

Do not move dialogs or loaders into the interceptor.

## 🌍 Localization rules

- put user-facing strings in `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`
- never edit generated localization files manually
- regenerate l10n when ARB files change

## 🧪 Testing rules

- use `test/` for unit and widget tests
- use `integration_test/` for heavier app flows
- test shell navigation changes
- test auth and request feedback behavior when touched

Useful references:

- `test/app/app_bloc_pop_module_test.dart`
- `integration_test/features/auth/auth_flow_test.dart`
- `integration_test/features/home/home_back_navigation_flow_test.dart`

## 📘 Documentation rules

When behavior changes, update:

- `README.md` if onboarding or top-level usage changes
- `docs/architecture.md` if app structure or flow changes
- `docs/testing.md` if test strategy changes
- `docs/ci-sonar.md` if CI or Sonar changes
- `docs/troubleshooting.md` if a recurring issue is identified

## 🛠️ Commands

- install dependencies: `flutter pub get`
- analyze: `flutter analyze`
- run app: `flutter run`
- run tests: `flutter test`
- run coverage: `flutter test --coverage`
- run integration tests: `flutter test integration_test`

## 📌 Important notes

- `.env` is a required Flutter asset
- CI copies `.env.test` to `.env`
- some constant-only Dart files may show artificially low LCOV coverage
- prefer changing docs in `docs/` instead of making `README.md` huge again
