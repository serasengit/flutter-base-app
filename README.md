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

# 📱 Create and install Android emulator

Android emulators are managed through Android Studio using the Android Virtual Device (AVD) Manager.

## ⚙️ Open Android Virtual Device Manager

Open Android Studio and go to:

```txt
More Actions → Virtual Device Manager
```

Or from an opened project:

```txt
Tools → Device Manager
```

---

## ➕ Create a new emulator

Click:

```txt
Create Device
```

---

## 📱 Select device definition

Choose a device profile.

Recommended examples:

```txt
Pixel 8
Pixel 7
Medium Phone
```

Click:

```txt
Next
```

---

## 📥 Download Android system image

Select an Android version image.

Recommended:

```txt
Android 14 (API 34)
```

If the image is not installed yet:

```txt
Download
```

Wait until the download finishes.

Click:

```txt
Next
```

---

## 🛠️ Configure emulator

You can customize:

- Emulator name
- RAM
- Storage
- Orientation
- Graphics acceleration

Recommended defaults are usually sufficient.

Click:

```txt
Finish
```

---

## ▶️ Start emulator

Inside Device Manager click:

```txt
▶ Play
```

Wait until Android boots completely.

---

## 🔌 Verify emulator connection

Run:

```bash
flutter devices
```

Expected result example:

```txt
emulator-5554 • Pixel_8 • android
```

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

# ▶️ Launch Android emulator

```bash
flutter emulators --launch Pixel_8
```

Wait until Android is fully started.

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

# 🧹 Remove unused Flutter platforms

Flutter is a multi-platform framework. A project can include support for several target platforms, even if the application is only going to be distributed for some of them.

Removing platforms that are not needed helps to:

- Reduce project complexity
- Avoid unnecessary build errors
- Simplify CI/CD pipelines
- Reduce tooling requirements
- Keep the repository focused on the real target platforms

---

# 🧩 Flutter supported platforms

Flutter projects can include the following platform folders:

```txt
android/   → Android applications
ios/       → iOS applications
web/       → Web applications
windows/   → Windows desktop applications
macos/     → macOS desktop applications
linux/     → Linux desktop applications
```

The shared Dart application code is usually located in:

```txt
lib/
test/
pubspec.yaml
```

These files and folders should normally be kept regardless of the target platforms.

---

# ✅ Check enabled platforms

To see which platforms are currently enabled in your Flutter SDK, run:

```bash
flutter config
```

You can also list available devices with:

```bash
flutter devices
```

---

# 📌 Remove a platform from the project

To remove support for a platform, delete its folder from the root of the project.

For example, to remove Web support:

```txt
web/
```

To remove Windows desktop support:

```txt
windows/
```

To remove iOS support:

```txt
ios/
```

After deleting the platform folder, run:

```bash
flutter clean
flutter pub get
```

---

# ⚙️ Disable platform support in Flutter config

In addition to deleting the platform folder from the project, you can disable platform support globally in your Flutter SDK configuration.

## Disable Web

```bash
flutter config --no-enable-web
```

## Disable Windows desktop

```bash
flutter config --no-enable-windows-desktop
```

## Disable Linux desktop

```bash
flutter config --no-enable-linux-desktop
```

## Disable macOS desktop

```bash
flutter config --no-enable-macos-desktop
```

## Disable iOS

```bash
flutter config --no-enable-ios
```

> Android is normally kept enabled because it is one of the most common Flutter targets.

---

# 🔄 Re-enable a platform later

If a removed platform is needed again, enable it and regenerate the platform folder.

## Re-enable Web

```bash
flutter config --enable-web
flutter create .
```

## Re-enable Windows desktop

```bash
flutter config --enable-windows-desktop
flutter create .
```

## Re-enable Linux desktop

```bash
flutter config --enable-linux-desktop
flutter create .
```

## Re-enable macOS desktop

```bash
flutter config --enable-macos-desktop
flutter create .
```

## Re-enable iOS

```bash
flutter config --enable-ios
flutter create .
```

---

