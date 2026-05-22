import 'package:flutter/material.dart';
import 'package:flutter_base_app/features/cities/presentation/views/cities_view.dart';
import 'package:flutter_base_app/features/home/presentation/views/home_module_view.dart';
import 'package:flutter_base_app/features/meteo_stations/presentation/views/meteo_stations_view.dart';
import 'package:flutter_base_app/features/users/presentation/views/users_view.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('HomeModuleView renders localized content', (tester) async {
    await tester.pumpWidget(_buildApp(const HomeModuleView()));
    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(HomeModuleView)))!;

    expect(find.text(l10n.home), findsOneWidget);
    expect(find.text(l10n.home_module_description), findsOneWidget);
  });

  testWidgets('UsersView renders localized content', (tester) async {
    await tester.pumpWidget(_buildApp(const UsersView()));
    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(UsersView)))!;

    expect(find.text(l10n.users), findsOneWidget);
    expect(find.text(l10n.users_module_description), findsOneWidget);
  });

  testWidgets('CitiesView renders localized content', (tester) async {
    await tester.pumpWidget(_buildApp(const CitiesView()));
    await tester.pump();

    final l10n = AppLocalizations.of(tester.element(find.byType(CitiesView)))!;

    expect(find.text(l10n.cities), findsOneWidget);
    expect(find.text(l10n.cities_module_description), findsOneWidget);
  });

  testWidgets('MeteoStationsView renders localized content', (tester) async {
    await tester.pumpWidget(_buildApp(const MeteoStationsView()));
    await tester.pump();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(MeteoStationsView)),
    )!;

    expect(find.text(l10n.meteo_stations), findsOneWidget);
    expect(find.text(l10n.meteo_stations_module_description), findsOneWidget);
  });
}
