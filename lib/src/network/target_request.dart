/// Target Request Protocol for LDFlutter Network Layer
///
/// This file defines the TargetRequest abstract class that serves as the core
/// protocol for all core requests in the LDFlutter core layer. It provides
/// a standardized interface for configuring core requests with headers,
/// authentication, SSL pinning, and request tasks.
///
/// The protocol is inspired by Swift's TargetRequest pattern and provides
/// a type-safe way to define core endpoints with their associated
/// configuration. It supports both simple success-only requests and
/// model-based requests that return decoded data.
///
/// Usage:
/// ```dart
/// class UserAPIRequest extends ModelTargetType<User> {
///   @override
///   String get baseURL => 'https://api.example.com';
///
///   @override
///   String get requestPath => '/users';
///
///   @override
///   HTTPMethod get requestMethod => HTTPMethod.get;
/// }
/// ```
library;

import 'package:bmflutter/src/helpers/enums.dart';

import 'core/network_monitor.dart';
import 'core/request_task.dart';
import 'core/ssl_pinning.dart';

/// Defines the required properties for a target core request
///
/// This abstract class serves as the core protocol for all core requests,
/// providing a standardized interface for configuring core endpoints.
/// It's equivalent to Swift's TargetRequest protocol and ensures type safety
/// and consistency across all core operations.
abstract class TargetRequest {
  /// The type of request (REST or SOAP)
  ///
  /// This property defines the protocol type for the core request.
  /// Currently supports REST and SOAP protocols, with REST being the default.
  RequestType get requestType;

  /// The base URL for the request
  ///
  /// This property defines the base URL that will be used for the core request.
  /// It should include the protocol (http/https) and hostname, but not the specific
  /// endpoint path which is defined separately in requestPath.
  String get baseURL;

  /// The endpoint path to append to the base URL
  ///
  /// This property defines the specific API endpoint path that will be appended
  /// to the base URL. It should start with a forward slash and include any
  /// path parameters or query parameters as needed.
  String get requestPath;

  /// The HTTP method used for the request (GET, POST, etc.)
  ///
  /// This property defines the HTTP method that will be used for the request.
  /// Common methods include GET, POST, PUT, DELETE, PATCH, etc.
  HTTPMethod get requestMethod;

  /// The type of task or body for this request
  ///
  /// This property defines the specific task configuration for the request,
  /// including parameters, body data, file uploads, or download settings.
  RequestTask get requestTask;

  /// Whether this request carries authorization credentials.
  ///
  /// When `true`, a 401 response will trigger an automatic token refresh
  /// via [TokenRefreshRegistry] before propagating the error.
  ///
  /// Set this to `false` on the refresh-token endpoint itself to prevent
  /// an infinite refresh loop. Defaults to `true` in all concrete base types.
  bool get isAuthorized;

  /// Standard headers for the request
  ///
  /// This property defines the standard HTTP headers that will be included
  /// with the request. These headers are merged with auth headers and
  /// default headers to create the final header set.
  Map<String, String> get headers;

  /// Authorization-specific headers
  ///
  /// This property defines headers related to authentication and authorization,
  /// such as Authorization tokens, API keys, or other security-related headers.
  /// These headers are merged with standard headers and default headers.
  Map<String, String> get authHeaders;

  /// SSL Pinning configuration (optional)
  ///
  /// This property defines the SSL/TLS certificate pinning configuration
  /// for enhanced security. If null, no SSL pinning will be applied.
  ///
  /// Returns the SSL pinning configuration or null if not specified
  SSLPinningConfiguration? get sslPinningConfiguration;

  /// Whether to use a unique filename for downloads.
  ///
  /// When `true`, [performDownload] will prepend a unique identifier
  /// (timestamp + hashCode) to the filename to prevent overwrites.
  /// Defaults to `false`.
  bool get useUniqueFilename => false;

  /// Merged headers including defaults
  ///
  /// This computed property combines all headers in the correct order:
  /// 1. Default headers (lowest priority)
  /// 2. Standard headers (medium priority)
  /// 3. Auth headers (highest priority)
  ///
  /// This ensures that auth headers can override standard headers,
  /// and standard headers can override default headers.
  ///
  /// Returns a Map containing all merged headers
  Map<String, String> get mergedHeaders {
    // Combine standard and auth headers
    final combined = {...headers, ...authHeaders};

    // Merge with default headers (defaults have lowest priority)
    return {...defaultHeaders, ...combined};
  }

