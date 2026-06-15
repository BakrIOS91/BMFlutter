import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bm_flutter/src/helpers/preferences/base_preferences.dart';

class _ConcretePrefs extends BasePreferences {}

// Exposes the @protected secure methods for testing
class _TestablePrefs extends BasePreferences {
  Future<String?> readSecure(String key) => getSecureInternal(key);
  Future<void> writeSecure(String key, String? value) => setSecureInternal(key, value);
}

void main() {
  late _ConcretePrefs prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'key_bool': true,
      'key_int': 42,
      'key_double': 3.14,
      'key_string': 'hello',
      'key_list': ['a', 'b', 'c'],
    });
    prefs = _ConcretePrefs();
    await prefs.init();
  });

  group('BasePreferences — getBool', () {
    test('returns stored value', () {
      expect(prefs.getBool('key_bool', false), true);
    });

    test('returns defaultValue when key is missing', () {
      expect(prefs.getBool('missing', false), false);
      expect(prefs.getBool('missing', true), true);
    });
  });

  group('BasePreferences — getInt', () {
    test('returns stored value', () {
      expect(prefs.getInt('key_int', 0), 42);
    });

    test('returns defaultValue when key is missing', () {
      expect(prefs.getInt('missing', 99), 99);
    });
  });

  group('BasePreferences — getDouble', () {
    test('returns stored value', () {
      expect(prefs.getDouble('key_double', 0.0), closeTo(3.14, 0.001));
    });

    test('returns defaultValue when key is missing', () {
      expect(prefs.getDouble('missing', 2.0), 2.0);
    });
  });

  group('BasePreferences — getString', () {
    test('returns stored value', () {
      expect(prefs.getString('key_string', ''), 'hello');
    });

    test('returns defaultValue when key is missing', () {
      expect(prefs.getString('missing', 'default'), 'default');
    });
  });

  group('BasePreferences — getStringList', () {
    test('returns stored value', () {
      expect(prefs.getStringList('key_list', []), ['a', 'b', 'c']);
    });

    test('returns defaultValue when key is missing', () {
      expect(prefs.getStringList('missing', ['x', 'y']), ['x', 'y']);
    });
  });

  group('BasePreferences — setBool', () {
    test('persists and reads back', () async {
      await prefs.setBool('new_bool', false);
      expect(prefs.getBool('new_bool', true), false);
    });
  });

  group('BasePreferences — setInt', () {
    test('persists and reads back', () async {
      await prefs.setInt('new_int', 123);
      expect(prefs.getInt('new_int', 0), 123);
    });
  });

  group('BasePreferences — setDouble', () {
    test('persists and reads back', () async {
      await prefs.setDouble('new_double', 2.71);
      expect(prefs.getDouble('new_double', 0.0), closeTo(2.71, 0.001));
    });
  });

  group('BasePreferences — setString', () {
    test('persists and reads back', () async {
      await prefs.setString('new_string', 'world');
      expect(prefs.getString('new_string', ''), 'world');
    });
  });

  group('BasePreferences — setStringList', () {
    test('persists and reads back', () async {
      await prefs.setStringList('new_list', ['x', 'y', 'z']);
      expect(prefs.getStringList('new_list', []), ['x', 'y', 'z']);
    });
  });

  group('BasePreferences — lifecycle hooks', () {
    test('initGenerated does not throw', () {
      expect(() => prefs.initGenerated(), returnsNormally);
    });

    test('disposeGenerated does not throw', () {
      expect(() => prefs.disposeGenerated(), returnsNormally);
    });
  });

  group('BasePreferences — secure storage', () {
    late _TestablePrefs securePrefs;

    setUp(() async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({});
      securePrefs = _TestablePrefs();
      await securePrefs.init();
    });

    test('writeSecure stores a value and readSecure retrieves it', () async {
      await securePrefs.writeSecure('token', 'abc123');
      final value = await securePrefs.readSecure('token');
      expect(value, 'abc123');
    });

    test('readSecure returns null for missing key', () async {
      final value = await securePrefs.readSecure('no_such_key');
      expect(value, isNull);
    });

    test('writeSecure with null value deletes the key', () async {
      await securePrefs.writeSecure('token', 'abc123');
      await securePrefs.writeSecure('token', null);
      final value = await securePrefs.readSecure('token');
      expect(value, isNull);
    });
  });
}
