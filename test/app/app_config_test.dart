import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Flutter Base App',
      packageName: 'com.example.flutter_base_app',
      version: '1.0.0',
      buildNumber: '1',
      buildSignature: '',
    );
  });

  test('AppConfig loads environment and exposes derived getters', () async {
    await AppConfig.load();

    expect(AppConfig.appName, isNotEmpty);
    expect(AppConfig.apiUrl, isA<String>());
    expect(Environment.values, contains(AppConfig.environment));

    final enabledFlags = <bool>[
      AppConfig.isDevelopmentEnvironment,
      AppConfig.isTestEnvironment,
      AppConfig.isProductionEnvironment,
    ].where((value) => value).length;

    expect(enabledFlags, 1);
  });
}
