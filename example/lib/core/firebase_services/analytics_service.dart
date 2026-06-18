import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_example/utilities/extensions/map_extensions.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // 🔹 Track screens
  Future<void> logScreen(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // 🔹 Generic event
  Future<void> logEvent(
    String name, {
    Map<String, Object?>? params,
  }) async {
    final filteredParams = params?.removeNulls();

    await _analytics.logEvent(
      name: name,
      parameters: filteredParams,
    );
  }

  // 🔹 Your business logic (example)
  Future<void> loginEvent({
    required String userName,
  }) async {
    await _analytics.logEvent(
      name: 'user_logged_in',
      parameters: {
        'userName': userName,
      },
    );
  }
}
