/// Font Helper for BMFlutter Design System
/// 
/// This file provides a centralized font styling system that automatically
/// scales fonts based on device screen size and provides consistent typography
/// across the application. It integrates with the device helper to ensure
/// responsive design and supports custom font weights through the FontWeightProtocol.
/// 
/// The helper automatically scales font sizes based on screen width to maintain
/// consistent visual hierarchy across different device sizes, from phones to tablets.
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
///   ),
/// )
/// ```

import 'package:flutter/material.dart';
import 'package:bmflutter/src/helpers/device_helper.dart';
import 'package:bmflutter/src/design/typography/app_font_weight.dart';

/// Centralized font styling helper for consistent typography across the app
/// 
/// This class provides static methods for creating TextStyle objects with
/// automatic scaling, custom font weights, and consistent styling options.
/// It ensures that typography remains consistent and responsive across all
/// device sizes and orientations.
class FontHelper {
  /// Creates a TextStyle with automatic scaling and custom properties
  /// 
  /// This method creates a TextStyle that automatically scales based on the
  /// device screen size, ensuring consistent visual hierarchy across devices.
  /// The scaling factor is calculated using the DeviceHelper to maintain
  /// proportional sizing.
  /// 
  /// Parameters:
  /// - [context]: BuildContext for accessing screen dimensions
  /// - [size]: Base font size in logical pixels (default: 14)
  /// - [weight]: Font weight protocol implementation (default: regular)
  /// - [color]: Text color (default: black)
  /// - [fontFamily]: Font family name (default: 'Cairo')
  /// 
  /// Returns a TextStyle with applied scaling and properties
  static TextStyle style({
    required BuildContext context,
    double size = 14,
    FontWeightProtocol weight = const _DefaultFontWeight(), // placeholder
    Color color = Colors.black,
    String fontFamily = 'Cairo',
  }) {
    // Get device-specific scaling factor for responsive design
    final scale = DeviceHelper.getScalingFactor(context);
    
    // Calculate scaled font size
    final scaledSize = size * scale;
    
    // Convert protocol weight to Flutter FontWeight
    // FontWeight.values array: [w100, w200, w300, w400, w500, w600, w700, w800, w900]
    // Index calculation: (weightValue / 100) - 1
    final fontWeightIndex = (weight.weightValue ~/ 100) - 1;
    final fontWeight = FontWeight.values[fontWeightIndex.clamp(0, 8)];
    
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: scaledSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

/// Default font weight implementation (Regular - 400)
/// 
/// This is a private implementation of FontWeightProtocol that provides
/// the default regular font weight (400). It's used as a fallback when
/// no specific weight is provided to the FontHelper.style method.
class _DefaultFontWeight implements FontWeightProtocol {
  const _DefaultFontWeight();
  
  /// Returns the default weight value of 400 (Regular)
  @override
  int get weightValue => 400;
}