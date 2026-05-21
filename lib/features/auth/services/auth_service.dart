import 'dart:convert';

import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/core/network/http_client_factory.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';

///
/// Authentication service
///
/// Responsible for direct HTTP communication with the authentication API.
///
class AuthService {
  final _client = HttpClientFactory.create();

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
