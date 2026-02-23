# Reducerpod Documentation

## Overview

Reducerpod is a code-generation framework for Flutter that simplifies the implementation of the reducer pattern with Riverpod. It introduces a `@Reducer` annotation that automatically generates Riverpod Notifier providers and the associated boilerplate code, allowing you to focus on writing your business logic.

## Core Concepts

*   **@Reducer:** An annotation that marks a class as a reducer feature.
*   **State:** The data model that represents the state of your feature.
*   **Action:** An event that can be dispatched to the reducer to trigger a state change.
*   **Reducer:** A pure function that takes the current state and an action and returns a new state.

## Getting Started

### 1. Installation

Add the following dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  freezed_annotation: ^2.4.1
  reducer_annotation:
    path: packages/reducer_annotation

dev_dependencies:
  build_runner: ^2.4.6
  freezed: ^2.4.5
  reducer_generator:
    path: packages/reducer_generator
```

### 2. Create a Feature

Create a new file for your feature, for example, `lib/features/counter/counter_feature.dart`.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reducer_annotation/reducer_annotation.dart';

part 'counter_feature.freezed.dart';
part 'counter_feature.g.dart';

@freezed
class CounterState with _$$CounterState {
  const factory CounterState({
    required int count,
  }) = _CounterState;
}

@freezed
sealed class CounterAction with _$$CounterAction {
  const factory CounterAction.increment() = _Increment;
  const factory CounterAction.decrement() = _Decrement;
}

@Reducer()
class CounterFeature extends _$$CounterFeature {
  @override
  CounterState build() {
    return const CounterState(count: 0);
  }

  @override
  CounterState reduce(
    CounterState state,
    CounterAction action,
  ) {
    return switch (action) {
      _Increment() => state.copyWith(count: state.count + 1),
      _Decrement() => state.copyWith(count: state.count - 1),
    };
  }
}
```

### 3. Run the Code Generator

Run the following command in your terminal to generate the necessary files:

```bash
flutter pub run build_runner build
```

### 4. Use the Provider in Your UI

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/features/counter/counter_feature.dart';

class CounterPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counterState = ref.watch(counterFeatureProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text('${counterState.count}'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(counterFeatureProvider.notifier).send(const CounterAction.increment()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## Advanced Usage

### Dependency Injection

You can use `ref` inside your reducer to access other providers:

```dart
@Reducer()
class MyFeature extends _$$MyFeature {
  @override
  MyState build() {
    final myService = ref.read(myServiceProvider);
    return MyState(data: myService.getData());
  }

  // ...
}
```

## Generated Code

The `reducer_generator` will create a `*.g.dart` file with the following components:

*   **Provider:** A Riverpod `NotifierProvider` for your feature.
*   **Abstract Base Class:** An abstract class that your feature class extends.
*   **Ref Extension (Optional):** An extension on `Ref` to provide a `send` method for your feature's actions.
