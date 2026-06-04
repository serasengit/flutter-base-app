import 'package:flutter/material.dart';
import 'package:flutter_base_app/core/dialogs/dialog_service.dart';
import 'package:flutter_base_app/core/network/request_feedback_coordinator.dart';
import 'package:flutter_base_app/core/network/request_tracker.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loader_overlay/loader_overlay.dart';

class _RecordingDialogService extends DialogService {
  _RecordingDialogService() : super();

  DialogType? openedType;
  String? openedTitle;
  String? openedDescription;
  DialogType? messagesType;
  String? messagesTitle;
  List<String>? shownMessages;

  @override
  Future<void> openDialog(
    BuildContext context, {
    required String key,
    required String title,
    required DialogType type,
    String? description,
  }) async {
    openedType = type;
    openedTitle = title;
    openedDescription = description;
  }

  @override
  Future<void> showMessagesDialog({
    required DialogType type,
    required String title,
    String? message,
    List<String>? messages,
    bool barrierDismissible = true,
  }) async {
    messagesType = type;
    messagesTitle = title;
    shownMessages = <String>[
      ...?message == null ? null : <String>[message],
      ...?messages,
    ];
  }
}

void main() {
  group('RequestFeedbackCoordinator', () {
    testWidgets('shows success dialog for success events', (tester) async {
      final tracker = RequestTracker();
      final dialogService = _RecordingDialogService();
      final coordinator = RequestFeedbackCoordinator(
        requestTracker: tracker,
        dialogService: dialogService,
      );
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        GlobalLoaderOverlay(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      coordinator.bind(navigatorKey);
      tracker.beginRequest();
      tracker.completeRequest(showSuccess: true);
      await tester.pump();

      final context = navigatorKey.currentContext!;
      final l10n = AppLocalizations.of(context)!;

      expect(dialogService.openedType, DialogType.success);
      expect(dialogService.openedTitle, isNotEmpty);
      expect(<String?>[
        dialogService.openedTitle,
        dialogService.openedDescription,
      ], contains(l10n.operation_completed_successfully));

      coordinator.dispose();
    });

    testWidgets('shows aggregated error messages for failed requests', (
      tester,
    ) async {
      final tracker = RequestTracker();
      final dialogService = _RecordingDialogService();
      final coordinator = RequestFeedbackCoordinator(
        requestTracker: tracker,
        dialogService: dialogService,
      );
      final navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        GlobalLoaderOverlay(
          child: MaterialApp(
            navigatorKey: navigatorKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const Scaffold(body: SizedBox.shrink()),
          ),
        ),
      );

      coordinator.bind(navigatorKey);
      tracker.beginRequest();
      tracker.completeRequest(errorMessage: 'HTTP 404: Usuario no encontrado');
      await tester.pump();

      expect(dialogService.messagesType, DialogType.error);
      expect(dialogService.messagesTitle, isNotEmpty);
      expect(dialogService.shownMessages, <String>[
        'HTTP 404: Usuario no encontrado',
      ]);

      coordinator.dispose();
    });
  });
}
