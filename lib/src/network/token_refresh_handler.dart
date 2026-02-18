/// Token Refresh Handler for BMFlutter Network Layer
///
/// Provides automatic token refresh when a 401 Unauthorized response is
/// received on an authorized request. A Completer-based mutex ensures that
/// if multiple requests receive a 401 simultaneously, only ONE refresh call
/// is made — all concurrent waiters share the same Future result.
///
/// Usage:
/// ```dart
/// // 1. Implement TokenRefreshHandler in your app
/// class MyRefreshHandler implements TokenRefreshHandler {
///   @override
///   Future<bool> refreshToken() async {
///     try {
///       final result = await RefreshTokenRequest().performAsync<TokenModel>();
///       await prefs.saveToken(result.accessToken);
///       return true;
///     } catch (_) {
///       return false;
///     }
///   }
/// }
///
/// // 2. Register once at app startup
/// TokenRefreshRegistry.register(MyRefreshHandler());
/// ```
library;

import 'dart:async';

/// Abstract interface that the host app implements to provide token-refresh logic.
///
/// The implementation should:
/// - Call the refresh-token API endpoint.
/// - Persist the new access token so that subsequent `createRequest()` calls
///   (which read from `authHeaders`) pick up the fresh token automatically.
/// - Return `true` on success, `false` on any failure.
abstract class TokenRefreshHandler {
  /// Attempts to refresh the access token.
  ///
  /// Returns `true` if the token was successfully refreshed and persisted,
  /// `false` if the refresh failed (e.g. refresh token also expired).
  Future<bool> refreshToken();
}

/// Global registry for [TokenRefreshHandler] with a Completer-based mutex.
///
/// The mutex guarantees that if multiple requests receive a 401 at the same
/// time, only a single [TokenRefreshHandler.refreshToken] call is made.
/// All concurrent callers await the same [Future<bool>] result.
class TokenRefreshRegistry {
  TokenRefreshRegistry._();

  static TokenRefreshHandler? _handler;

  /// In-flight refresh completer. Non-null while a refresh is running.
  static Completer<bool>? _refreshCompleter;

  /// Registers the [TokenRefreshHandler] to use for token refresh.
  ///
  /// Call this once at app startup (e.g. in `main.dart` or your DI setup).
  static void register(TokenRefreshHandler handler) {
    _handler = handler;
  }

  /// Clears the registered handler and resets mutex state.
  ///
  /// Useful for logout or testing.
  static void clear() {
    _handler = null;
    _refreshCompleter = null;
  }

  /// Attempts a token refresh, ensuring only one refresh runs at a time.
  ///
  /// - If no handler is registered, returns `false` immediately.
  /// - If a refresh is already in-flight, awaits and returns its result.
  /// - Otherwise, owns the refresh, completes the mutex, and resets it.
  static Future<bool> attemptRefresh() async {
    // No handler registered — token refresh not supported by this app.
    if (_handler == null) return false;

    // A refresh is already running — wait for it and share the result.
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    // We are the first caller — own the refresh.
    _refreshCompleter = Completer<bool>();
    try {
      final result = await _handler!.refreshToken();
      _refreshCompleter!.complete(result);
      return result;
    } catch (_) {
      // Treat any unexpected exception as a failed refresh.
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      // Reset so future 401s (after a successful refresh) can refresh again.
      _refreshCompleter = null;
    }
  }
}
