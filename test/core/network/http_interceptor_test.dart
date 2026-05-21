import 'dart:convert';

import 'package:flutter_base_app/core/network/api_error.dart';
import 'package:flutter_base_app/core/network/http_interceptor.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('HttpInterceptor', () {
    late StorageService storageService;
    late HttpInterceptor interceptor;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});

      storageService = StorageService();

      interceptor = HttpInterceptor(
        storageService: storageService,
        logger: Logger(),
      );
    });

    test('adds default headers without authorization', () async {
      final request = http.Request(
        'POST',
        Uri.parse('https://example.com/users'),
      );

      final intercepted = await interceptor.interceptRequest(request: request);

      expect(intercepted.headers['Content-Type'], 'application/json');

      expect(intercepted.headers['Accept'], 'application/json');

      expect(intercepted.headers['language'], isNotEmpty);

      expect(intercepted.headers.containsKey('Authorization'), isFalse);
    });

    test('adds bearer token when access token exists', () async {
      await storageService.saveAuthToken('token-123');

      final request = http.Request(
        'POST',
        Uri.parse('https://example.com/users'),
      );

      final intercepted = await interceptor.interceptRequest(request: request);

      expect(intercepted.headers['Authorization'], 'Bearer token-123');
    });

    test('returns successful responses unchanged', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        jsonEncode(<String, dynamic>{'ok': true}),
        200,
        request: request,
      );

      final intercepted = await interceptor.interceptResponse(
        response: response,
      );

      expect(intercepted.statusCode, 200);
    });

    test('returns streamed successful responses unchanged', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.StreamedResponse(
        Stream<List<int>>.value(
          utf8.encode(jsonEncode(<String, dynamic>{'ok': true})),
        ),
        201,
        request: request,
      );

      final intercepted = await interceptor.interceptResponse(
        response: response,
      );

      expect(intercepted.statusCode, 201);
    });

    test('throws ApiError with json message for failed responses', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        jsonEncode(<String, dynamic>{'message': 'Usuario no encontrado'}),
        404,
        request: request,
      );

      expect(
        () => interceptor.interceptResponse(response: response),
        throwsA(
          isA<ApiError>()
              .having((error) => error.statusCode, 'statusCode', 404)
              .having(
                (error) => error.message,
                'message',
                'Usuario no encontrado',
              ),
        ),
      );
    });

    test(
      'throws ApiError with plain text message when body is not json',
      () async {
        final request = http.Request(
          'GET',
          Uri.parse('https://example.com/users'),
        );

        final response = http.Response(
          'Service unavailable',
          503,
          request: request,
        );

        expect(
          () => interceptor.interceptResponse(response: response),
          throwsA(
            isA<ApiError>()
                .having((error) => error.statusCode, 'statusCode', 503)
                .having(
                  (error) => error.message,
                  'message',
                  'Service unavailable',
                ),
          ),
        );
      },
    );

    test('throws ApiError using reason phrase when body is empty', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        '',
        500,
        request: request,
        reasonPhrase: 'Internal Server Error',
      );

      expect(
        () => interceptor.interceptResponse(response: response),
        throwsA(
          isA<ApiError>()
              .having((error) => error.statusCode, 'statusCode', 500)
              .having(
                (error) => error.message,
                'message',
                'Internal Server Error',
              ),
        ),
      );
    });

    test('extracts code and message from structured json error', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        jsonEncode(<String, dynamic>{
          'code': 'user_not_found',
          'message': 'User not found',
        }),
        404,
        request: request,
      );

      expect(
        () => interceptor.interceptResponse(response: response),
        throwsA(
          isA<ApiError>()
              .having((error) => error.code, 'code', 'user_not_found')
              .having((error) => error.message, 'message', 'User not found'),
        ),
      );
    });

    test('extracts nested context details message', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        jsonEncode(<String, dynamic>{
          'context': <String, dynamic>{'details': 'Nested backend error'},
        }),
        422,
        request: request,
      );

      expect(
        () => interceptor.interceptResponse(response: response),
        throwsA(
          isA<ApiError>().having(
            (error) => error.message,
            'message',
            'Nested backend error',
          ),
        ),
      );
    });

    test('extracts nested validation error message', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        jsonEncode(<String, dynamic>{
          'context': <String, dynamic>{
            'errors': <Map<String, dynamic>>[
              <String, dynamic>{
                'code': 'invalid_email',
                'message': 'Email format invalid',
              },
            ],
          },
        }),
        422,
        request: request,
      );

      expect(
        () => interceptor.interceptResponse(response: response),
        throwsA(
          isA<ApiError>().having(
            (error) => error.message,
            'message',
            '[invalid_email] Email format invalid',
          ),
        ),
      );
    });

    test('uses response body string when json is not a map', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/users'),
      );

      final response = http.Response(
        jsonEncode(<String>['error-1', 'error-2']),
        400,
        request: request,
      );

      expect(
        () => interceptor.interceptResponse(response: response),
        throwsA(
          isA<ApiError>().having(
            (error) => error.message,
            'message',
            '[error-1, error-2]',
          ),
        ),
      );
    });
  });
}
