import 'package:analyzer/dart/element/element.dart';
import 'package:bmflutter/src/helpers/reducer/reducer_annotation.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class ReducerGenerator extends GeneratorForAnnotation<Reducer> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Reducer can only be applied to classes.',
        element: element,
      );
    }

    /// FIX nullable name
    final className = element.name ?? '';

    if (className.isEmpty) {
      throw InvalidGenerationSourceError(
        'Reducer class must have a valid name',
        element: element,
      );
    }

    /// Check build() method
    final buildMethod = element.getMethod('build');
    if (buildMethod == null) {
      throw InvalidGenerationSourceError(
        '$className must implement build()',
        element: element,
      );
    }

    /// Check reduce() method
    final reduceMethod = element.getMethod('reduce');
    if (reduceMethod == null) {
      throw InvalidGenerationSourceError(
        '$className must implement reduce()',
        element: element,
      );
    }

    /// Use formalParameters
    final parameters = reduceMethod.formalParameters;
    if (parameters.length < 2) {
      throw InvalidGenerationSourceError(
        'reduce must be: State reduce(State state, Action action)',
        element: element,
      );
    }

    final stateType = buildMethod.returnType.getDisplayString();
    final actionType = parameters.last.type.getDisplayString();

    final providerName = '${_lowerFirst(className)}Provider';

    final buffer = StringBuffer();

    ///
    /// Abstract base class
    ///
    buffer.writeln(
      'abstract class _\$$className extends Notifier<$stateType> {',
    );
    buffer.writeln(
      '  $stateType reduce($stateType state, $actionType action);',
    );
    buffer.writeln();
    buffer.writeln('  void send($actionType action) {');
    buffer.writeln('    state = reduce(state, action);');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    ///
    /// Concrete Notifier class automatically wrapping the feature
    ///
    final notifierClass = '${className}Notifier';
    buffer.writeln('class $notifierClass extends _\$$className {');
    buffer.writeln('  final $className _feature = $className();');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  $stateType build() => _feature.build();');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln(
      '  $stateType reduce($stateType state, $actionType action) =>',
    );
    buffer.writeln('      _feature.reduce(state, action);');
    buffer.writeln('}');
    buffer.writeln();

    ///
    /// Provider pointing to concrete Notifier
    ///
    buffer.writeln(
      'final $providerName = NotifierProvider<$notifierClass, $stateType>($notifierClass.new);',
    );
    buffer.writeln();

    ///
    /// Ref extension
    ///
    buffer.writeln('extension ${className}RefExtension on Ref {');
    buffer.writeln('  void send$className($actionType action) {');
    buffer.writeln('    read($providerName.notifier).send(action);');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  String _lowerFirst(String value) {
    return value.substring(0, 1).toLowerCase() + value.substring(1);
  }
}
