import 'package:bmflutter/core.dart';
import 'package:flutter/material.dart';

typedef SecureStorageWidgetBuilder<T> =
    Widget Function(BuildContext context, T value);

class SecureStorageListener<T> extends StatelessWidget {
  final String keyName;
  final T Function(Map<String, dynamic> json) fromJson; // <- required
  final SecureStorageWidgetBuilder<T> builder;
  final Widget? fallback;

  const SecureStorageListener({
    super.key,
    required this.keyName,
    required this.fromJson,
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

        final T value = fromJson(rawValue as Map<String, dynamic>);

        return builder(context, value);
      },
    );
  }
}
