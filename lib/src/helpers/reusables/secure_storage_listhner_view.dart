import 'package:bmflutter/core.dart';
import 'package:flutter/material.dart';

typedef SecureStorageWidgetBuilder<T> =
    Widget Function(BuildContext context, T value);

class SecureStorageListener<T extends SecureStorable> extends StatelessWidget {
  final String keyName;
  final SecureStorageWidgetBuilder<T> builder;
  final Widget? fallback;

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

        // Automatically call T.fromJson
        final T value = (T as dynamic).fromJson(
          rawValue as Map<String, dynamic>,
        );

        return builder(context, value);
      },
    );
  }
}
