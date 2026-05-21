import 'package:flutter/material.dart';
import 'package:flutter_base_app/core/validators/validators.dart';
import 'package:flutter_base_app/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _buildApp() {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(body: SizedBox.shrink()),
  );
}

void main() {
  testWidgets('Validators.combine returns first failing message', (tester) async {
    await tester.pumpWidget(_buildApp());
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SizedBox)),
    )!;

    final result = Validators.combine(<String? Function()>[
      () => Validators.isRequired('', l10n),
      () => Validators.maxLength('toolong', 3, l10n),
    ]);

    expect(result, l10n.required_field);
  });

  testWidgets('Validators.maxLength returns localized max length error', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    final l10n = AppLocalizations.of(
      tester.element(find.byType(SizedBox)),
    )!;

    expect(Validators.isRequired('value', l10n), isNull);
    expect(Validators.maxLength('abcd', 3, l10n), l10n.max_length(3));
    expect(Validators.maxLength('ab', 3, l10n), isNull);
  });
}
