import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_base_app/core/dialogs/dialog_service.dart';
import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:flutter_base_app/core/utils/functions.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:loader_overlay/loader_overlay.dart';

///
/// Coordinates global UI feedback produced by tracked API requests.
///
/// This controller keeps loader and dialog orchestration out of `app.dart`
/// while still using the tracker as the source of truth for concurrent
/// request activity.
///
class RequestFeedbackCoordinator {
  RequestFeedbackCoordinator({
    required RequestTracker requestTracker,
    required DialogService dialogService,
  }) : _requestTracker = requestTracker,
       _dialogService = dialogService;

  final RequestTracker _requestTracker;
  final DialogService _dialogService;
  StreamSubscription<RequestTrackerEvent>? _subscription;

  void bind(GlobalKey<NavigatorState> navigatorKey) {
    _dialogService.attachNavigatorKey(navigatorKey);
    _subscription ??= _requestTracker.events.listen(_handleTrackerEvent);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  void _handleTrackerEvent(RequestTrackerEvent event) {
    final context = _dialogService.navigatorKey.currentContext;
    if (!isSet(context)) {
      return;
    }

    switch (event) {
      case ShowLoaderEvent():
        context!.loaderOverlay.show();
      case HideLoaderEvent():
        context!.loaderOverlay.hide();
      case ShowRequestErrorsEvent(messages: final messages):
        _dialogService.showMessagesDialog(
          type: DialogType.error,
          title: AppLocalizations.of(context!)!.request_failed,
          messages: messages,
        );
      case ShowRequestSuccessEvent():
        _dialogService.openDialog(
          context!,
          key: 'requestSuccessDialog',
          title: AppLocalizations.of(context)!.operation_completed_successfully,
          type: DialogType.success,
        );
    }
  }
}
