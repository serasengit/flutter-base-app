import 'package:flutter/material.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';

///
/// Authentication controller
///
/// Responsible for managing form controllers and dispatching authentication events.
///
class AuthController {
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final appVersion = ValueNotifier<String?>(null);

  Future<void> initPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final buildNumber = packageInfo.buildNumber.trim();
    final version = packageInfo.version.trim();

    appVersion.value = buildNumber.isEmpty ? version : '$version+$buildNumber';
  }

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
    appVersion.dispose();
  }
}
