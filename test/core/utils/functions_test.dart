import 'package:flutter_base_app/core/utils/functions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isSet handles null-like and empty values', () {
    expect(isSet(null), isFalse);
    expect(isSet(''), isFalse);
    expect(isSet('   '), isFalse);
    expect(isSet(<Object>[]), isFalse);
    expect(isSet(<String, Object>{}), isFalse);
    expect(isSet('value'), isTrue);
    expect(isSet(0), isTrue);
  });
}
