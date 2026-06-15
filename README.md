# BMFlutter Package Utilities

BMFlutter is a Flutter package providing core utilities, UI components, and design system helpers. This document provides a **deep, detailed guide** with practical implementation examples for each utility available in the package.

> **Note:** The networking layer (TargetRequest, HTTP clients, SSL pinning, token refresh, etc.) has been moved to the separate `bm_flutter_networking` package.

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

A `sealed class` defining presentation states for managing UI lifecycles in BLoC-driven screens.

```dart
// Exhaustive pattern matching in UI:
Widget buildContent(ViewState state) {
  return switch (state) {
    Loading() => const CircularProgressIndicator(),
    OverlayLoading() => const LoadingOverlay(),
    Loaded() => const ContentWidget(),
    NoNetwork() => const OfflineWidget(),
    NoData() => const EmptyWidget(),
    Unauthorized() => const LoginPromptWidget(),
    ServerError() => const ServerErrorWidget(),
    UnexpectedError() => const GenericErrorWidget(),
    CustomErrorState(:final title, :final message) => ErrorView(
        title: title ?? '',
        message: message ?? '',
        image: Image.asset('assets/error.png'),
      ),
    SearchError() => const NoResultsWidget(),
    ForceUpdateError() => const UpdateRequiredWidget(),
    JailBroken() => const SecurityErrorWidget(),
  };
}
```

All error states expose an `errorModel` field for carrying structured data from the repository layer:

```dart
// In BLoC:
emit(ServerError(errorModel: apiResponse));

// In UI:
if (state is ServerError) {
  final model = state.errorModel;
}
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

Responsive scaling relative to a baseline device width. Adjusts padding and sizes automatically across multiple mobile factors.

```dart
final scale = DeviceHelper.getScalingFactor(context); // e.g. 1.2 on large device
final padding = 16.0 * scale;

Container(
  padding: EdgeInsets.all(padding),
  child: Text('Responsive Text'),
);
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

Register font families at app startup and resolve them via `FontHelper` in any widget. Prevents string-coded font-families scattered across widgets.

```dart
// In app startup:
FontRegistry.registerFont(FontKey.primary, 'Inter');
FontRegistry.registerFont(FontKey.secondary, 'Cairo');
```

**Using the FontHelper:**
Automatically resolves the registered font family and scales sizes via `DeviceHelper`.

```dart
Text(
  'Welcome Back',
  style: FontHelper.style(
    context: context,
    size: 24,
    weight: AppFontWeight.bold, // Type-safe weight map constraint
    color: Colors.black,
  ),
);
```

### FontWeightProtocol

Maps semantic weights (light, medium, bold) safely to their integer representations mapping into the framework values without raw numbers.

```dart
class BoldWeight implements FontWeightProtocol {
  @override
  int get weightValue => 700;
}
```
