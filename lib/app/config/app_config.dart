import 'package:flutter_dotenv/flutter_dotenv.dart';

///
/// Supported application environments
///
/// Common environments:
/// - dev  → local development
/// - test → testing / QA
/// - prod → production
///
enum Environment { dev, test, prod }

///
/// Global application configuration
///
/// Responsible for:
/// - Loading environment variables
/// - Managing application environment
/// - Exposing global configuration values
///
class AppConfig {
  ///
  /// Load environment configuration
  ///
  /// Reads variables from `.env` file.
  ///
  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  ///
  /// Application display name
  ///
  static String get appName => dotenv.env['APP_NAME'] ?? 'Flutter Base App';

  ///
  /// Backend API base URL
  ///
  static String get apiUrl => dotenv.env['API_URL'] ?? '';

  ///
  /// Current application environment
  ///
  static Environment get environment {
    final value = dotenv.env['APP_ENVIRONMENT']?.toLowerCase();

    return Environment.values.firstWhere(
      (env) => env.name == value,
      orElse: () => Environment.dev,
    );
  }

  ///
  /// Indicates whether the application is running in development environment
  ///
  static bool get isDevelopmentEnvironment => environment == Environment.dev;

  ///
  /// Indicates whether the application is running in test environment
  ///
  static bool get isTestEnvironment => environment == Environment.test;

  ///
  /// Indicates whether the application is running in production environment
  ///
  static bool get isProductionEnvironment => environment == Environment.prod;
}
