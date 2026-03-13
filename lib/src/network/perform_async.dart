/// Async Network Operations for LDFlutter Network Layer
///
/// This file provides async core operation extensions for both ModelTargetType
/// and SuccessTargetType. It handles the execution of core requests with
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

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bmflutter/src/helpers/api_error.dart';
import 'package:bmflutter/src/helpers/enums.dart';

import 'package:bmflutter/src/helpers/models/downloaded_file.dart';
import 'package:bmflutter/src/network/request.dart';
import 'package:bmflutter/src/network/target_request.dart';
import 'package:bmflutter/src/network/token_refresh_handler.dart';
import 'core/interceptor.dart';
import 'core/interceptors/logging_interceptor.dart';
import 'core/interceptors/auth_interceptor.dart';
import 'core/network_response.dart';

// ---------------------------------------------------------------------------
// ModelTargetType
// ---------------------------------------------------------------------------

/// Extension to perform async requests for [ModelTargetType].
extension PerformAsyncModelTargetType on ModelTargetType {
  /// Performs an async core request and returns the decoded model.
  Future<Response> performAsync<Response>() async {
    final response = await performAsyncWithCookies<Response>();
    return response.data;
  }

  /// Performs an async core request and returns data with cookies/headers.
  Future<NetworkResponse<Response>> performAsyncWithCookies<Response>() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final httpClient = http.Client();
    late final NetworkClient networkClient;
    networkClient = NetworkClient(
      httpClient,
      interceptors: [
        AuthInterceptor(
          isAuthorized: isAuthorized,
          refreshRequest: () async {
            await TokenRefreshRegistry.refreshToken();
            return createRequest();
          },
          retry: (req) => networkClient.send(req),
        ),
        LoggingInterceptor(),
      ],
    );

    try {
      final request = await createRequest();
      final streamedResponse = await networkClient.send(request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      final responseData = await streamedResponse.stream.toBytes();
      final rawSetCookie = streamedResponse.headers['set-cookie'];
      final cookies = parseSetCookieHeader(rawSetCookie);

      if (statusCategory == HTTPStatusCode.success) {
        return _decodeResponse<Response>(
          responseData: responseData,
          statusCode: statusCode,
          streamedResponse: streamedResponse,
          rawSetCookie: rawSetCookie,
          cookies: cookies,
        );
      }

      throw APIError(APIErrorType.httpError, statusCode: statusCategory);
    } catch (error) {
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      networkClient.close();
    }
  }

  /// Downloads a file.
  Future<DownloadedFile?> performDownload() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final httpClient = http.Client();
    late final NetworkClient networkClient;
    networkClient = NetworkClient(
      httpClient,
      interceptors: [
        AuthInterceptor(
          isAuthorized: isAuthorized,
          refreshRequest: () async {
            await TokenRefreshRegistry.refreshToken();
            return createRequest();
          },
          retry: (req) => networkClient.send(req),
        ),
        LoggingInterceptor(),
      ],
    );

    try {
      final request = await createRequest();
      final streamedResponse = await networkClient.send(request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);
      final remoteUrl = streamedResponse.request?.url ?? request.url;

      if (statusCategory == HTTPStatusCode.notAuthorize) {
        throw APIError(APIErrorType.httpError, statusCode: statusCategory);
      }

      final tempDir = Directory.systemTemp;
      String fileName = remoteUrl.pathSegments.last;

      if (useUniqueFilename) {
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final hash = hashCode.toRadixString(16);
        fileName = '${timestamp}_${hash}_$fileName';
      }

      final filePath = '${tempDir.path}/$fileName';
      final file = File(filePath);
      final sink = file.openWrite();
      await streamedResponse.stream.pipe(sink);
      await sink.close();

      if (statusCategory == HTTPStatusCode.success) {
        return DownloadedFile(
            downloadedUrl: file.uri,
            response: streamedResponse,
            remoteUrl: remoteUrl);
      }
      throw APIError(APIErrorType.httpError, statusCode: statusCategory);
    } catch (error) {
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      networkClient.close();
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
      final data = fromJson(decodedJson);
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
}

// ---------------------------------------------------------------------------
// SuccessTargetType
// ---------------------------------------------------------------------------

/// Extension to perform async requests for [SuccessTargetType].
extension PerformAsyncSuccessTargetType on SuccessTargetType {
  /// Performs an asynchronous core request and returns void if successful.
  Future<void> performAsync() async {
    await performAsyncWithCookies();
  }

  /// Performs an asynchronous core request and returns cookies/headers.
  Future<NetworkResponse<void>> performAsyncWithCookies() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final httpClient = http.Client();
    late final NetworkClient networkClient;
    networkClient = NetworkClient(
      httpClient,
      interceptors: [
        AuthInterceptor(
          isAuthorized: isAuthorized,
          refreshRequest: () async {
            await TokenRefreshRegistry.refreshToken();
            return createRequest();
          },
          retry: (req) => networkClient.send(req),
        ),
        LoggingInterceptor(),
      ],
    );

    try {
      final request = await createRequest();
      final streamedResponse = await networkClient.send(request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      final rawSetCookie = streamedResponse.headers['set-cookie'];
      final cookies = parseSetCookieHeader(rawSetCookie);

      if (statusCategory == HTTPStatusCode.success) {
        return NetworkResponse<void>(
          data: null,
          statusCode: statusCode,
          headers: streamedResponse.headers,
          rawSetCookieHeader: rawSetCookie,
          cookies: cookies,
        );
      }
      throw APIError(APIErrorType.httpError, statusCode: statusCategory);
    } catch (error) {
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      networkClient.close();
    }
  }
}
