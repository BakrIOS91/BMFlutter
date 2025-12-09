import 'package:bmflutter/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppCupertinoButton {
  /// Filled iOS button (like primary action buttons in iOS)
  static Widget filled({
    required BuildContext context,
    required String title,
    required VoidCallback? onPressed,
    TextStyle? titleStyle,
    Color? backgroundColor,
    double height = 50,
    double horizontalPadding = 20,
    double? width, // 👈 added
  }) {
    final double scale = DeviceHelper.getScalingFactor(context);

    return SizedBox(
      width: width != null ? width * scale : double.infinity,
      height: height * scale,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12 * scale),
        onPressed: onPressed,
        child: Text(title, style: titleStyle),
      ),
    );
  }

  /// Outlined iOS button (like secondary actions)
  static Widget outlined({
    required BuildContext context,
    required String title,
    required VoidCallback? onPressed,
    TextStyle? titleStyle,
    Color? borderColor,
    Color? backgroundColor,
    double backgroundOpacity = 0.0,
    double height = 50,
    double horizontalPadding = 20,
    double? width,
    double borderRadius = 12,
    double borderWidth = 1.5,
  }) {
    final double scale = DeviceHelper.getScalingFactor(context);

    return SizedBox(
      width: width != null ? width * scale : double.infinity,
      height: height * scale,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
        color:
            backgroundColor?.withOpacity(backgroundOpacity) ??
            Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius * scale),
        onPressed: onPressed,
        child: Text(title, style: titleStyle),
      ),
    ).decorated(
      border: Border.all(
        color: borderColor ?? Colors.black,
        width: borderWidth * scale,
      ),
      borderRadius: BorderRadius.circular(borderRadius * scale),
    );
  }
}

extension _Decorated on Widget {
  /// Helper to wrap a widget with a BoxDecoration
  Widget decorated({Color? color, Border? border, BorderRadius? borderRadius}) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: border,
        borderRadius: borderRadius,
      ),
      child: this,
    );
  }
}
