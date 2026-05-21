import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/intercepted_client.dart';
import 'package:flutter_base_app/core/network/tracking_http_client.dart';
import 'package:flutter_base_app/core/di/injectable.dart';

import 'http_interceptor.dart';

///
/// HTTP client factory
///
/// Responsible for creating the HTTP client used by the application.
///
/// The returned client automatically applies:
/// - Request headers
/// - Authentication token
/// - Global response error handling
/// - Global request tracking for loader and aggregated error dialogs
///
class HttpClientFactory {
  ///
  /// Private constructor
  ///
  /// Prevents creating instances of this utility class.
  ///
  HttpClientFactory._();

  ///
  /// Creates an intercepted HTTP client
  ///
  static http.Client create() {
    // First build the HTTP client with request/response interception.
    final interceptedClient = InterceptedClient.build(
      interceptors: [locator<HttpInterceptor>()],
    );

    // Then wrap it with a tracker-aware client so app-level loading and
    // aggregated request errors are handled in one place.
    return TrackingHttpClient(
      inner: interceptedClient,
      requestTracker: locator<RequestTracker>(),
    );
  }
}
