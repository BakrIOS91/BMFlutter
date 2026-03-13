import 'package:flutter_test/flutter_test.dart';
import 'package:bmflutter/core.dart';
import 'dart:async';

class MockRefreshHandler implements TokenRefreshHandler {
  int refreshCount = 0;
  Completer<bool>? completer;

  @override
  Future<bool> refreshToken() async {
    refreshCount++;
    completer = Completer<bool>();
    return completer!.future;
  }
}

void main() {
  group('TokenRefreshRegistry Tests', () {
    late MockRefreshHandler mockHandler;

    setUp(() {
      mockHandler = MockRefreshHandler();
      TokenRefreshRegistry.register(mockHandler);
    });

    test('refreshToken() triggers handler only once while pending', () async {
      // Trigger multiple refreshes simultaneously
      final f1 = TokenRefreshRegistry.refreshToken();
      final f2 = TokenRefreshRegistry.refreshToken();
      final f3 = TokenRefreshRegistry.refreshToken();

      expect(mockHandler.refreshCount, 1);

      // Complete the refresh
      mockHandler.completer?.complete(true);

      await Future.wait([f1, f2, f3]);

      expect(mockHandler.refreshCount, 1);
    });

    test('refreshToken() can trigger again after completion', () async {
      final f1 = TokenRefreshRegistry.refreshToken();
      mockHandler.completer?.complete(true);
      await f1;

      expect(mockHandler.refreshCount, 1);

      final f2 = TokenRefreshRegistry.refreshToken();
      mockHandler.completer?.complete(true);
      await f2;

      expect(mockHandler.refreshCount, 2);
    });
  });
}
