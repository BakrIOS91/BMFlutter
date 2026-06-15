import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/design/typography/font_helper.dart';
import 'package:bm_flutter/src/helpers/reusable/underlined_button.dart';

void main() {
  setUp(() {
    FontRegistry.registerFont(FontKey.primary, 'Inter');
  });

  group('UnderlinedButton', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnderlinedButton(
            title: 'Forgot Password?',
            onPressed: () {},
          ),
        ),
      ));
      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnderlinedButton(
            title: 'Click',
            onPressed: () => tapped = true,
          ),
        ),
      ));
      await tester.tap(find.text('Click'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('text has underline decoration by default', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnderlinedButton(
            title: 'Underlined',
            onPressed: () {},
          ),
        ),
      ));
      final text = tester.widget<Text>(find.text('Underlined'));
      expect(text.style?.decoration, TextDecoration.underline);
    });

    testWidgets('custom style still applies underline', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnderlinedButton(
            title: 'Custom',
            onPressed: () {},
            style: const TextStyle(fontSize: 18, color: Colors.green),
          ),
        ),
      ));
      final text = tester.widget<Text>(find.text('Custom'));
      expect(text.style?.decoration, TextDecoration.underline);
    });

    testWidgets('multiple taps invoke onPressed each time', (tester) async {
      int count = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: UnderlinedButton(
            title: 'Multi',
            onPressed: () => count++,
          ),
        ),
      ));
      await tester.tap(find.text('Multi'));
      await tester.pump();
      await tester.tap(find.text('Multi'));
      await tester.pump();
      expect(count, 2);
    });
  });
}
