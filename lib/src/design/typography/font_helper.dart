/// Font Helper for BMFlutter Design System
///
/// This file provides a centralized typography helper that:
/// - Automatically scales font sizes based on device size
/// - Resolves font family from the app theme (via ThemeExtension)
/// - Supports custom font weight abstractions
/// - Supports configurable line height (line spacing)
/// - Ensures consistent typography across all screens and clients
///
/// The helper is intentionally **stateless** and **theme-driven**,
/// making it suitable for white-label and multi-brand applications.
///
/// Usage:
/// ```dart
/// Text(
///   'Hello World',
///   style: FontHelper.style(
///     context: context,
///     size: 16,
///     weight: CustomFontWeight.bold,
///     color: Colors.blue,
///     lineHeight: 1.4,
///   ),
/// )
/// ```
library;

import 'package:bmflutter/src/design/typography/app_font_weight.dart';
import 'package:bmflutter/src/helpers/device_helper.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// FontKey (sealed class)
/// ---------------------------------------------------------------------------
///
/// Represents a type-safe key for font families in the design system.
///
/// Purpose:
/// - Provides predefined font keys (`primary`, `secondary`) for common usage.
/// - Allows runtime custom font keys using `FontKey.custom('myFont')`.
/// - Ensures type safety and reduces errors compared to raw strings.
/// - Works seamlessly with [FontRegistry] and [FontHelper].
///
/// Usage:
/// ```dart
/// // Predefined fonts
/// final primaryKey = FontKey.primary;
/// final secondaryKey = FontKey.secondary;
///
/// // Custom font key
/// final customKey = FontKey.custom('brandX');
/// ```
abstract class FontKey {
  const FontKey._();

  /// Predefined primary font
  static const primary = _PredefinedKey._('primary');

  /// Predefined secondary font
  static const secondary = _PredefinedKey._('secondary');

  /// Custom font key for runtime fonts
  factory FontKey.custom(String key) = _CustomKey;

  /// Internal string representation of the key
  String get key;
}

/// Private class for predefined keys
class _PredefinedKey extends FontKey {
  final String _key;
  const _PredefinedKey._(this._key) : super._();
  @override
  String get key => _key;
}

/// Private class for custom keys
class _CustomKey extends FontKey {
  final String _key;
  _CustomKey(this._key) : super._();
  @override
  String get key => _key;
}

/// ---------------------------------------------------------------------------
/// FontRegistry
/// ---------------------------------------------------------------------------
///
/// Centralized registry for managing multiple font families in a Flutter
/// design system package.
///
/// Purpose:
/// - Allows any host project to "register" one or more font families by key.
/// - Ensures that [FontHelper] can access the correct font at runtime
///   without hardcoding font names in the package.
/// - Fully reusable in multi-brand, multi-client, or white-label applications.
///
/// Features:
/// - Supports registering multiple fonts using [FontKey] (predefined or custom).
/// - Throws a descriptive exception if a requested font key is not registered,
///   preventing silent fallback to the system font.
/// - Works seamlessly with [FontHelper], [AppTextStyles], and other typography
///   helpers to provide consistent, scalable, theme-driven text styling.
///
/// Usage:
/// ```dart
/// // Register fonts once at app startup
/// FontRegistry.instance.registerFont(FontKey.primary, 'Inter');
/// FontRegistry.instance.registerFont(FontKey.secondary, 'Roboto');
/// FontRegistry.instance.registerFont(FontKey.custom('brandX'), 'CustomFont');
///
/// // Retrieve a font in FontHelper or any typography helper
/// final primaryFont = FontRegistry.instance.getFont(FontKey.primary);
/// final secondaryFont = FontRegistry.instance.getFont(FontKey.secondary);
/// final brandXFont = FontRegistry.instance.getFont(FontKey.custom('brandX'));
/// ```
///
/// Notes:
/// - Designed for packages or libraries where font names cannot be hardcoded.
/// - Enables consistent typography across all screens and widgets.
/// - Works with scaling, line height, and font weight abstractions when used
///   with [FontHelper].
class FontRegistry {
  FontRegistry._();
  static final FontRegistry instance = FontRegistry._();

  final Map<String, String> _fonts = {}; // key string → font family

  /// Register a font family with a [FontKey]
  void registerFont(FontKey key, String fontFamily) {
    _fonts[key.key] = fontFamily;
  }

  /// Retrieve a font family by [FontKey]
  String getFont(FontKey key) {
    final font = _fonts[key.key];
    if (font == null) {
      throw Exception('Font for key "${key.key}" is not registered!');
    }
    return font;
  }
}

/// ---------------------------------------------------------------------------
/// Font Helper
/// ---------------------------------------------------------------------------
///
/// Centralized helper for creating TextStyle objects that:
/// - Automatically scale with screen size
/// - Resolve font family from AppTypography
/// - Convert custom font weight abstractions to Flutter FontWeight
/// - Optionally apply line height (line spacing)
///
/// ⚠️ Important:
/// `inherit: false` is intentionally used to prevent DefaultTextStyle
/// or Theme text styles from overriding design-system decisions.
///
class FontHelper {
  /// Creates a scaled, theme-aware TextStyle.
  ///
  /// Parameters:
  /// - [context]: BuildContext used to resolve theme and device size
  /// - [size]: Base font size in logical pixels (default: 14)
  /// - [weight]: Font weight abstraction (default: regular / 400)
  /// - [color]: Text color (default: Colors.black)
  /// - [lineHeight]:
  ///   Line height multiplier relative to font size.
  ///   Examples:
  ///   - 1.2 → tight
  ///   - 1.4 → normal (recommended for body text)
  ///   - 1.6 → relaxed / descriptive text
  ///
  /// Notes:
  /// - Line height is **not scaled manually**
  /// - It scales naturally with font size
  /// - `null` preserves Flutter default behavior
  ///
  static TextStyle style({
    required BuildContext context,
    double size = 14,
    FontWeightProtocol weight = const _DefaultFontWeight(),
    Color color = Colors.black,
    double? lineHeight,
    FontKey fontKey = FontKey.primary,
  }) {
    // -----------------------------------------------------------------------
    // Responsive scaling
    // -----------------------------------------------------------------------
    final scale = DeviceHelper.getScalingFactor(context);
    final scaledSize = size * scale;

    // -----------------------------------------------------------------------
    // Convert abstract font weight → Flutter FontWeight
    //
    // FontWeight.values index mapping:
    // w100 → 0, w200 → 1, ... w900 → 8
    // -----------------------------------------------------------------------
    final fontWeightIndex = (weight.weightValue ~/ 100) - 1;
    final fontWeight = FontWeight
        .values[fontWeightIndex.clamp(0, FontWeight.values.length - 1)];

    // -----------------------------------------------------------------------
    // Resolve font family from typography theme extension
    // -----------------------------------------------------------------------
    final fontFamily = FontRegistry.instance.getFont(fontKey);

    return TextStyle(
      inherit: true, // Allows theme/default overrides and safer merging
      fontFamily: fontFamily,
      fontSize: scaledSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight == null
          ? null
          : lineHeight * scale, // 👈 line spacing support
    );
  }
}

/// ---------------------------------------------------------------------------
/// Default Font Weight
/// ---------------------------------------------------------------------------
///
/// Fallback implementation of [FontWeightProtocol].
/// Represents "Regular" weight (400).
///
class _DefaultFontWeight implements FontWeightProtocol {
  const _DefaultFontWeight();

  @override
  int get weightValue => 400;
}
