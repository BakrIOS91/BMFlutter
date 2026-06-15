import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:root_jailbreak_sniffer/rjsniffer.dart';

/// Model representing the result of a device security check.
///
/// [isSecure] – true if device passes all enforced security checks.
/// [reason] – human-readable description of the issues detected or success message.
class SecurityCheckResult {
  final bool isSecure;
  final String reason;

  SecurityCheckResult({required this.isSecure, required this.reason});
}

/// DeviceSecurityHelper
///
/// This class performs **comprehensive security checks** for Flutter apps
/// by combining multiple detection strategies:
///
/// 1️⃣ **`root_jailbreak_sniffer`** – Quick runtime checks for:
///    - Root or jailbreak presence
///    - Emulator / simulator detection
///    - Debugger attached detection
///
/// 2️⃣ **`jailbreak_root_detection`** – Deep checks for:
///    - Device trust
///    - Jailbreak / root binaries
///    - Debugging / emulators
///    - Tampering (iOS)
///    - Miscellaneous jailbreak indicators (like Cydia, SSH, etc.)
///
/// 3️⃣ **Advanced optional checks**:
///    - Frida / hooking detection (server binaries)
///    - Binary integrity verification (SHA256)
///    - Flutter constants exposure
///    - Multiple-layer root detection on Android
///
///     📌 Usage Example
///  // Call security helper
///   SecurityCheckResult result = await DeviceSecurityHelper.checkDeviceSecurity(
///     checkDebugging: isProduction, // skip debugger checks on dev
///     checkEmulator: isProduction,  // skip emulator checks on dev
///     bundleId: "com.example.myapp", // required for iOS tamper detection
///     expectedHash: "YOUR_SHA256_HASH_HERE", // optional
///     flutterSecrets: ["API_KEY", "SECRET_KEY"], // optional
///     apkPath: "/path/to/app.apk", // optional
///     ipaPath: "/path/to/app.ipa", // optional
///   );
///
///   // Print result
///   if (result.isSecure) {
///     print("✅ Device secure: ${result.reason}");
///   } else {
///     print("⚠️ Security issues detected: ${result.reason}");
///   }
///
class DeviceSecurityHelper {
  /// Performs a full device security check.
  ///
  /// Parameters:
  /// - [checkDebugging] – If false, debugger detection is skipped.
  /// - [checkEmulator] – If false, emulator/non-real device detection is skipped.
  /// - [bundleId] – Required for iOS tamper detection.
  /// - [expectedHash] – Expected SHA256 hash of the app binary (APK/IPA).
  /// - [flutterSecrets] – List of sensitive constants to check if exposed.
  /// - [apkPath] / [ipaPath] – Optional manual paths for SHA256 checks.
  static Future<SecurityCheckResult> checkDeviceSecurity({
    bool checkDebugging = true,
    bool checkEmulator = true,
    String? bundleId,
    String? expectedHash,
    List<String>? flutterSecrets,
    String? apkPath,
    String? ipaPath,
  }) async {
    List<String> issues = [];

    try {
      // =============================
      // 1️⃣ Quick runtime checks using root_jailbreak_sniffer
      // =============================
      // Only run these checks if at least one of the flags is enabled
      if (checkDebugging || checkEmulator) {
        // Detect any root/jailbreak compromise (quick check)
        bool? rjsCompromised = await Rjsniffer.amICompromised();
        if (rjsCompromised ?? false) {
          issues.add("Root/Jailbreak detected (root_jailbreak_sniffer)");
        }

        // Detect emulator/simulator
        if (checkEmulator) {
          bool? rjsEmulator = await Rjsniffer.amIEmulator();
          if (rjsEmulator ?? false) {
            issues.add("Emulator detected (root_jailbreak_sniffer)");
          }
        }

        // Detect debugger attached
        if (checkDebugging) {
          bool? rjsDebugged = await Rjsniffer.amIDebugged();
          if (rjsDebugged ?? false) {
            issues.add("Debugger attached (root_jailbreak_sniffer)");
          }
        }
      }

      // =============================
      // 2️⃣ Deep checks using jailbreak_root_detection
      // =============================
      final detector = JailbreakRootDetection.instance;

      // Core properties from detector
      final isNotTrust = await detector.isNotTrust; // Is device trusted by OS
      final isJailBroken =
          await detector.isJailBroken; // Root / Jailbreak presence
      final isRealDevice =
          await detector.isRealDevice; // Emulator vs real device
      final isDebugged = await detector.isDebugged; // Debugger attached
      final checkForIssues =
          await detector.checkForIssues; // List of potential indicators

      // -----------------------------
      // Emulator / non-real device detection
      // -----------------------------
      if (!isRealDevice && checkEmulator) {
        issues.add("Not a real device (jailbreak_root_detection)");
      }

      // -----------------------------
      // Debugger detection
      // -----------------------------
      if (isDebugged && checkDebugging) {
        issues.add("Debugger attached (jailbreak_root_detection)");
      }

      // -----------------------------
      // Critical root/jailbreak detection
      // Always enforce on real devices
      // -----------------------------
      if (isJailBroken && isRealDevice) {
        issues.add("Root/Jailbreak detected (jailbreak_root_detection)");
      }

      // -----------------------------
      // Device trust checks
      // -----------------------------
      if (isNotTrust && isRealDevice) {
        issues.add("Device not trusted (jailbreak_root_detection)");
      }

      // -----------------------------
      // Optional jailbreak indicators (Cydia, SSH, suspicious files)
      // Only report if real device AND emulator check enabled
      // -----------------------------
      if (checkForIssues.isNotEmpty && isRealDevice && checkEmulator) {
        issues.add(
          "Potential security issues detected (jailbreak_root_detection): ${checkForIssues.join(', ')}",
        );
      }

      // =============================
      // 3️⃣ Android-specific advanced checks
      // =============================
      if (defaultTargetPlatform == TargetPlatform.android) {
        final isOnExternalStorage = await detector.isOnExternalStorage;
        final isDevMode = await detector.isDevMode;
        if (isOnExternalStorage) {
          issues.add("App installed on external storage (Android)");
        }
        if (isDevMode) {
          issues.add("Developer mode enabled (Android)");
        }

        // Multiple-layer root detection (common SU paths)
        final suPaths = [
          '/system/bin/su',
          '/system/xbin/su',
          '/sbin/su',
          '/system/su',
          '/system/bin/.ext/su',
          '/system/usr/we-need-root/su',
          '/system/app/Superuser.apk',
        ];
        for (var path in suPaths) {
          if (await File(path).exists()) {
            issues.add(
              "SU binary found at $path (multiple-layer root detection)",
            );
          }
        }

        final magiskPath = '/sbin/magisk';
        if (await File(magiskPath).exists()) {
          issues.add("Magisk detected (multiple-layer root detection)");
        }
      }

      // =============================
      // 4️⃣ iOS-specific tampering checks
      // =============================
      if (defaultTargetPlatform == TargetPlatform.iOS && bundleId != null) {
        final isTampered = await detector.isTampered(bundleId);
        if (isTampered) {
          issues.add("App bundle tampered (iOS)");
        }
      }

      // =============================
      // 5️⃣ Frida / hooking detection
      // =============================
      final fridaFiles = ['/usr/bin/frida-server', '/usr/sbin/frida-server'];
      for (var path in fridaFiles) {
        if (await File(path).exists()) {
          issues.add("Frida server detected at $path");
        }
      }

      // =============================
      // 6️⃣ Binary integrity / SHA256 hash
      // =============================
      if (expectedHash != null) {
        String? filePath;
        if (defaultTargetPlatform == TargetPlatform.android) {
          filePath = apkPath;
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          filePath = ipaPath;
        }

        if (filePath != null && await File(filePath).exists()) {
          final bytes = await File(filePath).readAsBytes();
          final hash = sha256.convert(bytes).toString();
          if (hash != expectedHash) {
            issues.add("Binary integrity failed: SHA256 mismatch");
          }
        } else {
          issues.add(
            "Binary integrity check skipped: file path invalid or missing",
          );
        }
      }

      // =============================
      // 7️⃣ Flutter constants exposure
      // =============================
      if (flutterSecrets != null && flutterSecrets.isNotEmpty) {
        for (var secret in flutterSecrets) {
          final envValue = String.fromEnvironment(secret, defaultValue: '');
          if (envValue.isNotEmpty) {
            issues.add("Sensitive constant exposed: $secret");
          }
        }
      }
    } catch (e) {
      issues.add("Security check failed: $e");
    }

    // =============================
    // Return final result
    // =============================
    if (issues.isEmpty) {
      return SecurityCheckResult(
        isSecure: true,
        reason: "Device passed all security checks",
      );
    } else {
      return SecurityCheckResult(isSecure: false, reason: issues.join("; "));
    }
  }
}
