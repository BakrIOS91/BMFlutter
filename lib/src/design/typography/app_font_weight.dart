/// Font Weight Protocol for BMFlutter Design System
/// 
/// This file defines the abstract protocol for font weight types used throughout
/// the BMFlutter design system. It provides a standardized way to handle font
/// weights with numeric values that can be easily converted to Flutter's FontWeight.
/// 
/// The protocol ensures type safety and consistency across the design system,
/// allowing for easy extension and customization of font weights.
/// 
/// Usage:
/// ```dart
/// class CustomFontWeight implements FontWeightProtocol {
///   @override
///   int get weightValue => 600; // Semi-bold
/// }
/// ```

/// A protocol for font weight types used by FontHelper
/// 
/// This abstract class defines the contract for font weight implementations.
/// Any class implementing this protocol must provide a numeric weight value
/// that corresponds to standard font weight values (100-900).
abstract class FontWeightProtocol {
  /// Returns the numeric weight value (100-900)
  /// 
  /// Standard font weight values:
  /// - 100: Thin
  /// - 200: Extra Light
  /// - 300: Light
  /// - 400: Regular/Normal
  /// - 500: Medium
  /// - 600: Semi Bold
  /// - 700: Bold
  /// - 800: Extra Bold
  /// - 900: Black
  int get weightValue;
}