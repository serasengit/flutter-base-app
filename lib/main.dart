import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base_app/core/debug/bloc_devtools/bloc_devtools_client.dart';
import 'package:flutter_base_app/core/debug/bloc_devtools/bloc_devtools_observer.dart';

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

  if (kDebugMode) {
    final blocDevToolsClient = BlocDevToolsClient(logger: locator());
    blocDevToolsClient.start();
    Bloc.observer = BlocDevToolsObserver(sink: blocDevToolsClient);
  }
  // Load application configuration
  // (.env, environments, global settings, etc.)
  await AppConfig.load();

  // Launch application
  runApp(const App());
}
