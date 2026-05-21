# Architecture 🧱

## 🗂️ Main structure

The template uses a pragmatic split:

- `lib/app/`: shell, theme, routes and app-level bloc
- `lib/core/`: reusable infrastructure
- `lib/features/`: domain-specific code and UI

Example:

```text
lib/
  app/
  core/
  features/
  l10n/
```

## 🏠 App shell

The authenticated part of the app is modeled as a shell:

- `AuthBloc` decides between auth screen and authenticated shell
- `AppBloc` manages available modules, active module and module history
- `HomeView` renders the current module

Current sample modules:

- `home`
- `users`
- `cities`
- `meteo_stations`
- `logout`

These are example modules and can be replaced in real projects.

## 🧭 Navigation model

Top-level modules are not pushed through Navigator routes.

They are selected through shell state:

- `SetModule`
- `PopModule`
- `moduleHistory`

Current back behavior:

```text
Users -> Cities -> Meteo Stations
Back -> Cities
Back -> Users
Back -> Auth
Back -> exits app
```

Use normal route navigation only when a feature needs deeper internal flows such as details, wizards or edit screens.

## 🔐 Auth flow

Authentication is split into:

- `AuthService`: direct HTTP communication
- `AuthRepository`: service + local storage coordination
- `AuthBloc`: login/logout state transitions
- `AuthController`: form handling
- `AuthView`: login UI

Important rule:

- `AuthBloc` should not know unrelated feature blocs

## 🌐 Request feedback pipeline

Global request handling is intentionally separated:

- `HttpInterceptor`: headers, logging, error normalization
- `TrackingHttpClient`: request lifecycle tracking
- `RequestTracker`: concurrent request aggregation
- `RequestFeedbackCoordinator`: translates tracker events into UI feedback
- `DialogService`: shared dialog rendering

This keeps UI concerns out of the interceptor.

## 🧩 Feature structure

Keep features as small as possible.

Start with:

```text
lib/features/<feature>/
  presentation/
    views/
```

Add layers only if the feature needs them:

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

Recommended references:

- `lib/features/auth`
- `lib/features/home`
- `lib/features/users`
- `lib/features/cities`
- `lib/features/meteo_stations`

## 🎛️ Controllers vs blocs

Use controllers for:

- form keys
- text editing controllers
- small UI orchestration

Use blocs for:

- async feature state
- auth state
- shell state
- flows shared across widgets

If a controller starts collecting business logic, move that logic down into bloc/repository/service layers.

## 🌍 Localization

User-facing strings should live in:

- `lib/l10n/app_en.arb`
- `lib/l10n/app_es.arb`

Generated localization files should never be edited manually.

## 🏷️ App version

The auth screen shows the app version using `package_info_plus`.

The value comes from:

```yaml
pubspec.yaml
```

Example:

```yaml
version: 1.0.0+1
```
