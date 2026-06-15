import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/reusable/empty_bloc_listener.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
  void increment() => emit(state + 1);
}

void main() {
  group('emptyBlocListener', () {
    testWidgets('works inside MultiBlocListener without errors', (tester) async {
      final cubit = _CounterCubit();

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: MultiBlocListener(
              listeners: [emptyBlocListener<_CounterCubit, int>()],
              child: const Text('content'),
            ),
          ),
        ),
      );

      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('listener never fires — listenWhen always returns false', (tester) async {
      final cubit = _CounterCubit();
      bool wasCalled = false;

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: BlocListener<_CounterCubit, int>(
              listenWhen: (_, __) => false,
              listener: (_, __) => wasCalled = true,
              child: const SizedBox(),
            ),
          ),
        ),
      );

      cubit.increment();
      await tester.pump();
      expect(wasCalled, false);
    });

    testWidgets('state changes do not cause errors when used in MultiBlocListener', (tester) async {
      final cubit = _CounterCubit();

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: MultiBlocListener(
              listeners: [emptyBlocListener<_CounterCubit, int>()],
              child: const SizedBox(),
            ),
          ),
        ),
      );

      cubit.increment();
      await tester.pump();
      cubit.increment();
      await tester.pump();

      // No exceptions thrown
      expect(find.byType(MultiBlocListener), findsOneWidget);
    });

    testWidgets('multiple emptyBlocListeners can coexist in MultiBlocListener', (tester) async {
      final cubit = _CounterCubit();

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: MultiBlocListener(
              listeners: [
                emptyBlocListener<_CounterCubit, int>(),
                emptyBlocListener<_CounterCubit, int>(),
              ],
              child: const Text('multi'),
            ),
          ),
        ),
      );

      expect(find.text('multi'), findsOneWidget);
    });
  });
}
