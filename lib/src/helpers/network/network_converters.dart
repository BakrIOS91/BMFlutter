class NetworkConverters {
  static final Map<String, dynamic Function(dynamic)> _converters = {};

  static void register<T>(T Function(Map<String, dynamic>) converter) {
    final typeString = T.toString();

    // Register for single object
    _converters[typeString] = _createSingleConverter(converter, typeString);

    // Register for List<T> with explicit type handling
    _converters['List<$typeString>'] = _createListConverter(
      converter,
      typeString,
    );
  }

  static dynamic Function(dynamic) _createSingleConverter<T>(
    T Function(Map<String, dynamic>) converter,
    String typeString,
  ) {
    return (dynamic data) {
      if (data is Map<String, dynamic>) {
        return converter(data);
      }
      throw ArgumentError('Expected Map for $typeString');
    };
  }

  static dynamic Function(dynamic) _createListConverter<T>(
    T Function(Map<String, dynamic>) converter,
    String typeString,
  ) {
    return (dynamic data) {
      if (data is List<dynamic>) {
        final List<T> result = [];
        for (var i = 0; i < data.length; i++) {
          final item = data[i];
          if (item is Map<String, dynamic>) {
            result.add(converter(item));
          } else {
            throw ArgumentError(
              'Item $i in list is not a Map for List<$typeString>',
            );
          }
        }
        return result;
      }
      throw ArgumentError('Expected List for List<$typeString>');
    };
  }

  static dynamic convert<T>(dynamic data) {
    final typeString = T.toString();

    final converter = _converters[typeString];
    if (converter != null) {
      return converter(data);
    }

    // Special handling for List types that weren't explicitly registered
    if (typeString.startsWith('List<') && data is List<dynamic>) {
      final innerType = typeString.substring(5, typeString.length - 1);
      final itemConverter = _converters[innerType];
      if (itemConverter != null) {
        return data.map((item) => itemConverter(item)).toList();
      }
    }

    return data as T;
  }
}
