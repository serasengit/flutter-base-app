import 'package:flutter/material.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

///
/// Authentication controller
///
/// Responsible for managing form controllers and dispatching authentication events.
///
class AuthController {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  ///
  /// Validates the form and submits login event.
  ///
  void submit(BuildContext context) {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    context.read<AuthBloc>().add(
      LogIn(
        username: usernameController.text.trim(),
        password: passwordController.text,
      ),
    );
  }

  ///
  /// Releases controller resources.
  ///
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
  }
}
