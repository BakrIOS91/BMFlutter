# BMFlutter Package Utilities

BMFlutter is a Flutter package providing core utilities, UI components, and design system helpers. This document provides a **deep, detailed guide** with practical implementation examples for each utility available in the package.

> **Note:** The networking layer (TargetRequest, HTTP clients, SSL pinning, token refresh, etc.) has been moved to the separate `bm_flutter_networking` package.

> **Real-world example:** See [`example/`](example) — a full production app demonstrating ViewState, FontHelper, DeviceHelper, and more in practice.

## Table of Contents

1. [UI Components & Reusables](#1-ui-components--reusables)
   - [Custom Buttons](#custom-buttons)
   - [ErrorView & CustomError](#errorview--customerror)
   - [Bloc Listeners](#bloc-listeners)
2. [Core Utilities](#2-core-utilities)
   - [ViewState](#viewstate)
   - [Language Manager](#language-manager)
3. [Storage & Preferences](#3-storage--preferences)
4. [Device & Security](#4-device--security)
5. [Design & Typography](#5-design--typography)

---

## 1. UI Components & Reusables

### Custom Buttons

**AppCupertinoButton**
Unified Apple-style filled and outlined buttons handling states natively.

```dart
AppCupertinoButton.filled(
  context: context,
  title: 'Submit Data',
  onPressed: () => submit(),
  icon: Icons.check,
  iconPosition: Position.trailing,
);

AppCupertinoButton.outlined(
  context: context,
  title: 'Cancel',
  borderColor: Colors.red,
  onPressed: () => Navigator.pop(context),
);
```

**UnderlinedButton**
A lightweight button with an underline and iOS-like opacity-based tap feedback rather than material ripples.

```dart
UnderlinedButton(
  title: 'Forgot Password?',
  style: TextStyle(color: Colors.blue),
  onPressed: () => resetPassword(),
);
```

### ErrorView & CustomError

**ErrorView**
A standardized widget for showing error states (e.g., no internet, generic failures).

```dart
ErrorView(
  title: 'No Network',
  message: 'Please check your connection and try again.',
  image: Image.asset('assets/images/offline.png'),
  buttonTitle: 'Retry',
  retryAction: () => fetchContent(),
);
```

**CustomError Model**
Used combined with `ViewState.CustomErrorState` to pass specific UI error representations from a ViewModel/Bloc directly to the UI layer.

```dart
final error = CustomError(
  errorImage: Image.asset('assets/404.png'),
  errorTitle: 'Item Not Found',
  errorMessage: 'The product you are looking for does not exist.',
);
```

### Bloc Listeners

**emptyBlocListener**
A no-op listener useful for conditional array inserts in `MultiBlocListener`.

```dart
MultiBlocListener(
  listeners: [
    condition ? realListener : emptyBlocListener<MyBloc, MyState>(),
  ],
  child: ContentView(),
);
```

**preferencesListener**
Listen directly to generated `ValueListenable` items within a MultiBlocListener tree (ideal for tying authentication token changes directly to a BLoC).

```dart
preferencesListener<AuthBloc, AuthState, String?>(
  listenTo: locator<UserPreferences>().tokenNotifier,
  listener: (context, token) {
    if (token == null) context.read<AuthBloc>().add(LogoutEvent());
  },
);
```

---

## 2. Core Utilities

### ViewState

A `sealed class` defining all presentation states for BLoC-driven screens. Keep a `ViewState` field in every Freezed state and drive your UI from it — one field replaces separate `isLoading`, `error`, and `isLoaded` booleans.

**1. Add to your Freezed state:**

```dart
// splash_state.dart
@freezed
class SplashState with _$SplashState {
  const factory SplashState({
    @Default(ViewState.loaded) ViewState viewState,
    @Default(SplashNavigation.none) SplashNavigation navigation,
  }) = _SplashState;

  factory SplashState.initial() => const SplashState();
}
```

**2. Emit states from your BLoC:**

```dart
// splash_bloc.dart
emit(state.copyWith(viewState: const Loading()));

// On success:
emit(state.copyWith(viewState: ViewState.loaded));

// On network failure:
emit(state.copyWith(viewState: const NoNetwork()));

// On server error (carry the API response for display):
emit(state.copyWith(viewState: ServerError(errorModel: apiResponse)));

// On jailbreak detected:
emit(state.copyWith(viewState: ViewState.jailBroken));
```

**3. Wrap your screen content with `WithViewState`:**

`WithViewState` automatically handles loaders, overlays, and error screens — your `child` only runs when the state is `Loaded`.

```dart
// splash_view.dart
BlocBuilder<SplashBloc, SplashState>(
  builder: (context, state) {
    return Scaffold(
      body: WithViewState(
        viewState: state.viewState,
        retryAction: () => context.read<SplashBloc>().add(const SplashEvent.started()),
        child: YourContentWidget(),
      ),
    );
  },
);
```

Show errors as a bottom sheet instead of replacing the content (useful for screens that should stay visible behind the error):

```dart
WithViewState(
  viewState: state.viewState,
  errorDisplayMode: ErrorDisplayMode.bottomSheet,
  retryAction: () => context.read<SplashBloc>().add(const SplashEvent.started()),
  child: YourContentWidget(),
);
```

Enable pull-to-refresh by setting `isRefreshable: true`:

```dart
WithViewState(
  viewState: state.viewState,
  isRefreshable: true,
  retryAction: () => context.read<MyBloc>().add(const MyEvent.refresh()),
  child: YourListWidget(),
);
```

**4. All available states:**

| State | `isError` | Use case |
|---|---|---|
| `Loading()` | `false` | Full-screen blocking loader |
| `OverlayLoading()` | `false` | Transparent overlay loader |
| `Loaded()` | `false` | Normal content |
| `NoNetwork()` | `true` | No internet connection |
| `NoData()` | `true` | Empty result set |
| `ServerError(errorModel)` | `true` | HTTP / API failure |
| `UnexpectedError(errorModel)` | `true` | Unknown exception |
| `Unauthorized(errorModel)` | `true` | 401 / session expired |
| `SearchError(errorModel)` | `true` | Search-specific failure |
| `CustomErrorState(...)` | `true` | Fully customisable error |
| `ForceUpdateError(errorModel)` | `true` | App version too old |
| `JailBroken()` | `true` | Device security violation |

Use `state.isError` to guard any UI that should not appear during error states:

```dart
if (state.viewState != ViewState.loading)
  const BackButton(),
```

### Language Manager

Provide custom locale resolution overriding standard Flutter localizations.

```dart
class AppLanguageManager extends LanguageManager {
  @override
  List<SupportedLocale> get supported => [
    SupportedLocale.enUs,
    SupportedLocale.arEG,
  ];
}

final resolvedLocale = AppLanguageManager().resolve(platformLocale);
```

---

## 3. Storage & Preferences

Powered by macros and code generators inside `helpers/preferences/` to handle synchronous-style persistence combined seamlessly with secure storage.

```dart
// 1. Definition (needs `part 'user_preferences.g.dart';` and builder execution)
@GeneratePreferences()
class UserPreferences extends BasePreferences with _$UserPreferences {
  @UserDefault('theme_mode')
  late final String _themeMode = 'light';

  @Secure('user_auth_token')
  late final String? _token;
}

// 2. Initialization (Early in app lifecycle)
await locator<UserPreferences>().init();

// 3. Usage (Synchronous read/write)
final prefs = locator<UserPreferences>();
prefs.themeMode = 'dark'; // Automatically saves to SharedPreferences 
prefs.token = 'jwt_123';  // Automatically saves to FlutterSecureStorage mapping

// 4. Reactive Listening
ValueListenableBuilder<String?>(
  valueListenable: prefs.tokenNotifier,
  builder: (context, token, child) {
    return token == null ? const LoginScreen() : const HomeScreen();
  },
);
```

---

## 4. Device & Security

### DeviceHelper

`DeviceHelper.getScalingFactor` returns a factor relative to a reference device width (default 440 px, ~iPhone 16 Pro Max), clamped to `[0.9, 1.1]` on phones and fixed at `1.5` on tablets. Every size, spacing, and radius value that should scale across screen sizes must go through this factor.

**Set a custom reference width once at startup (optional):**

```dart
// main.dart — only if your design baseline differs from 440 px
DeviceRegistry.registerReferenceWidth(390.0); // iPhone 15 Pro baseline
```

**The recommended pattern — a `scaleValue` context extension:**

Add this once in your project and call it everywhere instead of using `DeviceHelper` directly in every widget:

```dart
// context_extension.dart
extension ContextExtension on BuildContext {
  double scaleValue(num value) => value * DeviceHelper.getScalingFactor(this);
}
```

**Use it for all sizes, spacing, and radii:**

```dart
// Sizing an image on the splash screen
SvgPicture.asset(
  splashLogo,
  width: context.scaleValue(280),
  height: context.scaleValue(203),
),

// Padding and gutters
Padding(
  padding: EdgeInsets.symmetric(horizontal: context.scaleValue(24)),
  child: Column(
    children: [
      SizedBox(height: context.scaleValue(16)),
      // ...
      SizedBox(height: context.scaleValue(56)),
    ],
  ),
),

// Border radii and button dimensions
ButtonStyle(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(context.scaleValue(12)),
  ),
  padding: EdgeInsets.symmetric(
    horizontal: context.scaleValue(24),
    vertical: context.scaleValue(16),
  ),
),

// Indicator stroke width
CircularProgressIndicator(
  strokeWidth: context.scaleValue(2),
),

// Inline font size (prefer FontHelper.style, but when needed):
TextStyle(fontSize: context.scaleValue(18)),
```

### DeviceSecurityHelper

Advanced environment validation to stop your app running in unsafe environments: prevents jailbreaks, root, debug mode interactions, and signature tampering.

```dart
final securityResult = await DeviceSecurityHelper.checkDeviceSecurity(
  bundleId: 'com.company.app',
  expectedHash: 'A1:B2:C3:D4:E5:F6...',
  flutterSecrets: ['SUPER_SECRET_KEY'],
);

if (!securityResult.isSecure) {
  print('App compromised: ${securityResult.reason}');
  exit(0); 
}
```

---

## 5. Design & Typography

Centralizes typography settings purely inside a native `ThemeExtension`.

### FontHelper & FontRegistry

`FontHelper.style` produces a `TextStyle` that is already scaled by `DeviceHelper` — you never call `DeviceHelper` separately for font sizes. Register your font families once at startup; the registry throws clearly if a key is missing.

**1. Register fonts at startup:**

```dart
// main.dart
void main() {
  FontRegistry.registerFont(FontKey.primary, 'Cairo');    // primary font (Arabic / Latin)
  FontRegistry.registerFont(FontKey.secondary, 'Inter');  // secondary / brand font
  runApp(const App());
}
```

**2. Implement `FontWeightProtocol` as a project-wide enum:**

```dart
// app_font_weight.dart
enum AppFontWeight implements FontWeightProtocol {
  regular,
  medium,
  semiBold,
  bold;

  @override
  int get weightValue {
    switch (this) {
      case AppFontWeight.regular:  return 400;
      case AppFontWeight.medium:   return 500;
      case AppFontWeight.semiBold: return 600;
      case AppFontWeight.bold:     return 700;
    }
  }
}
```

**3. Centralise all text styles in one class (recommended):**

Wrap `FontHelper.style` in a static helper so the size / weight / color contract lives in one place and widgets never repeat raw numbers:

```dart
// app_text_styles.dart
class AppTextStyles {
  AppTextStyles._();

  static TextStyle _style(BuildContext context, {
    required double size,
    required AppFontWeight weight,
    Color? color,
  }) =>
      FontHelper.style(
        context: context,
        size: size,
        weight: weight,
        color: color ?? Theme.of(context).colorScheme.primary,
      );

  // Display
  static TextStyle displayLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 32, weight: AppFontWeight.bold, color: color);

  static TextStyle displayMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 28, weight: AppFontWeight.bold, color: color);

  static TextStyle displaySmall(BuildContext context, {Color? color}) =>
      _style(context, size: 24, weight: AppFontWeight.bold, color: color);

  // Headline
  static TextStyle headlineLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 18, weight: AppFontWeight.bold, color: color);

  static TextStyle headlineMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 16, weight: AppFontWeight.bold, color: color);

  static TextStyle headlineSmall(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.semiBold, color: color);

  // Body
  static TextStyle bodyLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 18, weight: AppFontWeight.regular, color: color);

  static TextStyle bodyMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 16, weight: AppFontWeight.regular, color: color);

  static TextStyle bodySmall(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.regular, color: color);

  // Label / buttons
  static TextStyle labelLarge(BuildContext context, {Color? color}) =>
      _style(context, size: 14, weight: AppFontWeight.bold, color: color);

  static TextStyle labelMedium(BuildContext context, {Color? color}) =>
      _style(context, size: 12, weight: AppFontWeight.semiBold, color: color);

  static TextStyle labelSmall(BuildContext context, {Color? color}) =>
      _style(context, size: 12, weight: AppFontWeight.regular, color: color);
}
```

**4. Use in widgets:**

```dart
// Via the style class (recommended):
Text('Welcome Back', style: AppTextStyles.displaySmall(context)),
Text('Tap to continue', style: AppTextStyles.bodyMedium(context, color: Colors.grey)),

// Directly (for one-off styles):
Text(
  'Hello World',
  style: FontHelper.style(
    context: context,
    size: 16,
    weight: AppFontWeight.semiBold,
    color: Colors.black87,
    lineHeight: 1.4,
  ),
),

// With a secondary / brand font key:
Text(
  'Brand Tagline',
  style: FontHelper.style(
    context: context,
    size: 14,
    fontKey: FontKey.secondary,
    weight: AppFontWeight.medium,
  ),
),
```

Font sizes are automatically multiplied by `DeviceHelper.getScalingFactor` inside `FontHelper.style` — there is no need to call `context.scaleValue` on a font size passed to `FontHelper`.
