import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/device_helper.dart';

void main() {
  group('DeviceHelper.getScalingFactor', () {
    testWidgets('returns 1.5 for tablet dimensions (shortestSide >= 600)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(834, 1194)),
            child: Builder(
              builder: (BuildContext context) {
                final scale = DeviceHelper.getScalingFactor(context);
                expect(scale, 1.5);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('returns clamped minimum 0.9 for narrow phone (393 < 440)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(393, 852)),
            child: Builder(
              builder: (BuildContext context) {
                final scale = DeviceHelper.getScalingFactor(context);
                // 393 / 440 = 0.893... clamped to 0.9
                expect(scale, closeTo(0.9, 0.01));
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('returns 1.0 for exact reference width (440)', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(440, 956)),
            child: Builder(
              builder: (BuildContext context) {
                final scale = DeviceHelper.getScalingFactor(context);
                expect(scale, 1.0);
                return Container();
              },
            ),
          ),
        ),
      );
    });

    testWidgets('returns clamped maximum 1.1 for wide phone', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(500, 900)),
            child: Builder(
              builder: (BuildContext context) {
                final scale = DeviceHelper.getScalingFactor(context);
                // 500 / 440 = 1.136... clamped to 1.1
                expect(scale, closeTo(1.1, 0.01));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });

  group('DeviceRegistry', () {
    tearDown(() {
      // Reset to default after each test
      DeviceRegistry.registerReferenceWidth(440.0);
    });

    test('default referenceWidth is 440.0', () {
      expect(DeviceRegistry.referenceWidth, 440.0);
    });

    test('registerReferenceWidth updates the value', () {
      DeviceRegistry.registerReferenceWidth(375.0);
      expect(DeviceRegistry.referenceWidth, 375.0);
    });

    test('registerReferenceWidth can set to a custom value', () {
      DeviceRegistry.registerReferenceWidth(390.0);
      expect(DeviceRegistry.referenceWidth, 390.0);
    });

    testWidgets('custom referenceWidth affects scaling calculation', (WidgetTester tester) async {
      DeviceRegistry.registerReferenceWidth(390.0);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(size: Size(390, 844)),
            child: Builder(
              builder: (BuildContext context) {
                final scale = DeviceHelper.getScalingFactor(context);
                // 390 / 390 = 1.0 exactly
                expect(scale, closeTo(1.0, 0.01));
                return Container();
              },
            ),
          ),
        ),
      );
    });
  });
}
