import 'package:equatable/equatable.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';

/// Authentication session state.
class AuthState extends Equatable {
  final Auth? auth;

  const AuthState({this.auth});

  AuthState copyWith({Auth? auth}) {
    return AuthState(auth: auth ?? this.auth);
  }

  @override
  List<Object?> get props => [auth];
}
