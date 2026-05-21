import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter_base_app/core/network/api_error.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_base_app/core/storage/storage_service.dart';
import 'package:flutter_base_app/core/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http_interceptor.dart';
import 'package:logger/logger.dart';

///
/// HTTP request and response interceptor
///
/// Responsible for:
/// - Adding default request headers
/// - Adding authorization token when available
/// - Handling HTTP error responses globally
///
class HttpInterceptor extends InterceptorContract {
  final StorageService _storageService;
  final Logger _logger;

  HttpInterceptor({StorageService? storageService, Logger? logger})
    : _storageService = storageService ?? StorageService(),
      _logger = logger ?? locator<Logger>();

  ///
  /// Intercepts outgoing HTTP requests
  ///
  /// Adds:
  /// - Content-Type
  /// - Accept
  /// - Authorization header when token exists
  /// - Device language header
  ///
  @override
  Future<http.BaseRequest> interceptRequest({
    required http.BaseRequest request,
  }) async {
    // Read the persisted token just before sending the request so the header
    // always reflects the latest authenticated session.
    final token = await _storageService.getAuthToken();
    final languageCode = _resolveDeviceLanguageCode();

    request.headers['Content-Type'] = 'application/json';
    request.headers['Accept'] = 'application/json';
    request.headers['language'] = languageCode;

    if (isSet(token)) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    _logger.i('HTTP ${request.method} ${request.url}');
    _logger.d('Request headers: ${request.headers}');

    return request;
  }

  ///
  /// Returns the current device language code in simple header format.
  ///
  /// Example values:
  /// - en
  /// - es
  ///
  String _resolveDeviceLanguageCode() {
    final languageCode = ui.PlatformDispatcher.instance.locale.languageCode;
    return isSet(languageCode) ? languageCode.trim().toLowerCase() : 'en';
  }

  ///
  /// Intercepts incoming HTTP responses
  ///
  /// Allows successful responses:
  /// - 200
  /// - 201
  /// - 202
  /// - Any 2xx response
  ///
  /// Throws an exception for error responses.
  ///
  @override
  Future<http.BaseResponse> interceptResponse({
    required http.BaseResponse response,
  }) async {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    if (!isSuccess) {
      final apiError = await _extractApiError(response);
      _logger.e(
        'HTTP ${response.statusCode} ${response.request?.url}',
        error: apiError.displayMessage,
      );
      throw apiError;
    }

    _logger.i(
      'HTTP ${response.statusCode} ${response.request?.method} ${response.request?.url}',
    );

    return response;
  }

  ///
  /// Extracts a readable error message from the HTTP response body
  ///
  /// Supported response formats:
  /// - { "error": "message" }
  /// - { "message": "message" }
  /// - { "code": "user_not_found", "message": "User not found" }
  /// - { "code": "user_not_found", "context": { "details": "User not found" } }
  /// - plain text body
  ///
  Future<ApiError> _extractApiError(http.BaseResponse response) async {
    if (response is http.Response) {
      return _parseApiError(
        statusCode: response.statusCode,
        reasonPhrase: response.reasonPhrase,
        body: response.body,
      );
    }

    if (response is http.StreamedResponse) {
      final materializedResponse = await http.Response.fromStream(response);

      return _parseApiError(
        statusCode: materializedResponse.statusCode,
        reasonPhrase: materializedResponse.reasonPhrase,
        body: materializedResponse.body,
      );
    }

    final normalizedReasonPhrase = response.reasonPhrase?.trim();
    return ApiError(
      statusCode: response.statusCode,
      message: isSet(normalizedReasonPhrase)
          ? normalizedReasonPhrase!
          : 'Unexpected HTTP error',
    );
  }

  ///
  /// Converts a backend response body into a normalized API error.
  ///
  ApiError _parseApiError({
    required int statusCode,
    required String? reasonPhrase,
    required String body,
  }) {
    try {
      final decodedBody = jsonDecode(body);

      if (decodedBody is Map<String, dynamic>) {
        final code = decodedBody['code']?.toString();
        final message = _resolveErrorMessage(decodedBody);

        if (isSet(message)) {
          return ApiError(
            statusCode: statusCode,
            code: code,
            message: message!,
            raw: decodedBody,
          );
        }
      }

      return ApiError(statusCode: statusCode, message: decodedBody.toString());
    } catch (_) {
      final normalizedBody = body.trim();
      if (isSet(normalizedBody)) {
        return ApiError(statusCode: statusCode, message: normalizedBody);
      }

      final normalizedReasonPhrase = reasonPhrase?.trim();
      return ApiError(
        statusCode: statusCode,
        message: isSet(normalizedReasonPhrase)
            ? normalizedReasonPhrase!
            : 'Unexpected HTTP error',
      );
    }
  }

  ///
  /// Resolves the most helpful message from supported backend error shapes.
  ///
  String? _resolveErrorMessage(Map<String, dynamic> decodedBody) {
    final directMessage =
        decodedBody['message']?.toString() ?? decodedBody['error']?.toString();
    final normalizedDirectMessage = directMessage?.trim();

    if (isSet(normalizedDirectMessage)) {
      return normalizedDirectMessage!;
    }

    final context = decodedBody['context'];
    if (context is! Map<String, dynamic>) {
      return null;
    }

    final details = context['details']?.toString();
    final normalizedDetails = details?.trim();
    if (isSet(normalizedDetails)) {
      return normalizedDetails!;
    }

    final errors = context['errors'];
    if (errors is! List || errors.isEmpty) {
      return null;
    }

    final firstError = errors.first;
    if (firstError is! Map<String, dynamic>) {
      return null;
    }

    final nestedCode = firstError['code']?.toString();
    final nestedMessage = firstError['message']?.toString();
    final normalizedNestedCode = nestedCode?.trim();
    final normalizedNestedMessage = nestedMessage?.trim();

    if (isSet(normalizedNestedCode) && isSet(normalizedNestedMessage)) {
      return '[$normalizedNestedCode] $normalizedNestedMessage';
    }

    if (isSet(normalizedNestedMessage)) {
      return normalizedNestedMessage!;
    }

    return null;
  }
}
