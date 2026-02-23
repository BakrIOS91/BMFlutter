import 'di_enums.dart';

/// Manages the current active DIEnvironment for your app.
///
/// Example:
/// ```dart
/// void main() {
///   ProviderConfig.init(DIEnvironment.live);
///   runApp(ProviderScope(child: MyApp()));
/// }
/// ```
final class ProviderConfig {
  ProviderConfig._();

  static late DIEnvironment _current;

  /// Initialize the current environment
  static void init(DIEnvironment env) {
    _current = env;
  }

  /// Get the current environment
  static DIEnvironment get current => _current;

  /// Check if a specific environment is active
  static bool isCurrent(DIEnvironment env) => _current == env;
}
