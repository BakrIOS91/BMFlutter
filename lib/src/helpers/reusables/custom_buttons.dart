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
    Color? textColor,
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
    Color? textColor,
    double height = 50,
    double horizontalPadding = 20,
  }) {
    final double scale = DeviceHelper.getScalingFactor(context);

    return SizedBox(
      width: double.infinity,
      height: height * scale,
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
        borderRadius: BorderRadius.circular(12 * scale),
        color: Colors.transparent,
        onPressed: onPressed,
        child: Text(title, style: titleStyle),
      ),
    );
  }
}
