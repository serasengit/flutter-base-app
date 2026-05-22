import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_base_app/features/home/presentation/views/home_view.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppModule _moduleByRoute(String route) {
  return appModules.firstWhere((module) => module.route == route);
}

class _DummyClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }
}

class _NoOpAuthService extends AuthService {
  _NoOpAuthService() : super(client: _DummyClient());

  @override
  Future<Auth> login(Login login) async {
    return const Auth(
      accessToken: 'token',
      isAuthenticated: true,
      user: User(id: '1', username: 'demo-user', name: 'Demo User'),
      permissions: <String>[],
    );
  }

  @override
  Future<void> logout() async {}
}

class _RecordingAuthBloc extends AuthBloc {
  _RecordingAuthBloc()
    : super(
        repository: AuthRepository(
          authService: _NoOpAuthService(),
          storageService: StorageService(),
        ),
        logger: Logger(),
      );

  final List<AuthEvent> receivedEvents = <AuthEvent>[];

  @override
  void add(AuthEvent event) {
    receivedEvents.add(event);
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home back navigation flow', () {
    late AppBloc appBloc;
    late _RecordingAuthBloc authBloc;

    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      FlutterSecureStorage.setMockInitialValues(<String, String>{});
      appBloc = AppBloc();
      authBloc = _RecordingAuthBloc();
    });

    tearDown(() async {
      await appBloc.close();
      await authBloc.close();
    });

    testWidgets('goes back through module history and then logs out', (tester) async {
      final usersModule = _moduleByRoute(AppRoutes.users);
      final citiesModule = _moduleByRoute(AppRoutes.cities);
      final meteoStationsModule = _moduleByRoute(AppRoutes.meteoStations);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: <BlocProvider>[
            BlocProvider<AppBloc>.value(value: appBloc),
            BlocProvider<AuthBloc>.value(value: authBloc),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const HomeView(),
          ),
        ),
      );

      appBloc
        ..add(SetModule(module: usersModule))
        ..add(SetModule(module: citiesModule))
        ..add(SetModule(module: meteoStationsModule));
      await tester.pumpAndSettle();

      expect(appBloc.state.module, meteoStationsModule);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(appBloc.state.module, citiesModule);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(appBloc.state.module, usersModule);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(authBloc.receivedEvents, <AuthEvent>[const LogOut()]);
    });
  });
}
