import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/app/bloc/app_event.dart';
import 'package:flutter_base_app/app/routes/app_module.dart';
import 'package:flutter_base_app/app/routes/app_modules.dart';
import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_base_app/features/home/presentation/views/home_view.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnusedClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError('This fake AuthService should not send HTTP requests.');
  }
}

class _FakeAuthService extends AuthService {
  _FakeAuthService() : super(client: _UnusedClient());

  @override
  Future<void> logout() async {}
}

Widget _buildHome(AppBloc appBloc, AuthBloc authBloc) {
  return MultiBlocProvider(
    providers: <BlocProvider<dynamic>>[
      BlocProvider<AppBloc>.value(value: appBloc),
      BlocProvider<AuthBloc>.value(value: authBloc),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeView(),
    ),
  );
}

void main() {
  late AppBloc appBloc;
  late AuthBloc authBloc;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    configureDependencies();
    appBloc = AppBloc();
    authBloc = AuthBloc(
      repository: AuthRepository(
        authService: _FakeAuthService(),
        storageService: StorageService(),
      ),
      logger: Logger(),
    );
  });

  tearDown(() async {
    await appBloc.close();
    await authBloc.close();
  });

  testWidgets('drawer shows available modules', (tester) async {
    await tester.pumpWidget(_buildHome(appBloc, authBloc));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(HomeView)))!;

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text(l10n.users), findsOneWidget);
    expect(find.text(l10n.cities), findsOneWidget);
    expect(find.text(l10n.meteo_stations), findsOneWidget);
    expect(find.text(l10n.logout), findsOneWidget);
  });

  testWidgets('drawer only shows modules allowed by the current shell state', (
    tester,
  ) async {
    appBloc.add(
      const SetModules(
        modules: <AppModule>[
          homeModule,
          AppModule(
            route: AppRoutes.users,
            labelKey: 'users',
            icon: Icons.people_outline,
            order: 2,
            permissionPrefixes: <String>['users:'],
          ),
          logoutModule,
        ],
      ),
    );
    await Future<void>.delayed(Duration.zero);

    await tester.pumpWidget(_buildHome(appBloc, authBloc));
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(HomeView)))!;

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text(l10n.users), findsOneWidget);
    expect(find.text(l10n.cities), findsNothing);
    expect(find.text(l10n.meteo_stations), findsNothing);
    expect(find.text(l10n.logout), findsOneWidget);
  });
}
