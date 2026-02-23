/// **************************************************************************
/// ReducerGenerator
/// **************************************************************************
///
/// This generator creates a **Riverpod Notifier** wrapper for any class
/// annotated with `@Reducer()`. It follows a Clean Architecture approach
/// by separating:
///   - Feature logic (`SplashFeature`)
///   - Immutable state (`SplashState`)
///   - Actions (`SplashAction`)
///   - Notifier / Provider layer (generated automatically)
///
/// Example usage:
///
/// ```dart
/// import 'package:bmflutter/core.dart';
/// import 'package:flutter_riverpod/flutter_riverpod.dart';
/// import 'package:freezed_annotation/freezed_annotation.dart';
///
/// part 'splash_feature.freezed.dart';
/// part 'splash_feature.reducer.g.dart';
///
/// @freezed
/// class SplashState with _$SplashState {
///   const factory SplashState({@Default(0) int count}) = _SplashState;
/// }
///
/// @freezed
/// sealed class SplashAction with _$SplashAction {
///   const factory SplashAction.increment() = Increment;
/// }
///
/// @Reducer()
/// class SplashFeature {
///   SplashState build() => SplashState();
///
///   Future<void> reduce(
///     SplashState state,
///     SplashAction action,
///     Emitter<SplashState> emit,
///   ) async {
///     await action.map(
///       increment: (_) {
///         emit(state.copyWith(count: state.count + 1));
///       },
///     );
///   }
/// }
///
/// // Generated provider usage in UI:
/// class SplashView extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final state = ref.watch(splashFeatureProvider);
///
///     return Column(
///       children: [
///         Text('Count: ${state.count}'),
///         ElevatedButton(
///           onPressed: () => ref.sendSplashFeature(SplashAction.increment()),
///           child: const Text('Increment'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
library;

import 'package:analyzer/dart/element/element.dart';
import 'package:bmflutter/src/helpers/river_pod/reducer/reducer_annotation.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

/// Generator for classes annotated with `@Reducer()`.
/// Automatically generates:
///   - Abstract Notifier base class
///   - Concrete Notifier class
///   - NotifierProvider
///   - Ref extension for type-safe action dispatch
class ReducerGenerator extends GeneratorForAnnotation<Reducer> {
  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    // -----------------------------
    // 1. Validation
    // -----------------------------
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@Reducer can only be applied to classes',
        element: element,
      );
    }

    final className = element.name;
    if (className == null || className.isEmpty) {
      throw InvalidGenerationSourceError(
        'Invalid class name',
        element: element,
      );
    }

    /// Ensure `build()` exists for initial state
    final buildMethod = element.getMethod('build');
    if (buildMethod == null) {
      throw InvalidGenerationSourceError(
        '$className must implement build()',
        element: element,
      );
    }

    /// Ensure `reduce()` exists for handling actions
    final reduceMethod = element.getMethod('reduce');
    if (reduceMethod == null) {
      throw InvalidGenerationSourceError(
        '$className must implement reduce()',
        element: element,
      );
    }

    final parameters = reduceMethod.formalParameters;
    if (parameters.length != 3) {
      throw InvalidGenerationSourceError(
        'reduce must have signature: '
        'Future<void> reduce(State state, Action action, Emitter<State> emit)',
        element: element,
      );
    }

    // -----------------------------
    // 2. Extract types
    // -----------------------------
    final stateType = buildMethod.returnType.getDisplayString();
    final actionType = parameters[1].type.getDisplayString();
    final providerName = '${_lowerFirst(className)}Provider';
    final notifierClass = '${className}Notifier';

    final buffer = StringBuffer();

    // -----------------------------
    // 3. Emitter typedef
    // -----------------------------
    buffer.writeln('typedef Emitter<State> = void Function(State state);');
    buffer.writeln();

    // -----------------------------
    // 4. Abstract Notifier base class
    // -----------------------------
    buffer.writeln(
      'abstract class _\$$className extends Notifier<$stateType> {',
    );
    buffer.writeln();
    buffer.writeln(
      '  /// Reducer method to be implemented by concrete feature',
    );
    buffer.writeln('  Future<void> reduce(');
    buffer.writeln('    $stateType state,');
    buffer.writeln('    $actionType action,');
    buffer.writeln('    Emitter<$stateType> emit,');
    buffer.writeln('  );');
    buffer.writeln();
    buffer.writeln('  /// Sends an action and updates state via Emitter');
    buffer.writeln('  Future<void> send($actionType action) async {');
    buffer.writeln('    await reduce(');
    buffer.writeln('      state,');
    buffer.writeln('      action,');
    buffer.writeln('      (newState) { state = newState; },');
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    // -----------------------------
    // 5. Concrete Notifier wrapping feature
    // -----------------------------
    buffer.writeln('class $notifierClass extends _\$$className {');
    buffer.writeln('  late final $className _feature;');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  $stateType build() {');
    buffer.writeln('    _feature = $className();');
    buffer.writeln('    return _feature.build();');
    buffer.writeln('  }');
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln('  Future<void> reduce(');
    buffer.writeln('    $stateType state,');
    buffer.writeln('    $actionType action,');
    buffer.writeln('    Emitter<$stateType> emit,');
    buffer.writeln('  ) {');
    buffer.writeln('    return _feature.reduce(state, action, emit);');
    buffer.writeln('  }');
    buffer.writeln('}');
    buffer.writeln();

    // -----------------------------
    // 6. NotifierProvider
    // -----------------------------
    buffer.writeln(
      'final $providerName = NotifierProvider<$notifierClass, $stateType>(',
    );
    buffer.writeln('  $notifierClass.new,');
    buffer.writeln(');');
    buffer.writeln();

    // -----------------------------
    // 7. Ref extension for type-safe dispatch
    // -----------------------------
    buffer.writeln('extension ${className}RefExtension on Ref {');
    buffer.writeln('  Future<void> send$className($actionType action) {');
    buffer.writeln('    return read($providerName.notifier).send(action);');
    buffer.writeln('  }');
    buffer.writeln('}');

    return buffer.toString();
  }

  /// Converts first character to lowercase for provider naming
  String _lowerFirst(String value) {
    return value.substring(0, 1).toLowerCase() + value.substring(1);
  }
}
