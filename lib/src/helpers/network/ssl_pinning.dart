/// SSL/TLS Pinning for BMFlutter Network Layer
/// 
/// This file provides comprehensive SSL/TLS certificate pinning functionality
/// for enhanced security in network communications. It supports both certificate
/// pinning and public key pinning with configurable fallback options.
/// 
/// SSL pinning helps prevent man-in-the-middle attacks by validating that
/// the server's certificate matches expected pinned certificates or public
/// key hashes. This is especially important for sensitive applications
/// that handle user data or financial transactions.
/// 
/// Usage:
/// ```dart
/// final config = SSLPinningConfiguration(
///   isEnabled: true,
///   pinnedHosts: {'api.example.com'},
///   pinnedPublicKeyHashes: {'sha256/ABC123...'},
///   pinnedCertificatePaths: ['assets/certs/api.crt'],
/// );
/// 
/// final helper = SSLPinningHelper(configuration: config);
/// final client = await helper.createSecureHttpClient();
/// ```

import 'dart:developer';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asn1.dart';

/// Configuration for SSL/TLS pinning security settings
/// 
/// This class encapsulates all the configuration options for SSL pinning,
/// including which hosts to pin, certificate paths, public key hashes,
/// and fallback behavior. It provides a centralized way to configure
/// security settings for the network layer.
class SSLPinningConfiguration {
  /// Whether SSL pinning is enabled
  final bool isEnabled;
  
  /// Whether to allow fallback when pinning fails
  final bool allowFallback;
  
  /// Set of hostnames to apply pinning to
  final Set<String> pinnedHosts;
  
  /// Set of pinned public key hashes (SHA-256)
  final Set<String> pinnedPublicKeyHashes;
  
  /// List of certificate file paths in assets
  final List<String> pinnedCertificatePaths;

  /// Creates a new SSL pinning configuration
  /// 
  /// Parameters:
  /// - [isEnabled]: Whether SSL pinning is active (default: true)
  /// - [allowFallback]: Whether to allow connections when pinning fails (default: false)
  /// - [pinnedHosts]: Hostnames to apply pinning to (default: empty)
  /// - [pinnedPublicKeyHashes]: SHA-256 hashes of pinned public keys (default: empty)
  /// - [pinnedCertificatePaths]: Asset paths to certificate files (default: empty)
  const SSLPinningConfiguration({
    this.isEnabled = true,
    this.allowFallback = false,
    this.pinnedHosts = const {},
    this.pinnedPublicKeyHashes = const {},
    this.pinnedCertificatePaths = const [],
  });
}

/// Helper class to enforce SSL/TLS pinning for HttpClient
/// 
/// This class provides the core functionality for implementing SSL/TLS certificate
/// pinning in Flutter applications. It supports both certificate pinning and
/// public key pinning with comprehensive validation logic.
/// 
/// The helper preloads certificates from assets, validates server certificates
/// against pinned certificates and public key hashes, and provides fallback
/// options for development and testing scenarios.
class SSLPinningHelper {
  /// The SSL pinning configuration
  final SSLPinningConfiguration configuration;
  
  /// Preloaded certificate data for fast validation
  final List<Uint8List> _preloadedCerts = [];

  /// Creates a new SSL pinning helper
  /// 
  /// Parameters:
  /// - [configuration]: The SSL pinning configuration to use
  SSLPinningHelper({required this.configuration});

  /// Creates a secure [HttpClient] with SSL pinning enforced
  /// 
  /// This method creates an HttpClient instance with SSL pinning validation
  /// configured according to the provided configuration. It sets up certificate
  /// validation callbacks and preloads pinned certificates for fast validation.
  /// 
  /// The method handles both certificate pinning and public key pinning,
  /// with proper error handling and logging for debugging purposes.
  /// 
  /// Returns a configured HttpClient with SSL pinning enabled
  Future<HttpClient> createSecureHttpClient() async {
    // Build security context with trusted certificates
    final securityContext = await _buildSecurityContext();
    final client = HttpClient(context: securityContext);

    // Return client without pinning if disabled
    if (!configuration.isEnabled) return client;

    // Preload certificates for fast validation
    await _preloadCertificates();

    // Configure certificate validation callback
    client.badCertificateCallback = (cert, host, port) {
      // Allow connection if host is not in pinned hosts list
      if (!configuration.pinnedHosts.contains(host)) {
        return configuration.allowFallback;
      }

      try {
        final certDer = cert.der;

        // Validate certificate against pinned certificates
        if (_validateCertificateSync(certDer)) return true;
        
        // Validate public key against pinned hashes
        if (_validatePublicKey(cert)) return true;
      } catch (e) {
        // Log validation errors for debugging
        log('SSLPinning: Validation error: $e', name: 'SSLPinningHelper');
      }

      // Return fallback setting if validation fails
      return configuration.allowFallback;
    };

    return client;
  }

  /// Builds a [SecurityContext] and loads pinned certificates from assets
  /// 
  /// This method creates a SecurityContext with trusted root certificates
  /// and loads pinned certificates from the app's assets. It handles
  /// certificate loading errors gracefully and logs any issues for debugging.
  /// 
  /// Returns a SecurityContext configured with pinned certificates
  Future<SecurityContext> _buildSecurityContext() async {
    // Create security context with trusted root certificates
    final context = SecurityContext(withTrustedRoots: true);

    // Load each pinned certificate from assets
    for (final certPath in configuration.pinnedCertificatePaths) {
      try {
        // Load certificate bytes from assets
        final certBytes = await rootBundle.load(certPath);
        context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
      } catch (e) {
        // Log certificate loading errors for debugging
        log('SSLPinning: Could not load certificate from $certPath: $e',
            name: 'SSLPinningHelper');
      }
    }

    return context;
  }

  /// Preloads pinned certificate DER bytes for fast sync comparison.
  Future<void> _preloadCertificates() async {
    _preloadedCerts.clear();
    for (final path in configuration.pinnedCertificatePaths) {
      try {
        final data = await rootBundle.load(path);
        _preloadedCerts.add(data.buffer.asUint8List());
      } catch (_) {
        // Ignore loading errors
      }
    }
  }

  /// Synchronous certificate validation.
  bool _validateCertificateSync(Uint8List certDer) {
    for (final pinned in _preloadedCerts) {
      if (_listEquals(pinned, certDer)) return true;
    }
    return false;
  }

  /// Validates public key (SHA-256 hash) against pinned hashes.
  bool _validatePublicKey(X509Certificate cert) {
    try {
      final derBytes = cert.der;
      final parser = ASN1Parser(derBytes);

      final topLevelSeq = parser.nextObject() as ASN1Sequence;
      final tbsCertificateSeq = topLevelSeq.elements![0] as ASN1Sequence;

      final subjectPublicKeyInfo = tbsCertificateSeq.elements![6];
      final keyBytes = subjectPublicKeyInfo.encodedBytes;

      if (keyBytes == null) return false;

      final hash = sha256.convert(keyBytes).toString();
      final formattedHash = 'sha256/$hash';

      final isPinned = configuration.pinnedPublicKeyHashes.contains(formattedHash);
      if (!isPinned) {
        log('SSLPinning: Server public key hash not pinned: $formattedHash',
            name: 'SSLPinningHelper');
      }
      return isPinned;
    } catch (e, st) {
      log('SSLPinning: Public key validation failed: $e\n$st',
          name: 'SSLPinningHelper');
      return false;
    }
  }

  /// Compares two byte arrays.
  bool _listEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
