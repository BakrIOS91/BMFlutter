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

import 'package:bmflutter/src/design/typography/app_font_weight.dart';
import 'package:bmflutter/src/helpers/device_helper.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// Typography Theme Extension
/// ---------------------------------------------------------------------------
///
/// Defines typography tokens (e.g. font family) for the design system
/// without hard-coupling them to ThemeData.
///
/// Why ThemeExtension?
/// - Supports runtime updates
/// - Works with hot reload
/// - Scales for white-label / multi-client apps
/// - Keeps design tokens centralized
///
@immutable
class AppTypography extends ThemeExtension<AppTypography> {
  /// Primary font family used by the design system
  final String fontFamily;

  const AppTypography({required this.fontFamily});

  @override
  AppTypography copyWith({String? fontFamily}) {
    return AppTypography(fontFamily: fontFamily ?? this.fontFamily);
  }

  @override
  AppTypography lerp(ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    return AppTypography(fontFamily: fontFamily);
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
    final typography = Theme.of(context).extension<AppTypography>();
    final fontFamily = typography?.fontFamily;

    return TextStyle(
      inherit: false, // Prevents theme/default overrides
      fontFamily: fontFamily,
      fontSize: scaledSize,
      fontWeight: fontWeight,
      color: color,
      height: lineHeight, // 👈 line spacing support
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
