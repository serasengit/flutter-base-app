# 🚀 Flutter Base App

Reusable Flutter starter template for API-driven apps with:

- authentication
- modular shell navigation
- global request feedback
- localization
- testing and coverage
- SonarQube and GitLab CI support

## 📋 Quick start

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

Run tests:

```bash
flutter test
```

Run coverage:

```bash
flutter test --coverage
```

## 🗂️ Project structure

The repository is organized into three main areas:

- `lib/app/`: shell, theme, routes and app-level bloc
- `lib/core/`: reusable infrastructure and technical building blocks
- `lib/features/`: domain-specific screens and feature logic

Example structure:

```text
lib/
  app/
  core/
  features/
  l10n/
test/
integration_test/
docs/
```

## 🧱 Documentation

Detailed documentation is split into focused documents:

- [docs/setup.md](docs/setup.md): Flutter, Android, emulator, environment and local setup
- [docs/architecture.md](docs/architecture.md): `app/core/features`, auth flow and shell navigation
- [docs/testing.md](docs/testing.md): unit, widget, integration tests and coverage
- [docs/ci-sonar.md](docs/ci-sonar.md): GitLab pipeline, coverage gate and SonarQube
- [docs/troubleshooting.md](docs/troubleshooting.md): common Flutter and local environment issues

## 🧪 Testing

Regular tests:

```bash
flutter test
```

Coverage:

```bash
flutter test --coverage
```

Integration tests:

```bash
flutter test integration_test
```

## 🔁 CI

The GitLab pipeline currently uses these stages:

```text
dependencies -> analyze -> test -> build -> sonar
```

Required GitLab variables:

- `MIN_COVERAGE_PERCENTAGE`
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

## 📝 Notes

- `.env` is declared as a Flutter asset
- CI copies `.env.test` to `.env`
- top-level module navigation is state-driven through `AppBloc`
- example modules such as `users`, `cities` and `meteo_stations` are sample modules and can be replaced in real projects
