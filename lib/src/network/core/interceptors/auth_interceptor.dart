import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:bmflutter/src/helpers/enums.dart';
import '../interceptor.dart';

/// Interceptor that handles 401 Unauthorized responses by attempting a token refresh.
class AuthInterceptor extends NetworkInterceptor {
  final bool isAuthorized;
  final Future<http.BaseRequest> Function() refreshRequest;
  final Future<http.StreamedResponse> Function(http.BaseRequest) retry;

  bool _isRetrying = false;

  AuthInterceptor({
    required this.isAuthorized,
    required this.refreshRequest,
    required this.retry,
  });

  @override
  FutureOr<http.StreamedResponse> onResponse(
      http.BaseRequest request, http.StreamedResponse response) async {
    final statusCategory = HTTPStatusCode.from(response.statusCode);

    if (statusCategory == HTTPStatusCode.notAuthorize &&
        isAuthorized &&
        !_isRetrying) {
      _isRetrying = true;
      try {
        // Attempt refresh and retry
        final newRequest = await refreshRequest();
        return await retry(newRequest);
      } catch (_) {
        // If refresh/retry fails, return the original 401 response
        return response;
      }
    }

    return response;
  }
}
