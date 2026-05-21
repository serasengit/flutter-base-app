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
  ///
  /// Authentication token storage key
  ///
  static const String authTokenKey = 'AUTH_TOKEN';

  ///
  /// Returns the saved authentication token
  ///
  Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(authTokenKey);
  }

  ///
  /// Saves the authentication token
  ///
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(authTokenKey, token);
  }

  ///
  /// Removes the authentication token
  ///
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(authTokenKey);
  }
}
