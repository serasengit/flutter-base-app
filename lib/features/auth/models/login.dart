///
/// Login model
///
/// Represents user credentials sent to the authentication endpoint.
///
class Login {
  final String username;
  final String password;

  const Login({required this.username, required this.password});

  ///
  /// Converts login credentials to JSON.
  ///
  Map<String, dynamic> toJson() => {'username': username, 'password': password};
}
