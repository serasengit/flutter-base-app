# Troubleshooting 🛠️

## ❗ Android cmdline-tools component is missing

Open Android Studio:

```txt
SDK Manager → SDK Tools
```

Install:

```txt
Android SDK Command-line Tools (latest)
```

Then run:

```bash
flutter doctor
```

## ❗ Android license status unknown

Run:

```bash
flutter doctor --android-licenses
```

Accept all licenses.

## ❗ Visual Studio not installed

This warning only affects Windows desktop builds.

It is not required for Android emulator development.

You can ignore it unless you want to run:

```bash
flutter run -d windows
```

## ❗ Windows symlink support required

Some Flutter plugins require symlink support on Windows.

Enable Developer Mode:

```powershell
start ms-settings:developers
```

## ❗ ADB install errors in emulator

If you see errors such as:

```text
cmd: Can't find service: activity
cmd: Can't find service: package
```

the emulator usually booted incorrectly.

Try:

1. close the emulator completely
2. run `Cold Boot Now`
3. if needed, `Wipe Data`
4. restart ADB:

```bash
adb kill-server
adb start-server
```

## ❗ `flutter analyze` fails in CI with missing packages

If CI shows errors like:

```text
Target of URI doesn't exist: package:flutter_bloc/flutter_bloc.dart
```

the job is analyzing without resolved dependencies.

The current pipeline fixes this by running:

```bash
flutter pub get
```

inside the job before analysis.

## ❗ `.env` asset warning in CI

If Flutter reports:

```text
The asset file '.env' doesn't exist
```

make sure CI copies:

```text
.env.test -> .env
```

before running analysis, tests or build.
