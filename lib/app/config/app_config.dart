import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

    final info = await PackageInfo.fromPlatform();
    _packageName = info.packageName.trim();
    _version = info.version.trim();
    _buildNumber = info.buildNumber.trim();
  }

  ///
  /// Application package name
  ///
  static String _packageName = '';
  static String get packageName => _packageName;

  ///
  /// Application version
  ///
  static String _version = '';
  static String get version => _version;

  ///
  /// Application build number
  ///
  static String _buildNumber = '';
  static String get buildNumber => _buildNumber;

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
