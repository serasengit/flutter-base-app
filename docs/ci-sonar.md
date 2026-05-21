# CI And Sonar 🔁

## 🛠️ GitLab pipeline

The project includes:

```text
.gitlab-ci.yml
```

Current stages:

```text
dependencies -> analyze -> test -> build -> sonar
```

## 🚦 Stage behavior

### 📦 `dependencies`

Runs:

```bash
flutter pub get
```

### 🔎 `analyze`

Runs:

```bash
flutter analyze
```

CI copies `.env.test` to `.env` before analysis so Flutter does not fail on the declared `.env` asset.

### 🧪 `test`

Runs:

```bash
flutter test --coverage
```

Then computes total line coverage from:

```text
coverage/lcov.info
```

The job fails if coverage is below:

```text
MIN_COVERAGE_PERCENTAGE
```

### 🏗️ `build`

Runs:

```bash
flutter build apk --debug
```

### 📈 `sonar`

Runs SonarScanner with:

- `SONAR_HOST_URL`
- `SONAR_TOKEN`

## 🔐 Required GitLab variables

Configure in:

```text
Project > Settings > CI/CD > Variables
```

Required:

- `MIN_COVERAGE_PERCENTAGE`
- `SONAR_HOST_URL`
- `SONAR_TOKEN`

Recommended:

- mark `SONAR_TOKEN` as masked
- protect variables if needed for protected branches

## 📘 SonarQube

Configuration file:

```text
sonar-project.properties
```

Current setup:

- `lib` as sources
- `test` and `integration_test` as tests
- `coverage/lcov.info` as coverage input

Coverage exclusions include generated localization files and some constant-only files.

## 🚦 Pipeline execution scope

Current pipeline is intended to run on:

- merge requests
- `develop`
- `main`
