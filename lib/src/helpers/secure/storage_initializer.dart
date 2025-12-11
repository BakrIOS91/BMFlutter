import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageInitializer {
  static Future<void> clearKeychainOnFreshInstall() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool("is_first_run") ?? true;

    if (isFirstRun) {
      const secureStorage = FlutterSecureStorage();
      await secureStorage
          .deleteAll(); // clears Keychain on iOS + Keystore on Android
      await prefs.setBool("is_first_run", false);
    }
  }
}
