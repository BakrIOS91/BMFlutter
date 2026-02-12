import 'package:bmflutter/core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// UnderlinedButton (iOS style)
/// ---------------------------------------------------------------------------
///
/// A lightweight underlined text button with:
/// - iOS-style tap feedback (opacity)
/// - No splash/ripple
/// - Accepts full [TextStyle] override
/// - Defaults to design-system typography via [FontHelper]
///
class UnderlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  /// Optional text style override
  final TextStyle? style;

  const UnderlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = FontHelper.style(
      context: context,
      size: 14,
      color: Theme.of(context).colorScheme.primary,
    );

    return CupertinoButton(
      // iOS-style button
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      pressedOpacity: 0.3,
      minimumSize: Size(0, 0), // subtle fade when pressed
      child: Text(
        title,
        style: (style ?? defaultStyle).copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
