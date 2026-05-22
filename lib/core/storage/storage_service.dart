import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
/// Local key-value storage service
///
/// Responsible for:
/// - Reading persisted values
/// - Saving persisted values
/// - Removing persisted values
///
/// This service uses SharedPreferences internally.
///
class StorageService {
  StorageService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  ///
  /// Authentication token storage key
  ///
  static const String authTokenKey = 'AUTH_TOKEN';

  ///
  /// Authentication session storage key
  ///
  static const String authSessionKey = 'AUTH_SESSION';

  ///
  /// Returns the saved authentication token
  ///
  Future<String?> getAuthToken() async {
    return _secureStorage.read(key: authTokenKey);
  }

  ///
  /// Saves the authentication token
  ///
  Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: authTokenKey, value: token);
  }

  ///
  /// Returns the saved authentication session
  ///
  Future<Auth?> getAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    final rawSession = prefs.getString(authSessionKey);

    if (rawSession == null || rawSession.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawSession) as Map<String, dynamic>;
    return Auth.fromJson(decoded);
  }

  ///
  /// Saves the authentication session
  ///
  Future<void> saveAuthSession(Auth auth) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(authSessionKey, jsonEncode(auth.toJson()));
    await _secureStorage.write(key: authTokenKey, value: auth.accessToken);
  }

  ///
  /// Removes the authentication token
  ///
  Future<void> clearAuthToken() async {
    await _secureStorage.delete(key: authTokenKey);
  }

  ///
  /// Removes the persisted authentication session
  ///
  Future<void> clearAuthSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(authSessionKey);
    await _secureStorage.delete(key: authTokenKey);
  }
}
