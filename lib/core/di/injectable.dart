import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/core/dialogs/dialog_service.dart';
import 'package:flutter_base_app/core/network/http_client_factory.dart';
import 'package:flutter_base_app/core/network/http_interceptor.dart';
import 'package:flutter_base_app/core/network/request_feedback_coordinator.dart';
import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// Dependency injection container.
final GetIt locator = GetIt.instance;

/// Dependency registration types:
///
/// registerFactory:
/// Creates a new instance every time the dependency is requested.
///
/// registerFactoryParam:
/// Same as registerFactory, but allows passing up to 2 parameters.
///
/// registerSingleton:
/// Registers a singleton instance that lives during the entire app lifecycle.
///
/// registerLazySingleton:
/// Same as registerSingleton, but the instance is created only when first used.

///
/// Configures application dependencies.
///
/// Register here all shared services used across the application.
///
void configureDependencies() {
  if (locator.isRegistered<Logger>()) {
    return;
  }

  // Logger
  locator.registerLazySingleton<Logger>(
    () => Logger(
      printer: PrettyPrinter(
        // Number of method calls displayed in logs.
        // Set to 0 to disable stack trace lines.
        methodCount: 0,

        // Number of method calls displayed for error logs
        // when a stack trace is available.
        errorMethodCount: 5,

        // Maximum width of each log line before wrapping.
        lineLength: 120,

        // Enables ANSI colors in console output.
        colors: true,

        // Displays emojis depending on log level.
        //
        // Examples:
        // 🐛 debug
        // ℹ️ info
        // ⚠️ warning
        // ❌ error
        printEmojis: true,

        // Includes timestamp information in logs.
        // Displays current time and elapsed application time.
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    ),
  );

  // Local storage service
  locator.registerLazySingleton<StorageService>(() => StorageService());

  // Global dialog service
  locator.registerLazySingleton<DialogService>(() => DialogService());

  // Global request tracker
  locator.registerLazySingleton<RequestTracker>(() => RequestTracker());

  // Global request feedback controller
  locator.registerLazySingleton<RequestFeedbackCoordinator>(
    () => RequestFeedbackCoordinator(
      requestTracker: locator<RequestTracker>(),
      dialogService: locator<DialogService>(),
    ),
  );

  // HTTP interceptor
  locator.registerLazySingleton<HttpInterceptor>(
    () => HttpInterceptor(
      storageService: locator<StorageService>(),
      logger: locator<Logger>(),
    ),
  );

  // Shared HTTP client configured with interception and request tracking
  locator.registerLazySingleton<http.Client>(() => HttpClientFactory.create());

  // Services
  locator.registerLazySingleton<AuthService>(
    () => AuthService(client: locator<http.Client>()),
  );

  // Repositories
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authService: locator<AuthService>(),
      storageService: locator<StorageService>(),
    ),
  );

  // Global blocs
  locator.registerLazySingleton<AppBloc>(() => AppBloc());

  locator.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      repository: locator<AuthRepository>(),
      logger: locator<Logger>(),
    ),
  );
}
