## 0.1.4

- Added full platform support (Android, iOS, web, macOS, Windows, Linux).
- Used conditional imports to isolate `jailbreak_root_detection` and `root_jailbreak_sniffer` to mobile-only compile paths; web and desktop use a lightweight stub.
- Declared `platforms:` in pubspec.yaml to make platform support explicit on pub.dev.

## 0.1.3

- Added example app for pub.dev scoring.
- Upgraded dependencies: `flutter_secure_storage` to 10.3.1, `analyzer` to 13.0.0, `source_gen` to 4.2.3, `build_runner` to 2.15.0, and other transitive updates.

## 0.1.2

- Initial release as `bm_flutter` (migrated from `ld_flutter`).
- Annotation-driven preferences code generation via `@GeneratePreferences`, `@UserDefault`, and `@Secure`.
- `BasePreferences` with synchronous read/write backed by `SharedPreferences` and `FlutterSecureStorage`.
- `DeviceSecurityHelper` for jailbreak/root detection, debug-mode checks, and signature verification.
- `DeviceHelper` for responsive scaling relative to a baseline device width.
- `ViewState` sealed class covering loading, error, and data states for BLoC-driven screens.
- `LanguageManager` with `SupportedLocale` enum for custom locale resolution.
- UI components: `AppCupertinoButton`, `UnderlinedButton`, `ErrorView`, `emptyBlocListener`, and `preferencesListener`.
- Typography helpers: `FontHelper`, `FontKeyRegistry`, and `FontWeightProtocol`.
