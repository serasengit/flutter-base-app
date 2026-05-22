import 'package:flutter/material.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_base_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_base_app/features/auth/repositories/auth_repository.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class _UnusedClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError('This fake AuthService should not send HTTP requests.');
  }
}

class _NoOpAuthService extends AuthService {
  _NoOpAuthService() : super(client: _UnusedClient());

  @override
  Future<Auth> login(Login login) async {
    return const Auth(
      accessToken: 'token',
      isAuthenticated: true,
      user: User(id: '1', username: 'demo-user', name: 'Demo User'),
      permissions: <String>[],
    );
  }

  @override
  Future<void> logout() async {}
}

class _RecordingAuthBloc extends AuthBloc {
  _RecordingAuthBloc()
    : super(
        repository: AuthRepository(
          authService: _NoOpAuthService(),
          storageService: StorageService(),
        ),
        logger: Logger(),
      );

  final List<AuthEvent> receivedEvents = <AuthEvent>[];

  @override
  void add(AuthEvent event) {
    receivedEvents.add(event);

    // Intentionally do not call super.add(event).
    // These tests only verify that the controller dispatches events.
  }
}

void main() {
  group('AuthController', () {
    setUp(configureDependencies);

    testWidgets('dispatches login event when the form is valid', (
      tester,
    ) async {
      final controller = AuthController();
      final bloc = _RecordingAuthBloc();

      late BuildContext buildContext;

      controller.usernameController.text = '  demo-user  ';
      controller.passwordController.text = 'secret';

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Form(
                key: controller.formKey,
                child: Builder(
                  builder: (context) {
                    buildContext = context;
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      controller.submit(buildContext);

      await tester.pump();

      expect(bloc.receivedEvents.length, 1);

      expect(
        bloc.receivedEvents.single,
        const LogIn(username: 'demo-user', password: 'secret'),
      );

      controller.dispose();
    });

    testWidgets('does not dispatch login event when the form is invalid', (
      tester,
    ) async {
      final controller = AuthController();
      final bloc = _RecordingAuthBloc();

      late BuildContext buildContext;

      await tester.pumpWidget(
        BlocProvider<AuthBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: Scaffold(
              body: Form(
                key: controller.formKey,
                child: Builder(
                  builder: (context) {
                    buildContext = context;

                    return TextFormField(validator: (_) => 'invalid');
                  },
                ),
              ),
            ),
          ),
        ),
      );

      controller.submit(buildContext);

      await tester.pump();

      expect(bloc.receivedEvents, isEmpty);

      controller.dispose();
    });

    test('dispose releases text controllers', () {
      final controller = AuthController();

      controller.dispose();

      expect(
        () => controller.usernameController.text = 'value',
        throwsA(isA<FlutterError>()),
      );

      expect(
        () => controller.passwordController.text = 'value',
        throwsA(isA<FlutterError>()),
      );
    });
  });
}
