import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/design/typography/app_font_weight.dart';
import 'package:bm_flutter/src/design/typography/font_helper.dart';

class _CustomWeight implements FontWeightProtocol {
  final int value;
  const _CustomWeight(this.value);
  @override
  int get weightValue => value;
}

void main() {
  group('FontWeightProtocol', () {
    test('custom 100 returns 100', () {
      expect(const _CustomWeight(100).weightValue, 100);
    });

    test('custom 400 returns 400', () {
      expect(const _CustomWeight(400).weightValue, 400);
    });

    test('custom 700 returns 700', () {
      expect(const _CustomWeight(700).weightValue, 700);
    });

    test('custom 900 returns 900', () {
      expect(const _CustomWeight(900).weightValue, 900);
    });
  });

  group('FontKey', () {
    test('primary key is "primary"', () {
      expect(FontKey.primary.key, 'primary');
    });

    test('secondary key is "secondary"', () {
      expect(FontKey.secondary.key, 'secondary');
    });

    test('custom key stores provided string', () {
      expect(FontKey.custom('brandX').key, 'brandX');
    });

    test('custom key with empty string', () {
      expect(FontKey.custom('').key, '');
    });

    test('two custom instances with same value have equal keys', () {
      expect(FontKey.custom('x').key, FontKey.custom('x').key);
    });
  });

  group('FontRegistry', () {
    test('registerFont and getFont round-trip for primary', () {
      FontRegistry.registerFont(FontKey.primary, 'Inter');
      expect(FontRegistry.getFont(FontKey.primary), 'Inter');
    });

    test('registerFont and getFont round-trip for secondary', () {
      FontRegistry.registerFont(FontKey.secondary, 'Roboto');
      expect(FontRegistry.getFont(FontKey.secondary), 'Roboto');
    });

    test('registerFont overwrites previous value', () {
      FontRegistry.registerFont(FontKey.primary, 'Old');
      FontRegistry.registerFont(FontKey.primary, 'New');
      expect(FontRegistry.getFont(FontKey.primary), 'New');
    });

    test('custom key round-trip', () {
      final key = FontKey.custom('customFont');
      FontRegistry.registerFont(key, 'CustomFamily');
      expect(FontRegistry.getFont(FontKey.custom('customFont')), 'CustomFamily');
    });

    test('getFont throws for unregistered key', () {
      expect(
        () => FontRegistry.getFont(FontKey.custom('definitely_not_registered_xyz')),
        throwsException,
      );
    });
  });
}
