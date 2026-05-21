import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
