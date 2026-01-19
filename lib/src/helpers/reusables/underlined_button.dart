import 'package:bmflutter/core.dart';
import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// UnderlinedButton
/// ---------------------------------------------------------------------------
///
/// A lightweight text button that:
/// - Displays underlined text
/// - Accepts a full [TextStyle] for maximum flexibility
/// - Defaults to design-system typography via [FontHelper]
/// - Has no background or elevation
///
/// Recommended use cases:
/// - Inline actions (Retry, Learn more, Edit)
/// - Secondary CTAs
/// - Text links inside alerts or bottom sheets
///
class UnderlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  /// Optional text style override.
  ///
  /// If not provided, a default style is created using [FontHelper].
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

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        title,
        style: (style ?? defaultStyle).copyWith(
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
