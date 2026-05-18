# 🚀 flutter_base_app

Base Flutter application used as a starter project.

---

# 📋 Requirements

Before starting, make sure you have installed:

- ✅ Git
- ✅ Visual Studio Code
- ✅ Flutter SDK
- ✅ Android Studio
- ✅ Android SDK Command-line Tools
- ✅ Android Emulator
- ✅ VS Code Flutter extension
- ✅ VS Code Dart extension

Official Flutter setup guide:

🔗 https://docs.flutter.dev/install/with-vs-code

---

# 📥 Clone the repository

```bash
git clone <REPOSITORY_URL>
cd flutter_base_app
```

---

# 📦 Install dependencies

```bash
flutter pub get
```

---

# 🩺 Verify Flutter setup

Run:

```bash
flutter doctor -v
```

Expected result:

```txt
[√] Flutter
[√] Android toolchain
[√] Connected device
```

---

# ⚙️ Android SDK setup

Open Android Studio:

```txt
More Actions → SDK Manager
```

Go to:

```txt
SDK Tools
```

Install or enable:

```txt
Android SDK Command-line Tools (latest)
Android SDK Platform-Tools
Android SDK Build-Tools
Android Emulator
```

Apply changes and restart the terminal.

---

# 📜 Accept Android licenses

Run:

```bash
flutter doctor --android-licenses
```

Accept all licenses:

```txt
y
```

---

# 📱 Check available emulators

```bash
flutter emulators
```

Example:

```txt
1 available emulator:

Id      • Name    • Manufacturer • Platform

Pixel_8 • Pixel 8 • Google       • android
```

---

# ▶️ Launch Android emulator

```bash
flutter emulators --launch Pixel_8
```

Wait until Android is fully started.

---

# 🔌 Check connected devices

```bash
flutter devices
```

Expected result:

```txt
emulator-5554 • Pixel_8 • android
```

---

# ▶️ Run the application

```bash
flutter run
```

Or directly on the emulator:

```bash
flutter run -d emulator-5554
```

---

# 🌐 Run on Chrome

```bash
flutter run -d chrome
```

---

# ⚡ Hot reload

While the application is running:

```txt
r
```

🔄 Hot reload.

```txt
R
```

♻️ Hot restart.

```txt
q
```

❌ Quit application.

---

# 🛠️ Common issues

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

---

## ❗ Android license status unknown

Run:

```bash
flutter doctor --android-licenses
```

Accept all licenses.

---

## ❗ Visual Studio not installed

This warning only affects Windows desktop builds.

It is NOT required for Android emulator development.

You can ignore it unless you want to run:

```bash
flutter run -d windows
```

---

# 🧰 Useful commands

## 📦 Install dependencies

```bash
flutter pub get
```

## 🧹 Clean project

```bash
flutter clean
```

## 🩺 Check Flutter installation

```bash
flutter doctor
```

## 🔌 List devices

```bash
flutter devices
```

## 📱 List emulators

```bash
flutter emulators
```

## ▶️ Run application

```bash
flutter run
```

---

# 🧩 Recommended VS Code extensions

Install:

- Flutter
- Dart
- Error Lens
- GitLens

---

# 🏗️ Recommended project structure

```txt
lib/
 ├── core/
 ├── features/
 ├── shared/
 ├── services/
 ├── models/
 ├── routes/
 └── main.dart

android/
ios/
web/
windows/
pubspec.yaml
README.md
```

---

# 📂 Project structure

```txt
flutter_base_app/
 ├── android/
 ├── ios/
 ├── lib/
 ├── test/
 ├── web/
 ├── windows/
 ├── pubspec.yaml
 └── README.md
```

---

# 📦 Generate Android APK

Flutter allows generating an Android `.apk` file to install the application manually on an Android device or emulator.

## 🧹 Clean project before building

```bash
flutter clean
flutter pub get
```

## 🔨 Generate debug APK

Use this option for local testing:

```bash
flutter build apk --debug
```

Generated file:

```txt
build/app/outputs/flutter-apk/app-debug.apk
```

## 🚀 Generate release APK

Use this option to generate a production-ready APK:

```bash
flutter build apk --release
```

Generated file:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

## 📱 Install APK on connected emulator or device

Make sure the emulator or Android device is running:

```bash
flutter devices
```

Then install the APK:

```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

If the app is already installed, use:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## 🧪 Run release mode directly

You can also run the app in release mode without manually installing the APK:

```bash
flutter run --release
```

Or directly on an emulator:

```bash
flutter run --release -d emulator-5554
```

## 📂 APK output folder

All generated APK files are located in:

```txt
build/app/outputs/flutter-apk/
```

Example files:

```txt
app-debug.apk
app-release.apk
app-profile.apk
```
