/// Annotation to mark classes that should have copyWith methods generated
/// 
/// Usage:
/// ```dart
/// @AutoCopyWith()
/// class Person {
///   final String name;
///   final int age;
///   final String? email;
///   
///   Person({required this.name, required this.age, this.email});
/// }
/// ```
class AutoCopyWith {
  const AutoCopyWith();
}

/// Extension to provide copyWith functionality for classes annotated with @AutoCopyWith
/// 
/// This is a manual implementation that works without build_runner.
/// For each class you want to use copyWith with, you need to manually implement
/// the copyWith method or use the provided mixin.
mixin CopyWithMixin<T> {
  T copyWith();
}

/// Helper class to generate copyWith method code
/// 
/// This can be used to generate the copyWith method code that you can then
/// copy and paste into your classes.
class CopyWithCodeGenerator {
  /// Generates copyWith method code for a given class
  static String generateCopyWithCode({
    required String className,
    required List<CopyWithField> fields,
  }) {
    if (fields.isEmpty) {
      return '';
    }

    // Build the copyWith method parameters
    final parameters = fields.map((field) {
      return '${field.type}? ${field.name}';
    }).join(', ');

    // Build the constructor call parameters
    final constructorParams = fields.map((field) {
      return '${field.name}: ${field.name} ?? this.${field.name}';
    }).join(', ');

    // Generate the copyWith method
    return '''
  $className copyWith({
    $parameters,
  }) {
    return $className(
      $constructorParams,
    );
  }''';
  }
}

/// Represents a field in a class for copyWith generation
class CopyWithField {
  final String name;
  final String type;
  final bool isRequired;

  const CopyWithField({
    required this.name,
    required this.type,
    this.isRequired = false,
  });
}