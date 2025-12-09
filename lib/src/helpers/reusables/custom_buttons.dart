import 'package:bmflutter/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Position for both label & icon
enum Position { leading, center, trailing }

class AppCupertinoButton {
  /// Filled iOS button (Primary actions)
  static Widget filled({
    required BuildContext context,
    required String title,
    required VoidCallback? onPressed,
    TextStyle? titleStyle,
    Color? backgroundColor,
    double height = 50,
    double horizontalPadding = 20,
    double? width,

    // New customization:
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    Position iconPosition = Position.leading,
    Position labelPosition = Position.center,
  }) {
    final scale = DeviceHelper.getScalingFactor(context);

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
          iconPosition: iconPosition,
          labelPosition: labelPosition,
        ),
      ),
    );
  }

  /// Outlined iOS button (Secondary actions)
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

    // New customization:
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    Position iconPosition = Position.leading,
    Position labelPosition = Position.center,
  }) {
    final scale = DeviceHelper.getScalingFactor(context);

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
        color: Colors.transparent,
        onPressed: onPressed,
        child: _buildContent(
          context: context,
          title: title,
          titleStyle: titleStyle,
          icon: icon,
          iconColor: iconColor,
          iconSize: iconSize,
          iconPosition: iconPosition,
          labelPosition: labelPosition,
        ),
      ),
    );
  }

  /// 👇 Handles spacing, icon alignment, full-clickable area
  static Widget _buildContent({
    required BuildContext context,
    required String title,
    required TextStyle? titleStyle,
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    Position iconPosition = Position.leading,
    Position labelPosition = Position.center,
  }) {
    final scale = DeviceHelper.getScalingFactor(context);

    final textWidget = Text(title, style: titleStyle);

    final iconWidget = icon != null
        ? Icon(
            icon,
            size: iconSize * scale,
            color: iconColor ?? titleStyle?.color,
          )
        : null;

    /// 🧠 Special case: Center icon & separate label alignment
    if (iconWidget != null && iconPosition == Position.center) {
      return SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: _toAlign(labelPosition),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                child: textWidget,
              ),
            ),
            iconWidget,
          ],
        ),
      );
    }

    /// Normal Row case
    List<Widget> rowChildren = [];

    if (iconPosition == Position.leading && iconWidget != null) {
      rowChildren.add(iconWidget);
    }

    rowChildren.add(textWidget);

    if (iconPosition == Position.trailing && iconWidget != null) {
      rowChildren.add(iconWidget);
    }

    return SizedBox.expand(
      child: Row(
        mainAxisAlignment: _mapPositionToAlignment(labelPosition),
        mainAxisSize: MainAxisSize.max,
        children: rowChildren
            .map(
              (e) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 4 * scale),
                child: e,
              ),
            )
            .toList(),
      ),
    );
  }

  /// Convert Position → Row Alignment
  static MainAxisAlignment _mapPositionToAlignment(Position pos) {
    switch (pos) {
      case Position.leading:
        return MainAxisAlignment.start;
      case Position.trailing:
        return MainAxisAlignment.end;
      case Position.center:
      default:
        return MainAxisAlignment.center;
    }
  }

  /// Convert Position → Stack Alignment
  static Alignment _toAlign(Position pos) {
    switch (pos) {
      case Position.leading:
        return Alignment.centerLeft;
      case Position.trailing:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }
}
