# AGENTS 🤖

## 🎯 Purpose

This repository is a Flutter base app template that provides common app foundations such as:

- auth session management
- app shell module navigation
- global request feedback
- localized UI
- test, coverage, and CI support

Use this file as the primary guide for assistants and coding agents working in the repo.

## 🗂️ Architecture Boundaries

Keep responsibilities separated unless there is a strong reason not to.

- `lib/app/`: app shell, theme, routes, app-level state
- `lib/core/`: shared infrastructure and cross-feature utilities
- `lib/features/`: domain-specific behavior and UI

Do not move feature-specific logic into `core` just for convenience.

## 🧩 Feature Conventions

Keep features as small as behavior allows.

Start with:

- `presentation/views`

Add only when needed:

- `models`
- `presentation/bloc`
- `presentation/controllers`
- `repositories`
- `services`

Reference implementations live under:

- `lib/features/auth`
- `lib/features/home`

Sample modules may also exist in the repo to demonstrate patterns. Treat them as examples, not as product requirements.

## 🔐 Auth Responsibilities

Keep auth concerns narrowly scoped.

- `AuthBloc` manages auth and session state only
- `AuthBloc` must not coordinate unrelated feature blocs
- form orchestration belongs in `AuthController`
- direct remote auth calls belong in `AuthService`
- storage coordination belongs in `AuthRepository`

## 🧭 Shell And Navigation

Top-level modules are state-driven through `AppBloc`.

- use `SetModule`, `PopModule`, and `moduleHistory` for shell-level history
- use route-stack navigation for deeper flows inside a module

If shell navigation behavior changes, update tests that cover top-level back navigation.

## 🌐 Request Feedback

Preserve the current separation of responsibilities:

- `HttpInterceptor`: request/response decoration and API error normalization
- `TrackingHttpClient`: request lifecycle tracking
- `RequestTracker`: concurrent request aggregation
- `RequestFeedbackCoordinator`: UI reaction bridge
- `DialogService`: dialog rendering

Do not move loaders or dialogs into the interceptor layer.

## 🌍 Localization

- put user-facing strings in `lib/l10n/app_en.arb` and `lib/l10n/app_es.arb`
- never edit generated localization files manually
- regenerate localization outputs when ARB files change

## 🧪 Testing

- use `test/` for unit and widget tests
- use `integration_test/` for end-to-end or heavier app flows
- test shell navigation when modifying module transitions
- test auth behavior when touching session flows
- test request feedback behavior when touching networking feedback

Useful references:

- `test/app/app_bloc_pop_module_test.dart`
- `integration_test/features/auth/auth_flow_test.dart`
- `integration_test/features/home/home_back_navigation_flow_test.dart`

## 📘 Documentation

When behavior changes, update the relevant docs:

- `README.md` for onboarding or top-level usage changes
- `docs/architecture.md` for structure or flow changes
- `docs/testing.md` for test strategy changes
- `docs/ci-sonar.md` for CI or Sonar changes
- `docs/troubleshooting.md` for recurring issues

Prefer focused docs updates under `docs/` instead of overloading `README.md`.

## 🧱 Extending The Template

When adding a new feature:

- keep the feature inside `lib/features/<feature_name>/`
- start from the smallest folder structure that supports the behavior
- copy patterns from `auth` or `home` before introducing a new architecture style
- add localization for user-facing text
- add or update tests when navigation, auth, or request feedback behavior is affected

When adding a new top-level module:

- wire it through `AppBloc`
- define its back-navigation behavior explicitly
- add or update shell navigation tests

## 🛠️ Commands

- install dependencies: `flutter pub get`
- analyze: `flutter analyze`
- run app: `flutter run`
- run tests: `flutter test`
- run coverage: `flutter test --coverage`
- run integration tests: `flutter test integration_test`

## 📌 Notes

- `.env` is a required Flutter asset
- CI copies `.env.test` to `.env`
- some constant-only Dart files may show artificially low LCOV coverage
