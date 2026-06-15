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
