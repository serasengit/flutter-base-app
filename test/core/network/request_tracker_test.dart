import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emits loader and success events for a successful request', () async {
    final tracker = RequestTracker();

    final expectation = expectLater(
      tracker.events,
      emitsInOrder(<Matcher>[
        isA<ShowLoaderEvent>(),
        isA<HideLoaderEvent>(),
        isA<ShowRequestSuccessEvent>(),
      ]),
    );

    tracker.beginRequest();
    tracker.completeRequest(showSuccess: true);

    await expectation;
    tracker.dispose();
  });

  test('aggregates errors from concurrent requests into one event', () async {
    final tracker = RequestTracker();

    final expectation = expectLater(
      tracker.events,
      emitsInOrder(<Matcher>[
        isA<ShowLoaderEvent>(),
        isA<HideLoaderEvent>(),
        predicate<ShowRequestErrorsEvent>(
          (event) => event.messages.length == 2,
        ),
      ]),
    );

    tracker.beginRequest();
    tracker.beginRequest();
    tracker.completeRequest(errorMessage: 'First error');
    tracker.completeRequest(errorMessage: 'Second error');

    await expectation;
    tracker.dispose();
  });
}
