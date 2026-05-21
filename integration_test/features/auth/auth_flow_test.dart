import 'package:flutter/material.dart';
import 'package:flutter_base_app/features/auth/models/auth.dart';
import 'package:flutter_base_app/features/auth/models/user.dart';
import 'package:flutter_base_app/features/auth/presentation/views/auth_view.dart';
import 'package:flutter_base_app/features/home/presentation/home_page.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/test_bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Auth flow', () {
    testWidgets('shows auth screen on app startup', (tester) async {
      await bootstrapTestApp(tester);

      final context = tester.element(find.byType(AuthView));
      final l10n = AppLocalizations.of(context)!;

      expect(find.byType(AuthView), findsOneWidget);
      expect(find.text(l10n.sign_in), findsOneWidget);
      expect(find.text(l10n.username), findsOneWidget);
      expect(find.text(l10n.password), findsOneWidget);
    });

    testWidgets('validates required login fields', (tester) async {
      await bootstrapTestApp(tester);

      final context = tester.element(find.byType(AuthView));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.widgetWithText(ElevatedButton, l10n.login));
      await tester.pumpAndSettle();

      expect(find.text(l10n.required_field), findsNWidgets(2));
    });

    testWidgets('logs in and logs out with shell modules visible', (
      tester,
    ) async {
      await bootstrapTestApp(
        tester,
        authToReturn: const Auth(
          accessToken: 'token',
          isAuthenticated: true,
          user: User(id: '1', username: 'tester', name: 'Test User'),
          permissions: <String>[
            'users:read',
            'cities:read',
            'meteo_stations:read',
          ],
        ),
      );

      final authContext = tester.element(find.byType(AuthView));
      final authL10n = AppLocalizations.of(authContext)!;

      await tester.enterText(find.byType(TextFormField).at(0), 'tester');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret');
      await tester.tap(find.widgetWithText(ElevatedButton, authL10n.login));
      await tester.pumpAndSettle();

      final homeContext = tester.element(find.byType(HomePage));
      final homeL10n = AppLocalizations.of(homeContext)!;

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text(homeL10n.home), findsWidgets);

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(find.text(homeL10n.users), findsOneWidget);
      expect(find.text(homeL10n.cities), findsOneWidget);
      expect(find.text(homeL10n.meteo_stations), findsOneWidget);
      expect(find.text(homeL10n.logout), findsOneWidget);

      await tester.tap(find.text(homeL10n.logout));
      await tester.pumpAndSettle();

      expect(find.byType(AuthView), findsOneWidget);
      expect(find.text(authL10n.sign_in), findsOneWidget);
    });
  });
}
