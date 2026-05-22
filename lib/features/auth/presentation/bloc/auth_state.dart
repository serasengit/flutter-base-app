import 'package:equatable/equatable.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';

/// Authentication session state.
class AuthState extends Equatable {
  static const Object _unset = Object();

  final Auth? auth;
  final bool isBootstrapping;

  const AuthState({this.auth, this.isBootstrapping = false});

  AuthState copyWith({Object? auth = _unset, bool? isBootstrapping}) {
    return AuthState(
      auth: identical(auth, _unset) ? this.auth : auth as Auth?,
      isBootstrapping: isBootstrapping ?? this.isBootstrapping,
    );
  }

  @override
  List<Object?> get props => [auth, isBootstrapping];
}
