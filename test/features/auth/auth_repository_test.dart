import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _UnusedClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError('This fake AuthService should not send HTTP requests.');
  }
}

class _FakeAuthService extends AuthService {
  _FakeAuthService({
    required this.authToReturn,
    this.onLogout,
  }) : super(client: _UnusedClient());

  final Auth authToReturn;
  final void Function()? onLogout;

  @override
  Future<Auth> login(Login login) async => authToReturn;

  @override
  Future<void> logout() async {
    onLogout?.call();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    configureDependencies();
  });

  test('stores auth token on successful login', () async {
    const auth = Auth(
      accessToken: 'token',
      isAuthenticated: true,
      user: User(id: '1', username: 'tester'),
      permissions: <String>['users:read'],
    );
    final storageService = StorageService();
    final repository = AuthRepository(
      authService: _FakeAuthService(authToReturn: auth),
      storageService: storageService,
    );

    final result = await repository.login(
      const Login(username: 'tester', password: 'secret'),
    );

    expect(result, same(auth));
    expect(await storageService.getAuthToken(), 'token');
    expect((await storageService.getAuthSession())?.user.username, 'tester');
  });

  test('does not store auth token when login is not authenticated', () async {
    const auth = Auth(
      accessToken: '',
      isAuthenticated: false,
      user: User(id: '1', username: 'tester'),
      permissions: <String>[],
    );
    final storageService = StorageService();
    final repository = AuthRepository(
      authService: _FakeAuthService(authToReturn: auth),
      storageService: storageService,
    );

    await repository.login(const Login(username: 'tester', password: 'secret'));

    expect(await storageService.getAuthToken(), isNull);
    expect(await storageService.getAuthSession(), isNull);
  });

  test('restores persisted auth session', () async {
    const auth = Auth(
      accessToken: 'token',
      isAuthenticated: true,
      user: User(id: '1', username: 'tester'),
      permissions: <String>['users:read'],
    );
    final storageService = StorageService();
    await storageService.saveAuthSession(auth);

    final repository = AuthRepository(
      authService: _FakeAuthService(authToReturn: auth),
      storageService: storageService,
    );

    final restored = await repository.restoreSession();

    expect(restored?.accessToken, 'token');
    expect(restored?.user.username, 'tester');
    expect(restored?.permissions, <String>['users:read']);
  });

  test('logout clears persisted auth token', () async {
    var didLogout = false;
    const auth = Auth(
      accessToken: 'token',
      isAuthenticated: true,
      user: User(id: '1', username: 'tester'),
      permissions: <String>[],
    );
    final storageService = StorageService();
    await storageService.saveAuthToken('token');

    final repository = AuthRepository(
      authService: _FakeAuthService(
        authToReturn: auth,
        onLogout: () => didLogout = true,
      ),
      storageService: storageService,
    );

    await repository.logout();

    expect(didLogout, isTrue);
    expect(await storageService.getAuthToken(), isNull);
    expect(await storageService.getAuthSession(), isNull);
  });
}
