/// Enums and Constants for BMFlutter Network Layer
///
/// This file contains all the enumerations, constants, and error types used
/// throughout the BMFlutter network layer. It provides type-safe definitions
/// for HTTP methods, status codes, request types, error categories, and
/// multipart form data handling.
///
/// The enums are designed to be comprehensive and cover all common network
/// scenarios, from basic HTTP requests to complex file uploads and downloads.
/// Error handling is built into the enums with descriptive error messages
/// and proper categorization.
///
/// Usage:
/// ```dart
/// final method = HTTPMethod.post;
/// final status = HTTPStatusCode.from(200);
/// final error = APIError(APIErrorType.noNetwork);
/// ```
library;

import 'dart:typed_data';

/// Represents different app environments for configuration management
///
/// This enum defines the various deployment environments that the app
/// can run in, allowing for environment-specific configurations and
/// behaviors. Each environment can have different API endpoints,
/// logging levels, and feature flags.
enum AppEnvironment {
  /// Development environment for local development and testing
  development,

  /// Testing environment for automated tests and QA
  testing,

  /// Staging environment for pre-production testing
  staging,

  /// Pre-production environment for final testing before release
  preProduction,

  /// Production environment for live users
  production,
}

/// Represents the type of network request protocol
///
/// This enum defines the supported network request types, allowing the
/// system to handle different API protocols with appropriate configurations.
enum RequestType {
  /// REST API requests using standard HTTP methods
  rest,

  /// SOAP API requests using XML-based messaging
  soap,
}

/// Represents HTTP request methods as defined in RFC 7231
///
/// This enum provides type-safe HTTP method definitions that can be
/// easily converted to strings for use in HTTP requests. It covers
/// all standard HTTP methods including the most commonly used ones.
enum HTTPMethod {
  /// GET method for retrieving data
  get,

  /// POST method for creating new resources
  post,

  /// PUT method for updating existing resources
  put,

  /// DELETE method for removing resources
  delete,

  /// PATCH method for partial updates
  patch,

  /// HEAD method for retrieving headers only
  head,

  /// OPTIONS method for CORS preflight requests
  options,

  /// TRACE method for debugging
  trace,

  /// CONNECT method for tunneling
  connect,
}

/// Extension to get the string value for each HTTP method
///
/// This extension provides a convenient way to convert HTTPMethod enum
/// values to their string representations for use in HTTP requests.
extension HTTPMethodExtension on HTTPMethod {
  /// Returns the uppercase string representation of the HTTP method
  ///
  /// Example: HTTPMethod.post.value returns "POST"
  String get value => name.toUpperCase();
}

/// Base class for multipart form data types
///
/// This sealed class serves as the base for different types of multipart
/// form data that can be sent in HTTP requests. It uses the sealed class
/// pattern to ensure type safety and exhaustive pattern matching.
sealed class MultipartFormData {
  const MultipartFormData();
}

/// Multipart form data for binary file uploads
///
/// This class represents binary data that can be uploaded as part
/// of a multipart form request. It includes the file data, filename,
/// and MIME type for proper handling by the server.
class MultipartFormDataData extends MultipartFormData {
  /// The binary data of the file
  final Uint8List data;

  /// The name of the file
  final String fileName;

  /// The MIME type of the file (e.g., 'image/jpeg', 'application/pdf')
  final String mimeType;

  /// Creates a new MultipartFormDataData instance
  ///
  /// Parameters:
  /// - [data]: The binary data of the file
  /// - [fileName]: The name of the file
  /// - [mimeType]: The MIME type of the file
  const MultipartFormDataData({
    required this.data,
    required this.fileName,
    required this.mimeType,
  });
}

/// Multipart form data for text field uploads
///
/// This class represents text data that can be sent as part of a
/// multipart form request. It can handle any dynamic value that
/// can be converted to a string.
class MultipartFormDataText extends MultipartFormData {
  /// The text value to be sent
  final dynamic value;

  /// Creates a new MultipartFormDataText instance
  ///
  /// Parameters:
  /// - [value]: The text value to be sent (will be converted to string)
  const MultipartFormDataText(this.value);
}

/// Represents different types of network request tasks
///
/// This enum defines the various types of network operations that can be
/// performed, from simple requests to complex file uploads and downloads.
/// Each task type has specific handling logic in the network layer.
enum RequestTaskType {
  /// Plain request with no additional data
  plain,

  /// Request with URL parameters
  parameters,

  /// Request with JSON-encoded body
  encodedBody,

  /// File upload request
  uploadFile,

  /// Multipart form data upload
  uploadMultipart,

  /// File download request
  download,

  /// Resumable file download with offset support
  downloadResumable,
}

/// Represents HTTP status code categories for response handling
///
/// This enum categorizes HTTP status codes into logical groups for
/// easier handling and error management. It provides a factory method
/// to convert numeric status codes to their appropriate categories.
enum HTTPStatusCode {
  /// 1xx Informational responses
  information,

  /// 2xx Success responses
  success,

  /// 3xx Redirection responses
  redirection,

  /// 404 Not Found (specific common error)
  notFound,

  /// 401 Unauthorized (specific common error)
  notAuthorize,

  /// 4xx Client error responses
  clientError,

  /// 5xx Server error responses
  serverError,

  /// Unknown or unhandled status codes
  unknown;

  /// Factory method to create HTTPStatusCode from numeric status code
  ///
  /// This method analyzes the numeric status code and returns the
  /// appropriate HTTPStatusCode category for easier handling.
  ///
  /// Parameters:
  /// - [code]: The numeric HTTP status code
  ///
  /// Returns the corresponding HTTPStatusCode category
  static HTTPStatusCode from(int code) {
    // 1xx Informational responses
    if (code >= 100 && code < 200) return HTTPStatusCode.information;

    // 2xx Success responses
    if (code >= 200 && code < 300) return HTTPStatusCode.success;

    // 3xx Redirection responses
    if (code >= 300 && code < 400) return HTTPStatusCode.redirection;

    // Specific common error codes
    if (code == 401) return HTTPStatusCode.notAuthorize;
    if (code == 404) return HTTPStatusCode.notFound;

    // 4xx Client error responses
    if (code >= 400 && code < 500) return HTTPStatusCode.clientError;

    // 5xx Server error responses
    if (code >= 500 && code < 600) return HTTPStatusCode.serverError;

    // Unknown status codes
    return HTTPStatusCode.unknown;
  }
}

/// Enum representing API error categories for comprehensive error handling
///
/// This enum defines all possible error types that can occur during
/// network operations. Each error type has a specific meaning and
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

/// Represents different types of network-related errors with detailed information
///
/// This class provides a comprehensive error handling system for network operations.
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
