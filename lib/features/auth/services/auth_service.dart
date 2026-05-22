import 'dart:convert';

import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:http/http.dart' as http;

///
/// Authentication service
///
/// Responsible for direct HTTP communication with the authentication API.
///
class AuthService {
  final http.Client _client;

  AuthService({required http.Client client}) : _client = client;

  ///
  /// Sends login credentials to the backend.
  ///
  Future<Auth> login(Login login) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.apiUrl}/auth'),
      body: jsonEncode(login.toJson()),
    );

    return Auth.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  ///
  /// Sends logout request to the backend.
  ///
  Future<void> logout() async {
    await _client.post(Uri.parse('${AppConfig.apiUrl}/auth/logout'));
  }
}
