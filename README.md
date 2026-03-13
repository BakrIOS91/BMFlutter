# LDFlutter Package Utilities

LDFlutter is a comprehensive Flutter package providing a wide array of core utilities, network abstractions, UI components, and design system helpers. This document provides a **deep, detailed guide** with practical implementation examples for *each* utility available in the package.

## Table of Contents

1. [Network Layer](#1-network-layer)
   - [TargetRequest Protocol](#targetrequest-protocol)
   - [ModelTargetType & SuccessTargetType](#modeltargettype--successtargettype)
   - [RequestTask (Types of Requests)](#requesttask-types-of-requests)
   - [Performing Requests & Error Handling](#performing-requests--error-handling)
   - [Token Refresh & Authentication](#token-refresh--authentication)
   - [Network Monitor](#network-monitor)
   - [SSL Pinning](#ssl-pinning)
   - [Logging](#logging)
2. [UI Components & Reusables](#2-ui-components--reusables)
   - [Custom Buttons](#custom-buttons)
   - [ErrorView & CustomError](#errorview--customerror)
   - [Bloc Listeners](#bloc-listeners)
3. [Core Utilities](#3-core-utilities)
   - [ViewState](#viewstate)
   - [Language Manager](#language-manager)
4. [Storage & Preferences](#4-storage--preferences)
5. [Device & Security](#5-device--security)
6. [Design & Typography](#6-design--typography)

---

## 1. Network Layer

The networking layer is highly abstracted, type-safe, and inspired by Swift's Moya protocol. It separates endpoint definition from execution.

### TargetRequest Protocol

All network requests conform to `TargetRequest` or its higher-level abstractions.

#### ModelTargetType & SuccessTargetType

- Use `ModelTargetType<T>` when expecting a JSON response that needs decoding to model `T`.
- Use `SuccessTargetType` when you only care about the HTTP status code (e.g., DELETE, POST without body response).

**Example: Fetch Profile Request**
```dart
class UserProfileRequest extends ModelTargetType<UserProfile> {
  @override
  String get baseURL => 'https://api.example.com';
  
  @override
  String get requestPath => '/v1/profile';
  
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
  
  @override
  bool get isAuthorized => true; // Triggers token refresh on 401

  @override
  Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${locator<UserPreferences>().token}',
  };
}
```

**Example: Delete Account Request**
```dart
class DeleteAccountRequest extends SuccessTargetType {
  @override
  String get baseURL => 'https://api.example.com';
  
  @override
  String get requestPath => '/v1/account';
  
  @override
  HTTPMethod get requestMethod => HTTPMethod.delete;
  
  @override
  bool get isAuthorized => true;
}
```

### RequestTask (Types of Requests)

`RequestTask` encapsulates request parameters, bodies, and upload/download logic. 

**Examples of overriding `requestTask` in your `TargetRequest`:**

```dart
// 1. Plain Request (No body/params)
@override
RequestTask get requestTask => RequestTask.plain();

// 2. Query Parameters
@override
RequestTask get requestTask => RequestTask.parameters({'page': '1', 'limit': '20'});

// 3. JSON Encoded Body
@override
RequestTask get requestTask => RequestTask.encodedBody({'username': 'john', 'age': 30});

// 4. Single File Upload
@override
RequestTask get requestTask => RequestTask.uploadFile('/path/to/image.png');

// 5. Multipart Form Data 
@override
RequestTask get requestTask => RequestTask.uploadMultipart({
  'description': MultipartFormDataText('Profile Picture'),
  'file': MultipartFormDataData(imageBytes, 'image.jpg', 'image/jpeg'),
});

// 6. Download
@override
RequestTask get requestTask => RequestTask.download('https://url.com/file.pdf');

// 7. Resumable Download
@override
RequestTask get requestTask => RequestTask.downloadResumable(1024);
```

### Performing Requests & Error Handling

You can perform requests asynchronously using exceptions (`performAsync`) or functionally using `Result` (`performResult`).

**1. Using performAsync (Exceptions approach):**
```dart
try {
  final UserProfile profile = await UserProfileRequest().performAsync();
  print(profile.name);
} on APIError catch (error) {
  print('API Error: ${error.type} - ${error.statusCode}');
}
```

**2. Using performResult (Functional approach):**
```dart
final Result<UserProfile, APIError> result = await UserProfileRequest().performResult();

result.when(
  success: (profile) => print(profile.name),
  failure: (error) => showMessage(error.message),
); // Using pattern matching
```

**3. Requesting complex Response Wrappers (Headers + Cookies):**
```dart
final response = await UserProfileRequest().performAsyncWithCookies();
print(response.data.name);
print(response.headers['x-custom-header']);
print(response.cookies); // Parsed List<Cookie>
```

**4. Performing File Downloads:**
```dart
final DownloadedFile? file = await DownloadRequest().performDownload();
print('Saved to: ${file?.downloadedUrl}');
```

### Token Refresh & Authentication

Automatically handle 401 Unauthorized errors with a thread-safe global registry. It ensures concurrent 401 requests trigger only ONE refresh call.

```dart
class AppTokenRefresher implements TokenRefreshHandler {
  @override
  Future<bool> refreshToken() async {
    try {
      final response = await RefreshTokenRequest().performAsync();
      await locator<UserPreferences>().saveToken(response.token);
      return true;
    } catch (_) {
      return false; // Triggers forced logout downstream
    }
  }
}

// Register once in main.dart:
TokenRefreshRegistry.register(AppTokenRefresher());
```

### Network Monitor

Monitor connectivity status dynamically.

```dart
// Check on-demand
final isOnline = await NetworkMonitor.isConnected;

// Listen to stream globally
NetworkMonitor.onConnectivityChanged.listen((isConnected) {
  if (!isConnected) showOfflineWarning();
});
```

### SSL Pinning

Prevent MITM attacks by pinning server certificates.

```dart
// Define configuration
final config = SSLPinningConfiguration(
  mode: SSLPinningMode.certificate,
  pinnedHosts: [
    PinnedHost(
      hostname: 'api.example.com',
      certificatePaths: ['assets/certs/cert.cer'],
    ),
  ],
);

// Create secure client
final secureClient = await SSLPinningHelper.createSecureHttpClient(config);
```

### Logging

The `Logger` class is invoked automatically in `performAsync` to log outgoing requests, headers, and incoming responses (including formatted JSON bodies) to the console automatically. Wait to interact with the raw `Logger` class unless doing extremely custom raw calls.

### Network Converters

Decoding logic is strictly localized to your request definitions. You MUST either provide a decoder in the constructor or override the `fromJson` method.

**1. Local Registration (Recommended):**
Pass the decoder directly to the constructor for a clean, localized definition.

```dart
class UserProfileRequest extends ModelTargetType<UserProfile> {
  UserProfileRequest() : super(decoder: UserProfile.fromJson);
  
  // ... other overrides
}
```

**2. Overriding fromJson:**
If your decoding logic is complex, override the `fromJson` method.

```dart
class UserProfileRequest extends ModelTargetType<UserProfile> {
  @override
  UserProfile fromJson(Map<String, dynamic> json) {
    // Custom logic here
    return UserProfile.fromJson(json);
  }
}
```

---

## 2. UI Components & Reusables

### Custom Buttons

**AppCupertinoButton**
Unified Apple-style filled and outlined buttons handling states natively.

```dart
AppCupertinoButton.filled(
  context: context,
  title: 'Submit Data',
  isLoading: true, // Shows CupertinoActivityIndicator inside automatically
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
  textStyle: TextStyle(color: Colors.blue),
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
Used combined with `ViewState.CustomState` to pass specific UI error representations from a ViewModel/Bloc directly to the UI layer.

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

## 3. Core Utilities

### ViewState

A `sealed class` defining presentation states. It cleanly and safely wraps `APIError` into highly predictable UI-level states.

```dart
// Map APIError to ViewState representation in your Bloc/ViewModel:
final state = ViewState.failHandler(apiError);

// Exhaustive pattern matching in UI:
Widget buildContent(ViewState state) {
  return switch (state) {
    Loading() => const CircularProgressIndicator(),
    Loaded() => const ContentWidget(),
    NoNetwork() => const OfflineWidget(),
    Unauthorized() => const LoginPromptWidget(),
    CustomState(error: final err) => ErrorView(
      title: err.errorTitle,
      message: err.errorMessage,
      image: err.errorImage,
    ),
    _ => const GenericErrorWidget(),
  };
}
```

### Language Manager

Provide custom locale resolution overriding standard Flutter localizations.

```dart
class AppLanguageManager extends LanguageManager {
  @override
  List<SupportedLocale> get supported => [
    SupportedLocale.en_US, 
    SupportedLocale.ar_EG
  ];
}

final resolvedLocale = AppLanguageManager().resolve(platformLocale);
```

---

## 4. Storage & Preferences

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

## 5. Device & Security

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

## 6. Design & Typography

Centralizes typography settings purely inside a native `ThemeExtension`.

### FontHelper & AppTypography

Define font constraints centrally in `ThemeData`, preventing string-coded font-families scattered across widgets.

```dart
// In Theme Setup:
final theme = ThemeData(
  extensions: [
    AppTypography(fontFamily: 'Inter'), // Or 'Roboto', 'Cairo', etc.
  ],
);
```

**Using the FontHelper:**
Automatically fetches the theme extension's font family and scales sizes via `DeviceHelper`.

```dart
Text(
  'Welcome Back',
  style: FontHelper.style(
    context: context,
    size: 24, // Interpolated size
    weight: AppFontWeight.bold, // Type-safe weight map constraint
    color: Colors.black,
  ),
);
```

### FontWeightProtocol

Maps semantic weights (light, medium, bold) safely to their integer representations mapping into the framework values without raw numbers. 

```dart
// Native definition usage under the hood
class BoldWeight implements FontWeightProtocol {
  @override
  int get weightValue => 700;
}
```