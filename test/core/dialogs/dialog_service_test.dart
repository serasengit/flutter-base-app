import 'package:flutter/material.dart';
import 'package:flutter_base_app/core/dialogs/dialog_service.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp({
  required GlobalKey<NavigatorState> navigatorKey,
  Widget? child,
}) {
  return MaterialApp(
    navigatorKey: navigatorKey,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child ?? const SizedBox.shrink()),
  );
}

void main() {
  testWidgets('openDialog shows title, description and close action', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final dialogService = DialogService(navigatorKey: navigatorKey);

    await tester.pumpWidget(_buildApp(navigatorKey: navigatorKey));

    final dialogFuture = dialogService.openDialog(
      navigatorKey.currentContext!,
      key: 'closeDialog',
      title: 'Success title',
      description: 'Success description',
      type: DialogType.success,
    );
    await tester.pumpAndSettle();

    expect(find.text('Success title'), findsOneWidget);
    expect(find.text('Success description'), findsOneWidget);
    expect(find.byKey(const Key('closeDialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('closeDialog')));
    await tester.pumpAndSettle();
    await dialogFuture;

    expect(find.text('Success title'), findsNothing);
  });

  testWidgets('showMessagesDialog renders unique aggregated messages', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final dialogService = DialogService(navigatorKey: navigatorKey);

    await tester.pumpWidget(_buildApp(navigatorKey: navigatorKey));

    final dialogFuture = dialogService.showMessagesDialog(
      type: DialogType.error,
      title: 'Request failed',
      messages: <String>['One issue', 'One issue', 'Second issue'],
    );
    await tester.pumpAndSettle();

    expect(find.text('Request failed'), findsOneWidget);
    expect(find.text('- One issue'), findsOneWidget);
    expect(find.text('- Second issue'), findsOneWidget);
    expect(find.byKey(const Key('requestErrorsDialog')), findsOneWidget);

    await tester.tap(find.byKey(const Key('requestErrorsDialog')));
    await tester.pumpAndSettle();
    await dialogFuture;
  });
}
