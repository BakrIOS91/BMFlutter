import 'package:bmflutter/core.dart';
import 'package:flutter/material.dart';

/// A widget that listens for changes in secure storage and rebuilds
/// whenever the value for [keyName] is updated.
///
/// This widget works with any stored value, including models, strings,
/// or other types directly stored in [SecureStorageService].
///
/// Example usage:
/// ```dart
/// SecureStorageListener<LoginModel>(
///   keyName: AppConstants.kAppLoginModel,
///   builder: (context, loginModel) {
///     return Text("Hello, ${loginModel.userName}");
///   },
///   fallback: const Text("No user found"),
/// );
/// ```
///
/// - `keyName`: The key in secure storage to listen for.
/// - `builder`: Called whenever the value changes, passing the stored model.
/// - `fallback`: Optional widget to show when the value is null.
typedef SecureStorageWidgetBuilder<T> =
    Widget Function(BuildContext context, T value);

class SecureStorageListener<T> extends StatelessWidget {
  /// The key in secure storage to listen for changes.
  final String keyName;

  /// Builder function called with the value of type [T].
  final SecureStorageWidgetBuilder<T> builder;

  /// Optional widget to display if the key does not exist or is null.
  final Widget? fallback;

  /// Creates a SecureStorageListener.
  const SecureStorageListener({
    super.key,
    required this.keyName,
    required this.builder,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: SecureStorageService.instance.values,
      builder: (context, values, _) {
        final dynamic rawValue = values[keyName];

        if (rawValue == null) return fallback ?? const SizedBox.shrink();

        // Cast stored value directly to T (no fromJson needed)
        final T value = rawValue as T;

        return builder(context, value);
      },
    );
  }
}
