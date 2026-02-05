/// Network Response Wrapper for BMFlutter Network Layer
///
/// This file defines a NetworkResponse model that wraps decoded response data
/// along with response headers and cookies. It enables callers to access
/// server cookies alongside the decoded response payload.
library;

import 'dart:io';

/// Network response wrapper containing decoded data and response metadata.
class NetworkResponse<T> {
  /// Decoded response data
  final T data;

  /// HTTP status code
  final int statusCode;

  /// Response headers
  final Map<String, String> headers;

  /// Raw Set-Cookie header value (if present)
  final String? rawSetCookieHeader;

  /// Parsed cookies from Set-Cookie header (best-effort)
  final List<Cookie> cookies;

  /// Creates a new NetworkResponse instance
  const NetworkResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.rawSetCookieHeader,
    required this.cookies,
  });

  /// Returns a ready-to-use Cookie header string (`name=value; name2=value2`)
  String? get cookieHeader {
    if (cookies.isEmpty) return null;
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }
}

/// Best-effort parsing for Set-Cookie header into Cookie objects.
List<Cookie> parseSetCookieHeader(String? headerValue) {
  if (headerValue == null || headerValue.trim().isEmpty) return const [];

  final parts = _splitSetCookie(headerValue);
  final cookies = <Cookie>[];
  for (final part in parts) {
    try {
      cookies.add(Cookie.fromSetCookieValue(part));
    } catch (_) {
      // Ignore malformed cookie parts
    }
  }
  return cookies;
}

/// Splits a combined Set-Cookie header into individual cookie strings.
///
/// Handles the common case where the header is merged with commas, while
/// preserving commas inside Expires attribute values.
List<String> _splitSetCookie(String headerValue) {
  final parts = <String>[];
  var start = 0;
  var inExpires = false;
  final lower = headerValue.toLowerCase();

  for (var i = 0; i < headerValue.length; i++) {
    // Detect Expires attribute start (case-insensitive).
    if (!inExpires &&
        i + 8 <= headerValue.length &&
        lower.substring(i, i + 8) == 'expires=') {
      inExpires = true;
    }

    // Expires attribute ends at the next semicolon.
    if (inExpires && headerValue[i] == ';') {
      inExpires = false;
    }

    // Split on commas not inside Expires.
    if (headerValue[i] == ',' && !inExpires) {
      final part = headerValue.substring(start, i).trim();
      if (part.isNotEmpty) parts.add(part);
      start = i + 1;
    }
  }

  final last = headerValue.substring(start).trim();
  if (last.isNotEmpty) parts.add(last);

  return parts;
}
