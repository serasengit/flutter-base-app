import 'dart:async';

import 'package:flutter_base_app/core/network/api_error.dart';
import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:flutter_base_app/core/network/tracking_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class _FakeClient extends http.BaseClient {
  _FakeClient(this._handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request)
  _handler;

  bool wasClosed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _handler(request);
  }

  @override
  void close() {
    wasClosed = true;
    super.close();
  }
}

void main() {
  group('TrackingHttpClient', () {
    test(
      'emits loader and success events for successful non-auth POST requests',
      () async {
        final tracker = RequestTracker();

        final client = TrackingHttpClient(
          inner: _FakeClient((request) async {
            return http.StreamedResponse(
              Stream<List<int>>.value(<int>[111, 107]),
              201,
              request: request,
            );
          }),
          requestTracker: tracker,
        );

        final eventsExpectation = expectLater(
          tracker.events,
          emitsInOrder(<Matcher>[
            isA<ShowLoaderEvent>(),
            isA<HideLoaderEvent>(),
            isA<ShowRequestSuccessEvent>(),
          ]),
        );

        final response = await client.send(
          http.Request('POST', Uri.parse('https://example.com/users')),
        );

        expect(response.statusCode, 201);

        await eventsExpectation;

        client.close();
      },
    );

    test('does not emit success dialog event for GET requests', () async {
      final tracker = RequestTracker();
      final events = <RequestTrackerEvent>[];
      final subscription = tracker.events.listen(events.add);

      final client = TrackingHttpClient(
        inner: _FakeClient((request) async {
          return http.StreamedResponse(
            Stream<List<int>>.value(<int>[111, 107]),
            200,
            request: request,
          );
        }),
        requestTracker: tracker,
      );

      await client.send(
        http.Request('GET', Uri.parse('https://example.com/users')),
      );

      await Future<void>.delayed(Duration.zero);

      expect(events.whereType<ShowRequestSuccessEvent>(), isEmpty);
      expect(events.whereType<ShowLoaderEvent>().length, 1);
      expect(events.whereType<HideLoaderEvent>().length, 1);

      await subscription.cancel();
      client.close();
    });

    test('does not emit success dialog event for auth requests', () async {
      final tracker = RequestTracker();
      final events = <RequestTrackerEvent>[];
      final subscription = tracker.events.listen(events.add);

      final client = TrackingHttpClient(
        inner: _FakeClient((request) async {
          return http.StreamedResponse(
            Stream<List<int>>.value(<int>[111, 107]),
            200,
            request: request,
          );
        }),
        requestTracker: tracker,
      );

      await client.send(
        http.Request('POST', Uri.parse('https://example.com/auth/login')),
      );

      await Future<void>.delayed(Duration.zero);

      expect(events.whereType<ShowRequestSuccessEvent>(), isEmpty);
      expect(events.whereType<ShowLoaderEvent>().length, 1);
      expect(events.whereType<HideLoaderEvent>().length, 1);

      await subscription.cancel();
      client.close();
    });

    test('does not emit success dialog event for non-2xx responses', () async {
      final tracker = RequestTracker();
      final events = <RequestTrackerEvent>[];
      final subscription = tracker.events.listen(events.add);

      final client = TrackingHttpClient(
        inner: _FakeClient((request) async {
          return http.StreamedResponse(
            Stream<List<int>>.value(<int>[101, 114, 114, 111, 114]),
            400,
            request: request,
          );
        }),
        requestTracker: tracker,
      );

      final response = await client.send(
        http.Request('POST', Uri.parse('https://example.com/users')),
      );

      await Future<void>.delayed(Duration.zero);

      expect(response.statusCode, 400);
      expect(events.whereType<ShowRequestSuccessEvent>(), isEmpty);
      expect(events.whereType<ShowLoaderEvent>().length, 1);
      expect(events.whereType<HideLoaderEvent>().length, 1);

      await subscription.cancel();
      client.close();
    });

    test(
      'emits aggregated error event when request fails with ApiError',
      () async {
        final tracker = RequestTracker();

        final client = TrackingHttpClient(
          inner: _FakeClient((request) async {
            throw const ApiError(
              statusCode: 400,
              message: 'HTTP 400: Invalid request',
            );
          }),
          requestTracker: tracker,
        );

        final eventsExpectation = expectLater(
          tracker.events,
          emitsInOrder(<Matcher>[
            isA<ShowLoaderEvent>(),
            isA<HideLoaderEvent>(),
            isA<ShowRequestErrorsEvent>().having(
              (event) => event.messages,
              'messages',
              <String>['HTTP 400: HTTP 400: Invalid request'],
            ),
          ]),
        );

        expect(
          () => client.send(
            http.Request('POST', Uri.parse('https://example.com/users')),
          ),
          throwsA(isA<ApiError>()),
        );

        await eventsExpectation;

        client.close();
      },
    );

    test(
      'emits clean error message when request fails with Exception',
      () async {
        final tracker = RequestTracker();

        final client = TrackingHttpClient(
          inner: _FakeClient((request) async {
            throw Exception('Network unavailable');
          }),
          requestTracker: tracker,
        );

        final eventsExpectation = expectLater(
          tracker.events,
          emitsInOrder(<Matcher>[
            isA<ShowLoaderEvent>(),
            isA<HideLoaderEvent>(),
            isA<ShowRequestErrorsEvent>().having(
              (event) => event.messages,
              'messages',
              <String>['Network unavailable'],
            ),
          ]),
        );

        expect(
          () => client.send(
            http.Request('POST', Uri.parse('https://example.com/users')),
          ),
          throwsA(isA<Exception>()),
        );

        await eventsExpectation;

        client.close();
      },
    );

    test(
      'emits raw error message when request fails with non-Exception error',
      () async {
        final tracker = RequestTracker();

        final client = TrackingHttpClient(
          inner: _FakeClient((request) async {
            throw 'raw failure';
          }),
          requestTracker: tracker,
        );

        final eventsExpectation = expectLater(
          tracker.events,
          emitsInOrder(<Matcher>[
            isA<ShowLoaderEvent>(),
            isA<HideLoaderEvent>(),
            isA<ShowRequestErrorsEvent>().having(
              (event) => event.messages,
              'messages',
              <String>['raw failure'],
            ),
          ]),
        );

        expect(
          () => client.send(
            http.Request('POST', Uri.parse('https://example.com/users')),
          ),
          throwsA('raw failure'),
        );

        await eventsExpectation;

        client.close();
      },
    );

    test('closes inner client', () {
      final inner = _FakeClient((request) async {
        return http.StreamedResponse(
          const Stream<List<int>>.empty(),
          200,
          request: request,
        );
      });

      final client = TrackingHttpClient(
        inner: inner,
        requestTracker: RequestTracker(),
      );

      client.close();

      expect(inner.wasClosed, isTrue);
    });
  });
}
