/// Network Target Configuration for BMFlutter Network Layer
/// 
/// This file defines the Target abstract class that provides a protocol-based
/// approach to configuring network endpoints for different environments.
/// It allows for easy switching between development, staging, and production
/// environments with different API endpoints and configurations.
/// 
/// The Target protocol ensures that all network requests have consistent
/// base URL configuration while allowing for environment-specific customization.
/// It supports different schemes, hosts, ports, and API paths for various
/// deployment scenarios.
/// 
/// Usage:
/// ```dart
/// class ProductionTarget extends Target {
///   @override
///   AppEnvironment get appEnvironment => AppEnvironment.production;
///   
///   @override
///   String get kAppHost => 'api.example.com';
///   
///   @override
///   String get kAppScheme => 'https';
/// }
/// ```

import 'package:bmflutter/src/helpers/enums.dart';

/// Represents a target configuration for network requests
/// 
/// This abstract class defines the protocol for configuring network endpoints
/// across different environments. It provides a standardized way to configure
/// API endpoints, schemes, hosts, and paths for various deployment scenarios.
/// 
/// Implementations of this class should provide environment-specific configurations
/// that can be easily switched between development, staging, and production.
abstract class Target {
  /// The current environment of the app
  /// 
  /// This property identifies which environment the app is running in,
  /// allowing for environment-specific configurations and behaviors.
  AppEnvironment get appEnvironment;

  /// The host for the app
  /// 
  /// This property defines the hostname or IP address of the API server
  /// that the app will connect to for network requests.
  String get kAppHost;

  /// Optional main API path
  /// 
  /// This property defines an optional base path that will be prepended
  /// to all API endpoints. If null or empty, no base path is used.
  /// 
  /// Returns the API base path or null if not specified
  String? get kMainAPIPath => null;

  /// The scheme used by the app, e.g., 'https' or 'http'
  /// 
  /// This property defines the protocol scheme for network requests.
  /// Typically 'https' for production and 'http' for development.
  String get kAppScheme;

  /// Optional port for the app
  /// 
  /// This property defines an optional port number for the API server.
  /// If null, the default port for the scheme will be used.
  /// 
  /// Returns the port number or null for default
  int? get kAppPort => null;

  /// The base URL components for the app's network requests
  /// 
  /// This computed property constructs a Uri object from the individual
  /// components (scheme, host, port, path). It handles the optional API path
  /// and ensures proper URL construction for network requests.
  /// 
  /// Returns a Uri object with all base URL components
  ///
  String get sanitizedHost {
    // Remove any trailing or leading slashes accidentally added by subclasses
    return kAppHost.replaceAll(RegExp(r'^/+|/+$'), '');
  }

  Uri get kBaseURLComponents {
    final path = (kMainAPIPath != null && kMainAPIPath!.isNotEmpty)
        ? '/${kMainAPIPath!.replaceAll(RegExp(r'^/+'), '')}'
        : '/';

    return Uri(
      scheme: kAppScheme,
      host: sanitizedHost,
      port: kAppPort,
      path: path,
    );
  }

  /// The full base URL as a string
  /// 
  /// This computed property provides the complete base URL as a string,
  /// constructed from the individual components. It's useful for logging
  /// and debugging purposes.
  /// 
  /// Returns the complete base URL string
  String get kBaseURL => kBaseURLComponents.toString();
}
