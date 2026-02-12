import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// --- PREFERENCE SYSTEM ARCHITECTURE ---
///
/// `BasePreferences` is the orchestrator for all persistent state in the app.
/// It provides a unified interface for two distinct storage backends:
///
/// 1. **SharedPreferences**: Fast, synchronous-style local disk I/O. Best for
///    settings that need to be available instantly on UI startup.
/// 2. **FlutterSecureStorage**: Encrypted storage (Keychain/KeyStore). Best for
///    tokens and sensitive user data.
///
/// ### Reactivity Model
/// This class doesn't just store data; it makes it reactive. The generated mixins
/// use `ValueNotifier`s that are initialized here. When you update a property:
/// - The `SharedPreferences`/`SecureStorage` is updated (Disk).
/// - The `ValueNotifier` is triggered (In-Memory).
/// - Any listening `ValueListenableBuilder` or `addListener` is notified (UI).
///
/// ---

abstract class BasePreferences {
  /// The underlying instance of `SharedPreferences`.
  /// Loaded asynchronously during `init()`.
  late final SharedPreferences _prefs;

  /// The secure storage engine.
  /// Operations on this instance are always `Future`-based and encrypted.
  final _secureStorage = const FlutterSecureStorage();

  /// --- LIFECYCLE MANAGEMENT ---

  /// Initializes the storage engines and triggers code-generated setup.
  ///
  /// **Timing:** This must be called at app startup (e.g., in `main` or via a
  /// DI container like `GetIt` or `Provider`).
  ///
  /// **Flow:**
  /// 1. Opens `SharedPreferences` disk handle.
  /// 2. Calls `initGenerated()` to load all stored values into memory.
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    initGenerated();
  }

  /// Hook for code-generated initialization logic.
  ///
  /// The generator overrides this to:
  /// - Read every `@UserDefault` from disk and populate `ValueNotifier`s.
  /// - Trigger `Future` reads for every `@Secure` field.
  @mustCallSuper
  void initGenerated() {}

  /// Hook for code-generated disposal logic.
  ///
  /// The generator overrides this to:
  /// - Dispose all `ValueNotifier` instances to prevent memory leaks.
  @mustCallSuper
  void disposeGenerated() {}

  /// --- STORAGE HELPERS (GETTERS) ---

  /// Reads a boolean from `SharedPreferences`.
  /// Returns [defaultValue] if the key is missing.
  bool getBool(String key, bool defaultValue) =>
      _prefs.getBool(key) ?? defaultValue;

  /// Reads an integer from `SharedPreferences`.
  int getInt(String key, int defaultValue) =>
      _prefs.getInt(key) ?? defaultValue;

  /// Reads a double from `SharedPreferences`.
  double getDouble(String key, double defaultValue) =>
      _prefs.getDouble(key) ?? defaultValue;

  /// Reads a string from `SharedPreferences`.
  String getString(String key, String defaultValue) =>
      _prefs.getString(key) ?? defaultValue;

  /// Reads a list of strings from `SharedPreferences`. No nested types allowed.
  List<String> getStringList(String key, List<String> defaultValue) =>
      _prefs.getStringList(key) ?? defaultValue;

  /// --- STORAGE HELPERS (SETTERS) ---

  /// Persists a boolean to disk. Returns success/failure status.
  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  /// Persists an integer to disk.
  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  /// Persists a double to disk.
  Future<bool> setDouble(String key, double value) =>
      _prefs.setDouble(key, value);

  /// Persists a string to disk.
  Future<bool> setString(String key, String value) =>
      _prefs.setString(key, value);

  /// Persists a string list to disk.
  Future<bool> setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  /// --- SECURE STORAGE INTERNALS ---

  /// Reads a value from the encrypted store (Keychain/KeyStore).
  ///
  /// **Why @protected?** This should only be called by the generated mixin.
  /// The public API for tokens should be the type-safe generated property.
  @protected
  Future<String?> getSecureInternal(String key) =>
      _secureStorage.read(key: key);

  /// Writes (or deletes if null) a value in the encrypted store.
  ///
  /// **Security Note:** This is an asynchronous operation. While it returns
  /// immediately, the generated property ensures the UI is reactive even before
  /// the disk write completes.
  @protected
  Future<void> setSecureInternal(String key, String? value) {
    if (value == null) {
      return _secureStorage.delete(key: key);
    } else {
      return _secureStorage.write(key: key, value: value);
    }
  }
}
