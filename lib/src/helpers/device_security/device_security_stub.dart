/// Security check result for platforms where native checks are unavailable.
class SecurityCheckResult {
  final bool isSecure;
  final String reason;

  SecurityCheckResult({required this.isSecure, required this.reason});
}

/// Stub implementation of [DeviceSecurityHelper] for web and unsupported platforms.
///
/// All checks return [isSecure] as `true` because jailbreak/root detection
/// only applies to Android and iOS.
class DeviceSecurityHelper {
  static Future<SecurityCheckResult> checkDeviceSecurity({
    bool checkDebugging = true,
    bool checkEmulator = true,
    String? bundleId,
    String? expectedHash,
    List<String>? flutterSecrets,
    String? apkPath,
    String? ipaPath,
  }) async {
    return SecurityCheckResult(
      isSecure: true,
      reason: 'Device security checks are not applicable on this platform.',
    );
  }
}
