import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/enums.dart';
import 'package:bm_flutter/src/helpers/language_manager.dart';

class _DefaultManager extends LanguageManager {}

void main() {
  late _DefaultManager manager;

  setUp(() => manager = _DefaultManager());

  group('LanguageManager — defaults', () {
    test('supported returns all SupportedLocale values', () {
      expect(manager.supported, SupportedLocale.values);
    });

    test('fallback is enUs', () {
      expect(manager.fallback, SupportedLocale.enUs);
    });

    test('supportedLocales length equals SupportedLocale.values length', () {
      expect(manager.supportedLocales.length, SupportedLocale.values.length);
    });

    test('fallbackLocale is en_US', () {
      expect(manager.fallbackLocale.languageCode, 'en');
      expect(manager.fallbackLocale.countryCode, 'US');
    });
  });

  group('LanguageManager.resolve', () {
    test('null deviceLocale returns fallbackLocale', () {
      expect(manager.resolve(null), manager.fallbackLocale);
    });

    test('Arabic locale returns generic Locale("ar")', () {
      expect(manager.resolve(const Locale('ar', 'SA')), const Locale('ar'));
    });

    test('Arabic locale without country returns generic Locale("ar")', () {
      expect(manager.resolve(const Locale('ar')), const Locale('ar'));
    });

    test('known language (en) returns matching locale', () {
      final result = manager.resolve(const Locale('en'));
      expect(result.languageCode, 'en');
    });

    test('known language (de) returns matching locale', () {
      final result = manager.resolve(const Locale('de'));
      expect(result.languageCode, 'de');
    });

    test('known language (fr) returns matching locale', () {
      final result = manager.resolve(const Locale('fr'));
      expect(result.languageCode, 'fr');
    });

    test('unknown language returns fallbackLocale', () {
      final result = manager.resolve(const Locale('xx'));
      expect(result, manager.fallbackLocale);
    });
  });

  group('LanguageManager — custom subclass', () {
    test('can override supported and fallback', () {
      final custom = _CustomManager();
      expect(custom.supported, [SupportedLocale.enUs, SupportedLocale.arEG]);
      expect(custom.fallback, SupportedLocale.arEG);
    });

    test('custom resolve uses overridden supported list', () {
      final custom = _CustomManager();
      final result = custom.resolve(const Locale('en'));
      expect(result.languageCode, 'en');
    });

    test('custom resolve returns custom fallback for unsupported locale', () {
      final custom = _CustomManager();
      final result = custom.resolve(const Locale('ja'));
      expect(result, custom.fallbackLocale);
    });
  });
}

class _CustomManager extends LanguageManager {
  @override
  List<SupportedLocale> get supported => [SupportedLocale.enUs, SupportedLocale.arEG];

  @override
  SupportedLocale get fallback => SupportedLocale.arEG;
}
