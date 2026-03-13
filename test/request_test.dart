import 'package:flutter_test/flutter_test.dart';
import 'package:bmflutter/core.dart';

class TestRequest extends SuccessTargetType {
  final String _base;
  final String _path;

  TestRequest(this._base, this._path);

  @override
  String get baseURL => _base;

  @override
  String get requestPath => _path;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
}

void main() {
  group('Request URL Construction Tests', () {
    test('Standard URL resolution', () async {
      final target = TestRequest('https://api.example.com/', 'users');
      final request = await target.createRequest();
      expect(request.url.toString(), 'https://api.example.com/users');
    });

    test('URL resolution without trailing slash in base', () async {
      // Uri.resolve behavior: if base doesn't end with slash, it replaces the last segment
      // So 'https://api.example.com/v1'.resolve('users') -> 'https://api.example.com/users'
      // BUT 'https://api.example.com/v1/'.resolve('users') -> 'https://api.example.com/v1/users'
      final target = TestRequest('https://api.example.com/v1', 'users');
      final request = await target.createRequest();
      expect(request.url.toString(), 'https://api.example.com/users');
    });

    test('URL resolution with leading slash in path', () async {
      final target = TestRequest('https://api.example.com/v1/', '/users');
      final request = await target.createRequest();
      // Leading slash in resolve() makes it relative to host root
      expect(request.url.toString(), 'https://api.example.com/users');
    });
  });
}
