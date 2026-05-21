import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/config/app_config.dart';
import 'core/di/injectable.dart';

///
/// Application entry point
///
/// Responsible for:
/// - Initializing Flutter bindings
/// - Loading application configuration
/// - Initializing environment variables
/// - Starting the root application widget
///
Future<void> main() async {
  // Ensure Flutter engine bindings are initialized
  // before executing async platform code.
  WidgetsFlutterBinding.ensureInitialized();

  // Register application dependencies
  configureDependencies();

  // Load application configuration
  // (.env, environments, global settings, etc.)
  await AppConfig.load();

  // Launch application
  runApp(const App());
}
