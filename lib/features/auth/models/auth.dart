import 'package:flutter_base_app/features/auth/models/user.dart';

///
/// Authentication model
///
/// Represents a successful authentication session.
///
class Auth {
  final String accessToken;
  final bool isAuthenticated;
  final User user;
  final List<String> permissions;

  const Auth({
    required this.accessToken,
    required this.isAuthenticated,
    required this.user,
    required this.permissions,
  });

  ///
  /// Creates an auth model from backend JSON.
  ///
  factory Auth.fromJson(Map<String, dynamic> json) {
    return Auth(
      accessToken: json['accessToken']?.toString() ?? '',
      isAuthenticated: json['isAuthenticated'] == true,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      permissions: List<String>.from(json['permissions'] ?? []),
    );
  }
}
