import 'package:bmflutter/core.dart';
import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String title;
  final TextStyle? titleStyle;
  final String message;
  final TextStyle? messageStyle;
  final String? buttonTitle;
  final VoidCallback? retryAction;
  final Image image;

  const ErrorView({
    super.key,
    required this.title,
    this.titleStyle,
    required this.message,
    this.messageStyle,
    this.buttonTitle,
    this.retryAction,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    final double scale = DeviceHelper.getScalingFactor(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              image,
              _sizedBox(context, 20),
              Text(title, style: titleStyle, textAlign: TextAlign.center),
              _sizedBox(context, 8),
              Padding(
                padding: EdgeInsets.fromLTRB(8.0 * scale, 0, 8.0 * scale, 0),
                child: Text(
                  message,
                  style: messageStyle,
                  textAlign: TextAlign.center,
                ),
              ),
              if (buttonTitle != null && retryAction != null) ...[
                _sizedBox(context, 20),
                AppCupertinoButton.filled(
                  context: context,
                  title: buttonTitle ?? "",
                  onPressed: retryAction,
                ),
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
