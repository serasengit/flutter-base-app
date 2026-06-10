import 'dart:convert';

import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/features/auth/models/login.dart';
import 'package:flutter_base_app/features/auth/services/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class _RecordingClient extends http.BaseClient {
  _RecordingClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) _handler;
  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    return _handler(request);
  }
}

void main() {
  group('AuthService', () {
    setUp(() async {
      PackageInfo.setMockInitialValues(
        appName: 'Flutter Base App',
        packageName: 'com.example.flutter_base_app',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: '',
      );
      await AppConfig.load();
    });

    test('login posts credentials and parses auth payload', () async {
      final client = _RecordingClient((request) async {
        return http.StreamedResponse(
          Stream<List<int>>.value(
            utf8.encode(
              jsonEncode(<String, dynamic>{
                'accessToken': 'abc',
                'isAuthenticated': true,
                'user': <String, dynamic>{
                  'id': 1,
                  'username': 'demo',
                  'name': 'Demo User',
                  'language': 'en',
                  'role': <String, dynamic>{'id': 1, 'code': 'admin'},
                },
                'permissions': <String>['users:read'],
              }),
            ),
          ),
          200,
          request: request,
        );
      });
      final service = AuthService(client: client);

      final auth = await service.login(
        const Login(username: 'demo', password: 'secret'),
      );

      final request = client.requests.single as http.Request;
      expect(request.method, 'POST');
      expect(request.url.toString(), '${AppConfig.apiUrl}/auth');
      expect(request.body, jsonEncode(const Login(username: 'demo', password: 'secret').toJson()));
      expect(auth.accessToken, 'abc');
      expect(auth.user.username, 'demo');
      expect(auth.permissions, <String>['users:read']);
    });

    test('logout posts to logout endpoint', () async {
      final client = _RecordingClient((request) async {
        return http.StreamedResponse(
          Stream<List<int>>.value(const <int>[]),
          204,
          request: request,
        );
      });
      final service = AuthService(client: client);

      await service.logout();

      final request = client.requests.single as http.Request;
      expect(request.method, 'POST');
      expect(request.url.toString(), '${AppConfig.apiUrl}/auth/logout');
    });
  });
}
