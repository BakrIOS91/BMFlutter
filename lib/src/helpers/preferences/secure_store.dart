import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Where `@Secure` preference fields are persisted.
///
/// [BasePreferences] writes secure values through this interface. The default
/// is [FlutterSecureStore] (Keychain / Keystore). Register a different
/// implementation with [PreferencesStorage.registerSecureStore] before the
/// first `init()` call, for example on a platform where
/// `flutter_secure_storage` has no implementation, or in tests.
abstract interface class SecureStore {
  /// Returns the stored value for [key], or `null` when there is none.
  Future<String?> read(String key);

  /// Stores [value] under [key], replacing any previous value.
  Future<void> write(String key, String value);

  /// Removes [key].
  Future<void> delete(String key);
}

/// [SecureStore] backed by `flutter_secure_storage`. This is the default.
class FlutterSecureStore implements SecureStore {
  /// Creates a store, optionally with a customised [FlutterSecureStorage].
  const FlutterSecureStore([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory [SecureStore]. Values are lost when the app closes, so it is
/// meant for tests and for platforms without secure storage where losing the
/// value on restart is acceptable.
class MemorySecureStore implements SecureStore {
  final Map<String, String> _values = {};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// App-wide registry for the storage used by [BasePreferences].
class PreferencesStorage {
  PreferencesStorage._();

  static SecureStore _secureStore = const FlutterSecureStore();

  /// The store used for `@Secure` fields.
  static SecureStore get secureStore => _secureStore;

  /// Replaces the secure store. Call before preferences are initialised.
  static void registerSecureStore(SecureStore store) => _secureStore = store;

  /// Restores the default [FlutterSecureStore].
  static void resetSecureStore() => _secureStore = const FlutterSecureStore();
}
