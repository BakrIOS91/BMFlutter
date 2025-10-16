/// Network Monitor for BMFlutter Network Layer
/// 
/// This file provides comprehensive network connectivity monitoring using
/// the connectivity_plus package. It offers both on-demand connectivity
/// checks and real-time connectivity status streams for reactive programming.
/// 
/// The monitor supports multiple connection types including mobile data,
/// Wi-Fi, and Ethernet connections. It provides a simple boolean interface
/// for easy integration with network requests and UI state management.
/// 
/// Usage:
/// ```dart
/// // Check connectivity on-demand
/// final isOnline = await NetworkMonitor.isConnected;
/// 
/// // Listen to connectivity changes
/// NetworkMonitor.onConnectivityChanged.listen((isConnected) {
///   if (isConnected) {
///     print('Connected to internet');
///   } else {
///     print('No internet connection');
///   }
/// });
/// ```

import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides real-time and on-demand network connectivity status monitoring
///
/// This class offers a comprehensive solution for monitoring network connectivity
/// across different connection types. It provides both synchronous and asynchronous
/// methods for checking connectivity status and streams for reactive programming.
///
/// The monitor automatically handles different connection types (mobile, Wi-Fi,
/// Ethernet) and provides a unified boolean interface for easy integration.
///
/// Example:
/// ```dart
/// final isOnline = await NetworkMonitor.isConnected;
/// if (!isOnline) {
///   print("No internet connection");
/// }
/// ```
class NetworkMonitor {
  /// Private constructor to prevent instantiation
  /// 
  /// This class is designed to be used statically, so instantiation is not allowed.
  const NetworkMonitor._(); // Prevent instantiation

  /// Returns `true` if the device is connected to any available network
  /// 
  /// This method checks the current connectivity status and returns true if
  /// the device is connected to any of the supported network types (mobile, Wi-Fi, Ethernet).
  /// It's useful for on-demand connectivity checks before making network requests.
  /// 
  /// Returns a Future<bool> indicating connectivity status
  static Future<bool> get isConnected async {
    // Get current connectivity results
    final results = await Connectivity().checkConnectivity();
    
    // Check if any supported connection type is available
    // `results` is now a List<ConnectivityResult>
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  /// Emits connectivity status changes as a boolean stream
  ///
  /// This stream provides real-time connectivity status updates, emitting
  /// true when connected and false when disconnected. It's useful for
  /// reactive programming patterns and UI state management.
  ///
  /// Stream values:
  /// - `true` = connected to any supported network
  /// - `false` = disconnected from all networks
  static Stream<bool> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged.map((results) {
        // Each `results` event is a List<ConnectivityResult>
        // Check if any supported connection type is available
        return results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet);
      });
}
