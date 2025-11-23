import 'package:bmflutter/core.dart';
import 'package:flutter/widgets.dart';

abstract class LanguageManager {
  /// Projects may override only if they want to customize the list.
  List<SupportedLocale> get supported => SupportedLocale.values;

  /// Default fallback from enum (customizable if needed)
  SupportedLocale get fallback => SupportedLocale.en_US;

  /// Converts enum list → Flutter locales
  List<Locale> get supportedLocales => supported.map((e) => e.locale).toList();

  /// Fallback Locale object
  Locale get fallbackLocale => fallback.locale;

  /// Default resolution logic — only implemented ONCE ✅
  Locale resolve(Locale? deviceLocale) {
    if (deviceLocale == null) return fallbackLocale;

    // If explicitly Arabic → force generic Arabic
    if (deviceLocale.languageCode == 'ar') {
      return const Locale('ar');
    }

    return supportedLocales.firstWhere(
      (l) => l.languageCode == deviceLocale.languageCode,
      orElse: () => fallbackLocale,
    );
  }
}
