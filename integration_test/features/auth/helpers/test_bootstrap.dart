import 'package:flutter/widgets.dart';
import 'package:flutter_base_app/app/app.dart';
import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_auth_service.dart';

Future<void> bootstrapTestApp(
  WidgetTester tester, {
  Auth? authToReturn,
  Exception? loginError,
  Future<void> Function()? onLogout,
}) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});
  FlutterSecureStorage.setMockInitialValues(<String, String>{});
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();

  await _resetDependencies();
  configureDependencies();
  await AppConfig.load();

  _overrideAuthGraph(
    authToReturn: authToReturn,
    loginError: loginError,
    onLogout: onLogout,
  );

  await tester.pumpWidget(const App());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Future<void> _resetDependencies() async {
  await locator.reset(dispose: true);
}

void _overrideAuthGraph({
  Auth? authToReturn,
  Exception? loginError,
  Future<void> Function()? onLogout,
}) {
  final getIt = locator;

  _unregisterIfNeeded<AuthBloc>(getIt);
  _unregisterIfNeeded<AuthRepository>(getIt);
  _unregisterIfNeeded<AuthService>(getIt);

  getIt.registerLazySingleton<AuthService>(
    () => FakeAuthService(
      authToReturn: authToReturn,
      loginError: loginError,
      onLogout: onLogout,
      client: getIt<http.Client>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      authService: getIt<AuthService>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<AuthBloc>(
    () =>
        AuthBloc(repository: getIt<AuthRepository>(), logger: getIt<Logger>()),
  );
}

void _unregisterIfNeeded<T extends Object>(GetIt getIt) {
  if (getIt.isRegistered<T>()) {
    getIt.unregister<T>();
  }
}
