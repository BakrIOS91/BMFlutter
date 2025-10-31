/// Request Task Configuration for BMFlutter Network Layer
///
/// This file defines the RequestTask class that encapsulates different types
/// of network operations and their associated data. It provides a type-safe
/// way to configure various network requests including plain requests, file
/// uploads, downloads, and multipart form data.
///
/// The RequestTask uses factory constructors to create specific task types
/// with their associated data, ensuring type safety and preventing invalid
/// configurations. Each task type has specific handling logic in the network layer.
///
/// Usage:
/// ```dart
/// // Plain request
/// final plainTask = RequestTask.plain();
///
/// // Request with parameters
/// final paramTask = RequestTask.parameters({'page': 1, 'limit': 10});
///
/// // File upload
/// final uploadTask = RequestTask.uploadFile('/path/to/file.jpg');
///
/// // Multipart upload
/// final multipartTask = RequestTask.uploadMultipart({
///   'file': MultipartFormDataData(data, 'image.jpg', 'image/jpeg'),
///   'description': MultipartFormDataText('Profile picture'),
/// });
/// ```
library;

import 'dart:typed_data';

import 'package:bmflutter/src/helpers/enums.dart';

/// Encapsulates different types of network request tasks with associated data
///
/// This class provides a comprehensive way to configure various network
/// operations through factory constructors. Each task type has specific
/// associated data that is validated and used by the network layer.
class RequestTask {
  /// The type of request task to perform
  final RequestTaskType type;

  // Associated values for different task types
  /// URL parameters for parameter-based requests
  final Map<String, dynamic>? parameters;

  /// Request body for encoded body requests
  final dynamic body;

  /// File path for file upload requests
  final String? filePath;

  /// Multipart form fields for multipart uploads
  final Map<String, MultipartFormData>? fields;

  /// Download URL for download requests
  final String? url;

  /// Resume data for resumable downloads
  final Uint8List? resumeData;

  /// Byte offset for resumable downloads
  final int? offset;

  /// Private constructor for creating RequestTask instances
  ///
  /// This constructor is private to ensure that RequestTask instances
  /// are only created through the factory constructors, which provide
  /// type safety and validation.
  const RequestTask._({
    required this.type,
    this.parameters,
    this.body,
    this.filePath,
    this.fields,
    this.url,
    this.resumeData,
    this.offset,
  });

  /// Factory constructor for plain requests with no additional data
  ///
  /// Creates a RequestTask for simple requests that don't require
  /// parameters, body, or file uploads. This is the most basic
  /// request type.
  ///
  /// Returns a RequestTask configured for plain requests
  factory RequestTask.plain() => RequestTask._(type: RequestTaskType.plain);

  /// Factory constructor for requests with URL parameters
  ///
  /// Creates a RequestTask for requests that include URL parameters.
  /// The parameters will be appended to the request URL as query parameters.
  ///
  /// Parameters:
  /// - [params]: Map of parameter names to values
  ///
  /// Returns a RequestTask configured for parameter-based requests
  factory RequestTask.parameters(Map<String, dynamic> params) =>
      RequestTask._(type: RequestTaskType.parameters, parameters: params);

  /// Factory constructor for requests with JSON-encoded body
  ///
  /// Creates a RequestTask for requests that include a JSON-encoded
  /// request body. The body will be automatically encoded to JSON
  /// and sent with the request.
  ///
  /// Parameters:
  /// - [body]: The data to be encoded as JSON in the request body
  ///
  /// Returns a RequestTask configured for body-based requests
  factory RequestTask.encodedBody(dynamic body) =>
      RequestTask._(type: RequestTaskType.encodedBody, body: body);

  /// Factory constructor for file upload requests
  ///
  /// Creates a RequestTask for uploading a single file. The file
  /// will be read from the specified path and sent as the request body.
  ///
  /// Parameters:
  /// - [filePath]: The local path to the file to upload
  ///
  /// Returns a RequestTask configured for file upload
  factory RequestTask.uploadFile(String filePath) =>
      RequestTask._(type: RequestTaskType.uploadFile, filePath: filePath);

  /// Factory constructor for multipart form data uploads
  ///
  /// Creates a RequestTask for uploading multiple files and text fields
  /// as multipart form data. This is useful for complex uploads that
  /// include both files and form fields.
  ///
  /// Parameters:
  /// - [fields]: Map of field names to MultipartFormData objects
  ///
  /// Returns a RequestTask configured for multipart uploads
  factory RequestTask.uploadMultipart(Map<String, MultipartFormData> fields) =>
      RequestTask._(type: RequestTaskType.uploadMultipart, fields: fields);

  /// Factory constructor for file download requests
  ///
  /// Creates a RequestTask for downloading a file from the specified URL.
  /// The downloaded file will be saved to a temporary location.
  ///
  /// Parameters:
  /// - [url]: The URL of the file to download
  ///
  /// Returns a RequestTask configured for file download
  factory RequestTask.download(String url) =>
      RequestTask._(type: RequestTaskType.download, url: url);

  /// Factory constructor for resumable file downloads
  ///
  /// Creates a RequestTask for resumable downloads that can be paused
  /// and resumed. This is useful for large file downloads that may
  /// be interrupted.
  ///
  /// Parameters:
  /// - [resumeData]: Optional resume data from a previous download attempt
  /// - [offset]: Optional byte offset to resume from
  ///
  /// Returns a RequestTask configured for resumable downloads
  factory RequestTask.downloadResumable({Uint8List? resumeData, int? offset}) =>
      RequestTask._(
        type: RequestTaskType.downloadResumable,
        resumeData: resumeData,
        offset: offset,
      );
}
