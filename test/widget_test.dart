import 'package:flutter_base_app/app/app.dart';
import 'package:flutter_base_app/app/config/app_config.dart';
import 'package:flutter_base_app/core/di/injectable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads auth view first', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    configureDependencies();
    await AppConfig.load();

    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
