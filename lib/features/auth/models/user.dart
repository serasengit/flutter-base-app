///
/// Authenticated user model
///
/// Represents the user returned by the backend after authentication.
///
class User {
  final String id;
  final String username;
  final String? email;
  final String? name;

  const User({required this.id, required this.username, this.email, this.name});

  ///
  /// Creates a user model from backend JSON.
  ///
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      name: json['name']?.toString(),
    );
  }
}
