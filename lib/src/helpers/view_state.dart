import 'package:flutter/material.dart';
import 'api_error.dart';
import 'enums.dart';
import 'models/custom_error.dart';

/// ViewState
sealed class ViewState {
  const ViewState();

  /// Indicates whether this state represents an error
  bool get isError;

  /// Equivalent to Swift’s `static func failHandler`
  ///
  /// Converts an [APIError] into a corresponding [ViewState].
  static ViewState failHandler(APIError apiError) {
    switch (apiError.type) {
      case APIErrorType.invalidURL:
      case APIErrorType.dataConversionFailed:
      case APIErrorType.stringConversionFailed:
      case APIErrorType.invalidSoapMultipartRequest:
      case APIErrorType.xmlEncodingFailed:
      case APIErrorType.notSupportedSOAPOperation:
      case APIErrorType.invalidResponse:
        return unexpectedError;

      case APIErrorType.noNetwork:
        return noNetwork;

      case APIErrorType.httpError:
        final status = apiError.statusCode;
        switch (status) {
          case HTTPStatusCode.notAuthorize:
            return unauthorized;
          case HTTPStatusCode.notFound:
            return const NoData();
          case HTTPStatusCode.serverError:
            return serverError;
          default:
            return unexpectedError;
        }
    }
  }

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
  const NoNetwork();
  @override
  bool get isError => true;
}

final class NoData extends ViewState {
  const NoData();
  @override
  bool get isError => true;
}

final class ServerError extends ViewState {
  const ServerError();
  @override
  bool get isError => true;
}

final class UnexpectedError extends ViewState {
  const UnexpectedError();
  @override
  bool get isError => true;
}

final class Unauthorized extends ViewState {
  const Unauthorized();
  @override
  bool get isError => true;
}

final class CustomState extends ViewState {
  final CustomError error;
  const CustomState(this.error);
  @override
  bool get isError => true;
}

final class SearchError extends ViewState {
  const SearchError();
  @override
  bool get isError => true;
}

final class ForceUpdateError extends ViewState {
  const ForceUpdateError();
  @override
  bool get isError => true;
}

final class JailBroken extends ViewState {
  const JailBroken();
  @override
  bool get isError => true;
}
