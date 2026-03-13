import 'enums.dart';

/// Enum representing API error categories for comprehensive error handling
///
/// This enum defines all possible error types that can occur during
/// core operations. Each error type has a specific meaning and
/// corresponding error message for better debugging and user feedback.
enum APIErrorType {
  /// Invalid URL formation or parsing error
  invalidURL,

  /// Failed to convert data to expected format
  dataConversionFailed,

  /// Failed to convert string data
  stringConversionFailed,

  /// HTTP protocol error with status code
  httpError,

  /// Invalid SOAP multipart request format
  invalidSoapMultipartRequest,

  /// XML encoding/decoding failure
  xmlEncodingFailed,

  /// SOAP operation not supported by the system
  notSupportedSOAPOperation,

  /// No internet connection available
  noNetwork,

  /// Invalid or malformed response from server
  invalidResponse,
}

/// Represents different types of core-related errors with detailed information
///
/// This class provides a comprehensive error handling system for core operations.
/// It includes the error type, optional status code, and human-readable error messages.
/// The class implements the Exception interface for proper error propagation.
class APIError implements Exception {
  /// The type of error that occurred
  final APIErrorType type;

  /// Optional HTTP status code associated with the error
  final HTTPStatusCode? statusCode;

  /// Creates a new APIError instance
  ///
  /// Parameters:
  /// - [type]: The type of error that occurred
  /// - [statusCode]: Optional HTTP status code (default: null)
  const APIError(this.type, {this.statusCode});

  /// Returns a human-readable error message
  ///
  /// This method provides descriptive error messages for each error type,
  /// making it easier to debug issues and provide user feedback.
  @override
  String toString() {
    switch (type) {
      case APIErrorType.invalidURL:
        return 'Invalid URL formation.';
      case APIErrorType.dataConversionFailed:
        return 'Failed to convert data.';
      case APIErrorType.stringConversionFailed:
        return 'Failed to convert string.';
      case APIErrorType.httpError:
        return 'HTTP Error with status code: $statusCode';
      case APIErrorType.invalidSoapMultipartRequest:
        return 'Invalid SOAP multipart request.';
      case APIErrorType.xmlEncodingFailed:
        return 'XML encoding failed.';
      case APIErrorType.notSupportedSOAPOperation:
        return 'SOAP operation not supported.';
      case APIErrorType.noNetwork:
        return 'No internet connection.';
      case APIErrorType.invalidResponse:
        return 'Invalid response.';
    }
  }
}
