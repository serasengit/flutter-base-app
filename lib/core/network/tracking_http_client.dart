import 'package:flutter_base_app/app/routes/app_routes.dart';
import 'package:flutter_base_app/core/network/api_error.dart';
import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:http/http.dart' as http;

///
/// HTTP client wrapper that reports request lifecycle to the RequestTracker.
///
/// The wrapped client keeps all HTTP behavior unchanged while this class adds
/// app-level tracking for global loading and aggregated error feedback.
///
class TrackingHttpClient extends http.BaseClient {
  TrackingHttpClient({
    required http.Client inner,
    required RequestTracker requestTracker,
  }) : _inner = inner,
       _requestTracker = requestTracker;

  final http.Client _inner;
  final RequestTracker _requestTracker;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Track every request start so the app can display a global loader while
    // there are still pending network operations.
    _requestTracker.beginRequest();

    try {
      final response = await _inner.send(request);

      // Successful non-login requests trigger a shared success confirmation.
      _requestTracker.completeRequest(
        showSuccess: _shouldShowSuccessMessage(request, response),
      );
      return response;
    } catch (error) {
      // Failed requests contribute their message to the current error batch.
      _requestTracker.completeRequest(
        errorMessage: _extractErrorMessage(error),
      );
      rethrow;
    }
  }

  @override
  void close() {
    _inner.close();
  }

  ///
  /// Normalizes thrown HTTP errors into user-displayable text.
  ///
  String _extractErrorMessage(Object error) {
    if (error is ApiError) {
      return error.displayMessage;
    }

    const exceptionPrefix = 'Exception: ';
    final message = error.toString().trim();

    if (message.startsWith(exceptionPrefix)) {
      return message.substring(exceptionPrefix.length).trim();
    }

    return message;
  }

  ///
  /// Decides whether a successful response should show the generic success
  /// confirmation to the user.
  ///
  bool _shouldShowSuccessMessage(
    http.BaseRequest request,
    http.StreamedResponse response,
  ) {
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final isAuthRequest = request.url.path.contains(AppRoutes.auth);
    final isGetRequest = request.method.toUpperCase() == 'GET';

    return isSuccess && !isAuthRequest && !isGetRequest;
  }
}
