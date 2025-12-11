import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ---------------------------------------------------------------------------
/// BASE MODEL CONTRACT
/// ---------------------------------------------------------------------------
/// Any model you want to store securely should implement:
///  - toJson()
///  - a static fromJson(Map) constructor
///
/// Example:
/// class User implements SecureStorable {
///   final String name;
///   User({required this.name});
///
///   @override
///   Map<String, dynamic> toJson() => {'name': name};
///
///   static User fromJson(Map<String, dynamic> json) =>
///       User(name: json['name']);
/// }
///
/// ---------------------------------------------------------------------------
abstract class SecureStorable {
  Map<String, dynamic> toJson();

  static T fromJson<T extends SecureStorable>(Map<String, dynamic> json) {
    throw UnimplementedError('fromJson must be implemented in subclass.');
  }
}

/// ---------------------------------------------------------------------------
/// SECURE STORAGE SERVICE
/// A robust wrapper around FlutterSecureStorage:
///  - Supports primitive values
///  - Supports Maps, Lists, Model objects
///  - Reactive values via ValueNotifier
/// ---------------------------------------------------------------------------
class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Reactive in-memory cache of all stored values
  final ValueNotifier<Map<String, dynamic>> _values =
      ValueNotifier<Map<String, dynamic>>({});

  ValueNotifier<Map<String, dynamic>> get values => _values;

  /// -------------------------------------------------------------------------
  /// Initialize storage by reading specific keys (optional)
  ///
  /// Example:
  /// await SecureStorageService.instance.init(['token', 'user']);
  /// -------------------------------------------------------------------------
  Future<void> init([List<String>? keys]) async {
    if (keys == null) return;

    for (final key in keys) {
      final raw = await _storage.read(key: key);
      if (raw != null) {
        _values.value = {..._values.value, key: _decode(raw)};
      }
    }
  }

  /// -------------------------------------------------------------------------
  /// WRITE ANY VALUE
  ///
  /// Accepts:
  ///  - int, double, bool, String
  ///  - Map, List
  ///  - Models that implement SecureStorable
  ///
  /// Example:
  /// await write("loggedIn", true);
  /// await write("counter", 5);
  /// await write("settings", {"theme": "dark"});
  /// await write("user", User(...));
  /// -------------------------------------------------------------------------
  Future<void> write(String key, dynamic value) async {
    final encoded = _encode(value);
    await _storage.write(key: key, value: encoded);

    // Update local cache
    _values.value = {..._values.value, key: value};
  }

  /// -------------------------------------------------------------------------
  /// WRITE MODEL
  ///
  /// Convenience wrapper specifically for models
  ///
  /// Example:
  /// await writeModel("user", userModel);
  /// -------------------------------------------------------------------------
  Future<void> writeModel<T extends SecureStorable>(String key, T model) async {
    await write(key, model);
  }

  /// -------------------------------------------------------------------------
  /// READ ANY VALUE
  ///
  /// Automatically returns:
  ///  - primitives
  ///  - Map
  ///  - List
  ///  - Or raw String
  ///
  /// Example:
  /// bool? loggedIn = await read<bool>("loggedIn");
  /// int? count = await read<int>("counter");
  /// Map? settings = await read<Map>("settings");
  /// -------------------------------------------------------------------------
  Future<T?> read<T>(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;

    final decoded = _decode(raw);

    // Ensure type safety at runtime
    if (decoded is T) {
      _values.value = {..._values.value, key: decoded};
      return decoded;
    }

    // If mismatch, return null
    return null;
  }

  /// -------------------------------------------------------------------------
  /// READ MODEL
  ///
  /// Requires a "fromJson" callback.
  ///
  /// Example:
  /// final user = await readModel("user", User.fromJson);
  /// -------------------------------------------------------------------------
  Future<T?> readModel<T extends SecureStorable>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;

    final decoded = _decode(raw) as Map<String, dynamic>;
    final model = fromJson(decoded);

    _values.value = {..._values.value, key: model};
    return model;
  }

  /// -------------------------------------------------------------------------
  /// DELETE ONE KEY
  ///
  /// Example:
  /// await delete("token");
  /// -------------------------------------------------------------------------
  Future<void> delete(String key) async {
    await _storage.delete(key: key);

    final newMap = Map<String, dynamic>.from(_values.value);
    newMap.remove(key);
    _values.value = newMap;
  }

  /// -------------------------------------------------------------------------
  /// CLEAR ALL
  ///
  /// Example:
  /// await clear();
  /// -------------------------------------------------------------------------
  Future<void> clear() async {
    await _storage.deleteAll();
    _values.value = {};
  }

  /// -------------------------------------------------------------------------
  /// ENCODING HELPERS
  /// -------------------------------------------------------------------------
  String _encode(dynamic value) {
    if (value is String) return value;
    return json.encode(value);
  }

  dynamic _decode(String raw) {
    try {
      return json.decode(raw);
    } catch (_) {
      return raw; // return string if not json
    }
  }
}
