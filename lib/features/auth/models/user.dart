import 'package:equatable/equatable.dart';

///
/// Authenticated user model
///
/// Represents the user returned by the backend after authentication.
///
class User extends Equatable {
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

  /// Serializes the user model for local persistence.
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, username, email, name];
}
