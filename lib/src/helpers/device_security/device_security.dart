import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:jailbreak_root_detection/jailbreak_root_detection.dart';
import 'package:root_jailbreak_sniffer/rjsniffer.dart';

/// Model representing the result of a security check
class SecurityCheckResult {
  final bool isSecure;
  final String reason;

  SecurityCheckResult({required this.isSecure, required this.reason});
}

/// A helper class for comprehensive device security checks in Flutter.
class DeviceSecurityHelper {
  /// Performs a comprehensive security check
  static Future<SecurityCheckResult> checkDeviceSecurity({
    bool checkDebugging = true,
    bool checkEmulator = true,
    String? bundleId,
    String? expectedHash,
    List<String>? flutterSecrets,
    String? apkPath, // manually provide APK path for SHA256 check
    String? ipaPath, // manually provide IPA path for SHA256 check
  }) async {
    List<String> issues = [];

    try {
      // =============================
      // 1️⃣ root_jailbreak_sniffer checks
      // =============================
      if (checkEmulator || checkDebugging) {
        bool? rjsCompromised = await Rjsniffer.amICompromised();
        if (rjsCompromised ?? false) {
          issues.add("Root/Jailbreak detected (root_jailbreak_sniffer)");
        }

        if (checkEmulator) {
          bool? rjsEmulator = await Rjsniffer.amIEmulator();
          if (rjsEmulator ?? false) {
            issues.add("Emulator detected (root_jailbreak_sniffer)");
          }
        }

        if (checkDebugging) {
          bool? rjsDebugged = await Rjsniffer.amIDebugged();
          if (rjsDebugged ?? false) {
            issues.add("Debugger attached (root_jailbreak_sniffer)");
          }
        }
      }

      // =============================
      // 2️⃣ jailbreak_root_detection checks
      // =============================
      final detector = JailbreakRootDetection.instance;

      final isNotTrust = await detector.isNotTrust;
      final isJailBroken = await detector.isJailBroken;
      final isRealDevice = await detector.isRealDevice;
      final isDebugged = await detector.isDebugged;
      final checkForIssues = await detector.checkForIssues;

      // Emulator / non-real device checks
      if (!isRealDevice && checkEmulator) {
        issues.add("Not a real device (jailbreak_root_detection)");
      }

      // Debugger detection
      if (isDebugged && checkDebugging) {
        issues.add("Debugger attached (jailbreak_root_detection)");
      }

      // Critical security checks always run
      if (isJailBroken) {
        // Only report if real device to avoid false positives in simulator
        if (isRealDevice)
          issues.add("Root/Jailbreak detected (jailbreak_root_detection)");
      }

      if (isNotTrust && isRealDevice) {
        issues.add("Device not trusted (jailbreak_root_detection)");
      }

      // Only report other jailbreak issues if device is real AND emulator check is enabled
      if (checkForIssues.isNotEmpty && isRealDevice && checkEmulator) {
        issues.add(
          "Potential security issues detected (jailbreak_root_detection): ${checkForIssues.join(', ')}",
        );
      }

      // =============================
      // Android-specific advanced checks
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
      // iOS-specific tamper detection
      // =============================
      if (defaultTargetPlatform == TargetPlatform.iOS && bundleId != null) {
        final isTampered = await detector.isTampered(bundleId);
        if (isTampered) {
          issues.add("App bundle tampered (iOS)");
        }
      }

      // =============================
      // 3️⃣ Frida / hooking detection
      // =============================
      final fridaFiles = ['/usr/bin/frida-server', '/usr/sbin/frida-server'];
      for (var path in fridaFiles) {
        if (await File(path).exists()) {
          issues.add("Frida server detected at $path");
        }
      }

      // =============================
      // 4️⃣ Binary integrity / SHA256 hash check
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
      // 5️⃣ Flutter-specific constants check
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
    // 6️⃣ Return final result
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
