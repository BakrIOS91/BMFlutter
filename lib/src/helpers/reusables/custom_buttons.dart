import 'package:bmflutter/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum IconPosition { leading, center, trailing }

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
    double? width,

    // New:
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    IconPosition iconPosition = IconPosition.leading,
    MainAxisAlignment labelAlignment = MainAxisAlignment.center,
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
        child: _buildContent(
          context: context,
          title: title,
          titleStyle: titleStyle,
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
          labelAlignment: labelAlignment,
          iconPosition: iconPosition,
        ),
      ),
    );
  }

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

    // New:
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    IconPosition iconPosition = IconPosition.leading,
    MainAxisAlignment labelAlignment = MainAxisAlignment.center,
  }) {
    final double scale = DeviceHelper.getScalingFactor(context);

    return Container(
      width: width != null ? width * scale : double.infinity,
      height: height * scale,
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.black,
          width: borderWidth * scale,
        ),
        borderRadius: BorderRadius.circular(borderRadius * scale),
        color:
            backgroundColor?.withValues(alpha: backgroundOpacity) ??
            Colors.transparent,
      ),
      child: CupertinoButton(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
        borderRadius: BorderRadius.circular(borderRadius * scale),
        onPressed: onPressed,
        color: Colors.transparent,
        child: _buildContent(
          context: context,
          title: title,
          titleStyle: titleStyle,
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
          labelAlignment: labelAlignment,
          iconPosition: iconPosition,
        ),
      ),
    );
  }

  static Widget _buildContent({
    required BuildContext context,
    required String title,
    required TextStyle? titleStyle,
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    IconPosition iconPosition = IconPosition.leading,
    MainAxisAlignment labelAlignment = MainAxisAlignment.center,
  }) {
    final double scale = DeviceHelper.getScalingFactor(context);

    final textWidget = Text(title, style: titleStyle);
    final iconWidget = icon != null
        ? Icon(
            icon,
            size: iconSize * scale,
            color: iconColor ?? titleStyle?.color,
          )
        : null;

    List<Widget> children = [];

    switch (iconPosition) {
      case IconPosition.leading:
        if (iconWidget != null) children.add(iconWidget);
        children.add(textWidget);
        break;

      case IconPosition.center:
        children.add(textWidget);
        if (iconWidget != null) children.add(iconWidget);
        break;

      case IconPosition.trailing:
        children.add(textWidget);
        if (iconWidget != null) children.add(iconWidget);
        break;
    }

    return Row(
      mainAxisAlignment: labelAlignment,
      mainAxisSize: MainAxisSize.min,
      children: children
          .map(
            (e) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0 * scale),
              child: e,
            ),
          )
          .toList(),
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
