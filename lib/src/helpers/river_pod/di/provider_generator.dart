import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'di_enums.dart';
import 'provider_annotation.dart';
import 'provider_config.dart';

/// Generator for classes annotated with `@Provider`
///
/// Features:
/// 1. Supports multiple environments: `env: [DIEnvironment.live, DIEnvironment.mock]`
/// 2. Supports provider types: singleton, factory, statefulSingleton
/// 3. Injects constructor dependencies automatically based on type
/// 4. Generates private providers for each environment
/// 5. Generates a public environment-aware provider
class ProviderGenerator extends GeneratorForAnnotation<Provider> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Provider can only be applied to classes',
        element: element,
      );
    }

    final className = element.name;
    if (className == null || className.isEmpty) {
      throw InvalidGenerationSourceError(
        'Class name for @Provider annotation cannot be null or empty',
        element: element,
      );
    }

    /// --- Read annotation fields ---
    final envListReader = annotation.read('env');
    final envList = envListReader.isNull
        ? <DIEnvironment>[]
        : envListReader.listValue
            .map(
              (e) => DIEnvironment.values[e.getField('index')!.toIntValue()!],
            )
            .toList();

    final asTypeReader = annotation.read('asType');
    final asType = asTypeReader.isNull
        ? className
        : asTypeReader.typeValue.getDisplayString();

    final typeReader = annotation.read('type');
    final type = typeReader.isNull
        ? 'ProviderType.factory'
        : 'ProviderType.${typeReader.revive().accessor}';

    /// --- Constructor parameters for dependency injection ---
    final constructor = element.constructors.first;
    if (className.isEmpty) {
      throw InvalidGenerationSourceError('Class name cannot be empty',
          element: element);
    }
    final dependencies = constructor.formalParameters;

    final depReads = dependencies.map((p) {
      final typeName = p.type.getDisplayString();
      final providerName = '${_lowerFirst(typeName)}Provider';
      return 'ref.read($providerName)';
    }).join(',\n    ');

    final buffer = StringBuffer();

    /// --- Generate private providers for each environment ---
    for (final env in envList) {
      buffer.writeln(
        'final _${_lowerFirst(className)}${env.name}Provider = ${_providerImplementation(type, className)}((ref) {',
      );
      buffer.writeln('  return $className(');
      if (depReads.isNotEmpty) buffer.writeln('    $depReads,');
      buffer.writeln('  );');
      buffer.writeln('});\\n');
    }

    /// --- Generate main public provider ---
    final publicName = '${_lowerFirst(asType)}Provider';
    buffer.writeln('final $publicName = Provider<$asType>((ref) {');

    if (envList.isEmpty) {
      // No environment, just return the singleton/factory
      buffer.writeln('  return ref.read(_${_lowerFirst(className)}Provider);');
    } else {
      buffer.writeln('  switch (ProviderConfig.current) {');
      for (final env in envList) {
        buffer.writeln(
          '    case DIEnvironment.${env.name}: return ref.read(_${_lowerFirst(className)}${env.name}Provider);',
        );
      }
      buffer.writeln(
        '    default: throw Exception("No provider configured for environment \${ProviderConfig.current}");',
      );
      buffer.writeln('  }');
    }

    buffer.writeln('});\\n');

    return buffer.toString();
  }

  /// Converts `ClassName` -> `className`
  String _lowerFirst(String value) =>
      value.substring(0, 1).toLowerCase() + value.substring(1);

  /// Returns the correct Riverpod provider type based on ProviderType
  String _providerImplementation(String type, String className) {
    switch (type) {
      case 'ProviderType.singleton':
      case 'ProviderType.lazySingleton':
        return 'Provider';
      case 'ProviderType.factory':
        return 'Provider.autoDispose';
      case 'ProviderType.statefulSingleton':
        return 'NotifierProvider';
      default:
        return 'Provider';
    }
  }
}
