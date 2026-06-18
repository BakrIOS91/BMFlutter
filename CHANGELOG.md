## 0.1.7

- Replaced minimal example with full production app (Firebase-free): removed `firebase_core`, `firebase_analytics`, `firebase_crashlytics`, `firebase_messaging`, and `flutter_local_notifications`; uses plain `runApp()`.
- Added `.vscode/launch.json` with Debug and Release configurations.
- Test credentials (`TEST_EMAIL` / `TEST_PASSWORD`) loaded via `envied` from `.env` — pre-fill the login form in debug builds.
- Fixed `WithViewState._buildErrorView` cast: uses `APIError.errorModelAs<ResponseError>()` (new in `bm_flutter_networking` 0.1.11) via a private `_serverMessage()` helper — eliminates the double-cast pattern.
- Cleaned up `env.dart` / `.env`: removed stale Firebase notification fields.
- iOS minimum deployment target bumped to 15.0.

## 0.1.6

- Replaced the minimal example app with a full production app (`flutter_example`) migrated from a real project.
- Example uses `bm_flutter: ^0.1.5` and `bm_flutter_networking: ^0.1.10` as direct pub.dev dependencies instead of a git reference.
- All imports migrated from the legacy `ld_flutter` package to the split `bm_flutter` / `bm_flutter_networking` packages.
- Added `WithViewState.failHandler` — a static method on `WithViewState` that maps `APIError` to the correct `ViewState` error variant (`NoNetwork`, `Unauthorized`, `ServerError`, `UnexpectedError`).
- Updated README with real-world usage examples for `ViewState` (BLoC + Freezed integration, `WithViewState` widget), `FontHelper` / `FontRegistry` (startup registration, `AppFontWeight` enum, `AppTextStyles` wrapper), and `DeviceHelper` (`scaleValue` context extension, scaling sizes / spacing / radii).

## 0.1.5

- Fixed WASM compatibility: moved builder implementation from `lib/build.dart` to `lib/src/builder.dart` so pana no longer flags `analyzer`/`source_gen` (build-time-only deps) as WASM incompatible for the runtime library.
- Updated `build.yaml` import to `package:bm_flutter/src/builder.dart`.

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
