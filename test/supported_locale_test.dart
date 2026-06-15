import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/enums.dart';

void main() {
  group('SupportedLocale', () {
    test('rawValue for single-part locale (ar)', () {
      expect(SupportedLocale.ar.rawValue, 'ar');
    });

    test('rawValue for two-part locale (arAE)', () {
      expect(SupportedLocale.arAE.rawValue, 'ar_AE');
    });

    test('rawValue for enUs', () {
      expect(SupportedLocale.enUs.rawValue, 'en_US');
    });

    test('rawValue for zhCn', () {
      expect(SupportedLocale.zhCn.rawValue, 'zh_CN');
    });

    test('locale for single-part (ar) has no country code', () {
      final locale = SupportedLocale.ar.locale;
      expect(locale, const Locale('ar'));
      expect(locale.countryCode, isNull);
    });

    test('locale for two-part (enUs) splits correctly', () {
      final locale = SupportedLocale.enUs.locale;
      expect(locale.languageCode, 'en');
      expect(locale.countryCode, 'US');
    });

    test('locale for arAE splits correctly', () {
      final locale = SupportedLocale.arAE.locale;
      expect(locale.languageCode, 'ar');
      expect(locale.countryCode, 'AE');
    });

    test('locale for deDe splits correctly', () {
      final locale = SupportedLocale.deDe.locale;
      expect(locale.languageCode, 'de');
      expect(locale.countryCode, 'DE');
    });

    test('all rawValues are distinct', () {
      final rawValues = SupportedLocale.values.map((e) => e.rawValue).toSet();
      expect(rawValues.length, SupportedLocale.values.length);
    });

    test('values list is non-empty and contains expected entries', () {
      expect(SupportedLocale.values, contains(SupportedLocale.ar));
      expect(SupportedLocale.values, contains(SupportedLocale.en));
      expect(SupportedLocale.values, contains(SupportedLocale.enUs));
      expect(SupportedLocale.values.length, greaterThan(50));
    });
  });
}
