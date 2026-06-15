import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/preferences/annotations.dart';

void main() {
  group('GeneratePreferences', () {
    test('can be instantiated (runtime)', () {
      // ignore: prefer_const_constructors
      final annotation = GeneratePreferences();
      expect(annotation, isA<GeneratePreferences>());
    });
  });

  group('UserDefault', () {
    test('stores provided key (runtime)', () {
      // ignore: prefer_const_constructors
      final annotation = UserDefault('myKey');
      expect(annotation.key, 'myKey');
    });

    test('stores empty key', () {
      // ignore: prefer_const_constructors
      final annotation = UserDefault('');
      expect(annotation.key, '');
    });

    test('two instances with same key have equal keys', () {
      // ignore: prefer_const_constructors
      final a = UserDefault('k');
      // ignore: prefer_const_constructors
      final b = UserDefault('k');
      expect(a.key, b.key);
    });
  });

  group('Secure', () {
    test('stores provided key (runtime)', () {
      // ignore: prefer_const_constructors
      final annotation = Secure('secretKey');
      expect(annotation.key, 'secretKey');
    });

    test('stores token key', () {
      // ignore: prefer_const_constructors
      final annotation = Secure('auth_token');
      expect(annotation.key, 'auth_token');
    });
  });

  group('InApp', () {
    test('can be instantiated (runtime)', () {
      // ignore: prefer_const_constructors
      final annotation = InApp();
      expect(annotation, isA<InApp>());
    });
  });
}
