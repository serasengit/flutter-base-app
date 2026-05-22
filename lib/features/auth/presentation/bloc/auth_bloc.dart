import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';

/// Manages authentication session state and login/logout actions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;
  final Logger logger;

  AuthBloc({required this.repository, required this.logger})
    : super(const AuthState(isBootstrapping: true)) {
    on<RestoreSession>(_restoreSession);
    on<LogIn>(_logIn);
    on<LogOut>(_logOut);
  }

  /// Restores a previously persisted session during app startup.
  Future<void> _restoreSession(
    RestoreSession event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final auth = await repository.restoreSession();
      emit(AuthState(auth: auth, isBootstrapping: false));
    } catch (error, stackTrace) {
      logger.e(
        'Failed to restore persisted session',
        error: error,
        stackTrace: stackTrace,
      );

      emit(const AuthState(isBootstrapping: false));
    }
  }

  /// Executes the login flow and stores the authenticated session in state.
  Future<void> _logIn(LogIn event, Emitter<AuthState> emit) async {
    try {
      final auth = await repository.login(
        Login(username: event.username, password: event.password),
      );

      emit(state.copyWith(auth: auth, isBootstrapping: false));
    } catch (error, stackTrace) {
      logger.e('Authentication failed', error: error, stackTrace: stackTrace);

      emit(const AuthState(isBootstrapping: false));
    }
  }

  /// Clears the persisted session and resets auth state.
  Future<void> _logOut(LogOut event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(const AuthState(isBootstrapping: false));
  }
}
