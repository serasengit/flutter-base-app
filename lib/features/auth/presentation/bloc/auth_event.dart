import 'package:equatable/equatable.dart';

/// Base type for authentication events.
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Login event
class LogIn extends AuthEvent {
  final String username;
  final String password;

  const LogIn({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}

/// Logout event
class LogOut extends AuthEvent {
  const LogOut();
}
