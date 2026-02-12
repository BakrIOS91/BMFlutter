/// Downloaded File Model for BMFlutter Network Layer
///
/// This file defines the DownloadedFile model that represents the result
/// of a file download operation. It contains information about both the
/// local downloaded file and the original remote file, along with the
/// HTTP response metadata.
///
/// The model provides serialization support for storing download information
/// and can be used to track download progress, verify file integrity,
/// and manage downloaded files across the application.
///
/// Usage:
/// ```dart
/// final downloadedFile = DownloadedFile(
///   downloadedUrl: localFileUri,
///   remoteUrl: remoteFileUri,
///   response: httpResponse,
/// );
/// ```
library;

import 'package:http/http.dart' as http;

/// Model representing a downloaded file with metadata
///
/// This class encapsulates all information related to a file download operation,
/// including the local file path, remote URL, and HTTP response details.
/// It provides a convenient way to track and manage downloaded files.
class DownloadedFile {
  /// The local URI of the downloaded file
  final Uri? downloadedUrl;

  /// The HTTP response from the download request
  final http.StreamedResponse? response;

  /// The original remote URL of the downloaded file
  final Uri? remoteUrl;

  /// Creates a new DownloadedFile instance
  ///
  /// Parameters:
  /// - [downloadedUrl]: The local URI where the file was saved
  /// - [response]: The HTTP response from the download request
  /// - [remoteUrl]: The original remote URL of the file
  const DownloadedFile({this.downloadedUrl, this.response, this.remoteUrl});

  /// Converts the DownloadedFile to a JSON-serializable map
  ///
  /// This method serializes the DownloadedFile instance to a Map
  /// that can be easily stored or transmitted. Only the URL information
  /// is serialized, as the HTTP response contains non-serializable data.
  ///
  /// Returns a Map containing the serialized file information
  Map<String, dynamic> toJson() => {
    'downloadedUrl': downloadedUrl?.toString(),
    'remoteUrl': remoteUrl?.toString(),
  };
}
