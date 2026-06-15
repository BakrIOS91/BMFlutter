import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/reusable/preferences_listener.dart';

class _FakeCubit extends Cubit<int> {
  _FakeCubit() : super(0);
}

class _DynamicListenerHost extends StatefulWidget {
  final ValueNotifier<String> notifier;
  final void Function(String) onValue;

  const _DynamicListenerHost({required this.notifier, required this.onValue});

  @override
  State<_DynamicListenerHost> createState() => _DynamicListenerHostState();
}

class _DynamicListenerHostState extends State<_DynamicListenerHost> {
  @override
  Widget build(BuildContext context) {
    return PreferencesListener<_FakeCubit, int, String>(
      listenTo: widget.notifier,
      listener: (_, value) => widget.onValue(value),
      child: const SizedBox(),
    );
  }
}

void main() {
  group('PreferencesListener', () {
    testWidgets('calls listener when ValueNotifier changes', (tester) async {
      final notifier = ValueNotifier<String>('initial');
      final cubit = _FakeCubit();
      final received = <String>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: PreferencesListener<_FakeCubit, int, String>(
              listenTo: notifier,
              listener: (_, value) => received.add(value),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      notifier.value = 'changed';
      await tester.pump();
      expect(received, ['changed']);
    });

    testWidgets('calls listener multiple times for multiple changes', (tester) async {
      final notifier = ValueNotifier<int>(0);
      final cubit = _FakeCubit();
      final received = <int>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: PreferencesListener<_FakeCubit, int, int>(
              listenTo: notifier,
              listener: (_, value) => received.add(value),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      notifier.value = 1;
      await tester.pump();
      notifier.value = 2;
      await tester.pump();
      notifier.value = 3;
      await tester.pump();

      expect(received, [1, 2, 3]);
    });

    testWidgets('listenWhen=false suppresses all listener calls', (tester) async {
      final notifier = ValueNotifier<String>('initial');
      final cubit = _FakeCubit();
      final received = <String>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: PreferencesListener<_FakeCubit, int, String>(
              listenTo: notifier,
              listener: (_, value) => received.add(value),
              listenWhen: (_, __) => false,
              child: const SizedBox(),
            ),
          ),
        ),
      );

      notifier.value = 'changed';
      await tester.pump();
      expect(received, isEmpty);
    });

    testWidgets('listenWhen filters selectively', (tester) async {
      final notifier = ValueNotifier<int>(0);
      final cubit = _FakeCubit();
      final received = <int>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: PreferencesListener<_FakeCubit, int, int>(
              listenTo: notifier,
              listener: (_, value) => received.add(value),
              listenWhen: (prev, curr) => curr > 1,
              child: const SizedBox(),
            ),
          ),
        ),
      );

      notifier.value = 1; // filtered out (not > 1)
      await tester.pump();
      notifier.value = 2; // passes
      await tester.pump();

      expect(received, [2]);
    });

    testWidgets('disposes listener on widget removal without crashing', (tester) async {
      final notifier = ValueNotifier<String>('initial');
      final cubit = _FakeCubit();
      final received = <String>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: PreferencesListener<_FakeCubit, int, String>(
              listenTo: notifier,
              listener: (_, value) => received.add(value),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      // Remove the widget tree
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Changing notifier after dispose should not crash
      notifier.value = 'post-dispose';
      await tester.pump();
      expect(received, isEmpty);
    });

    testWidgets('renders child widget', (tester) async {
      final notifier = ValueNotifier<String>('val');
      final cubit = _FakeCubit();

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: PreferencesListener<_FakeCubit, int, String>(
              listenTo: notifier,
              listener: (_, __) {},
              child: const Text('child content'),
            ),
          ),
        ),
      );

      expect(find.text('child content'), findsOneWidget);
    });

    testWidgets('didUpdateWidget re-subscribes when listenTo changes', (tester) async {
      final notifier1 = ValueNotifier<String>('a');
      final notifier2 = ValueNotifier<String>('x');
      final cubit = _FakeCubit();
      final received = <String>[];

      // Build with notifier1
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: _DynamicListenerHost(
              notifier: notifier1,
              onValue: (v) => received.add(v),
            ),
          ),
        ),
      );

      // Swap to notifier2
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: _DynamicListenerHost(
              notifier: notifier2,
              onValue: (v) => received.add(v),
            ),
          ),
        ),
      );

      // notifier1 should no longer be listened to
      notifier1.value = 'old_change';
      await tester.pump();
      expect(received, isEmpty);

      // notifier2 should be listened to
      notifier2.value = 'new_change';
      await tester.pump();
      expect(received, ['new_change']);
    });

    testWidgets('preferencesListener() function works inside MultiBlocListener', (tester) async {
      final notifier = ValueNotifier<int>(0);
      final cubit = _FakeCubit();
      final received = <int>[];

      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            home: MultiBlocListener(
              listeners: [
                preferencesListener<_FakeCubit, int, int>(
                  listenTo: notifier,
                  listener: (_, value) => received.add(value),
                ),
              ],
              child: const Text('content'),
            ),
          ),
        ),
      );

      notifier.value = 42;
      await tester.pump();
      expect(received, [42]);
    });
  });
}
