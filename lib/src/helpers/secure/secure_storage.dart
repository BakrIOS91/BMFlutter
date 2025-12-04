import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._internal();
  static final SecureStorageService instance = SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Reactive map of key -> dynamic (String, Map, List, etc.)
  final ValueNotifier<Map<String, dynamic>> _values =
      ValueNotifier<Map<String, dynamic>>({});

  ValueNotifier<Map<String, dynamic>> get values => _values;

  /// Initialize with optional keys
  Future<void> init([List<String>? keys]) async {
    if (keys != null) {
      for (final key in keys) {
        final raw = await _storage.read(key: key);
        if (raw != null) {
          _values.value = {..._values.value, key: _decode(raw)};
        }
      }
    }
  }

  /// Save any JSON-serializable object (String, Map, List, Model)
  Future<void> write<T>(String key, T value) async {
    final encoded = _encode(value);
    await _storage.write(key: key, value: encoded);
    _values.value = {..._values.value, key: value};
  }

  /// Read and decode
  Future<T?> read<T>(String key) async {
    final raw = await _storage.read(key: key);
    if (raw == null) return null;
    final decoded = _decode(raw);
    _values.value = {..._values.value, key: decoded};
    return decoded as T;
  }

  /// Delete key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
    final newMap = Map<String, dynamic>.from(_values.value);
    newMap.remove(key);
    _values.value = newMap;
  }

  /// Clear all
  Future<void> clear() async {
    await _storage.deleteAll();
    _values.value = {};
  }

  /// Encode object to string
  String _encode(dynamic value) {
    if (value is String) return value;
    return json.encode(value);
  }

  /// Decode string to object
  dynamic _decode(String raw) {
    try {
      return json.decode(raw);
    } catch (_) {
      return raw;
    }
  }
}
