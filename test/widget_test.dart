import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/app.dart';
import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await locator.reset(dispose: true);
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    PackageInfo.setMockInitialValues(
      appName: 'Flutter Base App',
      packageName: 'com.example.flutter_base_app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  tearDown(() async {
    await locator.reset(dispose: true);
  });

  testWidgets('App loads auth view first', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    await AppConfig.load();

    await tester.pumpWidget(const App());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
