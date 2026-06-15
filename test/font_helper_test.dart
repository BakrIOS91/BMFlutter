import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/design/typography/app_font_weight.dart';
import 'package:bm_flutter/src/design/typography/font_helper.dart';

class _BoldWeight implements FontWeightProtocol {
  const _BoldWeight();
  @override
  int get weightValue => 700;
}

class _ThinWeight implements FontWeightProtocol {
  const _ThinWeight();
  @override
  int get weightValue => 100;
}

void main() {
  setUp(() {
    FontRegistry.registerFont(FontKey.primary, 'Inter');
    FontRegistry.registerFont(FontKey.secondary, 'Roboto');
  });

  group('FontHelper.style', () {
    testWidgets('returns correct fontFamily for primary key', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context);
            return const SizedBox();
          }),
        ),
      );
      expect(result.fontFamily, 'Inter');
    });

    testWidgets('returns correct fontFamily for secondary key', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context, fontKey: FontKey.secondary);
            return const SizedBox();
          }),
        ),
      );
      expect(result.fontFamily, 'Roboto');
    });

    testWidgets('default size 14 at reference width (440) gives ~14', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(440, 956)),
            child: Builder(builder: (context) {
              result = FontHelper.style(context: context, size: 14);
              return const SizedBox();
            }),
          ),
        ),
      );
      expect(result.fontSize, closeTo(14.0, 0.1));
    });

    testWidgets('size scales up for tablet (shortestSide >= 600)', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(834, 1194)),
            child: Builder(builder: (context) {
              result = FontHelper.style(context: context, size: 14);
              return const SizedBox();
            }),
          ),
        ),
      );
      // scale = 1.5 for tablet
      expect(result.fontSize, closeTo(21.0, 0.1));
    });

    testWidgets('w700 maps to FontWeight.w700', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context, weight: const _BoldWeight());
            return const SizedBox();
          }),
        ),
      );
      expect(result.fontWeight, FontWeight.w700);
    });

    testWidgets('w100 maps to FontWeight.w100', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context, weight: const _ThinWeight());
            return const SizedBox();
          }),
        ),
      );
      expect(result.fontWeight, FontWeight.w100);
    });

    testWidgets('default weight is w400', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context);
            return const SizedBox();
          }),
        ),
      );
      expect(result.fontWeight, FontWeight.w400);
    });

    testWidgets('applies specified color', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context, color: Colors.red);
            return const SizedBox();
          }),
        ),
      );
      expect(result.color, Colors.red);
    });

    testWidgets('default color is black', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context);
            return const SizedBox();
          }),
        ),
      );
      expect(result.color, Colors.black);
    });

    testWidgets('lineHeight is null when not provided', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(builder: (context) {
            result = FontHelper.style(context: context);
            return const SizedBox();
          }),
        ),
      );
      expect(result.height, isNull);
    });

    testWidgets('lineHeight is set when provided', (tester) async {
      late TextStyle result;
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(440, 956)),
            child: Builder(builder: (context) {
              result = FontHelper.style(context: context, lineHeight: 1.5);
              return const SizedBox();
            }),
          ),
        ),
      );
      expect(result.height, isNotNull);
      expect(result.height!, closeTo(1.5, 0.1));
    });
  });
}
