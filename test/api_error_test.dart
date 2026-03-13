import 'package:bmflutter/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('APIError Tests', () {
    test('toString returns correct message for invalidURL', () {
      const error = APIError(APIErrorType.invalidURL);
      expect(error.toString(), contains('Invalid URL formation.'));
    });

    test('toString returns correct message for noNetwork', () {
      const error = APIError(APIErrorType.noNetwork);
      expect(error.toString(), contains('No internet connection.'));
    });

    test('toString includes status code for httpError', () {
      const error = APIError(APIErrorType.httpError,
          statusCode: HTTPStatusCode.notAuthorize);
      expect(error.toString(),
          contains('HTTP Error with status code: HTTPStatusCode.notAuthorize'));
    });
  });
}
