import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';

class FakeAuthService extends AuthService {
  FakeAuthService({
    this.authToReturn,
    this.loginError,
    this.onLogin,
    this.onLogout,
  });

  final Auth? authToReturn;
  final Exception? loginError;
  final Future<void> Function(Login login)? onLogin;
  final Future<void> Function()? onLogout;

  @override
  Future<Auth> login(Login login) async {
    if (onLogin != null) {
      await onLogin!(login);
    }

    if (loginError != null) {
      throw loginError!;
    }

    if (authToReturn == null) {
      throw StateError('FakeAuthService requires authToReturn or loginError.');
    }

    return authToReturn!;
  }

  @override
  Future<void> logout() async {
    if (onLogout != null) {
      await onLogout!();
    }
  }
}
