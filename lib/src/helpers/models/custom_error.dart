import 'package:flutter/material.dart';

class CustomError {
  final Image errorImage;
  final String errorTitle;
  final String errorMessage;
  final String? buttonTitle;
  final VoidCallback? retryAction;

  const CustomError({
    required this.errorImage,
    required this.errorTitle,
    required this.errorMessage,
    this.buttonTitle,
    this.retryAction,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomError && other.buttonTitle == buttonTitle;
  }

  @override
  int get hashCode => buttonTitle.hashCode;
}
