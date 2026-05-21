# Setup ⚙️

## 📋 Requirements

Before starting, install:

- Git
- Visual Studio Code
- Flutter SDK
- Android Studio
- Android SDK Command-line Tools
- Android Emulator
- VS Code Flutter extension
- VS Code Dart extension

Official Flutter setup guide:

https://docs.flutter.dev/install/with-vs-code

## 📥 Clone the repository

```bash
git clone <REPOSITORY_URL>
cd flutter_base_app
```

## 📦 Install dependencies

```bash
flutter pub get
```

## 🩺 Verify Flutter setup

```bash
flutter doctor -v
```

Expected result should include at least:

```txt
[√] Flutter
[√] Android toolchain
[√] Connected device
```

## ⚙️ Android SDK setup

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

## 📱 Android emulator

### ⚙️ Open Android Virtual Device Manager

Open Android Studio and go to:

```txt
More Actions → Virtual Device Manager
```

Or from an opened project:

```txt
Tools → Device Manager
```

### ➕ Create a new emulator

Click:

```txt
Create Device
```

### 📱 Select device definition

Recommended examples:

```txt
Pixel 8
Pixel 7
Medium Phone
```

### 📥 Download Android system image

Recommended:

```txt
Android 14 (API 34)
```

If the image is not installed yet:

```txt
Download
```

### 🔌 Verify emulator connection

```bash
flutter devices
```

Example:

```txt
emulator-5554 • Pixel_8 • android
```

## 📜 Android licenses

```bash
flutter doctor --android-licenses
```

## 🌱 Environment files

The app reads runtime values from `.env`.

Committed CI-safe file:

- `.env.test`

Current example:

```env
APP_NAME=Flutter Base App
APP_ENVIRONMENT=test
API_URL=http://127.0.0.1:3000/api/v1
```

For local development, create your own `.env` if needed.

## 🚀 Run the app

Launch an emulator:

```bash
flutter emulators --launch Pixel_8
```

Run:

```bash
flutter run
```

Run on Chrome:

```bash
flutter run -d chrome
```

## ⚡ Hot reload

While the app is running:

```txt
r
```

Hot reload

```txt
R
```

Hot restart

```txt
q
```

Quit app

## 🧰 Useful commands

```bash
flutter pub get
flutter clean
flutter doctor
flutter devices
flutter run
flutter analyze
```

## 🧹 Platform support

Flutter projects may include:

```txt
android/
ios/
web/
windows/
macos/
linux/
```

### 🧩 Supported platform folders

Shared app code usually stays in:

```txt
lib/
test/
pubspec.yaml
```

### ✅ Check enabled platforms

```bash
flutter config
flutter devices
```

### 📌 Remove a platform

Delete the platform folder from the project root.

Then run:

```bash
flutter clean
flutter pub get
```

### ⚙️ Disable platform support globally

Examples:

```bash
flutter config --no-enable-web
flutter config --no-enable-windows-desktop
```

### 🔄 Re-enable later

Example:

```bash
flutter config --enable-web
flutter create .
```

## 📦 Build commands

### 🤖 Android builds

```bash
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

### 🍎 iOS builds

```bash
flutter build ipa
```

### 🌐 Web builds

```bash
flutter build web
```

### 🪟 Windows desktop builds

```bash
flutter build windows
```

### 🍎 macOS desktop builds

```bash
flutter build macos
```

### 🐧 Linux desktop builds

```bash
flutter build linux
```

### 🧪 Run in release mode

```bash
flutter run --release
flutter run -d chrome --release
flutter run -d windows --release
flutter run -d macos --release
flutter run -d linux --release
```
