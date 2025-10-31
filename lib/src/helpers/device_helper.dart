/// Device Helper for BMFlutter Design System
///
/// This file provides device-specific utilities for responsive design,
/// particularly for calculating scaling factors based on screen dimensions.
/// It ensures that UI elements scale appropriately across different device
/// sizes while maintaining readability and usability.
///
/// The helper uses a reference width approach to calculate scaling factors,
/// ensuring consistent visual hierarchy across phones, tablets, and other devices.
///
/// Usage:
/// ```dart
/// final scale = DeviceHelper.getScalingFactor(context);
/// final scaledFontSize = baseFontSize * scale;
/// ```
library;

import 'package:flutter/material.dart';

/// Device-specific utilities for responsive design
///
/// This class provides static methods for calculating device-specific
/// scaling factors and other device-related utilities. It helps maintain
/// consistent UI proportions across different screen sizes and orientations.
class DeviceHelper {
  /// Returns a scaling factor relative to baseline width
  ///
  /// This method calculates a scaling factor based on the current device's
  /// screen width compared to a reference width. The scaling factor is used
  /// to adjust font sizes, spacing, and other UI elements to maintain
  /// consistent visual hierarchy across different device sizes.
  ///
  /// The reference width is set to 440.0 logical pixels (similar to iPhone 16 Pro Max),
  /// which serves as the baseline for scaling calculations. The scaling factor
  /// is clamped between 0.9 and 1.1 to prevent extreme scaling that could
  /// affect readability.
  ///
  /// Parameters:
  /// - [context]: BuildContext for accessing MediaQuery
  ///
  /// Returns a double scaling factor between 0.9 and 1.1
  static double getScalingFactor(BuildContext context) {
    // Get current screen width from MediaQuery
    final screenWidth = MediaQuery.of(context).size.width;

    // Reference width (can adjust for different baselines)
    // This represents the baseline device width for scaling calculations
    const referenceWidth = 440.0; // like iPhone 16 Pro Max

    // Calculate raw scaling factor
    double scale = screenWidth / referenceWidth;

    // Limit max scale for readability
    // Prevents extreme scaling that could make text too small or too large
    return scale.clamp(0.9, 1.1);
  }
}
