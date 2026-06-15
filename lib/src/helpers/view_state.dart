import 'package:flutter/material.dart';

sealed class ViewState {
  const ViewState();

  bool get isError;

  static const loading = Loading();
  static const overlayLoading = OverlayLoading();
  static const loaded = Loaded();
  static const noNetwork = NoNetwork();
  static const noData = NoData();
  static const serverError = ServerError();
  static const unexpectedError = UnexpectedError();
  static const unauthorized = Unauthorized();
  static const forceUpdate = ForceUpdateError();
  static const jailBroken = JailBroken();
  static const searchError = SearchError();
  static const customError = CustomErrorState();
}

// Non-error states
final class Loading extends ViewState {
  const Loading();
  @override
  bool get isError => false;
}

final class OverlayLoading extends ViewState {
  const OverlayLoading();
  Color get color => Colors.transparent;
  @override
  bool get isError => false;
}

final class Loaded extends ViewState {
  const Loaded();
  @override
  bool get isError => false;
}

// Error states
final class NoNetwork extends ViewState {
  final dynamic errorModel;
  const NoNetwork({this.errorModel});
  @override
  bool get isError => true;
}

final class NoData extends ViewState {
  final dynamic errorModel;
  const NoData({this.errorModel});
  @override
  bool get isError => true;
}

final class ServerError extends ViewState {
  final dynamic errorModel;
  const ServerError({this.errorModel});
  @override
  bool get isError => true;
}

final class UnexpectedError extends ViewState {
  final dynamic errorModel;
  const UnexpectedError({this.errorModel});
  @override
  bool get isError => true;
}

final class Unauthorized extends ViewState {
  final dynamic errorModel;
  const Unauthorized({this.errorModel});
  @override
  bool get isError => true;
}

final class CustomErrorState extends ViewState {
  final String? title;
  final String? message;
  final String? image;
  final String? buttonText;
  final VoidCallback? onPressed;
  final String secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final dynamic errorModel;
  const CustomErrorState(
      {this.title = '',
      this.message = '',
      this.image = '',
      this.buttonText = '',
      this.onPressed,
      this.secondaryButtonText = '',
      this.onSecondaryPressed,
      this.errorModel});
  @override
  bool get isError => true;
}

final class SearchError extends ViewState {
  final dynamic errorModel;
  const SearchError({this.errorModel});
  @override
  bool get isError => true;
}

final class ForceUpdateError extends ViewState {
  final dynamic errorModel;
  const ForceUpdateError({this.errorModel});
  @override
  bool get isError => true;
}

final class JailBroken extends ViewState {
  final dynamic errorModel;
  const JailBroken({this.errorModel});
  @override
  bool get isError => true;
}
