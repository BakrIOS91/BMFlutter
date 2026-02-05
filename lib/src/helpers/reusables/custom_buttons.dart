import 'package:bmflutter/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum Position { leading, center, trailing }

class AppCupertinoButton {
  /// =========================
  /// Filled Button
  /// =========================
  static Widget filled({
    required BuildContext context,
    required String title,
    required VoidCallback? onPressed,
    bool enabled = true,
    TextStyle? titleStyle,
    Color? backgroundColor,
    double height = 50,
    double horizontalPadding = 20,
    double? width,
    Color? shadowColor,
    double shadowBlurRadius = 0,
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    Position iconPosition = Position.leading,
    Position labelPosition = Position.center,
  }) {
    final scale = DeviceHelper.getScalingFactor(context);

    final effectiveBackground = enabled
        ? backgroundColor ?? Colors.white
        : Colors.grey.shade300;

    final effectiveTitleStyle = enabled
        ? titleStyle
        : titleStyle?.copyWith(color: Colors.grey);

    final effectiveIconColor = enabled
        ? iconColor ?? titleStyle?.color
        : Colors.grey;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12 * scale),
      color: Colors.transparent,
      onPressed: enabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.6,
        child: Container(
          width: width != null ? width * scale : double.infinity,
          height: height * scale,
          decoration: BoxDecoration(
            color: effectiveBackground,
            borderRadius: BorderRadius.circular(12 * scale),
            boxShadow: shadowBlurRadius > 0
                ? [
                    BoxShadow(
                      color:
                          shadowColor?.withValues(alpha: 0.3) ?? Colors.black26,
                      blurRadius: shadowBlurRadius * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : [],
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
          child: _buildContent(
            context: context,
            title: title,
            titleStyle: effectiveTitleStyle,
            icon: icon,
            iconColor: effectiveIconColor,
            iconSize: iconSize,
            iconPosition: iconPosition,
            labelPosition: labelPosition,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// Outlined Button
  /// =========================
  static Widget outlined({
    required BuildContext context,
    required String title,
    required VoidCallback? onPressed,
    bool enabled = true,
    TextStyle? titleStyle,
    Color? borderColor,
    Color? backgroundColor,
    double backgroundOpacity = 0.0,
    double height = 50,
    double horizontalPadding = 20,
    double? width,
    double borderRadius = 12,
    double borderWidth = 1.5,
    Color? shadowColor,
    double shadowBlurRadius = 0,
    IconData? icon,
    Color? iconColor,
    double iconSize = 22,
    Position iconPosition = Position.leading,
    Position labelPosition = Position.center,
  }) {
    final scale = DeviceHelper.getScalingFactor(context);

    final effectiveBorder = enabled
        ? borderColor ?? Colors.black
        : Colors.grey.shade400;

    final effectiveBackground = enabled
        ? backgroundColor?.withValues(alpha: backgroundOpacity)
        : Colors.grey.withValues(alpha: 0.1);

    final effectiveTitleStyle = enabled
        ? titleStyle
        : titleStyle?.copyWith(color: Colors.grey);

    final effectiveIconColor = enabled
        ? iconColor ?? titleStyle?.color
        : Colors.grey;

    return CupertinoButton(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(borderRadius * scale),
      color: Colors.transparent,
      onPressed: enabled ? onPressed : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.5,
        child: Container(
          width: width != null ? width * scale : double.infinity,
          height: height * scale,
          decoration: BoxDecoration(
            border: Border.all(
              color: effectiveBorder,
              width: borderWidth * scale,
            ),
            borderRadius: BorderRadius.circular(borderRadius * scale),
            color: effectiveBackground,
            boxShadow: shadowBlurRadius > 0
                ? [
                    BoxShadow(
                      color:
                          shadowColor?.withValues(alpha: 0.3) ?? Colors.black26,
                      blurRadius: shadowBlurRadius * scale,
                      offset: Offset(0, 2 * scale),
                    ),
                  ]
                : [],
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding * scale),
          child: _buildContent(
            context: context,
            title: title,
            titleStyle: effectiveTitleStyle,
            icon: icon,
            iconColor: effectiveIconColor,
            iconSize: iconSize,
            iconPosition: iconPosition,
            labelPosition: labelPosition,
          ),
        ),
      ),
    );
  }

  /// =========================
  /// Content Builder
  /// =========================
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

    if (iconWidget != null && iconPosition == Position.center) {
      return Stack(
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
      );
    }

    final children = <Widget>[];

    if (iconPosition == Position.leading && iconWidget != null) {
      children.add(iconWidget);
    }

    children.add(textWidget);

    if (iconPosition == Position.trailing && iconWidget != null) {
      children.add(iconWidget);
    }

    return Row(
      mainAxisAlignment: _mapPositionToAlignment(labelPosition),
      children: children
          .map(
            (e) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              child: e,
            ),
          )
          .toList(),
    );
  }

  static MainAxisAlignment _mapPositionToAlignment(Position pos) {
    switch (pos) {
      case Position.leading:
        return MainAxisAlignment.start;
      case Position.trailing:
        return MainAxisAlignment.end;
      case Position.center:
        return MainAxisAlignment.center;
    }
  }

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
