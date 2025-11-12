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
library;

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
  AppEnvironment get appEnvironment;

  /// The host for the app (e.g., 'api.example.com')
  String get kAppHost;

  /// Optional main API path (e.g., 'v1')
  ///
  /// Represents the version or root path of the API (if any).
  String? get kMainAPIPath => null;

  /// Optional API sub-path (e.g., 'api')
  ///
  /// Represents a prefix path that comes before the main API path.
  /// Example: if `kAppApiPath` = 'api' and `kMainAPIPath` = 'v1',
  /// the final URL becomes: `https://example.com/api/v1/`
  String? get kAppApiPath => null;

  /// The scheme used by the app, e.g., 'https' or 'http'
  String get kAppScheme;

  /// Optional port number for the API server
  int? get kAppPort => null;

  /// Sanitized host (removes extra slashes)
  String get sanitizedHost => kAppHost.replaceAll(RegExp(r'^/+|/+$'), '');

  /// Constructs the full base URL components
  Uri get kBaseURLComponents {
    // Combine optional API and main paths safely
    final pathSegments = <String>[];
    if (kAppApiPath != null && kAppApiPath!.isNotEmpty) {
      pathSegments.add(kAppApiPath!.replaceAll(RegExp(r'^/+|/+$'), ''));
    }
    if (kMainAPIPath != null && kMainAPIPath!.isNotEmpty) {
      pathSegments.add(kMainAPIPath!.replaceAll(RegExp(r'^/+|/+$'), ''));
    }

    final combinedPath = pathSegments.isNotEmpty
        ? '/${pathSegments.join('/')}'
        : '/';

    return Uri(
      scheme: kAppScheme,
      host: sanitizedHost,
      port: kAppPort,
      path: combinedPath,
    );
  }

  /// Returns the complete base URL as a string
  String get kBaseURL => kBaseURLComponents.toString();
}
