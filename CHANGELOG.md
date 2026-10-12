## 0.1.11

- Raised dependency constraints to allow the latest releases: `flutter_secure_storage ^11.2.0`, `source_gen ^4.3.0`, `analyzer <15.0.0`.
- Applied `dart format` to `lib/` and `test/`.
- Regenerated the example app's `app_preferences.pref.g.dart` (stale `void initGenerated()` signature).

## 0.1.10

- Replaced `root_jailbreak_sniffer` with `bm_root_jailbreak_sniffer` (a fork that adds a Swift Package Manager manifest on iOS). It has no SwiftPM manifest upstream, so it forced CocoaPods and the `IOSSecuritySuite` pod into apps otherwise on SwiftPM. Detection is unchanged on both platforms, including the Android Magisk Hide checks; `DeviceSecurityHelper` only changes its import.

## 0.1.9

- Fixed a startup race in `BasePreferences`/the preferences generator: `@Secure` fields were loaded via a fire-and-forget `getSecureInternal(...).then(...)` inside `initGenerated()`, so `init()` (and therefore `@preResolve`/DI setup) could complete before a secure field's real persisted value had actually loaded — leaving it at its just-constructed default in the meantime. Any authorized request built in that window went out with an empty/default token, and a token-refresh handler reading the same not-yet-loaded field could mistake it for "no session" and log the user out without ever calling the network. `initGenerated()` is now `Future<void>` and every `@Secure` field is genuinely `await`ed before it returns; `init()` awaits `initGenerated()` in turn. Trades a small amount of extra cold-start latency for closing the race — every consumer needs `dart run build_runner build` after upgrading to regenerate `*.pref.g.dart` with the new `async` signature.

## 0.1.8

- Added `SvgVecBuilder` (`lib/src/svg_vec_builder.dart`) — a build_runner `Builder` that precompiles each `.svg` asset into a `<name>.svg.vec` `vector_graphics` binary, registered via build.yaml with `auto_apply: dependents` so it applies automatically to any app depending on this package. Rendering the `.svg.vec` output instead of the raw `.svg` skips `flutter_svg`'s runtime XML parsing/tessellation, eliminating jank/memory spikes when many SVG icons mount at once (e.g. list scrolling). Generated `.svg.vec` files are build artifacts and should not be committed.

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
