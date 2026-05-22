import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
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
  _FakeAuthService({
    this.authToReturn,
    this.loginError,
    this.onLogout,
  }) : super(client: _UnusedClient());

  final Auth? authToReturn;
  final Exception? loginError;
  final void Function()? onLogout;

  @override
  Future<Auth> login(Login login) async {
    if (loginError != null) {
      throw loginError!;
    }

    return authToReturn!;
  }

  @override
  Future<void> logout() async {
    onLogout?.call();
  }
}

void main() {
  const auth = Auth(
    accessToken: 'token',
    isAuthenticated: true,
    user: User(id: '1', username: 'tester', name: 'Test User'),
    permissions: <String>['users:read'],
  );

  late StorageService storageService;
  late Logger logger;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    configureDependencies();
    storageService = StorageService();
    logger = Logger();
  });

  test('emits authenticated state on successful login', () async {
    final repository = AuthRepository(
      authService: _FakeAuthService(authToReturn: auth),
      storageService: storageService,
    );
    final bloc = AuthBloc(repository: repository, logger: logger);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[equals(const AuthState(auth: auth))]),
    );

    bloc.add(const LogIn(username: 'tester', password: 'secret'));

    await expectation;
    expect(await storageService.getAuthToken(), 'token');
    await bloc.close();
  });

  test('emits empty state on failed login', () async {
    final repository = AuthRepository(
      authService: _FakeAuthService(loginError: Exception('boom')),
      storageService: storageService,
    );
    final bloc = AuthBloc(repository: repository, logger: logger);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[equals(const AuthState())]),
    );

    bloc.add(const LogIn(username: 'tester', password: 'secret'));

    await expectation;
    expect(await storageService.getAuthToken(), isNull);
    await bloc.close();
  });

  test('clears auth state on logout', () async {
    var didLogout = false;
    final repository = AuthRepository(
      authService: _FakeAuthService(
        authToReturn: auth,
        onLogout: () => didLogout = true,
      ),
      storageService: storageService,
    );
    final bloc = AuthBloc(repository: repository, logger: logger);

    bloc.add(const LogIn(username: 'tester', password: 'secret'));
    await Future<void>.delayed(Duration.zero);

    final expectation = expectLater(
      bloc.stream,
      emitsInOrder(<Matcher>[equals(const AuthState())]),
    );

    bloc.add(const LogOut());

    await expectation;
    expect(didLogout, isTrue);
    expect(await storageService.getAuthToken(), isNull);
    await bloc.close();
  });
}
