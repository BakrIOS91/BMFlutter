/// --- PREFERENCE SYSTEM ANNOTATIONS ---
///
/// This library defines the meta-programming contract for the `BMFlutter`
/// preference system. It enables automated generation of type-safe, reactive,
/// and persistent storage classes.
///
/// ### Architecture Overview
/// The system uses `source_gen` to scan these annotations at build time.
/// It leverages the "Mirror-free" approach, meaning it works perfectly
/// with Flutter's AOT compilation (Release builds).
///
/// ---
library;

/// Annotates a class that extends `BasePreferences` to trigger code generation.
///
/// This is the entry point for the generator. When a class is marked with
/// `@GeneratePreferences()`, the builder creates a corresponding
/// `part 'file.preferences.dart'` file.
///
/// ### Detailed Scenario: Multi-Module App
/// If you have a modular app, you can create separate preference classes
/// for each module (e.g., `AuthPreferences`, `ProfilePreferences`).
///
/// ```dart
/// @GeneratePreferences()
/// class UserPreferences extends BasePreferences with _$UserPreferences {
///   @UserDefault('user_id')
///   late final int _userId = 0;
/// }
/// ```
class GeneratePreferences {
  const GeneratePreferences();
}

/// Annotates a field for persistence in standard `SharedPreferences`.
///
/// **Best for:** UI states, non-sensitive settings, flags, and local caches.
/// **Storage:** XML file on Android, Plist on iOS.
///
/// ### Complex Scenario: Storing Custom Models
/// While `SharedPreferences` only supports primitives natively, this system
/// automatically handles objects that have `toJson` and `fromJson`.
///
/// ```dart
/// class UserProfile {
///   final String name;
///   UserProfile({required this.name});
///   Map<String, dynamic> toJson() => {'name': name};
///   static UserProfile fromJson(Map<String, dynamic> json) => UserProfile(name: json['name']);
/// }
///
/// @GeneratePreferences()
/// class ProfilePrefs extends BasePreferences with _$ProfilePrefs {
///   @UserDefault('profile_data')
///   late final UserProfile _profile;
/// }
/// ```
class UserDefault {
  /// The unique string key used for storage.
  /// Ensure keys are unique across the entire app namespace.
  final String key;

  const UserDefault(this.key);
}

/// Annotates a field to be stored securely via `FlutterSecureStorage`.
///
/// **Best for:** Bearer tokens, API credentials, and PII (Personally Identifiable Information).
/// **Security:** Uses **Keychain** (iOS), **KeyStore** (Android), and **SecretService/libsecret** (Linux).
///
/// ### Deep Implementation Detail
/// Unlike `SharedPreferences`, secure storage operations are asynchronous by nature
/// in the underlying OS. The generated system handles this by providing
/// immediate in-memory reactive access via `ValueNotifier`, while the
/// persistence to disk happens in the background.
///
/// ### Complex Scenario: Token Refresh
/// ```dart
/// @GeneratePreferences()
/// class SecurePrefs extends BasePreferences with _$SecurePrefs {
///   @Secure('jwt_token')
///   late final String? _token;
/// }
/// ```
class Secure {
  /// The unique key for the secure entry.
  final String key;

  const Secure(this.key);
}
