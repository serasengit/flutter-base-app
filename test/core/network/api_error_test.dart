import 'package:flutter_base_app/core/network/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiError exposes a normalized display message', () {
    const error = ApiError(statusCode: 404, message: 'Not found');

    expect(error.displayMessage, 'HTTP 404: Not found');
    expect(error.toString(), 'HTTP 404: Not found');
  });
}
