import 'package:bm_flutter/core.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatefulWidget {
  final String title;
  final TextStyle? titleStyle;
  final String message;
  final TextStyle? messageStyle;
  final String? buttonTitle;
  final VoidCallback? retryAction;
  final Image image;
  final Widget? retryButton;
  final Color? backgroundColor; // New parameter for background color
  final Decoration? backgroundDecoration; // New parameter for custom decoration

  /// Moves focus to [retryButton] when the view appears. Use on TV, where
  /// there is no pointer to tap the button.
  final bool autofocusRetry;

  const ErrorView({
    super.key,
    required this.title,
    this.titleStyle,
    required this.message,
    this.messageStyle,
    this.buttonTitle,
    this.retryAction,
    required this.image,
    this.retryButton,
    this.backgroundColor,
    this.backgroundDecoration,
    this.autofocusRetry = false,
  });

  @override
  State<ErrorView> createState() => _ErrorViewState();
}

class _ErrorViewState extends State<ErrorView> {
  final FocusNode _retryScope = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    if (widget.autofocusRetry) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        for (final node in _retryScope.traversalDescendants) {
          if (node.canRequestFocus) {
            node.requestFocus();
            return;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _retryScope.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale = DeviceHelper.getScalingFactor(context);
    return Container(
      // Using Container instead of Scaffold for background support
      decoration: widget.backgroundDecoration ??
          BoxDecoration(
            color: widget.backgroundColor ?? Colors.white, // Default background
          ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.image,
              _sizedBox(context, 20),
              Text(widget.title,
                  style: widget.titleStyle, textAlign: TextAlign.center),
              _sizedBox(context, 8),
              Padding(
                padding: EdgeInsets.fromLTRB(8.0 * scale, 0, 8.0 * scale, 0),
                child: Text(
                  widget.message,
                  style: widget.messageStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              if (widget.buttonTitle != null &&
                  widget.retryAction != null &&
                  widget.retryButton != null) ...[
                _sizedBox(context, 20),
                Focus(focusNode: _retryScope, child: widget.retryButton!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _sizedBox(BuildContext context, double size) {
    final double scale = DeviceHelper.getScalingFactor(context);
    return SizedBox(height: size * scale);
  }
}
