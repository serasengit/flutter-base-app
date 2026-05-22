import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/app.dart';
import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/home/presentation/home_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
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
  });

  testWidgets('App restores persisted session before choosing home', (
    WidgetTester tester,
  ) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    await AppConfig.load();

    final storageService = locator<StorageService>();
    await storageService.saveAuthSession(
      const Auth(
        accessToken: 'token',
        isAuthenticated: true,
        user: User(id: '1', username: 'tester', name: 'Test User'),
        permissions: <String>['users:read'],
      ),
    );

    await tester.pumpWidget(const App());
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(HomePage), findsOneWidget);
  });
}
