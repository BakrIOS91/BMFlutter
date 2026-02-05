/// Async Network Operations for BMFlutter Network Layer
///
/// This file provides async network operation extensions for both ModelTargetType
/// and SuccessTargetType. It handles the execution of network requests with
/// comprehensive error handling, logging, and response processing.
///
/// The extensions support both data-fetching operations (ModelTargetType) and
/// simple success/failure operations (SuccessTargetType), along with file
/// download capabilities.
///
/// Usage:
/// ```dart
/// // For model-based requests
/// final user = await userRequest.performAsync<User>();
///
/// // For success-only requests
/// await deleteRequest.performAsync();
///
/// // For file downloads
/// final file = await downloadRequest.performDownload();
/// ```
library;

import 'dart:convert';
import 'dart:io';

import 'package:bmflutter/src/helpers/enums.dart';
import 'package:bmflutter/src/helpers/models/downloaded_file.dart';
import 'package:bmflutter/src/helpers/network/logger.dart';
import 'package:bmflutter/src/helpers/network/network_converters.dart';
import 'package:bmflutter/src/helpers/network/network_response.dart';
import 'package:bmflutter/src/network/request.dart';
import 'package:bmflutter/src/network/target_request.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Extension to perform async requests for ModelTargetType
///
/// This extension provides async network operations for requests that need
/// to decode response data into specific model types. It handles connectivity
/// checks, request creation, response processing, and error handling.
///

extension PerformAsyncModelTargetType on ModelTargetType {
  /// Performs an async network request and returns the decoded models
  ///
  /// This method executes a complete network request cycle including connectivity
  /// checks, request creation, HTTP execution, response logging, and data decoding.
  /// It automatically handles various error scenarios and provides detailed logging.
  ///
  /// Generic type [Response] represents the expected response model type
  ///
  /// Throws: `APIError` for various network and data conversion errors
  ///
  /// Returns the decoded response data as the specified type
  Future<Response> performAsync<Response>() async {
    final response = await performAsyncWithCookies<Response>();
    return response.data;
  }

  /// Performs an async network request and returns data with cookies/headers
  ///
  /// This method is identical to [performAsync] but also returns response
  /// headers and parsed cookies so they can be used by the caller.
  Future<NetworkResponse<Response>> performAsyncWithCookies<Response>() async {
    // Check for internet connection
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    // Create the HTTP request
    final request = await createRequest();

    try {
      // Prepare client (use SSL pinning later if implemented)
      final client = http.Client();
      http.StreamedResponse streamedResponse;

      try {
        streamedResponse = await client.send(request);
      } on SocketException {
        throw const APIError(APIErrorType.httpError);
      }

      final responseData = await streamedResponse.stream.toBytes();
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);
      final rawSetCookie = streamedResponse.headers['set-cookie'];
      final cookies = parseSetCookieHeader(rawSetCookie);

      Logger.logResponse(
        method: request.method,
        url: request.url,
        statusCode: statusCode,
        responseData: responseData,
      );

      // Handle response status
      switch (statusCategory) {
        case HTTPStatusCode.success:
          try {
            final decodedJson = json.decode(utf8.decode(responseData));
            final data = NetworkConverters.convert<Response>(decodedJson);
            return NetworkResponse<Response>(
              data: data,
              statusCode: statusCode,
              headers: streamedResponse.headers,
              rawSetCookieHeader: rawSetCookie,
              cookies: cookies,
            );
          } catch (error) {
            if (kDebugMode) {
              print(error);
            }
            throw const APIError(APIErrorType.dataConversionFailed);
          }

        default:
          throw APIError(APIErrorType.httpError, statusCode: statusCategory);
      }
    } catch (error) {
      Logger.logResponse(
        method: request.method,
        url: request.url,
        error: error,
      );
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    }
  }

  /// Downloads a file and returns the local file path wrapped in [DownloadedFile]
  ///
  /// This method handles file download operations, including connectivity checks,
  /// request creation, file streaming, and local file storage. It creates a
  /// temporary file and streams the download data to it.
  ///
  /// The method handles various download scenarios including resumable downloads
  /// and provides comprehensive logging for debugging purposes.
  ///
  /// Throws: `APIError` for network and file system errors
  ///
  /// Returns a DownloadedFile instance with local and remote file information
  Future<DownloadedFile?> performDownload() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final request = await createRequest();
    final client = http.Client();

    try {
      Logger.logRequest(
        method: request.method,
        url: request.url,
        headers: request.headers,
      );

      final streamedResponse = await client.send(request);

      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      // Get remote URL
      final remoteUrl = request.url;

      // Create temp file for download
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/${remoteUrl.pathSegments.last}';
      final file = File(filePath);

      // Save downloaded bytes
      final sink = file.openWrite();
      await streamedResponse.stream.pipe(sink);
      await sink.close();

      Logger.logResponse(
        method: request.method,
        url: request.url,
        statusCode: statusCode,
        responseData: utf8.encode('Downloaded to: $filePath'),
      );

      switch (statusCategory) {
        case HTTPStatusCode.success:
          return DownloadedFile(
            downloadedUrl: file.uri,
            response: streamedResponse,
            remoteUrl: remoteUrl,
          );

        default:
          throw APIError(APIErrorType.httpError, statusCode: statusCategory);
      }
    } catch (error) {
      Logger.logResponse(
        method: request.method,
        url: request.url,
        error: error,
      );
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      client.close();
    }
  }
}

/// Extension to perform async requests for SuccessTargetType
///
/// This extension provides async network operations for requests that don't
/// need to decode response data. It's useful for operations like creating,
/// updating, or deleting resources where you only care about success/failure.
extension PerformAsyncSuccessTargetType on SuccessTargetType {
  /// Performs an asynchronous network request and returns void if successful or throws an error
  ///
  /// This method executes a complete network request cycle for success-only operations.
  /// It handles connectivity checks, request creation, HTTP execution, and response
  /// validation without attempting to decode response data.
  ///
  /// The method is optimized for operations where the response body is not needed,
  /// such as DELETE, PUT, or POST operations that only return status codes.
  ///
  /// Throws: `APIError` for various network and HTTP errors
  ///
  /// Returns void on successful completion
  Future<void> performAsync() async {
    // Check for internet connection
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    // Create the HTTP request
    final request = await createRequest();

    try {
      Logger.logRequest(
        method: request.method,
        url: request.url,
        headers: request.headers,
      );

      // Prepare client (can later support SSL pinning)
      final client = http.Client();
      http.StreamedResponse streamedResponse;

      try {
        streamedResponse = await client.send(request);
      } on SocketException {
        throw const APIError(APIErrorType.noNetwork);
      }

      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      Logger.logResponse(
        method: request.method,
        url: request.url,
        statusCode: statusCode,
      );

      // Handle different status code ranges
      switch (statusCategory) {
        case HTTPStatusCode.success:
          return;
        default:
          throw APIError(APIErrorType.httpError, statusCode: statusCategory);
      }
    } catch (error) {
      Logger.logResponse(
        method: request.method,
        url: request.url,
        error: error,
      );
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    }
  }
}
