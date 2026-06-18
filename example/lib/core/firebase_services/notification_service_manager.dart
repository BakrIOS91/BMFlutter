// Dart imports:
import 'dart:developer';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_example/core/firebase_services/firebase_options.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:injectable/injectable.dart';

/// ------------------------------------------------------------
/// 🔹 Background Handler (MUST be top-level)
/// ------------------------------------------------------------
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  log("📩 Background message: ${message.messageId}");
}

/// ------------------------------------------------------------
/// 🔹 Notification Service
/// ------------------------------------------------------------
@lazySingleton
class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();
  static const _androidChannelId = 'default_channel';
  static const _androidChannelName = 'General Notifications';
  final AppPreferences pref;
  NotificationService(this.pref);

  /// Initialize everything
  Future<void> init() async {
    await FirebaseMessaging.instance.setAutoInitEnabled(true);

    // iOS: show notifications in foreground
    if (Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Register FCM handlers
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);
    _registerForegroundHandler();
    _registerOpenedAppHandler();

    // Handle terminated notifications
    await _checkTerminatedNotification();

    // Request permission
    await _requestPermission();

    // Setup FCM token handling
    await _setupTokenHandling();
  }

  // ------------------------------------------------------------
  // 🔹 Initialize local notifications
  // ------------------------------------------------------------
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (details) {
        log("📩 Local notification tapped: ${details.payload}");
      },
    );

    // Create Android notification channel (for Android 8+)
    if (Platform.isAndroid) {
      final androidChannel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        importance: Importance.max,
        description: 'General notifications',
      );
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(androidChannel);
    }
  }

  // ------------------------------------------------------------
  // 🔹 Foreground notifications
  // ------------------------------------------------------------
  static void _registerForegroundHandler() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log("📩 Foreground message: ${message.notification?.title ?? message.data['title']}");

      // Android: always show local notification for foreground
      if (Platform.isAndroid) {
        _showLocalNotification(message);
      } else if (Platform.isIOS) {
        // iOS: show notification only if payload contains notification
        if (message.notification != null) {
          _showLocalNotification(message);
        }
      }
    });
  }

  // ------------------------------------------------------------
  // 🔹 Notification opened from background
  // ------------------------------------------------------------
  static void _registerOpenedAppHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log("📩 Notification opened: ${message.data}");
      _handleNotificationClick(message);
    });
  }

  // ------------------------------------------------------------
  // 🔹 Handle terminated notifications
  // ------------------------------------------------------------
  Future<void> _checkTerminatedNotification() async {
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      log("📩 App launched from terminated via notification");
      _handleNotificationClick(initialMessage);
    }
  }

  // ------------------------------------------------------------
  // 🔹 Public: check notification permission
  // ------------------------------------------------------------
  Future<bool> checkNotificationStatus() async {
    final settings = await FirebaseMessaging.instance.getNotificationSettings();
    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized;
    log("🔐 Notification permission granted: $granted");
    pref.notificationGranted = granted;
    return granted;
  }

  // ------------------------------------------------------------
  // 🔹 Request permission (internal)
  // ------------------------------------------------------------
  Future<void> _requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await checkNotificationStatus();
  }

  // ------------------------------------------------------------
  // 🔹 Public: setup token handling
  // ------------------------------------------------------------
  Future<void> setupTokenHandling() async {
    await _setupTokenHandling();
  }

  // ------------------------------------------------------------
  // 🔹 Internal: setup token
  // ------------------------------------------------------------
  Future<void> _setupTokenHandling() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        log("🔑 FCM Token: $token");
        pref.fcmToken = token;
      }
    } catch (e) {
      log("⚠️ Error getting token: $e");
    }

    FirebaseMessaging.instance.onTokenRefresh.listen(
      (newToken) {
        log("🔁 Token refreshed: $newToken");
        pref.fcmToken = newToken;
      },
    );
  }

  // ------------------------------------------------------------
  // 🔹 Show local notification
  // ------------------------------------------------------------
  static void _showLocalNotification(RemoteMessage message) {
    final androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    final title = message.data['title'] ?? message.notification?.title;
    final body = message.data['body'] ?? message.notification?.body;

    // Use a fixed notification ID to prevent stacking if desired
    final notificationId = title.hashCode;

    _notifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: message.data.toString(),
    );
  }

  // ------------------------------------------------------------
  // 🔹 Handle notification tap
  // ------------------------------------------------------------
  static void _handleNotificationClick(RemoteMessage message) {
    // Example: navigate to a screen
    // if (message.data['screen'] == 'orders') {
    //   AppNavigator.push('/orders');
    // }
  }
}
