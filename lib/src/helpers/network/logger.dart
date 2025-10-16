/// Network Logger for BMFlutter Network Layer
/// 
/// This file provides comprehensive logging functionality for HTTP requests
/// and responses. It includes formatted output, JSON pretty-printing, and
/// debug-friendly logging that can be easily enabled or disabled.
/// 
/// The logger automatically formats request and response data for easy
/// debugging and includes emojis and visual separators for better readability
/// in debug output. It supports both request and response logging with
/// detailed information about headers, parameters, and body content.
/// 
/// Usage:
/// ```dart
/// Logger.logRequest(
///   method: 'POST',
///   url: Uri.parse('https://api.example.com/users'),
///   headers: {'Content-Type': 'application/json'},
/// );
/// ```

import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Logger helper for HTTP requests and responses with formatted output
/// 
/// This class provides static methods for logging HTTP requests and responses
/// with detailed formatting, JSON pretty-printing, and debug-friendly output.
/// It can be globally enabled or disabled and automatically formats data
/// for easy debugging and monitoring.
class Logger {
  /// Enable or disable logging globally
  /// 
  /// This flag controls whether logging is active. It's set to kDebugMode
  /// by default, which means logging is only enabled in debug builds.
  static bool isEnabled = kDebugMode;

  /// Logs an HTTP request with detailed formatting
  /// 
  /// This method logs all aspects of an HTTP request including method, URL,
  /// headers, parameters, and body content. The output is formatted with
  /// emojis and visual separators for easy debugging.
  /// 
  /// Parameters:
  /// - [method]: The HTTP method (GET, POST, etc.)
  /// - [url]: The request URL
  /// - [headers]: Optional request headers
  /// - [parameters]: Optional URL parameters
  /// - [body]: Optional request body as bytes
  static void logRequest({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    Uint8List? body,
  }) {
    // Early return if logging is disabled
    if (!isEnabled) return;

    // Log request header with visual separator
    _safeLog('############################## Request ##############################');
    _safeLog('📤 Will send $method request for ${url.toString()}\n');

    // Log headers if present
    if (headers != null && headers.isNotEmpty) {
      _safeLog('🏷 Headers:');
      headers.forEach((key, value) => _safeLog('$key : $value'));
    }

    // Log parameters if present
    if (parameters != null && parameters.isNotEmpty) {
      _safeLog('\nParameters: ${_prettyPrintJson(parameters)}\n');
    }

    // Log body if present
    if (body != null && body.isNotEmpty) {
      _safeLog('\nBody: ${_prettyPrintBody(body)}\n');
    }

    // Log request footer
    _safeLog('############################## End Request ##############################\n');
  }

  /// Logs an HTTP response with status and data formatting
  /// 
  /// This method logs HTTP responses including status codes, response data,
  /// and any errors that occurred. It uses emojis to indicate success/failure
  /// and formats response data for easy debugging.
  /// 
  /// Parameters:
  /// - [method]: The HTTP method that was used
  /// - [url]: The request URL
  /// - [statusCode]: The HTTP status code received
  /// - [responseData]: Optional response body as bytes
  /// - [error]: Optional error that occurred during the request
  static void logResponse({
    required String method,
    required Uri url,
    int? statusCode,
    Uint8List? responseData,
    Object? error,
  }) {
    // Early return if logging is disabled
    if (!isEnabled) return;

    // Log response header with visual separator
    _safeLog('############################## Received Response ##############################');

    // Log error if present
    if (error != null) {
      _safeLog('❌ $statusCode $method request for $url returned Error: $error');
    }

    // Log response details if status code is available
    if (statusCode != null) {
      // Choose emoji based on status code success
      final statusEmoji = (statusCode >= 200 && statusCode < 300) ? '✅' : '⚠️';
      _safeLog('$statusEmoji Did receive response $statusCode for request $url');
      
      // Log response body if present
      if (responseData != null && responseData.isNotEmpty) {
        _safeLog('\nBody:\n${_prettyPrintBody(responseData)}');
      } else {
        _safeLog('\nBody: Empty or Void...');
      }
    }

    // Log response footer
    _safeLog('############################## End Response ##############################\n');
  }

  /// Internal safe log function with controlled output
  /// 
  /// This method provides a safe way to log messages with proper formatting
  /// and width control. It only logs when logging is enabled and uses
  /// Flutter's debugPrint with a controlled wrap width for better readability.
  /// 
  /// Parameters:
  /// - [message]: The message to log
  static void _safeLog(String message) {
    if (isEnabled) debugPrint(message, wrapWidth: 1024);
  }

  /// Pretty prints JSON parameters with proper indentation
  /// 
  /// This method formats JSON data with proper indentation for better
  /// readability in debug output. It handles conversion errors gracefully
  /// by falling back to string representation.
  /// 
  /// Parameters:
  /// - [json]: The JSON data to format
  /// 
  /// Returns a formatted JSON string or fallback representation
  static String _prettyPrintJson(Map<String, dynamic> json) {
    try {
      // Use JsonEncoder with 2-space indentation for pretty printing
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (_) {
      // Fallback to string representation if JSON encoding fails
      return json.toString();
    }
  }

  /// Pretty prints request/response body with JSON formatting
  /// 
  /// This method attempts to decode and format response body data as JSON.
  /// If the data is not valid JSON, it falls back to UTF-8 string decoding.
  /// This ensures that both JSON and plain text responses are properly formatted.
  /// 
  /// Parameters:
  /// - [body]: The response body as bytes
  /// 
  /// Returns a formatted string representation of the body
  static String _prettyPrintBody(Uint8List body) {
    try {
      // Decode bytes to UTF-8 string
      final decoded = utf8.decode(body);
      
      // Try to parse as JSON and format it
      final jsonMap = json.decode(decoded);
      return _prettyPrintJson(jsonMap);
    } catch (_) {
      // Fallback to UTF-8 decoding with malformed character handling
      return utf8.decode(body, allowMalformed: true);
    }
  }
}
