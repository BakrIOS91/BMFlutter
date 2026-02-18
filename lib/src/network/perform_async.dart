/// Async Network Operations for BMFlutter Network Layer
///
/// This file provides async network operation extensions for both ModelTargetType
/// and SuccessTargetType. It handles the execution of network requests with
/// comprehensive error handling, logging, and response processing.
///
/// When a 401 Unauthorized response is received on an [isAuthorized] request,
/// the layer automatically attempts a token refresh via [TokenRefreshRegistry].
/// If the refresh succeeds the original request is rebuilt (fresh token from
/// [authHeaders]) and re-sent exactly once. If the refresh fails the
/// [Unauthorized] error propagates normally.
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
import 'package:bmflutter/src/network/token_refresh_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ---------------------------------------------------------------------------
// ModelTargetType
// ---------------------------------------------------------------------------

/// Extension to perform async requests for [ModelTargetType].
extension PerformAsyncModelTargetType on ModelTargetType {
  /// Performs an async network request and returns the decoded model.
  ///
  /// Convenience wrapper around [performAsyncWithCookies] that discards
  /// the response metadata and returns only the decoded data.
  Future<Response> performAsync<Response>() async {
    final response = await performAsyncWithCookies<Response>();
    return response.data;
  }

  /// Performs an async network request and returns data with cookies/headers.
  ///
  /// Handles connectivity checks, request creation, HTTP execution, response
  /// logging, and data decoding. On a 401 response the layer will attempt a
  /// token refresh (if [isAuthorized] is `true` and a [TokenRefreshHandler]
  /// is registered), rebuild the request with the fresh token, and re-send
  /// exactly once before propagating any error.
  Future<NetworkResponse<Response>> performAsyncWithCookies<Response>() async {
    // Check for internet connection.
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    // Build the initial request.
    final request = await createRequest();
    final client = http.Client();

    try {
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

      switch (statusCategory) {
        case HTTPStatusCode.success:
          return _decodeResponse<Response>(
            responseData: responseData,
            statusCode: statusCode,
            streamedResponse: streamedResponse,
            rawSetCookie: rawSetCookie,
            cookies: cookies,
          );

        case HTTPStatusCode.notAuthorize:
          // Attempt a single token refresh if this request is authorized.
          if (isAuthorized) {
            final refreshed = await TokenRefreshRegistry.attemptRefresh();
            if (refreshed) {
              // Rebuild the request so authHeaders picks up the new token.
              final retryRequest = await createRequest();
              final retryStreamed = await client.send(retryRequest);
              final retryData = await retryStreamed.stream.toBytes();
              final retryStatusCategory = HTTPStatusCode.from(
                retryStreamed.statusCode,
              );
              final retryRawSetCookie = retryStreamed.headers['set-cookie'];
              final retryCookies = parseSetCookieHeader(retryRawSetCookie);

              Logger.logResponse(
                method: retryRequest.method,
                url: retryRequest.url,
                statusCode: retryStreamed.statusCode,
                responseData: retryData,
              );

              if (retryStatusCategory == HTTPStatusCode.success) {
                return _decodeResponse<Response>(
                  responseData: retryData,
                  statusCode: retryStreamed.statusCode,
                  streamedResponse: retryStreamed,
                  rawSetCookie: retryRawSetCookie,
                  cookies: retryCookies,
                );
              }
            }
          }
          throw APIError(APIErrorType.httpError, statusCode: statusCategory);

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

  /// Decodes a successful HTTP response into a [NetworkResponse].
  NetworkResponse<Response> _decodeResponse<Response>({
    required List<int> responseData,
    required int statusCode,
    required http.StreamedResponse streamedResponse,
    required String? rawSetCookie,
    required List<Cookie> cookies,
  }) {
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
      if (kDebugMode) print(error);
      throw const APIError(APIErrorType.dataConversionFailed);
    }
  }

  /// Downloads a file and returns the local file path wrapped in [DownloadedFile].
  ///
  /// On a 401 response the layer will attempt a token refresh (if [isAuthorized]
  /// is `true`), rebuild the request with the fresh token, and re-send exactly
  /// once. The file sink is only opened after a successful status check so
  /// there is no partial-write risk on the retry.
  ///
  /// Throws [APIError] for network and file system errors.
  Future<DownloadedFile?> performDownload() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final client = http.Client();
    // Declare outside try so the catch block can reference it for logging.
    late final http.BaseRequest request;

    try {
      // Build and send the initial request.
      request = await createRequest();

      Logger.logRequest(
        method: request.method,
        url: request.url,
        headers: request.headers,
      );

      var streamedResponse = await client.send(request);
      var statusCode = streamedResponse.statusCode;
      var statusCategory = HTTPStatusCode.from(statusCode);
      var remoteUrl = request.url;

      // Handle 401 — attempt token refresh and retry once.
      if (statusCategory == HTTPStatusCode.notAuthorize && isAuthorized) {
        final refreshed = await TokenRefreshRegistry.attemptRefresh();
        if (refreshed) {
          // Rebuild the request so authHeaders picks up the new token.
          final retryRequest = await createRequest();

          Logger.logRequest(
            method: retryRequest.method,
            url: retryRequest.url,
            headers: retryRequest.headers,
          );

          streamedResponse = await client.send(retryRequest);
          statusCode = streamedResponse.statusCode;
          statusCategory = HTTPStatusCode.from(statusCode);
          remoteUrl = retryRequest.url;
        }
      }

      // If still unauthorized after refresh attempt, propagate the error.
      if (statusCategory == HTTPStatusCode.notAuthorize) {
        throw APIError(APIErrorType.httpError, statusCode: statusCategory);
      }

      // Create temp file and stream the download.
      final tempDir = Directory.systemTemp;
      final filePath = '${tempDir.path}/${remoteUrl.pathSegments.last}';
      final file = File(filePath);
      final sink = file.openWrite();
      await streamedResponse.stream.pipe(sink);
      await sink.close();

      Logger.logResponse(
        method: request.method,
        url: remoteUrl,
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

// ---------------------------------------------------------------------------
// SuccessTargetType
// ---------------------------------------------------------------------------

/// Extension to perform async requests for [SuccessTargetType].
extension PerformAsyncSuccessTargetType on SuccessTargetType {
  /// Performs an asynchronous network request and returns void if successful.
  ///
  /// Convenience wrapper around [performAsyncWithCookies].
  Future<void> performAsync() async {
    await performAsyncWithCookies();
  }

  /// Performs an asynchronous network request and returns cookies/headers.
  ///
  /// Handles connectivity checks, request creation, HTTP execution, and
  /// response validation without decoding response data. On a 401 response
  /// the layer will attempt a token refresh (if [isAuthorized] is `true`),
  /// rebuild the request with the fresh token, and re-send exactly once.
  Future<NetworkResponse<void>> performAsyncWithCookies() async {
    // Check for internet connection.
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    // Build the initial request.
    final request = await createRequest();
    final client = http.Client();

    try {
      Logger.logRequest(
        method: request.method,
        url: request.url,
        headers: request.headers,
      );

      http.StreamedResponse streamedResponse;
      try {
        streamedResponse = await client.send(request);
      } on SocketException {
        throw const APIError(APIErrorType.noNetwork);
      }

      var statusCode = streamedResponse.statusCode;
      var statusCategory = HTTPStatusCode.from(statusCode);
      var rawSetCookie = streamedResponse.headers['set-cookie'];
      var cookies = parseSetCookieHeader(rawSetCookie);

      Logger.logResponse(
        method: request.method,
        url: request.url,
        statusCode: statusCode,
      );

      switch (statusCategory) {
        case HTTPStatusCode.success:
          return NetworkResponse<void>(
            data: null,
            statusCode: statusCode,
            headers: streamedResponse.headers,
            rawSetCookieHeader: rawSetCookie,
            cookies: cookies,
          );

        case HTTPStatusCode.notAuthorize:
          // Attempt a single token refresh if this request is authorized.
          if (isAuthorized) {
            final refreshed = await TokenRefreshRegistry.attemptRefresh();
            if (refreshed) {
              // Rebuild the request so authHeaders picks up the new token.
              final retryRequest = await createRequest();
              final retryStreamed = await client.send(retryRequest);
              final retryStatusCategory = HTTPStatusCode.from(
                retryStreamed.statusCode,
              );
              final retryRawSetCookie = retryStreamed.headers['set-cookie'];
              final retryCookies = parseSetCookieHeader(retryRawSetCookie);

              Logger.logResponse(
                method: retryRequest.method,
                url: retryRequest.url,
                statusCode: retryStreamed.statusCode,
              );

              if (retryStatusCategory == HTTPStatusCode.success) {
                return NetworkResponse<void>(
                  data: null,
                  statusCode: retryStreamed.statusCode,
                  headers: retryStreamed.headers,
                  rawSetCookieHeader: retryRawSetCookie,
                  cookies: retryCookies,
                );
              }
            }
          }
          throw APIError(APIErrorType.httpError, statusCode: statusCategory);

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
