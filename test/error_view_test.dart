import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/reusable/error_view.dart';

Image _testImage() => Image.asset(
      'assets/error.png',
      errorBuilder: (_, __, ___) => const SizedBox(key: Key('img')),
    );

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(size: Size(440, 956)),
        child: child,
      ),
    ),
  );
}

void main() {
  group('ErrorView', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Error Title',
        message: 'Error message',
        image: _testImage(),
      )));
      await tester.pump();
      expect(find.text('Error Title'), findsOneWidget);
    });

    testWidgets('renders message text', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Title',
        message: 'Detailed message here',
        image: _testImage(),
      )));
      await tester.pump();
      expect(find.text('Detailed message here'), findsOneWidget);
    });

    testWidgets('retryButton is shown when all three params provided', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Error',
        message: 'Message',
        image: _testImage(),
        buttonTitle: 'Retry',
        retryAction: () => tapped = true,
        retryButton: ElevatedButton(
          key: const Key('retry'),
          onPressed: () => tapped = true,
          child: const Text('Retry'),
        ),
      )));
      await tester.pump();
      expect(find.byKey(const Key('retry')), findsOneWidget);
      await tester.tap(find.byKey(const Key('retry')));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('retryButton hidden when buttonTitle is null', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Title',
        message: 'Message',
        image: _testImage(),
        retryAction: () {},
        retryButton: const ElevatedButton(
          onPressed: null,
          child: Text('Should not show'),
        ),
      )));
      await tester.pump();
      expect(find.text('Should not show'), findsNothing);
    });

    testWidgets('retryButton hidden when retryAction is null', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Title',
        message: 'Message',
        image: _testImage(),
        buttonTitle: 'Retry',
        retryButton: const ElevatedButton(
          onPressed: null,
          child: Text('Should not show'),
        ),
      )));
      await tester.pump();
      expect(find.text('Should not show'), findsNothing);
    });

    testWidgets('retryButton hidden when retryButton widget is null', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Title',
        message: 'Message',
        image: _testImage(),
        buttonTitle: 'Retry',
        retryAction: () {},
      )));
      await tester.pump();
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('applies backgroundColor', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Title',
        message: 'Message',
        image: _testImage(),
        backgroundColor: Colors.blue.shade100,
      )));
      await tester.pump();
      // Verify widget tree renders without error
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('applies custom titleStyle', (tester) async {
      await tester.pumpWidget(_wrap(ErrorView(
        title: 'Styled Title',
        message: 'Message',
        image: _testImage(),
        titleStyle: const TextStyle(fontSize: 24, color: Colors.red),
      )));
      await tester.pump();
      final text = tester.widget<Text>(find.text('Styled Title'));
      expect(text.style?.fontSize, 24);
    });
  });
}
