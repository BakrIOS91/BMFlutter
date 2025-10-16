/// HTTP Request Creation for BMFlutter Network Layer
/// 
/// This file provides the Request extension for TargetRequest that handles
/// the creation and configuration of HTTP requests. It supports various
/// request types including plain requests, parameter-based requests,
/// file uploads, multipart uploads, and downloads.
/// 
/// The extension automatically handles URL construction, header merging,
/// body encoding, and request type configuration based on the TargetRequest
/// and RequestTask specifications.
/// 
/// Usage:
/// ```dart
/// final request = await targetRequest.createRequest();
/// final response = await httpClient.send(request);
/// ```

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:bmflutter/src/helpers/enums.dart';
import 'package:bmflutter/src/network/target_request.dart';

/// Extension to create HTTP requests from TargetRequest configurations
/// 
/// This extension provides methods for converting TargetRequest instances
/// into actual HTTP requests that can be sent over the network. It handles
/// all the complexity of URL construction, header merging, and body encoding.
extension Request on TargetRequest {
  /// Creates an `http.Request` based on the specified `TargetRequest` and current `Task`
  /// 
  /// This method constructs a complete HTTP request from the TargetRequest configuration.
  /// It handles URL validation, header merging, and request type configuration.
  /// The method supports both REST and SOAP request types with appropriate handling.
  /// 
  /// Throws: `APIError` if there is an error in URL formation, data conversion, or JSON encoding
  /// 
  /// Returns a configured HTTP request ready to be sent
  Future<http.BaseRequest> createRequest() async {
    try {
      // Validate and construct URL
      final fullUrl = baseURL + requestPath;
      if (fullUrl.isEmpty) {
        throw const APIError(APIErrorType.invalidURL);
      }

      final url = Uri.tryParse(fullUrl);
      if (url == null) {
        throw const APIError(APIErrorType.invalidURL);
      }

      // Create request with method and headers
      final request = http.Request(requestMethod.value, url);
      request.headers.addAll(mergedHeaders);

      switch (requestType) {
        case RequestType.rest:
          return await _configureRESTRequest(request);
        case RequestType.soap:
          return _configureSOAPRequest(request);
      }
    } catch (e) {
      if (e is APIError) rethrow;
      throw const APIError(APIErrorType.invalidURL);
    }
  }

  /// Configures an `http.Request` for a REST request based on the specified `Task`
  /// 
  /// This method handles the configuration of REST requests based on the
  /// RequestTask type. It supports various task types including plain requests,
  /// parameter-based requests, body-encoded requests, file uploads, and downloads.
  /// 
  /// Parameters:
  /// - [request]: The base HTTP request to configure
  /// 
  /// Returns a configured HTTP request for REST operations
  Future<http.BaseRequest> _configureRESTRequest(http.Request request) async {
    switch (requestTask.type) {
      case RequestTaskType.plain:
      case RequestTaskType.download:
        return request;

      case RequestTaskType.parameters:
        final params = requestTask.parameters;
        if (params != null) {
          final uri = request.url.replace(queryParameters: params);
          return http.Request(request.method, uri)..headers.addAll(request.headers);
        }
        return request;

      case RequestTaskType.encodedBody:
        final body = requestTask.body;
        if (body != null) {
          try {
            final requestBody = jsonEncode(body);
            request.body = requestBody;
            request.headers['Content-Length'] =
                utf8.encode(requestBody).length.toString();
            request.headers['Content-Type'] = 'application/json';
          } catch (_) {
            throw const APIError(APIErrorType.dataConversionFailed);
          }
        }
        return request;

      case RequestTaskType.uploadFile:
        final filePath = requestTask.filePath;
        if (filePath != null) {
          final file = File(filePath);
          if (await file.exists()) {
            request.bodyBytes = await file.readAsBytes();
          } else {
            throw const APIError(APIErrorType.invalidURL);
          }
        }
        return request;

      case RequestTaskType.uploadMultipart:
        final fields = requestTask.fields;
        if (fields != null) {
          final multipartRequest = http.MultipartRequest(request.method, request.url);
          multipartRequest.headers.addAll(request.headers);

          for (final entry in fields.entries) {
            final fieldName = entry.key;
            final formData = entry.value;

            if (formData is MultipartFormDataData) {
              final multipartFile = http.MultipartFile.fromBytes(
                fieldName,
                formData.data,
                filename: formData.fileName,
                contentType: MediaType.parse(formData.mimeType),
              );
              multipartRequest.files.add(multipartFile);
            } else if (formData is MultipartFormDataText) {
              multipartRequest.fields[fieldName] = formData.value.toString();
            } else {
              throw const APIError(APIErrorType.dataConversionFailed);
            }
          }
          return multipartRequest;
        }
        return request;

      case RequestTaskType.downloadResumable:
        final offset = requestTask.offset;
        if (offset != null) {
          request.headers['Range'] = 'bytes=$offset-';
        }
        return request;
    }
  }

  /// Configures an `http.Request` for a SOAP request based on the specified `Task`
  /// 
  /// This method handles the configuration of SOAP requests. Currently,
  /// SOAP operations are not supported in this implementation, so it throws
  /// an appropriate error indicating the unsupported operation.
  /// 
  /// Parameters:
  /// - [request]: The base HTTP request to configure
  /// 
  /// Throws: `APIError` with `notSupportedSOAPOperation` type
  /// 
  /// Returns: This method always throws an error as SOAP is not supported
  http.BaseRequest _configureSOAPRequest(http.Request request) {
    throw const APIError(APIErrorType.notSupportedSOAPOperation);
  }
}
