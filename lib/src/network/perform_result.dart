/// Result-Based Network Operations for BMFlutter Network Layer
///
/// This file provides result-based network operation extensions that return
/// Result types instead of throwing exceptions. This approach provides a
/// more functional programming style for error handling and makes it easier
/// to handle network errors in a type-safe manner.
///
/// The extensions support both model-based requests and success-only requests,
/// along with file download operations, all returning Result types for
/// comprehensive error handling.
///
/// Usage:
/// ```dart
/// // For model-based requests with result handling
/// final result = await userRequest.performResult<User>();
/// result.when(
///   success: (user) => print('User: $user'),
///   failure: (error) => print('Error: $error'),
/// );
///
/// // For success-only requests
/// final result = await deleteRequest.performResult();
/// if (result.isSuccess) {
///   print('Delete successful');
/// }
/// ```
library;

import 'package:bmflutter/src/helpers/enums.dart';
import 'package:bmflutter/src/helpers/models/downloaded_file.dart';
import 'package:bmflutter/src/helpers/network/network_response.dart';
import 'package:bmflutter/src/helpers/network/result.dart';
import 'package:bmflutter/src/network/perform_async.dart';
import 'package:bmflutter/src/network/target_request.dart';

/// Provides a convenient method to perform a request returning a `Result<Response, APIError>`
///
/// This extension provides result-based network operations for ModelTargetType requests.
/// Instead of throwing exceptions, it returns Result types that can be handled
/// functionally using pattern matching or the when() method.
extension PerformResultModelTargetType on ModelTargetType {
  /// Performs a network request and returns a Result type for functional error handling
  ///
  /// This method executes a network request and wraps the result in a Result type,
  /// providing a functional approach to error handling. It catches all exceptions
  /// and converts them to appropriate Result types.
  ///
  /// Generic type [Response] represents the expected response model type
  ///
  /// Returns a Result containing either the decoded response or an APIError
  Future<Result<Response, APIError>> performResult<Response>() async {
    try {
      // Perform async network request and decode response
      final response = await performAsync<Response>();
      return Success<Response, APIError>(response);
    } on APIError catch (error) {
      // Catch known APIError types
      return Failure<Response, APIError>(error);
    } catch (_) {
      // Catch unexpected runtime errors
      return Failure<Response, APIError>(
        APIError(
          APIErrorType.httpError,
          statusCode: HTTPStatusCode.clientError,
        ),
      );
    }
  }

  /// Performs a network request and returns a Result with cookies/headers
  ///
  /// This method wraps [performAsyncWithCookies] in a Result for functional
  /// error handling.
  Future<Result<NetworkResponse<Response>, APIError>>
      performResultWithCookies<Response>() async {
    try {
      final response = await performAsyncWithCookies<Response>();
      return Success<NetworkResponse<Response>, APIError>(response);
    } on APIError catch (error) {
      return Failure<NetworkResponse<Response>, APIError>(error);
    } catch (_) {
      return Failure<NetworkResponse<Response>, APIError>(
        APIError(
          APIErrorType.httpError,
          statusCode: HTTPStatusCode.clientError,
        ),
      );
    }
  }

  /// Performs a file download and returns a Result type for functional error handling
  ///
  /// This method executes a file download operation and wraps the result in a Result type,
  /// providing a functional approach to error handling for download operations.
  /// It catches all exceptions and converts them to appropriate Result types.
  ///
  /// Returns a Result containing either the DownloadedFile or an APIError
  Future<Result<DownloadedFile?, APIError>> performDownloadResult() async {
    try {
      final result = await performDownload();
      return Success<DownloadedFile?, APIError>(result);
    } on APIError catch (error) {
      return Failure<DownloadedFile?, APIError>(error);
    } catch (_) {
      return Failure<DownloadedFile?, APIError>(
        APIError(
          APIErrorType.httpError,
          statusCode: HTTPStatusCode.clientError,
        ),
      );
    }
  }
}

/// Provides a convenient method to perform a request returning a `Result<void, APIError>`
///
/// This extension provides result-based network operations for SuccessTargetType requests.
/// It's designed for operations that don't need to decode response data, such as
/// DELETE, PUT, or POST operations that only return status codes.
extension PerformResultSuccessTargetType on SuccessTargetType {
  /// Performs a success-only network request and returns a Result type
  ///
  /// This method executes a network request for operations that don't need
  /// response data decoding. It wraps the result in a Result type for
  /// functional error handling.
  ///
  /// Returns a Result containing either void (success) or an APIError
  Future<Result<void, APIError>> performResult() async {
    try {
      await performAsync();
      return const Success<void, APIError>(null);
    } on APIError catch (error) {
      return Failure<void, APIError>(error);
    } catch (_) {
      return Failure<void, APIError>(
        APIError(
          APIErrorType.httpError,
          statusCode: HTTPStatusCode.clientError,
        ),
      );
    }
  }
}