# 📂 Example project structures

## Project with all common platforms

```txt
flutter_base_app/
 ├── android/
 ├── ios/
 ├── lib/
 ├── linux/
 ├── macos/
 ├── test/
 ├── web/
 ├── windows/
 ├── pubspec.yaml
 └── README.md
```

## Project with only selected platforms

Example keeping only Android and Web:

```txt
flutter_base_app/
 ├── android/
 ├── lib/
 ├── test/
 ├── web/
 ├── pubspec.yaml
 └── README.md
```

Example keeping only Android:

```txt
flutter_base_app/
 ├── android/
 ├── lib/
 ├── test/
 ├── pubspec.yaml
 └── README.md
```

---

# ⚠️ Tooling notes

Some platforms require additional tooling:

- Android requires Android Studio / Android SDK
- iOS and macOS require XCode
- Windows requires Visual Studio with desktop C++ tooling
- Web requires Chrome or another supported browser
- Linux requires Linux desktop build dependencies

If a platform is removed from the project, its specific tooling is no longer needed unless another project requires it.

---

# 💡 Recommendation

Only keep the platforms that are actually required by the product.

For example:

```txt
android/
ios/
```

or:

```txt
android/
web/
```

or:

```txt
windows/
```

This keeps the repository easier to maintain and avoids platform-specific issues that are not relevant to the application.

---

# 📦 Generate application builds for all platforms

Flutter can generate distributable builds for all supported target platforms.

Before generating any build, it is recommended to clean the project:

```bash
flutter clean
flutter pub get
```

---

# 🤖 Android builds

## Generate APK

### Debug APK

```bash
flutter build apk --debug
```

### Release APK

```bash
flutter build apk --release
```

Generated files:

```txt
build/app/outputs/flutter-apk/
```

Example:

```txt
app-debug.apk
app-release.apk
```

---

## Generate Android App Bundle (Google Play)

```bash
flutter build appbundle --release
```

Generated file:

```txt
build/app/outputs/bundle/release/app-release.aab
```

---

# 🍎 iOS builds

> Requires macOS and XCode installed.

## Generate iOS release build

```bash
flutter build ipa
```

Generated files are located under:

```txt
build/ios/
```

---

# 🌐 Web builds

## Generate production web build

```bash
flutter build web
```

Generated files:

```txt
build/web/
```

These files can be deployed to:

- Nginx
- Apache
- Firebase Hosting
- GitHub Pages
- Azure
- AWS S3
- Any static hosting provider

---

# 🪟 Windows desktop builds

> Requires Visual Studio with Desktop Development tools installed.

## Generate Windows executable

```bash
flutter build windows
```

Generated files:

```txt
build/windows/
```

---

# 🍎 macOS desktop builds

> Requires macOS and XCode installed.

## Generate macOS desktop application

```bash
flutter build macos
```

Generated files:

```txt
build/macos/
```

---

# 🐧 Linux desktop builds

> Requires Linux desktop build dependencies installed.

## Generate Linux desktop application

```bash
flutter build linux
```

Generated files:

```txt
build/linux/
```

---

# 🧪 Run application in release mode

Flutter can run applications directly in release mode without manually installing the generated build.

## Android

```bash
flutter run --release
```

## Web

```bash
flutter run -d chrome --release
```

## Windows

```bash
flutter run -d windows --release
```

## macOS

```bash
flutter run -d macos --release
```

## Linux

```bash
flutter run -d linux --release
```

---

# ⚠️ Platform requirements

Each platform requires its own tooling and SDKs.

| Platform | Required tooling                  |
| -------- | --------------------------------- |
| Android  | Android Studio + Android SDK      |
| iOS      | macOS + XCode                     |
| macOS    | XCode                             |
| Windows  | Visual Studio Desktop Development |
| Linux    | Linux build dependencies          |
| Web      | Supported browser                 |

---

# 🩺 Verify platform setup

Use:

```bash
flutter doctor -v
```

Flutter will show missing SDKs, licenses, or build tools for each enabled platform.
