import 'package:flutter/material.dart';
import 'package:flutter_base_app/app/theme/app_layout.dart';
import 'package:flutter_base_app/core/validators/validators.dart';
import 'package:flutter_base_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AuthContent();
  }
}

class _AuthContent extends StatefulWidget {
  const _AuthContent();

  @override
  State<_AuthContent> createState() => _AuthContentState();
}

class _AuthContentState extends State<_AuthContent> {
  final controller = AuthController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _scaffold(context, l10n);
  }

  Widget _scaffold(BuildContext context, AppLocalizations l10n) {
    return Scaffold(appBar: _appBar(l10n), body: _body(context, l10n));
  }

  PreferredSizeWidget _appBar(AppLocalizations l10n) {
    return AppBar(title: Text(l10n.login));
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: ViewLayout.pagePadding,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: FormLayout.authFormMaxWidth,
            ),
            child: _form(context, l10n),
          ),
        ),
      ),
    );
  }

  Widget _form(BuildContext context, AppLocalizations l10n) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _title(context, l10n),
          GapLayout.vXs,
          _subtitle(context, l10n),
          GapLayout.vLg,
          _usernameField(l10n),
          GapLayout.vSm,
          _passwordField(context, l10n),
          GapLayout.vMd,
          _submitButton(context, l10n),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.sign_in,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _subtitle(BuildContext context, AppLocalizations l10n) {
    return Text(
      l10n.sign_in_description,
      style: Theme.of(context).textTheme.bodyMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _usernameField(AppLocalizations l10n) {
    return TextFormField(
      controller: controller.usernameController,
      validator: (value) => Validators.combine([
        () => Validators.isRequired(value, l10n),
        () => Validators.maxLength(value, 100, l10n),
      ]),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: l10n.username,
        prefixIcon: const Icon(Icons.person_outline),
      ),
    );
  }

  Widget _passwordField(BuildContext context, AppLocalizations l10n) {
    return TextFormField(
      controller: controller.passwordController,
      validator: (value) => Validators.combine([
        () => Validators.isRequired(value, l10n),
        () => Validators.maxLength(value, 255, l10n),
      ]),
      obscureText: true,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: l10n.password,
        prefixIcon: const Icon(Icons.lock_outline),
      ),
      onFieldSubmitted: (_) => controller.submit(context),
    );
  }

  Widget _submitButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () => controller.submit(context),
      child: Text(l10n.login),
    );
  }
}
