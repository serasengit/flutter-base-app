import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/bloc/app_bloc.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_base_app/features/home/presentation/home_page.dart';
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

class _NoOpAuthService extends AuthService {
  _NoOpAuthService() : super(client: _UnusedClient());

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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
  });

  testWidgets('HomePage renders HomeView', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: <BlocProvider>[
          BlocProvider<AppBloc>(create: (_) => AppBloc()),
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              repository: AuthRepository(
                authService: _NoOpAuthService(),
                storageService: StorageService(),
              ),
              logger: Logger(),
            ),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );

    expect(find.byType(HomeView), findsOneWidget);
  });
}
