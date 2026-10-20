import 'dart:typed_data';

import 'package:bm_flutter/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child, {Size size = const Size(960, 540)}) => MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    );

void main() {
  setUpAll(() => FontRegistry.registerFont(FontKey.primary, 'Inter'));

  group('WithViewState', () {
    testWidgets('shows the child when loaded', (tester) async {
      await tester.pumpWidget(_app(
        const WithViewState(
            viewState: ViewState.loaded, child: Text('content')),
      ));
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a loader for Loading', (tester) async {
      await tester.pumpWidget(_app(
        const WithViewState(
            viewState: ViewState.loading, child: Text('content')),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('replaces content with the error view and retries',
        (tester) async {
      var retried = 0;
      await tester.pumpWidget(_app(
        WithViewState(
          viewState: ViewState.noNetwork,
          retryAction: () => retried++,
          child: const Text('content'),
        ),
      ));
      expect(find.text('No connection'), findsOneWidget);
      expect(find.text('content').hitTestable(), findsNothing);
      await tester.tap(find.text('Retry'));
      expect(retried, 1);
    });

    testWidgets('autofocusRetry focuses the retry button', (tester) async {
      await tester.pumpWidget(_app(
        WithViewState(
          viewState: ViewState.noNetwork,
          retryAction: () {},
          autofocusRetry: true,
          child: const Text('content'),
        ),
      ));
      await tester.pump();
      final focused = FocusManager.instance.primaryFocus;
      expect(focused, isNotNull);
      expect(
        find.descendant(
          of: find.byType(FilledButton),
          matching: find.byWidgetPredicate((w) => w is Focus),
        ),
        findsWidgets,
      );
      expect(focused!.context, isNotNull);
    });

    testWidgets('uses a String errorModel and custom texts', (tester) async {
      await tester.pumpWidget(_app(
        const WithViewState(
          viewState: ServerError(errorModel: 'Server said no'),
          texts: ViewStateTexts(errorTitle: 'Oops'),
          child: Text('content'),
        ),
      ));
      expect(find.text('Oops'), findsOneWidget);
      expect(find.text('Server said no'), findsOneWidget);
    });

    testWidgets('errorMessageResolver reads a custom model', (tester) async {
      await tester.pumpWidget(_app(
        WithViewState(
          viewState: const UnexpectedError(errorModel: {'msg': 'from map'}),
          errorMessageResolver: (m) => (m as Map)['msg'] as String?,
          child: const Text('content'),
        ),
      ));
      expect(find.text('from map'), findsOneWidget);
    });

    testWidgets('errorBuilder overrides the default view', (tester) async {
      await tester.pumpWidget(_app(
        WithViewState(
          viewState: ViewState.noData,
          errorBuilder: (context, state, retry) => const Text('custom'),
          child: const Text('content'),
        ),
      ));
      expect(find.text('custom'), findsOneWidget);
      expect(find.text('Nothing here yet'), findsNothing);
    });

    testWidgets('bottomSheet mode keeps the content visible', (tester) async {
      await tester.pumpWidget(_app(
        const WithViewState(
          viewState: ViewState.noNetwork,
          errorDisplayMode: ErrorDisplayMode.bottomSheet,
          child: Text('content'),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('content'), findsOneWidget);
      expect(find.text('No connection'), findsOneWidget);
    });
  });

  group('ErrorView autofocusRetry', () {
    testWidgets('moves focus into the retry button', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(
        ErrorView(
          title: 't',
          message: 'm',
          buttonTitle: 'Retry',
          retryAction: () {},
          image: Image.memory(Uint8List(0), errorBuilder: (_, __, ___) {
            return const SizedBox();
          }),
          autofocusRetry: true,
          retryButton: TextButton(
            focusNode: node,
            onPressed: () {},
            child: const Text('Retry'),
          ),
        ),
      ));
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
    });
  });

  group('DeviceHelper TV mode', () {
    tearDown(DeviceRegistry.resetTvMode);

    testWidgets('scales the screen height against the design height',
        (tester) async {
      DeviceRegistry.registerTvMode();
      late double scale;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          scale = DeviceHelper.getScalingFactor(context);
          return const SizedBox();
        }),
        size: const Size(960, 540),
      ));
      expect(scale, closeTo(0.5, 1e-9));
    });

    testWidgets('a 1080 logical-pixel TV has scale 1', (tester) async {
      DeviceRegistry.registerTvMode();
      late double scale;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          scale = DeviceHelper.getScalingFactor(context);
          return const SizedBox();
        }),
        size: const Size(1920, 1080),
      ));
      expect(scale, 1.0);
    });

    testWidgets('is off by default (tablet rule still applies)',
        (tester) async {
      expect(DeviceRegistry.isTvMode, isFalse);
      late double scale;
      await tester.pumpWidget(_app(
        Builder(builder: (context) {
          scale = DeviceHelper.getScalingFactor(context);
          return const SizedBox();
        }),
        size: const Size(1920, 1080),
      ));
      expect(scale, 1.5);
    });

    test('resetTvMode restores defaults', () {
      DeviceRegistry.registerTvMode(designHeight: 720);
      expect(DeviceRegistry.tvDesignHeight, 720);
      DeviceRegistry.resetTvMode();
      expect(DeviceRegistry.isTvMode, isFalse);
      expect(DeviceRegistry.tvDesignHeight, 1080);
    });
  });

  group('SecureStore', () {
    tearDown(PreferencesStorage.resetSecureStore);

    test('MemorySecureStore reads, writes and deletes', () async {
      final store = MemorySecureStore();
      expect(await store.read('k'), isNull);
      await store.write('k', 'v');
      expect(await store.read('k'), 'v');
      await store.delete('k');
      expect(await store.read('k'), isNull);
    });

    test('registerSecureStore swaps the store and reset restores the default',
        () {
      final memory = MemorySecureStore();
      PreferencesStorage.registerSecureStore(memory);
      expect(PreferencesStorage.secureStore, same(memory));
      PreferencesStorage.resetSecureStore();
      expect(PreferencesStorage.secureStore, isA<FlutterSecureStore>());
    });
  });

  group('Focusable buttons', () {
    testWidgets('AppCupertinoButton takes the requested autofocus',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(
        Builder(
          builder: (context) => AppCupertinoButton.filled(
            context: context,
            title: 'Go',
            onPressed: () {},
            focusNode: node,
            autofocus: true,
          ),
        ),
      ));
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
    });

    testWidgets('UnderlinedButton accepts a focus node', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      await tester.pumpWidget(_app(
        UnderlinedButton(
          title: 'Help',
          onPressed: () {},
          focusNode: node,
          autofocus: true,
        ),
      ));
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);
    });
  });
}
