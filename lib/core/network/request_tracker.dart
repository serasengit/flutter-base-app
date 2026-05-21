import 'dart:async';

import 'package:flutter_base_app/core/utils/functions.dart';

/// Base class for all request tracker events.
abstract class RequestTrackerEvent {
  const RequestTrackerEvent();
}

/// Event emitted when a loading process should be displayed.
class ShowLoaderEvent extends RequestTrackerEvent {
  const ShowLoaderEvent();
}

/// Event emitted when the loading process should be hidden.
class HideLoaderEvent extends RequestTrackerEvent {
  const HideLoaderEvent();
}

/// Event emitted when request errors need to be displayed.
class ShowRequestErrorsEvent extends RequestTrackerEvent {
  const ShowRequestErrorsEvent({required this.messages});

  /// List of error messages collected during requests.
  final List<String> messages;
}

/// Event emitted when a successful request notification should be shown.
class ShowRequestSuccessEvent extends RequestTrackerEvent {
  const ShowRequestSuccessEvent();
}

/// Tracks the lifecycle of application requests and coordinates UI feedback.
///
/// This class manages:
/// - Loading indicators
/// - Request error aggregation
/// - Success notifications
class RequestTracker {
  /// Broadcast stream controller used to notify request events.
  final StreamController<RequestTrackerEvent> _controller =
      StreamController<RequestTrackerEvent>.broadcast();

  /// Stores pending error messages from requests.
  final List<String> _pendingErrors = <String>[];

  /// Indicates whether a success notification should be displayed.
  bool _hasPendingSuccess = false;

  /// Number of active ongoing requests.
  int _activeRequestCount = 0;

  /// Public stream used to listen to request events.
  Stream<RequestTrackerEvent> get events => _controller.stream;

  /// Marks the beginning of a request.
  ///
  /// Displays the loader when the first request starts.
  void beginRequest() {
    _activeRequestCount += 1;

    if (_activeRequestCount == 1) {
      _controller.add(const ShowLoaderEvent());
    }
  }

  /// Marks the completion of a request.
  ///
  /// Optionally handles:
  /// - Error messages
  /// - Success notifications
  void completeRequest({String? errorMessage, bool showSuccess = false}) {
    // Normalize and store error messages if present.
    final normalizedErrorMessage = errorMessage?.trim();

    if (isSet(normalizedErrorMessage)) {
      _pendingErrors.add(normalizedErrorMessage!);
    }

    // Mark success notification if required.
    if (showSuccess) {
      _hasPendingSuccess = true;
    }

    // Decrease active request count safely.
    if (_activeRequestCount > 0) {
      _activeRequestCount -= 1;
    }

    // Wait until all active requests are completed.
    if (_activeRequestCount != 0) {
      return;
    }

    // Hide the loader once all requests finish.
    _controller.add(const HideLoaderEvent());

    // Emit collected request errors if any exist.
    if (_pendingErrors.isNotEmpty) {
      final messages = List<String>.from(_pendingErrors);

      _pendingErrors.clear();
      _hasPendingSuccess = false;

      _controller.add(ShowRequestErrorsEvent(messages: messages));
      return;
    }

    // Emit success event if there are no errors.
    if (_hasPendingSuccess) {
      _hasPendingSuccess = false;
      _controller.add(const ShowRequestSuccessEvent());
    }
  }

  /// Releases stream controller resources.
  void dispose() {
    _controller.close();
  }
}
