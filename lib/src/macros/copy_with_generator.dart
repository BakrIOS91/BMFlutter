import 'macro_copy_with.dart';

/// Utility class to help generate copyWith method code
class CopyWithGenerator {
  /// Generates copyWith method code for a class
  /// 
  /// Example usage:
  /// ```dart
  /// final code = CopyWithGenerator.generateForClass(
  ///   className: 'Person',
  ///   fields: [
  ///     CopyWithField(name: 'name', type: 'String'),
  ///     CopyWithField(name: 'age', type: 'int'),
  ///     CopyWithField(name: 'email', type: 'String?'),
  ///   ],
  /// );
  /// print(code);
  /// ```
  static String generateForClass({
    required String className,
    required List<CopyWithField> fields,
  }) {
    return CopyWithCodeGenerator.generateCopyWithCode(
      className: className,
      fields: fields,
    );
  }

  /// Generates copyWith method code for a class with common field types
  /// 
  /// This is a convenience method for common use cases.
  static String generateForCommonClass({
    required String className,
    required Map<String, String> fields, // fieldName -> fieldType
  }) {
    final copyWithFields = fields.entries
        .map((entry) => CopyWithField(
              name: entry.key,
              type: entry.value,
            ))
        .toList();

    return generateForClass(
      className: className,
      fields: copyWithFields,
    );
  }
}

/// Example usage and testing
void main() {
  // Example 1: Person class
  final personCode = CopyWithGenerator.generateForClass(
    className: 'Person',
    fields: [
      CopyWithField(name: 'name', type: 'String'),
      CopyWithField(name: 'age', type: 'int'),
      CopyWithField(name: 'email', type: 'String?'),
    ],
  );
  
  print('Person copyWith method:');
  print(personCode);
  print('\n' + '='*50 + '\n');

  // Example 2: Product class
  final productCode = CopyWithGenerator.generateForCommonClass(
    className: 'Product',
    fields: {
      'id': 'String',
      'title': 'String',
      'price': 'double',
      'isAvailable': 'bool',
    },
  );
  
  print('Product copyWith method:');
  print(productCode);
}

