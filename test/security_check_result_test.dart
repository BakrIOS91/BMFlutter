import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter/src/helpers/device_security/device_security.dart';

void main() {
  group('SecurityCheckResult', () {
    test('stores isSecure=true and reason', () {
      final result = SecurityCheckResult(
        isSecure: true,
        reason: 'Device passed all security checks',
      );
      expect(result.isSecure, true);
      expect(result.reason, 'Device passed all security checks');
    });

    test('stores isSecure=false and reason', () {
      final result = SecurityCheckResult(
        isSecure: false,
        reason: 'Root detected; Debugger attached',
      );
      expect(result.isSecure, false);
      expect(result.reason, 'Root detected; Debugger attached');
    });

    test('reason can be empty string', () {
      final result = SecurityCheckResult(isSecure: true, reason: '');
      expect(result.reason, '');
    });

    test('isSecure reflects false correctly', () {
      final secure = SecurityCheckResult(isSecure: true, reason: 'ok');
      final insecure = SecurityCheckResult(isSecure: false, reason: 'fail');
      expect(secure.isSecure, isNot(insecure.isSecure));
    });
  });
}
