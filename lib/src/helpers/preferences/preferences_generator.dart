import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'annotations.dart';

/// --- PREFERENCE GENERATOR ENGINE ---
///
/// This generator automates the bridge between Dart class declarations and
/// persistent storage. It uses the `analyzer` package to inspect the
/// Abstract Syntax Tree (AST) of the annotated classes.
///
/// ### Generation Pipeline:
/// 1. **Discovery**: Identify classes annotated with `@GeneratePreferences`.
/// 2. **Parsing**: Scan all fields, filtering for private fields with specific annotations.
/// 3. **Validation**: Ensure types are supported (Primitives, Enums, or JSON models).
/// 4. **Buffering**: Write a mixin that provides reactivity and persistence.
///
/// ### Bridge Metadata:
/// - **TypeChecker**: Used to identify annotations without hardcoding strings.
/// - **ConstantReader**: Used to extract data (like `key`) from annotations.
///
/// ---

class PreferencesGenerator extends GeneratorForAnnotation<GeneratePreferences> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // 1. VALIDATION: Ensure the annotation is used on a class.
    // In the Element model, everything is an Element, but we specifically
    // need a ClassElement to access its fields and methods.
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '`@GeneratePreferences` can only be used on classes.',
        element: element,
      );
    }

    final classElement = element;
    final className = classElement.name!;
    final mixinName = '_\$$className';

    final buffer = StringBuffer();
    buffer.writeln('// ignore_for_file: non_constant_identifier_names');
    buffer.writeln('// ignore_for_file: unnecessary_cast');

    // THE MIXIN: We constrain the mixin to 'on BasePreferences' so it can
    // access storage helpers like 'getString', 'setBool', etc.
    buffer.writeln('mixin $mixinName on BasePreferences {');

    // Abstract getters for private fields: This allows the mixin to
    // "read" the initial value from the class it is being mixed into.
    _generateAbstractGetters(classElement, buffer);

    _generateValueNotifiers(classElement, buffer);
    _generateGettersAndSetters(classElement, buffer);
    _generateInit(classElement, buffer);
    _generateDispose(classElement, buffer);

    buffer.writeln('}');
    return buffer.toString();
  }

  /// Generates abstract getters for the private fields in the base class.
  ///
  /// Since the original fields are private (e.g., `_myFlag`), the mixin
  /// cannot access them directly. By defining `bool get _myFlag;`, the
  /// compiler forces the base class to provide it (which it does, since
  /// it owns the field).
  void _generateAbstractGetters(
    ClassElement classElement,
    StringBuffer buffer,
  ) {
    for (final field in classElement.fields) {
      if (!field.isPrivate) continue;

      final userDefault = _getAnnotation(field, 'UserDefault');
      final secure = _getAnnotation(field, 'Secure');
      if (userDefault == null && secure == null) continue;

      final type = field.type.getDisplayString();
      buffer.writeln('  $type get ${field.name};');
    }
  }

  /// Creates ValueNotifiers for each persistent field.
  ///
  /// These notifiers hold the "Golden State" of the preference in memory.
  /// UI components listen to these for real-time updates.
  void _generateValueNotifiers(ClassElement classElement, StringBuffer buffer) {
    for (final field in classElement.fields) {
      if (!field.isPrivate ||
          (_getAnnotation(field, 'UserDefault') == null &&
              _getAnnotation(field, 'Secure') == null)) {
        continue;
      }

      final type = field.type.getDisplayString();
      final name = field.name!;
      final notifierName = '${name.replaceFirst('_', '')}Notifier';

      // Initialize with the field value (which is usually the default).
      buffer.writeln(
        '  late final ValueNotifier<$type> $notifierName = ValueNotifier($name);',
      );
    }
  }

  /// Generates the public Type-Safe API for each preference.
  ///
  /// This creates:
  /// - A public getter (e.g., `String get myKey => ...`)
  /// - A public setter (e.g., `set myKey(String value) => ...`)
  void _generateGettersAndSetters(
    ClassElement classElement,
    StringBuffer buffer,
  ) {
    for (final field in classElement.fields) {
      if (!field.isPrivate) continue;

      final userDefault = _getAnnotation(field, 'UserDefault');
      final secure = _getAnnotation(field, 'Secure');
      if (userDefault == null && secure == null) continue;

      // Extract the storage key from the annotation.
      final key =
          userDefault?.read('key').stringValue ??
          secure?.read('key').stringValue;

      final name = field.name!;
      final fieldName = name.replaceFirst('_', '');
      final notifierName = '${fieldName}Notifier';
      final type = field.type.getDisplayString();

      // GETTER: Proxy to the ValueNotifier.
      buffer.writeln('  $type get $fieldName => $notifierName.value;');

      // SETTER: Update the Proxy -> Trigger Reactive UI -> Persist to Disk.
      buffer.writeln('  set $fieldName($type value) {');
      buffer.writeln('    $notifierName.value = value;');

      if (userDefault != null) {
        _generateUserDefaultSetter(field, key!, buffer);
      } else if (secure != null) {
        _generateSecureSetter(field, key!, buffer);
      }
      buffer.writeln('  }');
    }
  }

  /// Determines which SharedPreferences method to call based on the field type.
  void _generateUserDefaultSetter(
    FieldElement field,
    String key,
    StringBuffer buffer,
  ) {
    final type = field.type;
    if (type.isDartCoreBool) {
      buffer.writeln("    setBool('$key', value);");
    } else if (type.isDartCoreInt) {
      buffer.writeln("    setInt('$key', value);");
    } else if (type.isDartCoreDouble) {
      buffer.writeln("    setDouble('$key', value);");
    } else if (type.isDartCoreString) {
      buffer.writeln("    setString('$key', value);");
    } else if (type.getDisplayString() == 'List<String>') {
      buffer.writeln("    setStringList('$key', value as List<String>);");
    } else if (_isEnum(type.element)) {
      // ENUMS: Stored as their integer index.
      buffer.writeln("    setInt('$key', (value as Enum).index);");
    } else {
      // MODELS: Encoded to JSON and stored as a String.
      buffer.writeln(
        "    setString('$key', json.encode((value as dynamic).toJson()));",
      );
    }
  }

  /// Handles secure persistence calling the BasePreferences internal helper.
  void _generateSecureSetter(
    FieldElement field,
    String key,
    StringBuffer buffer,
  ) {
    buffer.writeln('    if (value == null) {');
    buffer.writeln("      setSecureInternal('$key', null);");
    buffer.writeln('    } else {');
    // SECURE MODELS: Encoded to JSON before being encrypted.
    buffer.writeln(
      "      setSecureInternal('$key', json.encode((value as dynamic).toJson()));",
    );
    buffer.writeln('    }');
  }

  /// Generates code to load disk values into the reactive ValueNotifiers.
  void _generateInit(ClassElement classElement, StringBuffer buffer) {
    buffer.writeln('  @override');
    buffer.writeln('  void initGenerated() {');
    buffer.writeln('    super.initGenerated();');
    for (final field in classElement.fields) {
      if (!field.isPrivate) continue;

      final userDefault = _getAnnotation(field, 'UserDefault');
      final secure = _getAnnotation(field, 'Secure');
      final key =
          userDefault?.read('key').stringValue ??
          secure?.read('key').stringValue;
      if (key == null) continue;

      final name = field.name!;
      final notifierName = '${name.replaceFirst('_', '')}Notifier';
      final type = field.type.getDisplayString();
      final defaultValue = name;

      if (userDefault != null) {
        // SharedPreferences reads are synchronous after init().
        if (field.type.isDartCoreBool) {
          buffer.writeln(
            "    $notifierName.value = getBool('$key', $defaultValue);",
          );
        } else if (field.type.isDartCoreInt) {
          buffer.writeln(
            "    $notifierName.value = getInt('$key', $defaultValue);",
          );
        } else if (field.type.isDartCoreDouble) {
          buffer.writeln(
            "    $notifierName.value = getDouble('$key', $defaultValue);",
          );
        } else if (field.type.isDartCoreString) {
          buffer.writeln(
            "    $notifierName.value = getString('$key', $defaultValue);",
          );
        } else if (field.type.getDisplayString() == 'List<String>') {
          buffer.writeln(
            "    $notifierName.value = getStringList('$key', $defaultValue);",
          );
        } else if (_isEnum(field.type.element)) {
          buffer.writeln(
            "    final index = getInt('$key', ($defaultValue as Enum).index);",
          );
          buffer.writeln(
            '    if (index < $type.values.length) { $notifierName.value = $type.values[index]; }',
          );
        } else {
          buffer.writeln("    final jsonString = getString('$key', '');");
          buffer.writeln('    if (jsonString.isNotEmpty) {');
          buffer.writeln(
            '      $notifierName.value = $type.fromJson(json.decode(jsonString)) as dynamic;',
          );
          buffer.writeln('    }');
        }
      } else {
        // SECURE READS: These are always asynchronous.
        // We load them via a .then() so the app can continue booting while
        // the encryption engine performs its work.
        buffer.writeln("    getSecureInternal('$key').then((jsonString) {");
        buffer.writeln(
          '      if (jsonString != null && jsonString.isNotEmpty) {',
        );
        buffer.writeln(
          '        $notifierName.value = $type.fromJson(json.decode(jsonString)) as dynamic;',
        );
        buffer.writeln('      }');
        buffer.writeln('    });');
      }
    }
    buffer.writeln('  }');
  }

  /// Cleaning up to prevent memory leaks in long-running apps.
  void _generateDispose(ClassElement classElement, StringBuffer buffer) {
    buffer.writeln('  @override');
    buffer.writeln('  void disposeGenerated() {');
    buffer.writeln('    super.disposeGenerated();');
    for (final field in classElement.fields) {
      if (!field.isPrivate ||
          (_getAnnotation(field, 'UserDefault') == null &&
              _getAnnotation(field, 'Secure') == null)) {
        continue;
      }
      final name = field.name!;
      final notifierName = '${name.replaceFirst('_', '')}Notifier';
      buffer.writeln('    $notifierName.dispose();');
    }
    buffer.writeln('  }');
  }

  /// Bridge to the SourceGen annotation scanner.
  ConstantReader? _getAnnotation(Element element, String name) {
    final checker = TypeChecker.fromUrl(
      'package:bmflutter/src/helpers/preferences/annotations.dart#$name',
    );
    final annotation = checker.firstAnnotationOf(element);
    return annotation != null ? ConstantReader(annotation) : null;
  }

  /// Helper to identify if an Element type is an Enum.
  bool _isEnum(Element? element) => element is EnumElement;
}