  /// Default headers applied to all requests
  ///
  /// This property defines the default HTTP headers that are applied
  /// to all core requests. These headers provide sensible defaults
  /// for content type and acceptance, but can be overridden by
  /// standard or auth headers.
  ///
  /// Returns a Map containing default headers
  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': '*/*',
      };

  /// Checks if the device is connected to the internet
  ///
  /// This static method provides a convenient way to check core
  /// connectivity before making requests. It uses the NetworkMonitor
  /// to determine if the device has an active internet connection.
  ///
  /// Returns true if connected to internet, false otherwise
  static Future<bool> get isConnectedToInternet async {
    return await NetworkMonitor.isConnected;
  }

  /// Returns a human-readable description of the request task
  ///
  /// This method provides a descriptive string representation of the
  /// current request task configuration. It's useful for logging,
  /// debugging, and monitoring core requests.
  ///
  /// Returns a descriptive string of the request task
  String get requestTaskDescription {
    switch (requestTask.type) {
      case RequestTaskType.plain:
        return 'Plain request';
      case RequestTaskType.parameters:
        return 'Parameters: ${requestTask.parameters}';
      case RequestTaskType.encodedBody:
        return 'Body: ${requestTask.body}';
      case RequestTaskType.uploadFile:
        return 'Upload file: ${requestTask.filePath}';
      case RequestTaskType.uploadMultipart:
        return 'Multipart fields: ${requestTask.fields?.keys.toList()}';
      case RequestTaskType.download:
        return 'Download from: ${requestTask.url}';
      case RequestTaskType.downloadResumable:
        return 'Resumable download with offset: ${requestTask.offset}';
    }
  }
}

/// Marker interface for simple "success-only" requests (no data decoding)
///
/// This abstract class provides a convenient base for requests that don't
/// need to decode response data. It's useful for operations like creating,
/// updating, or deleting resources where you only care about success/failure.
///
/// The class provides sensible defaults for all required properties,
/// making it easy to create simple core requests without extensive configuration.
abstract class SuccessTargetType extends TargetRequest {
  /// Always returns REST for success-only requests
  @override
  RequestType get requestType => RequestType.rest;

  /// Defaults to `false`
  /// itself to prevent an infinite refresh loop.
  @override
  bool get isAuthorized => false;

  /// Empty headers by default (can be overridden)
  @override
  Map<String, String> get headers => {};

  /// Empty auth headers by default (can be overridden)
  @override
  Map<String, String> get authHeaders => {};

  /// Plain request task by default (can be overridden)
  @override
  RequestTask get requestTask => RequestTask.plain();

  /// No SSL pinning by default (can be overridden)
  @override
  SSLPinningConfiguration? get sslPinningConfiguration => null;
}

/// Model-based request for decoding data into a models [T]
///
/// This abstract class provides a convenient base for requests that need
/// to decode response data into specific model types. It's useful for
/// operations like fetching user data, lists, or other structured responses.
///
/// The generic type T represents the expected response model type.
/// The class provides sensible defaults while allowing for customization.
abstract class ModelTargetType<T> extends TargetRequest {
  /// Optional decoder function for manual JSON conversion.
  final T Function(Map<String, dynamic>)? decoder;

  ModelTargetType({this.decoder});

  /// Always returns REST for model-based requests
  @override
  RequestType get requestType => RequestType.rest;

  /// Defaults to `false`
  /// itself to prevent an infinite refresh loop.
  @override
  bool get isAuthorized => false;

  /// Empty headers by default (can be overridden)
  @override
  Map<String, String> get headers => {};

  /// Empty auth headers by default (can be overridden)
  @override
  Map<String, String> get authHeaders => {};

  /// Plain request task by default (can be overridden)
  @override
  RequestTask get requestTask => RequestTask.plain();

  /// No SSL pinning by default (can be overridden)
  @override
  SSLPinningConfiguration? get sslPinningConfiguration => null;

  /// Decodes the JSON response into the model type [T].
  ///
  /// By default, this uses the [decoder] provided in the constructor.
  /// Subclasses MUST either provide a decoder or override this method.
  T fromJson(Map<String, dynamic> json) {
    if (decoder != null) {
      return decoder!(json);
    }
    throw UnimplementedError(
      'fromJson MUST be overridden or a decoder MUST be provided in the constructor for ModelTargetType<$T>',
    );
  }
}
