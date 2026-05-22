import 'package:flutter_base_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthEvent', () {
    test('base AuthEvent props are empty', () {
      const event = RestoreSession();

      expect(event.props, isEmpty);
    });

    test('RestoreSession supports equality through props', () {
      const event = RestoreSession();

      expect(event, const RestoreSession());
      expect(event.props, isEmpty);
    });

    test('LogIn supports equality through props', () {
      const event = LogIn(username: 'demo', password: 'secret');

      expect(event, const LogIn(username: 'demo', password: 'secret'));

      expect(event.props, <Object?>['demo', 'secret']);
    });

    test('LogOut supports equality through props', () {
      const event = LogOut();

      expect(event, const LogOut());
      expect(event.props, isEmpty);
    });
  });
}
