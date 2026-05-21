# SKILL: Manage Flutter Features And Flows 🧠

## When To Use

Use this workflow when you need to add, modify or debug a feature, screen, module flow or API-connected behavior in this Flutter repository.

Typical cases:

- add a new feature module
- connect a screen to an API service
- add or adjust shell module navigation
- add auth-related UI or session behavior
- add request feedback handling
- add unit, widget or integration tests
- update localization, README or CI behavior after feature changes

## Recommended Reference Features

Use these folders as the main examples:

- `lib/features/auth`
- `lib/features/home`
- `lib/features/users`
- `lib/features/cities`
- `lib/features/meteo_stations`

## Workflow

1. Identify whether the change belongs to `app`, `core` or a concrete `feature`
2. Decide whether it is shell-level state, feature state or simple local widget state
3. Add or update models, services and repositories if API or persistence is involved
4. Add or update bloc/controller/view code
5. Register dependencies in `lib/core/di/injectable.dart` when needed
6. Add or update modules in `lib/app/routes/app_modules.dart` if it is a top-level shell module
7. Add or update localization keys in `lib/l10n/*.arb`
8. Add or update tests in `test/` or `integration_test/`
9. Update `README.md` if public behavior or developer workflow changed
10. Update CI, Sonar or coverage config if quality tooling scope changed

## File-Level Checklist

### App Shell

Use `lib/app` for:

- shell-level navigation
- active module selection
- module history / back behavior
- global app config
- routes metadata
- theme and layout constants

When a top-level module changes behavior, review:

- `lib/app/bloc/app_bloc.dart`
- `lib/app/bloc/app_event.dart`
- `lib/app/bloc/app_state.dart`
- `lib/app/routes/app_modules.dart`
- `lib/features/home/presentation/views/home_view.dart`

### Feature Layer

Use `lib/features/<feature>` for business-specific code.

A lightweight feature may only need:

- `presentation/views`

When the feature grows, add:

- `models`
- `presentation/bloc`
- `presentation/controllers`
- `repositories`
- `services`

### Services And Repositories

Service responsibilities:

- direct HTTP communication
- request payload and response parsing
- low-level remote behavior

Repository responsibilities:

- coordinate service + storage
- persist authentication data when needed
- hide infrastructure details from blocs

Patterns to reuse:

- `lib/features/auth/services/auth_service.dart`
- `lib/features/auth/repositories/auth_repository.dart`

### Bloc And Controller Responsibilities

Use `Bloc` for:

- async feature state
- session state
- shell state
- flows that multiple widgets depend on

Use local controllers for:

- form keys
- text controllers
- view-only input orchestration

Patterns to reuse:

- `lib/features/auth/presentation/bloc/auth_bloc.dart`
- `lib/features/auth/presentation/controllers/auth_controller.dart`

### Request Feedback

For API-driven operations, keep this separation:

- `HttpInterceptor`: request/response decoration, logging and API error normalization
- `TrackingHttpClient`: request lifecycle tracking
- `RequestTracker`: concurrent request aggregation
- `RequestFeedbackCoordinator`: translate tracker events into dialogs/loaders
- `DialogService`: shared dialog rendering

Do not move UI dialog logic into the interceptor itself.

### Localization

If you add any user-facing string:

1. add it to:
   - `lib/l10n/app_en.arb`
   - `lib/l10n/app_es.arb`
2. regenerate localizations if required
3. remove obsolete keys if behavior changed

Avoid hardcoded user-facing labels in views unless there is a strong reason.

## Navigation Rules

The project uses two different navigation styles:

- shell module navigation through `AppBloc`
- route stack navigation only when deeper feature flows need it

Top-level modules should usually be handled through:

- `SetModule`
- `PopModule`
- `moduleHistory`

Current shell back flow:

```text
Users -> Cities -> Meteo Stations
Back -> Cities
Back -> Users
Back -> Auth
Back -> exits app
```

When changing this behavior, review:

- `lib/features/home/presentation/views/home_view.dart`
- `test/app/app_bloc_pop_module_test.dart`
- `integration_test/features/home/home_back_navigation_flow_test.dart`

## Testing Checklist

For a typical feature change, consider:

- model serialization / equality tests
- repository tests
- bloc tests
- widget tests for the main view
- integration tests only when the flow depends on shell/back/system interactions

Use:

- `test/` for unit and widget tests
- `integration_test/` for heavier app flow validation

Typical coverage cases:

- success path
- error path
- validation failures
- module switching / shell flow
- auth login/logout transitions
- localization rendering

## CI And Quality Checklist

If the change affects tooling or project structure, review:

- `.gitlab-ci.yml`
- `sonar-project.properties`
- `README.md`

Current CI stages:

- `dependencies`
- `analyze`
- `test`
- `build`
- `sonar`

Current quality gate inputs:

- `MIN_COVERAGE_PERCENTAGE`
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

## Common Pitfalls

- putting shell behavior inside feature blocs
- making `AuthBloc` know unrelated blocs
- mixing interceptor responsibilities with dialog rendering
- hardcoding localized strings in widgets
- forgetting to register new dependencies in `injectable.dart`
- adding top-level modules without updating `app_modules.dart`
- forgetting to cover shell back behavior when changing module navigation
- moving tests out of `test/` and breaking `flutter test --coverage`
- forgetting `.env` / `.env.test` implications in CI

## Quick Feature Template

For a new API-driven feature:

1. `lib/features/<feature>/models`
2. `lib/features/<feature>/services`
3. `lib/features/<feature>/repositories`
4. `lib/features/<feature>/presentation/bloc`
5. `lib/features/<feature>/presentation/controllers`
6. `lib/features/<feature>/presentation/views`
7. `test/features/<feature>/...`
8. `integration_test/features/<feature>/...` if the flow is shell/system-dependent
9. `lib/l10n/*.arb`
10. `README.md`
