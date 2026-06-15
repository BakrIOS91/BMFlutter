import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/reusable/custom_buttons.dart';

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
  group('Position enum', () {
    test('has leading, center, trailing values', () {
      expect(Position.values, containsAll([Position.leading, Position.center, Position.trailing]));
    });
  });

  group('AppCupertinoButton.filled', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Press Me',
          onPressed: () {},
        ),
      )));
      expect(find.text('Press Me'), findsOneWidget);
    });

    testWidgets('enabled state has opacity 1.0', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Enabled',
          onPressed: () {},
        ),
      )));
      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 1.0);
    });

    testWidgets('disabled state has opacity 0.6', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Disabled',
          onPressed: () {},
          isDisabled: true,
        ),
      )));
      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 0.6);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Tap',
          onPressed: () => tapped = true,
        ),
      )));
      await tester.tap(find.text('Tap'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('disabled button does not invoke onPressed', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'NoTap',
          onPressed: () => tapped = true,
          isDisabled: true,
        ),
      )));
      await tester.tap(find.text('NoTap'), warnIfMissed: false);
      await tester.pump();
      expect(tapped, false);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'With Icon',
          onPressed: () {},
          icon: Icons.add,
        ),
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('AppCupertinoButton.outlined', () {
    testWidgets('renders title text', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.outlined(
          context: context,
          title: 'Outlined',
          onPressed: () {},
        ),
      )));
      expect(find.text('Outlined'), findsOneWidget);
    });

    testWidgets('enabled state has opacity 1.0', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.outlined(
          context: context,
          title: 'Enabled Outline',
          onPressed: () {},
        ),
      )));
      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 1.0);
    });

    testWidgets('disabled state has opacity 0.5', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.outlined(
          context: context,
          title: 'Outline Disabled',
          onPressed: () {},
          isDisabled: true,
        ),
      )));
      final opacity = tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity));
      expect(opacity.opacity, 0.5);
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.outlined(
          context: context,
          title: 'OutlineTap',
          onPressed: () => tapped = true,
        ),
      )));
      await tester.tap(find.text('OutlineTap'));
      await tester.pump();
      expect(tapped, true);
    });

    testWidgets('renders with icon at trailing position', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.outlined(
          context: context,
          title: 'Trailing',
          onPressed: () {},
          icon: Icons.arrow_forward,
          iconPosition: Position.trailing,
        ),
      )));
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('renders with shadow when shadowBlurRadius > 0', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.outlined(
          context: context,
          title: 'Shadow',
          onPressed: () {},
          shadowBlurRadius: 8.0,
          shadowColor: Colors.black,
        ),
      )));
      expect(find.text('Shadow'), findsOneWidget);
    });
  });

  group('AppCupertinoButton — shadow and center-icon branches', () {
    testWidgets('filled renders with shadow when shadowBlurRadius > 0', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Shadowed',
          onPressed: () {},
          shadowBlurRadius: 6.0,
          shadowColor: Colors.blue,
        ),
      )));
      expect(find.text('Shadowed'), findsOneWidget);
    });

    testWidgets('icon at center position uses Stack layout (labelPosition=leading)', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Go',
          onPressed: () {},
          icon: Icons.star,
          iconPosition: Position.center,
          labelPosition: Position.leading,
        ),
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byType(Stack), findsAtLeastNWidgets(1));
    });

    testWidgets('icon at center position — labelPosition=center', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Go',
          onPressed: () {},
          icon: Icons.star,
          iconPosition: Position.center,
          labelPosition: Position.center,
        ),
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('icon at center position — labelPosition=trailing', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Go',
          onPressed: () {},
          icon: Icons.star,
          iconPosition: Position.center,
          labelPosition: Position.trailing,
        ),
      )));
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('filled with custom width', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'OK',
          onPressed: () {},
          width: 200,
        ),
      )));
      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('Row layout with leading icon (covers _mapPositionToAlignment leading)', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Leading',
          onPressed: () {},
          icon: Icons.add,
          iconPosition: Position.leading,
          labelPosition: Position.leading,
        ),
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Row layout with trailing label (covers _mapPositionToAlignment trailing)', (tester) async {
      await tester.pumpWidget(_wrap(Builder(
        builder: (context) => AppCupertinoButton.filled(
          context: context,
          title: 'Trailing',
          onPressed: () {},
          icon: Icons.add,
          iconPosition: Position.leading,
          labelPosition: Position.trailing,
        ),
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
