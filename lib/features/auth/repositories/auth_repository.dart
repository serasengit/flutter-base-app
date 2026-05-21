import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';

/// Repository responsible for handling authentication operations.
///
/// This layer coordinates authentication requests between
/// the remote service and local storage.
class AuthRepository {
  /// Remote authentication service.
  final AuthService authService;

  /// Local storage service used to persist authentication data.
  final StorageService storageService;

  const AuthRepository({
    required this.authService,
    required this.storageService,
  });

  /// Performs the login process.
  ///
  /// If authentication succeeds and a valid access token exists,
  /// the token is stored locally.
  Future<Auth> login(Login login) async {
    final auth = await authService.login(login);

    // Persist authentication token locally when login succeeds.
    if (auth.isAuthenticated && auth.accessToken.isNotEmpty) {
      await storageService.saveAuthToken(auth.accessToken);
    }

    return auth;
  }

  /// Performs the logout process.
  ///
  /// Clears both the remote session and locally stored token.
  Future<void> logout() async {
    await authService.logout();
    await storageService.clearAuthToken();
  }
}
